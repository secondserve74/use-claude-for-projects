-- 1-Day SaaS Blueprint — PostgreSQL schema
-- Multi-tenant micro-SaaS: organisations own data, users belong to orgs,
-- billing state mirrors Stripe. Designed for Supabase/Postgres with RLS.
--
-- Design rules baked in (each learned the hard way — see BLUEPRINT.md):
--   * The app NEVER trusts the client for entitlement — subscription state
--     lives here, written only by the verified Stripe webhook.
--   * Stripe redelivers webhooks; every event is recorded for idempotency.
--   * RLS is on by default; a tenant can only ever see its own rows.

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto";  -- gen_random_uuid()

-- ---------------------------------------------------------------------------
-- Tenancy
-- ---------------------------------------------------------------------------
create table organisations (
    id              uuid primary key default gen_random_uuid(),
    name            text not null,
    -- Stripe linkage (nullable until first checkout)
    stripe_customer_id text unique,
    created_at      timestamptz not null default now()
);

create table users (
    id              uuid primary key default gen_random_uuid(),  -- match auth provider id
    email           text not null unique,
    created_at      timestamptz not null default now()
);

-- A user can belong to multiple orgs; role governs who may change billing.
create table memberships (
    org_id          uuid not null references organisations(id) on delete cascade,
    user_id         uuid not null references users(id) on delete cascade,
    role            text not null default 'member'
                       check (role in ('owner', 'admin', 'member')),
    created_at      timestamptz not null default now(),
    primary key (org_id, user_id)
);

-- ---------------------------------------------------------------------------
-- Billing (mirror of Stripe — never the source of truth, always downstream)
-- ---------------------------------------------------------------------------
-- Plans are seeded from your Stripe Prices. price_id is the join key.
create table plans (
    price_id        text primary key,            -- Stripe Price id (price_...)
    name            text not null,
    -- entitlement knobs the app actually enforces
    seat_limit      int  not null default 1,
    monthly_quota   int  not null default 1000,
    is_active       boolean not null default true
);

create table subscriptions (
    id                     uuid primary key default gen_random_uuid(),
    org_id                 uuid not null references organisations(id) on delete cascade,
    stripe_subscription_id text not null unique,
    price_id               text references plans(price_id),
    -- Stripe status: trialing|active|past_due|canceled|incomplete|unpaid...
    status                 text not null,
    current_period_end     timestamptz,
    cancel_at_period_end   boolean not null default false,
    updated_at             timestamptz not null default now(),
    unique (org_id)   -- one active subscription per org (adjust if you sell add-ons)
);
create index on subscriptions (status);

-- ---------------------------------------------------------------------------
-- Webhook idempotency & audit — Stripe WILL redeliver events
-- ---------------------------------------------------------------------------
create table webhook_events (
    id              text primary key,            -- Stripe event id (evt_...)
    type            text not null,
    received_at     timestamptz not null default now(),
    processed_at    timestamptz,
    error           text
);

-- Optional: your product's usage/quota ledger, referenced by entitlement checks
create table usage_events (
    id              uuid primary key default gen_random_uuid(),
    org_id          uuid not null references organisations(id) on delete cascade,
    kind            text not null,
    quantity        int  not null default 1,
    created_at      timestamptz not null default now()
);
create index on usage_events (org_id, created_at);

-- ---------------------------------------------------------------------------
-- Row Level Security — deny by default, tenant-scoped reads
-- ---------------------------------------------------------------------------
alter table organisations enable row level security;
alter table memberships   enable row level security;
alter table subscriptions enable row level security;
alter table usage_events  enable row level security;
-- plans is public-readable (pricing page); webhook_events is service-role only.
alter table plans         enable row level security;

-- Assumes auth.uid() returns the current user id (Supabase). Adjust for your auth.
create policy org_read on organisations for select to authenticated
    using (id in (select org_id from memberships where user_id = auth.uid()));

create policy membership_read on memberships for select to authenticated
    using (user_id = auth.uid()
           or org_id in (select org_id from memberships where user_id = auth.uid()));

create policy subscription_read on subscriptions for select to authenticated
    using (org_id in (select org_id from memberships where user_id = auth.uid()));

create policy usage_read on usage_events for select to authenticated
    using (org_id in (select org_id from memberships where user_id = auth.uid()));

create policy plans_read on plans for select to authenticated using (true);

-- NOTE: all WRITES to subscriptions/webhook_events happen via the service-role
-- key inside the Stripe webhook handler, which bypasses RLS. No client-side
-- path may write billing state. That separation is the whole security model.

-- ---------------------------------------------------------------------------
-- Entitlement helper — the one question the app asks on every gated action
-- ---------------------------------------------------------------------------
create or replace function org_is_active(p_org uuid) returns boolean
language sql stable as $$
    select exists (
        select 1 from subscriptions s
        where s.org_id = p_org
          and s.status in ('active', 'trialing')
          and (s.current_period_end is null or s.current_period_end > now())
    );
$$;
