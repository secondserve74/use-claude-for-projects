# use-claude-for-projects

Reusable Claude project templates. Copy these files into any new project to give Claude consistent behaviour, scope boundaries, and session continuity from day one.

## The five files

| File | Purpose |
|------|---------|
| `claude.md` | Behaviour rules — how Claude should act, what needs approval, what verification looks like |
| `spec.md` | Project spec — problem, users, features, endpoints, delivery, build order |
| `AGENTS.md` | Subagent architecture — which agent owns which scope, hot zones, blocked-by dependencies |
| `gotchas.md` | Hard-won decisions — traps to avoid, non-obvious constraints, project-specific rules |
| `journal.md` | Session log — read at session start, append at session end |
| `.claude/skills/extract-approach/` | The recorder — after every non-trivial solve, the approach (trap, wrong path, fix, proof) is captured into gotchas.md so future sessions inherit the reasoning |

## How to use

1. Copy all five files plus the `.claude/` directory into the root of your new project
2. Fill in the placeholders in `claude.md` (stack, hot zones) and `spec.md` (problem, users, features, etc.)
3. Add the `legal-content` agent to `AGENTS.md` only if your project collects user data or has compliance requirements — otherwise remove it
4. Add project-specific gotchas to `gotchas.md` as you discover them
5. Start the journal in `journal.md` with your first session entry

Claude reads all five files at the start of each session. The journal keeps context alive across sessions so you never have to re-explain where things were left.

## Example

`examples/makescents/` contains the complete filled-in versions for the MakeCents broker callback form — a real project with a React frontend, Vercel serverless backend, Twilio OTP verification, and Google Sheets data storage. Use it as a reference for how to fill in the templates.

## Blueprints

`blueprints/` holds ready-to-run boilerplates that apply the template disciplines to a specific product shape:

- `blueprints/1-day-saas/` — end-to-end multi-tenant micro-SaaS: PostgreSQL schema with RLS + Stripe-mirror billing, a signature-verified idempotent Stripe webhook, and the exact builder + phase system prompts that drive a lower-cost model to build it safely (billing is a human-reviewed hot zone; entitlement is server-side only).

## What the templates enforce

- **Verification discipline** — Claude states what it's about to do, how it will verify success, and what done looks like before touching anything
- **Hot zone approval** — sensitive areas (payments, auth, credentials, etc.) require explicit approval before any change
- **Subagent boundaries** — each agent owns a defined scope; cross-scope changes stop for orchestrator review
- **Session continuity** — the journal means context survives across sessions without manual re-briefing
- **Gotchas as law** — anything in gotchas.md is non-negotiable and additive-only; Claude flags contradictions rather than proceeding
- **Evidence-based done** — a task is complete when the named check passed and the evidence (log line, HTTP status, query result) is shown, not when it "should work"
- **Checkable quality bars** — every deliverable type gets a done-when checklist of observable checks, never adjectives
- **The learning law** — every non-trivial solve leaves a field-report gotcha entry behind, so hard-won reasoning outlives the session (and the model) that produced it
- **Spec → operating manual** — spec.md is the build plan; once live, claude.md is rewritten as the as-built operating manual and becomes the source of truth
- **Safe testing** — live third-party accounts are never test targets; a designated test channel and the underscore-disable env-var convention are set before first integration
