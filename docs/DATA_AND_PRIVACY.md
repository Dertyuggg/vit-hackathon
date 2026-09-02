# Data & Privacy — Swara

Swara handles voice recordings, phone numbers, and financial transaction data for real people — treat this doc as binding, not aspirational, even at hackathon-MVP stage.

## Voice Data

- Raw audio recordings are transient by default: send to the ASR provider/model, keep the resulting transcript, and do not persist the raw audio file unless there is a specific, disclosed reason to (e.g. actively debugging ASR accuracy on a consented sample).
- **Never commit sample audio containing a real, identifiable person's voice to the git repository** — this is a Golden Rule in `AGENTS.md` (#7). Test fixtures should be either synthetically generated (TTS) or from a team member who has explicitly consented to their voice being used as a checked-in test fixture, and that consent should be noted in this file's "Test Fixtures" section below once created.
- If a demo needs live audio from a judge or bystander, that's fine for the on-the-spot experience, but don't quietly persist that recording into a permanent store without telling them.

## Personal Data in the Ledger

`ledger_entries` and `buyers` tables hold real names and phone numbers. For MVP:
- Row Level Security (per `SETUP.md` §4) must ensure a merchant can only read their own data — no cross-merchant queries from the client, ever.
- Don't log phone numbers or names to console/error-tracking in plaintext in a way that would end up in a shared log stream — mask them (e.g. last 4 digits) in logs.

## SMS / Payment Links

- Razorpay payment links carry a specific transaction amount and (depending on configuration) buyer contact info — treat the same as other personal data above.
- SMS delivery in India requires DLT (TRAI) registration for the sending entity/template — this is a compliance requirement, not just a technical one, and is called out in `CONTEXT.md` Known Risks because it has real lead time.

## Credit Profile Export

- The bank-facing export (`docs/CREDIT_SCORING_LOGIC.md`) contains a summary of a merchant's real financial activity. Exporting it should require the merchant's explicit action/consent in the real product — for a hackathon demo this can be simplified, but say so explicitly in the demo narrative rather than silently skipping consent design and letting it look solved.

## Test Fixtures

(Fill in as they're created.) Record here: what synthetic/consented audio or data fixtures exist, where they live, and confirmation they don't contain a non-consenting real person's data.
