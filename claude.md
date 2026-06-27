# Claude Project Instructions

## General Behaviour
- Follow the project spec. When in doubt, ask before assuming.
- Prefer explicit over implicit. Leave clear comments in code.
- Never expose secrets, API keys, or credentials in output.
- Save a memory checkpoint at the end of every working session and after any significant milestone (feature confirmed working, blocker resolved, etc.). Update the project memory file with current build step progress, what's confirmed working, what's broken, and any open blockers.

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

## Hot Zones — Ask Before Changing
<!-- List the sensitive areas specific to this project -->
The following areas require explicit approval before any code is modified:
- payments — billing, pricing, or transaction logic
- auth — authentication, session handling, token logic
- credentials — any file referencing env vars, API keys, or secrets
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
- spec.md — full project spec including features, data flow, and out of scope.
- journal.md — running session log. Read at session start, append at session end.
