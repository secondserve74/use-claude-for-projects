# Gotchas
# Hard-won decisions. Read before touching anything.

## How to use this file
Each entry documents a specific trap, decision, or non-obvious constraint.
Format: what the gotcha is, why it matters, and what to do instead.
Add entries as you discover them — don't wait until after something breaks.

## 1. Credentials — Never in the Frontend
GOTCHA: API keys or secrets appearing in client-side code.

All calls to external services go through serverless/backend functions only.
Credentials live in environment variables, never in source code.
Add .env to .gitignore on day one. Check before first commit.

## 2. Environment Variables — Local vs Production
GOTCHA: Assuming .env.local vars are available in production.

.env.local is for local dev only.
Production env vars must be set separately in your hosting provider (e.g. Vercel dashboard).
Verify all required env vars are set in both environments before go-live.

## 3. [Add project-specific gotchas below]

<!--
Template for new entries:

## N. Short Title

GOTCHA: One line describing the wrong assumption.

Explanation of why this is a trap and what breaks.
The correct approach and any action items.
-->
