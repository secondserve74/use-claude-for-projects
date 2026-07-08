# Gotchas
# Hard-won decisions. Read before touching anything.

## How to use this file
Each entry is a field report, not a summary — it must carry the reasoning, so a future (possibly weaker) model inherits the judgment and not just the fix.
Entries are ADDITIVE ONLY — never delete or rewrite one. If superseded, append "SUPERSEDED by entry N" and write the new one.
Include exact error text where one existed — future sessions grep for it.

Format for every new entry:

```
## N. <Short name of the trap>
GOTCHA: <the wrong assumption, one line>
Why it matters: <what actually happens — symptom, misleading error, cost>
The wrong path: <the obvious fix that failed, and why — the most valuable line>
What to do instead: <concrete steps/code/SQL, executable not advisory>
Proof it works: <the observable check that confirms it — checkable, not "works now">
```

## 1. Credentials — Never in the Frontend
GOTCHA: API keys or secrets appearing in client-side code.

All calls to external services go through serverless/backend functions only.
Credentials live in environment variables, never in source code.
Add .env to .gitignore on day one. Check before first commit.

## 2. No Git Remote = Production Source on One Laptop
GOTCHA: Building and deploying (especially via CLI deploys) without ever adding a git remote.

Why it matters: The live system's only source copy sits on one machine. Disk failure loses a production system. Found in a real project weeks after it went live.
What to do instead: `gh repo create <name> --private --source=. --remote=origin --push` in the first session. Review the tree for secrets first (.env ignored, no real values in .env.example unless deliberate).
Proof it works: `git remote -v` shows the remote; `git status` clean; the GitHub repo shows the latest commit.

## 3. Environment Variables — Local vs Production, and Redeploys
GOTCHA: Assuming .env.local vars reach production, or that changing a production env var takes effect on its own.

.env.local is for local dev only — production env vars are set separately in the hosting provider.
Adding, changing, OR REMOVING a production env var does nothing until a redeploy — the running container keeps the old values. Any procedure that toggles an env var must include a redeploy before the next step, or the toggle silently did nothing.

## 4. Never Bake a Destination URL into a Published Artifact
GOTCHA: Encoding your real URL directly into a QR code, posted image, printed flyer, or embed snippet.

Why it matters: Once published, the artifact is frozen. Restructure the site and every historical artifact breaks — there is no redirect to fix an image that's already live. A bare URL also carries no attribution.
What to do instead: Route everything through a redirect layer you control (`/go/{slug}` → 302 to the destination with a source tag). One artifact serves forever; the destination stays editable; every channel is attributable.
Proof it works: `curl -w '%{redirect_url}'` on each slug shows the tagged destination; changing the map changes where a years-old QR lands.

## 5. Verifying a Deploy by Polling Status Codes Matches the OLD Deployment
GOTCHA: Waiting for a new deploy with "until curl returns <status>" when the old deployment already returns that status for the path.

Why it matters: While the new deploy builds, the old one keeps serving — the poll matches stale behaviour instantly and reports success against the wrong build.
What to do instead: Poll for behaviour ONLY the new deployment exhibits — a route that 404s on the old build, the exact new redirect_url, new body content — or wait on the deploy tool itself.
Proof it works: The check stays pending during the build and passes only when the new-build-only behaviour appears.

## 6. Platform Write Scope ≠ Read Scope
GOTCHA: Assuming a token that can create (posts, messages, records) can also read them or their metrics back.

Why it matters: Write and read are separate OAuth scopes on most platforms (LinkedIn, Meta, etc.), and read/analytics scopes are often gated behind separate approval programs. The 403 arrives at feature-build time, weeks after posting worked.
What to do instead: Verify the READ scope exists before building any metrics/read feature; ship fetchers with graceful degradation (log the scope error, store nothing, continue) so the pipeline survives partial permissions.
Proof it works: The job's audit trail shows scope failures on the blocked platform while others succeed and the run exits cleanly.

## 7. Never Test Against Live Third-Party Accounts
GOTCHA: "Just one test post/SMS/charge" against a real business account, real customers, or a real phone number.

Why it matters: Live followers see test posts; strangers get OTP texts; refunds cost fees. And approval in one test doesn't make the next one safe.
What to do instead: Designate a test channel (personal account, sandbox, own phone) in claude.md. Disable live targets with the underscore-prefix env-var convention. Write the safe procedure as a project skill with a safe-state check FIRST and evidence-based pass criteria.
Proof it works: The skill's safe-state check aborts when a live target is enabled; test runs land only on the test channel.

## 8. Check for a Platform-Native Feature Before Adding Infrastructure
GOTCHA: Reaching for new infrastructure (Redis, queues, cron services) for a capability the existing platform already ships.

Why it matters: Every new service is a new failure mode, credential, and bill. Real example: per-IP rate limiting on OTP sends needed zero new infrastructure — Twilio Verify has built-in custom rate limits, enforced server-side, configured via two API calls.
What to do instead: Before adding a dependency, search "<platform> <capability>" in the provider's docs. Prefer the native feature; fail open where availability matters more than the guard.
Proof it works: The feature works with no new env vars, deps, or services in the diff.

## 9. Anything That Sends in Batches Needs Pacing
GOTCHA: A dispatcher/sender that fires EVERY eligible item the moment its window opens.

Why it matters: Batch approval is the natural human workflow (approve 5 things at night). Without pacing, all 5 fire simultaneously — spammy, and uniform-burst timing is what platform bot detection looks for.
What to do instead: A drip guard: at most one send per channel per window, oldest first; check the last-sent timestamp per channel before sending. Design it in before go-live, not after the first burst.
Proof it works: With 3+ items eligible at once, one run sends exactly one per channel; the rest follow in later windows.

## 10. [Add project-specific gotchas below — use the field-report format above]

## 11. An Operating Manual Only Helps a Model That Loads It
GOTCHA: Assuming that because claude.md/CLAUDE.md exists and is well-written, every session will follow it.

Why it matters: Transplant-testing four repos' docs on a cold model, the three sessions that read the manual (9-10 tool calls) followed it precisely — hot-zone declarations, safe-test procedures, house style, index sync. The one session that made ZERO tool calls on a "quick, just jot this down" task never read the manual and fell back to generic behaviour (real IP in notes, missing the whole point of the format, index left stale). Same doc, same model — the only variable was whether it read.
The wrong path: Rewriting the manual to be clearer. The manual was fine; it was never loaded. More words don't fix an unread file.
What to do instead: (1) In a real Claude Code session inside the repo, CLAUDE.md auto-loads — reliable. The risk is subagents pointed at the repo and quick-task mindsets. (2) Put a "AI assistants: read CLAUDE.md before editing" banner at the very top of README.md so even a hasty session is compelled to read. (3) VERIFY the transplant — run a cold model against a realistic task with no hints and grade whether it reaches the manual's rules; a doc is not proven until watched.
Proof it works: The re-tested session read the manual (7 tool calls) and produced fully compliant output; the failure was reproducibly about reading, not about doc content.
