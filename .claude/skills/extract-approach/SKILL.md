---
name: extract-approach
description: After solving any non-trivial problem, capture HOW it was solved — the trap, the wrong path, the approach that held, and the proof — into gotchas.md so future sessions and weaker models inherit the reasoning, not just the fix.
---

# Extract Approach — problem-solving recorder

Run this immediately after any non-trivial solve, before moving to the next task.
A solution without its learnings note is unfinished work.

"Non-trivial" means any of:
- The first obvious fix was wrong or incomplete
- The root cause was different from the symptom
- It took more than two attempts or required research
- It involved a third-party platform's undocumented behaviour
- A decision was made that constrains future work

## Procedure

1. Open `gotchas.md`. Find the highest entry number. Your entry is that number + 1.
2. Write the entry in this exact structure (field report, not summary):

```
## N. <Short name of the trap>

GOTCHA: <One sentence — the wrong assumption or hidden trap.>

Why it matters: <What actually happens when you hit it — the symptom, the
misleading error, the cost. Include the exact error text if there was one,
because future sessions will grep for it.>

The wrong path: <What the obvious fix was and specifically why it failed.
This is the most valuable line — it stops the next model from re-walking it.>

What to do instead: <The approach that held, as concrete steps or code,
not advice. Include the exact command/config/SQL if applicable.>

Proof it works: <The observable check that confirms the fix — the log line,
the HTTP status, the query result. Checkable, not "it works now".>
```

3. Entries are additive only — never delete or rewrite an existing entry. If an old entry is superseded, append "SUPERSEDED by entry N" to it and write the new one.
4. If the solve changed a permanent decision (architecture, platform, business rule), also update the relevant section of `claude.md` and append to `journal.md`.

## Quality bar (checkable)

- [ ] Entry contains exact error text or observable symptom (greppable)
- [ ] "The wrong path" names a specific failed approach, not "we tried some things"
- [ ] "What to do instead" contains a command, code, config, or SQL — something executable
- [ ] "Proof it works" is something a model can verify without asking the user
