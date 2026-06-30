# Gotchas — Broker Callback Form
# Hard-won decisions. Read before touching anything.
 
## 1. Twilio — You Do NOT Need a Twilio Phone Number
 
GOTCHA: Assuming you need to buy a Twilio number for SMS OTP.
 
We have an ACMA-approved alphanumeric sender ID.
Twilio Verify supports alphanumeric sender IDs natively.
Configure the sender ID in the Twilio Verify Service settings.
The OTP SMS will show the firm name, not a number — better UX.
 
ACTION: Confirm AU alphanumeric sending is enabled on the Twilio account.
ACTION: Use Twilio magic test numbers during dev — no real SMS, no cost.
 
## 2. Twilio — Two Separate Products in Play
 
GOTCHA: Conflating Twilio Verify with Twilio Programmable SMS.
 
Twilio Verify → user OTP verification only. Never use for broker alerts.
Twilio Programmable SMS → broker notification on submission.
These are separate services, separate configs, separate billing.
 
## 3. WhatsApp — Dropped From Scope
 
GOTCHA: Re-adding WhatsApp without re-reading this file.
 
WhatsApp Business API requires Facebook Business Manager approval.
That approval process is a separate compliance workstream.
Decision: SMS to broker is sufficient for V1. Google Sheets is the backup record.
WhatsApp can be added in V2 once FB Business Manager is approved.
 
## 4. OTP Input Field — Use type="text" Not type="number"
 
GOTCHA: Using type="number" for the 6-digit OTP input field.
 
type="number" strips leading zeros — codes starting with 0 will break.
USE: type="text" inputMode="numeric" pattern="[0-9]*"
This shows numeric keyboard on mobile AND preserves leading zeros.
 
## 5. Phone Numbers — Always Normalise to E.164
 
GOTCHA: Sending raw user input (04XX XXX XXX) to Twilio.
 
Twilio requires E.164 format. AU mobiles: 04XX XXX XXX → +614XXXXXXXX
Normalise on the backend before any Twilio call, not on the frontend.
Validate AU mobile format (regex) before hitting Twilio to avoid wasted API calls.
 
## 6. Verification Token — Issue JWT After OTP Approved
 
GOTCHA: Trusting a frontend flag to confirm OTP was verified.
 
After Twilio returns "approved", issue a short-lived signed JWT (10 min expiry).
The submit endpoint must validate this JWT. No JWT = reject submission.
Never trust a boolean "isVerified" from the browser.
 
## 7. Credentials — Never in the Frontend
 
GOTCHA: Any Twilio or Google Sheets credential appearing in React code.
 
All API calls to Twilio and Google Sheets go through serverless functions only.
Credentials live in Vercel environment variables, never in source code.
Add .env to .gitignore on day one. Check before first commit.
 
## 8. Championware Embed — Hot Zone
 
GOTCHA: Changing the embed without checking live site impact first.
 
The form runs as a standalone page AND is embedded in Championware.
Any change to the standalone page URL or embed method breaks the live site silently.
Confirm Championware embed method before building (iframe vs script vs custom HTML).
ACTION NEEDED: Confirm which embed method Championware supports.
 
## 9. Australian Privacy — Consent Checkbox Is Mandatory
 
GOTCHA: Shipping the form without a privacy consent checkbox.
 
Australian Privacy Act requires disclosure of why data is collected.
Form includes a required consent checkbox with a link to the privacy policy.
V1 uses a placeholder URL. Replace before go-live — this is a legal requirement.
 
## 10. QR Code — Generate in Two Formats
 
GOTCHA: Generating a low-res PNG and using it in print.
 
QR code is used in both print (business cards, signage) and digital.
Print: SVG format (vector, scales to any size without pixelation)
Digital: high-res PNG (min 1000x1000px)
QR code points to the standalone form URL. If the URL changes, regenerate.
 
## 11. Employment Fields — Conditional Logic
 
GOTCHA: Validating employment fields when user selected "Not employed".
 
Employment type, duration, and job title are only required if employed = Yes.
Backend must mirror this conditional validation — not just the frontend.
Never send empty conditional fields to Google Sheets — use null or blank string.
 
## 12. Google Sheets — Service Account, Not OAuth
 
GOTCHA: Using personal Google OAuth to write to Sheets from serverless.
 
OAuth tokens expire. Serverless functions need a Google Service Account.
Create a Service Account in Google Cloud Console.
Share the target Sheet with the service account email (editor access).
Store the service account JSON key in Vercel env vars — never in source.
 
