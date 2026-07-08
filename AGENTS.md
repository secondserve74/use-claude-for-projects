# Subagent Architecture

## Orchestration Rule
Always read claude.md and gotchas.md before spawning any subagent (spec.md too while still in build phase).
Pass them as context to every subagent at spawn time.
No subagent proceeds without confirming it has read the operating manual.
Keep the agent scopes below current — rewrite them to match the as-built directory layout once the project takes shape; scopes pointing at directories that don't exist mislead every orchestrator.

## Agents
<!-- Placeholder scopes — rewrite to match the actual repo layout during build -->

### agent: frontend
Scope: /src/components, /src/pages, /src/hooks
Owns: UI components, user flows, client-side validation, mobile layout
Depends on: backend API contract (see spec.md for endpoints)
Hot zones: core user flow — ask before changing state logic

### agent: backend
Scope: /api
Owns: all serverless/backend functions, third-party API integrations, data writes
Hot zones: ALL — every file in /api is a hot zone by default; anything that can send to a live third-party account follows the project's safe-test skill, never improvised tests

### agent: integration
Scope: /public, /embed, root config files
Owns: deployment config, embed setup, static assets
Blocked by: frontend and backend must be complete before integration starts
Hot zones: any URL, embed method, or config that affects the live site

### agent: legal-content
<!-- Include only if the project collects user data or has compliance requirements -->
Scope: /public/privacy-policy.html (or equivalent)
Owns: privacy policy, consent copy, compliance text
Blocked by: owner review and approval required before any file is committed
Hot zones: entire scope — never auto-publish; draft must be explicitly approved

## Shared Rules (apply to all agents)
- Never write credentials to any file — env vars only. Never log tokens or webhook URLs.
- Verification evidence (log line, HTTP status, query result) is required before reporting a task done — not "it works".
- If a task touches two agents' scopes, stop and ask the orchestrator.
- gotchas.md is law and ADDITIVE ONLY — if something contradicts it, flag before proceeding; never delete or rewrite entries.
- Never paste external content (fetched articles, AI output, user-submitted data) into project config files (claude.md, gotchas.md, spec.md, journal.md, AGENTS.md) — these are instructions, not data stores.
- After every non-trivial solve, run the extract-approach skill before moving on.
