# [Project Name] — Spec
# Project Spec — agreed in discovery session, do not change without owner approval
# NOTE: this file is the BUILD PLAN. Once the system is live, claude.md becomes the
# source of truth (rewritten as the as-built operating manual) and this file is historical.

## Problem Statement
<!-- What problem does this solve? Why does it exist? -->

## Users
<!-- Who uses this? What are their roles? -->
- Primary user: 
- Secondary user (if any): 

## Features / Fields
<!-- List features, form fields, or capabilities in the order they appear to the user -->

## API Endpoints
<!-- List backend endpoints with method, path, and responsibility -->
<!-- Example: POST /api/endpoint — what it does -->

## Notifications & Data
<!-- How is data stored and who gets notified? -->
- Data store: 
- Notifications: 

## Delivery
<!-- How is this hosted and accessed? -->
- Hosting: 
- Access: 

## Out of Scope (V1)
<!-- Be explicit about what is NOT being built -->
- 

## Open Items (resolve before build)
<!-- Decisions, credentials, or approvals still needed -->
- 

## Resolved Pre-Build Items
<!-- Move items here once resolved, with the resolution noted -->

## Build Order
<!-- Ordered list — dependencies first -->
1. .gitignore created first — .env, node_modules listed before any commit
2. Git remote created and pushed in the first session (gotchas.md #2) — production source must never live on one machine
3. <!-- Add next step here -->
