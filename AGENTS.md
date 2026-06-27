# Subagent Architecture

## Orchestration Rule
Always read claude.md, gotchas.md, and spec.md before spawning any subagent.
Pass all three files as context to every subagent at spawn time.
No subagent proceeds without confirming it has read the spec.

## Agents

### agent: frontend
Scope: /src/components, /src/pages, /src/hooks
Owns: UI components, user flows, client-side validation, mobile layout
Depends on: backend API contract (see spec.md for endpoints)
Hot zones: core user flow — ask before changing state logic

### agent: backend
Scope: /api
Owns: all serverless/backend functions, third-party API integrations, data writes
Hot zones: ALL — every file in /api is a hot zone by default

### agent: integration
Scope: /public, /embed, root config files
Owns: deployment config, embed setup, static assets
Blocked by: frontend and backend must be complete before integration starts
Hot zones: any URL, embed method, or config that affects the live site

### agent: legal-content
Scope: /public/privacy-policy.html (or equivalent)
Owns: privacy policy, consent copy, compliance text
Blocked by: owner review and approval required before any file is committed
Hot zones: entire scope — never auto-publish; draft must be explicitly approved

## Shared Rules (apply to all agents)
- Never write credentials to any file — env vars only
- Run verification and report results after every task
- If a task touches two agents' scopes, stop and ask the orchestrator
- gotchas.md is law — if something contradicts it, flag it before proceeding
