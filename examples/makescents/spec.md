# MakeCents — Broker Callback Form
# Project Spec — agreed in discovery session, do not change without owner approval
 
## Problem Statement
Broker is receiving asset finance enquiries with fake or unreachable phone numbers.
This form solves that by making SMS OTP verification a hard gate on submission.
No verified phone = no submission. No exceptions, no bypasses.
 
## Users
Submitter: Australian individuals seeking asset finance
Cars, boats, caravans, holidays, debt consolidation, business equipment
Recipient: One broker / one firm (MakeCents). No routing logic.
 
## Form Fields (in order)
first_name Text, required
last_name Text, required
email Email, required (collected, not verified)
mobile AU mobile, required — normalise to E.164 (+614XXXXXXXX)
[OTP GATE] 6-digit SMS code — hard gate, form cannot proceed without
postcode 4-digit AU postcode, required
employed Boolean yes/no toggle, required
employment_type Conditional (if employed=yes): Full-time | Part-time | Self-employed | Casual
employment_length Conditional (if employed=yes): <6mo | 6-12mo | 1-2yr | 2-5yr | 5yr+
job_title Conditional (if employed=yes): Text, required
finance_amount Number, required
finance_purpose Free text, required — what the finance is for
privacy_consent Required checkbox — links to placeholder policy URL until go-live
 
## OTP Flow
State 1: User fills name, email, mobile → clicks "Send verification code"
State 2: Mobile field locks. User enters 6-digit code. 30s resend cooldown.
State 3: On approval → backend issues signed JWT (10 min expiry)
State 4: Remaining fields unlock. User completes and submits.
Submit endpoint validates JWT. Expired or missing JWT = rejected.
Max 3 wrong attempts before requiring new code. Max 3 sends per number per hour.
 
## Backend API Endpoints
POST /api/send-otp Validate AU mobile → call Twilio Verify → return ok/fail
POST /api/verify-otp Check code with Twilio → if approved issue JWT → return token
POST /api/submit Validate JWT → validate all fields → SMS broker → write Sheets → return ok
 
## Notifications & Data
Broker SMS: Twilio Programmable SMS — all fields in message body
Broker mobile: +61403493205 (E.164). Stored as BROKER_MOBILE in Vercel env vars.
Google Sheets: One row per submission. Service Account auth (not OAuth).
Sheet name: "Verified Submissions" (new sheet, to be shared with service account email after setup).
Columns (in order): submitted_at | first_name | last_name | email | mobile | postcode | employed | employment_type | employment_length | job_title | finance_amount | finance_purpose
Conditional fields (employment_type, employment_length, job_title): blank string when employed = No.
WhatsApp: OUT OF SCOPE for V1. Add in V2 after FB Business Manager approval.
 
## Twilio Configuration
Verify Service: SMS OTP only. Alphanumeric sender ID (ACMA approved).
Sender ID: Set to MakeCents (or approved string) in Verify Service settings.
No Twilio number required for OTP. Alphanumeric sender covers AU.
Test mode: Use Twilio magic numbers during dev. Never send real SMS in dev.
 
## Delivery
Hosting: Vercel (serverless functions + React frontend)
Embed: Standalone page (QR target) + embedded in Championware site via iframe
Championware embed method: iframe pointing to standalone URL. Chosen for full CSS/JS isolation — prevents Championware builder from conflicting with React state or OTP flow. Standalone page is the QR target and iframe source — same URL, no duplication.
Championware domain: https://www.makescentsfinancial.com.au (exact CORS origin for all /api/* endpoints)
Standalone URL: callback.makescentsfinancial.com.au — CNAME pointing to cname.vercel-dns.com is live. Domain is added to Vercel project during deployment setup (build step). QR code generation (step 8) is unblocked once Vercel confirms domain and SSL.
QR code: SVG for print, high-res PNG for digital. Points to standalone URL.
Mobile first: Most users arrive via QR code on a phone.

## Custom Domain Process (when ready)
1. Decide on subdomain — e.g. apply.makescentsfinancial.com.au or callback.makescentsfinancial.com.au
2. Confirm DNS access — check whether makescentsfinancial.com.au DNS is managed through Championware or a registrar (e.g. VentraIP, Crazy Domains). Access needed to add a CNAME record.
3. Add domain in Vercel — Project Settings → Domains → add the subdomain
4. Add CNAME at DNS provider — point subdomain to cname.vercel-dns.com
5. Vercel auto-provisions SSL (Let's Encrypt) — typically live within minutes
6. Verify in browser, then generate QR code
7. Treat URL as permanent once QR codes are distributed — any change requires reprinting all physical materials
 
## Out of Scope (V1)
- WhatsApp broker notifications
- Email verification
- Callback scheduling / calendar
- CRM integration
- Multi-broker routing
- Broker-facing dashboard
- Full privacy policy (placeholder URL until go-live)
 
## Open Items (resolve before build)
- Twilio AU alphanumeric sending: confirmed enabled ✓
- ACMA sender ID string: "Makes Cents" — requested, pending final approval. Configured in Twilio Verify Service settings during build.
- Provide Twilio Account SID + Auth Token (for Vercel env vars)
- Create Google Cloud service account + download JSON key (for Vercel env vars)
- Create "Verified Submissions" Google Sheet + note spreadsheet ID, then share with service account email after it is created during setup
- Replace privacy policy placeholder URL before go-live (legal requirement — agent: legal-content owns this)
- Add callback.makescentsfinancial.com.au to Vercel project during deployment setup (CNAME already live)

## Resolved Pre-Build Items
- Championware embed method: iframe ✓
- Championware domain: https://www.makescentsfinancial.com.au ✓
- Standalone URL: callback.makescentsfinancial.com.au ✓
- Broker mobile: +61403493205 ✓
- Google Sheets name: "Verified Submissions" ✓
 
## Build Order
1. .gitignore created first — .env, .env.local, node_modules, service account JSON listed before any commit
2. Backend API endpoints (Twilio wired, tested with magic numbers)
3. React form — all fields, no OTP yet, mock API
4. OTP flow layered onto phone field
5. Google Sheets write on submission
6. Broker SMS notification
7. Error states and edge cases
8. Mobile polish
9. QR code generation
10. Championware embed (iframe pointing to standalone URL)
11. Swap test credentials for live, test with real phone
