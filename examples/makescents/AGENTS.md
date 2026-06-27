# Subagent Architecture

## Orchestration Rule
Always read claude.md, gotchas.md, and spec.md before spawning any subagent.
Pass all three files as context to every subagent at spawn time.
No subagent proceeds without confirming it has read the spec.

## Agents

### agent: frontend
Scope: /src/components, /src/pages, /src/hooks
Owns: React form, OTP flow UI, conditional field logic, mobile layout, QR code display
Depends on: backend API contract (see spec.md for endpoints)
Hot zones: verification UI flow — ask before changing OTP state logic

### agent: backend  
Scope: /api
Owns: /api/send-otp, /api/verify-otp, /api/submit
Owns: Twilio Verify config, Google Sheets Service Account write, broker SMS
Hot zones: ALL — every file in /api is a hot zone by default

### agent: integration
Scope: /public, /embed, root config files
Owns: QR code generation (SVG + PNG), Championware embed config, Vercel deployment config
Blocked by: frontend and backend must be complete before integration starts
Hot zones: championware embed — any URL or iframe change breaks the live site

### agent: legal-content
Scope: /public/privacy-policy.html (or equivalent static file)
Owns: Privacy policy draft (Australian Privacy Principles compliant), final URL handed to frontend agent for consent checkbox
Blocked by: Owner review and approval required before any file is committed to repo
Hot zones: entire scope — never auto-publish; draft must be explicitly approved before going live

## Shared Rules (apply to all agents)
- Never write credentials to any file — env vars only
- Run verification and report results after every task
- If a task touches two agents' scopes, stop and ask the orchestrator
- gotchas.md is law — if something contradicts it, flag it before proceeding
