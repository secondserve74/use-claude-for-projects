# Claude Project Instructions

## General Behaviour
- Follow the project spec. When in doubt, ask before assuming.
- Prefer explicit over implicit. Leave clear comments in code.
- Never expose secrets, API keys, or credentials in output.
- Save a memory checkpoint at the end of every working session and after any significant milestone (feature confirmed working, blocker resolved, etc.). Update the project memory file with current build step progress, what's confirmed working, what's broken, and any open blockers.

## Spec vs Operating Manual
spec.md is the build plan — aspirational until built. Once the system is live, THIS file becomes the source of truth: rewrite it as the as-built operating manual (actual architecture, actual conventions, actual quality bars) and treat spec.md as historical. A claude.md that describes what was planned instead of what exists actively misleads every future session.

## Session Journal
Maintain a running journal in journal.md at the project root.
- At the start of each session: read journal.md to orient on where things were left
- At the end of each session or after any significant milestone: append a dated entry covering what was discussed, what was decided, what was done, and what is blocked or pending
- Entries must be written by date (YYYY-MM-DD) with enough detail that someone reading cold understands the full context
- The journal is a human-readable record — not a task list. Write it in plain prose, not bullet points only.

## Verification Before Starting Work
Before writing any code or making any changes, state out loud:
1. What you are about to do
2. How you will verify it worked (specific test, output, or observable result)
3. What done looks like for this task

When work is complete, run that verification and report the results.
Do not mark a task done without completing this step.

## Quality Bars — Checkable Criteria, Not Adjectives
Every deliverable type in this project gets a "done when" checklist of observable checks — a log line, an HTTP status, a query result — never "works correctly" or "looks good". A weaker model cannot invent a quality bar, but it applies a written one perfectly. Define them as the project takes shape:

- **[deliverable type]** — done when: [ ] check 1, [ ] check 2
- Example — backend endpoint: [ ] deployed, [ ] curl of happy path returns expected JSON (pasted), [ ] auth rejects without credentials (status pasted), [ ] failure path writes a log/audit row

Report outcomes with the evidence, not around it. "Deployed" means pushed AND the new behaviour was observed live — otherwise say "pushed, awaiting deploy". If tests fail, paste the failure.

## Safe Testing
Before the first integration with any live third-party account (social page, payment provider, SMS service, production sheet): designate a test channel and write it down here. Convention: underscore-prefix an env var (`_LIVE_ACCOUNT_ID`) to disable a target while preserving the value; a `platformEnabled`-style check gates on the un-prefixed name. Never improvise a test against a live account — codify the safe procedure as a project skill (see automatesocials' `test-pipeline` skill for the pattern: safe-state check first, evidence-based pass criteria, explicit cleanup).

## Mistakes a Weaker Model Will Make Here
<!-- As the project matures, list the specific mistakes a less capable model would make
     in THIS codebase, each with the rule that prevents it. This section is the highest-value
     part of the file — it is the judgment layer future sessions inherit. Example format:
1. **Testing against the live X account.** Rule: follow the test-pipeline skill, never improvise.
2. **Using the admin key client-side.** Rule: server uses SERVICE_KEY; client uses PUBLIC_KEY only.
-->

## Learning Law
After every non-trivial solve, run the `extract-approach` skill (.claude/skills/extract-approach) before moving on. A solution without its learnings note in gotchas.md is unfinished work. "Non-trivial" = the first fix was wrong, the cause differed from the symptom, it took research, or a platform behaved undocumentedly.

## Hot Zones — Ask Before Changing
<!-- List the sensitive areas specific to this project -->
The following areas require explicit approval before any code is modified:
- payments — billing, pricing, or transaction logic
- auth — authentication, session handling, token logic
- credentials — any file referencing env vars, API keys, or secrets
- anything that sends outward — posts, emails, SMS: a config error spams real people
- the human approval gate, if one exists — removing it is never the model's decision
- [add project-specific hot zones here]

Before touching a hot zone, you must:
1. Name the hot zone you are about to change
2. Describe exactly what you intend to change and why
3. State the blast radius — what else could break or be affected
4. Wait for explicit approval ("yes go ahead" or equivalent)

Never proceed on a hot zone change based on implied or assumed approval.

## Stack
<!-- Fill in the tech stack for this project -->
- Frontend: 
- Backend: 
- Database / Data: 
- Third-party services: 
- Hosting: 

## Reference Files
- gotchas.md — known traps and hard decisions. Read before starting any task.
- spec.md — build plan (historical once built; this file is then the source of truth).
- journal.md — running session log. Read at session start, append at session end.
- .claude/skills/ — extract-approach ships with the template; add project-specific skills (safe-test procedure, go-live sequence) as the project matures.
