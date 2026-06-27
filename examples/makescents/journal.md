# MakeCents Broker Callback Form — Project Journal

A running record of every working session. Read this at the start of each session to orient. Append at the end of each session or after any significant milestone.

---

<!-- PAST SESSIONS: Fill in below based on your recollection of earlier work -->

## [Pre-2026-06-25] — Initial Build (Sessions 1–N)
*To be filled in by project owner*

---

## 2026-06-25 — Session: Broker SMS Debugging Begins

Picked up the project after a gap. No memory had been saved from previous sessions so context had to be reconstructed from the code and spec files. Established that build steps 1–5 were complete and confirmed working: OTP via Twilio Verify was sending real SMS, and Google Sheets was populating on submission. Broker SMS (step 6) was not working.

Ran `vercel dev`, submitted the form, and confirmed Sheets populated but broker received no SMS and no error appeared in the Vercel console. Checked Twilio Monitor → Logs → Messaging and found error 21703: Messaging Service has no available sender.

Investigation: all env vars confirmed correct (TWILIO_MESSAGING_SID=MG..., TWILIO_VERIFY_SERVICE_SID=VA..., BROKER_MOBILE set). Sender "Makes Cents" alphanumeric ID was present in the Messaging Service sender pool but error persisted.

Found that the AU alphanumeric sender ID regulatory compliance registration (Australia:Mobile Business) was in draft state under Trust Hub → Registrations. Completed and submitted it.

Also added session save points to claude.md and set up memory files so future sessions start with full context.

---

## 2026-06-26 — Session: Regulatory Approvals

Primary compliance bundle (Australia:Mobile Business 2026-06-22) approved. Retested — still error 21703. Discovered the issue: "Makes Cents" being in the Messaging Service sender pool is not enough — it also needs to be registered under Numbers and Senders → Alphanumeric Sender IDs → Australian Registrations. That section was empty.

Started the Australian alphanumeric sender ID registration for "Makes Cents". Twilio requested more information during the process.

---

## 2026-06-27 — Session: Alphanumeric Sender ID Registration

Completed and submitted the alphanumeric sender ID registration for "Makes Cents" with the additional information Twilio requested. Waiting for review.

---

## 2026-06-28 — Session: Approvals and Compliance Issue

Alphanumeric sender ID "Makes Cents" approved. 

Before testing, found that the primary compliance profile under Trust Hub → Registrations was rejected. Reason: the profile was set up using the husband's name and email, but he is not on the ASIC paperwork for the business. Twilio requires the registered business owner's details and a matching business email domain. Wife (the ASIC-registered business owner) needs to redo the primary compliance profile with her own details.

Decision: wife will handle the primary compliance profile resubmission.

Decided to create a GitHub template repo (secondserve74/use-claude-for-projects) to capture the claude.md, spec.md, AGENTS.md, and gotchas.md as reusable templates for future projects, with the MakeCents files preserved as examples. Also added journal.md as a standard part of the template so all future projects maintain a session log from day one.

**Pending:** Wife to complete primary compliance profile → broker SMS to be retested once approved.

---

<!-- FUTURE SESSIONS: Append below this line -->
