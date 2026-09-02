# CONTEXT.md — Swara Living Memory

This file is the project's persistent brain. Antigravity agents lose working memory between sessions — this file is how continuity survives that. **Update it at the end of every session.** Stale context here is worse than no context, so prune aggressively: move anything no longer true into "Decision History," don't leave it in "Current State."

---

## 0. One-Paragraph Project Summary

Swara is a voice-native micro-commerce and credit app for rural Indian merchants. A merchant speaks a sale in their own dialect into a one-button PWA; the app transcribes it (dialect-aware ASR), extracts structured sale data (item, qty, price, buyer), logs an append-only ledger entry, and SMS's the buyer a Razorpay payment link. Over time the ledger becomes an exportable "Shadow Credit Score" a partner bank can underwrite against. Built for a hackathon under the team name "Team Claude coders."

---

## 1. Current State

**Phase:** Pre-code — documentation and environment setup.

**What exists right now:**
- Pitch deck (7 slides) — see `docs/PITCH_DECK_SUMMARY.md`
- This documentation set (AGENTS.md, CONTEXT.md, SETUP.md, rules, workflows)
- No code written yet

**What's next (in order):**
1. Confirm target dialect/language for MVP proof-of-concept (see Open Decisions #1 — this blocks all ASR work)
2. Scaffold the repo per the structure in `AGENTS.md` §4
3. Stand up Supabase project, run initial migration (merchants, ledger_entries, buyers tables)
4. Build the one-button voice capture screen (frontend only, mock transcript)
5. Wire real ASR (AI4Bharat model or API) once dialect is chosen
6. Wire NLU extraction on top of real transcripts
7. Wire Razorpay payment link generation
8. Wire SMS send
9. Build the credit-profile export view (read-only, for demo)

---

## 2. Open Decisions (do not silently assume — ask the human)

1. **Which dialect/language is the MVP proof-of-concept?** The deck itself poses this as an open question to the audience ("Which local dialect or regional focus would make the most compelling proof-of-concept for the ML model?"). Nothing dialect-specific should be hardcoded until this is answered.
2. **SMS provider** — MSG91 vs Twilio vs another. Needs regional-language template support and India DLT (Distributed Ledger Technology registration for SMS, a TRAI requirement) compliance. Not yet decided.
3. **ASR delivery mode** — self-hosted AI4Bharat model (needs GPU inference, more control, no per-call cost) vs. a hosted API (Bhashini government API, or a commercial one) for the hackathon demo. See `docs/ASR_DECISION.md` for the trade-off writeup; final call still open.
4. **Auth for merchants** — phone-OTP only (fits low-literacy users best) vs. Supabase's built-in email/password. Leaning phone-OTP; not yet locked in.

---

## 3. Decision History (append-only — never delete a past decision, only supersede it)

| Date | Decision | Reasoning | Superseded by |
|---|---|---|---|
| (backfilled) | Backend moved from Flask + Clerk (per original pitch deck slide 5) to Supabase | Consolidates DB + Auth + serverless functions + storage into one service, faster to ship for a hackathon timeline | — still current |
| (backfilled) | DB moved from MySQL (per original pitch deck slide 5) to Supabase Postgres | Follows from the Supabase decision above | — still current |
| (this session) | ASR recommendation updated from plain OpenAI Whisper (per deck) to AI4Bharat IndicConformer/IndicWhisper as primary, Whisper as fallback | AI4Bharat's models are purpose-built and benchmarked on Indian languages/dialects (Vistaar benchmark, MIT-licensed, free); plain Whisper's dialect performance on Indian regional speech is materially weaker. See `docs/ASR_DECISION.md` | still open pending dialect choice (#1 above) |

---

## 4. Session Log

Add a new entry at the top each session. Keep entries short — 3-6 lines. This is a changelog, not a diary.

### Session 2 — 2026-09-02
- Scaffolding complete: Monorepo `pnpm` workspaces properly configured with `@swara/shared` package.
- Supabase initialized locally: Edge functions created and initial `0001_init.sql` schema applied with RLS policies.
- Frontend properly configured with core dependencies.
- Still blocked on Open Decisions (dialect, SMS provider, ASR path, Auth strategy).

### Session 1 — [DATE TO FILL IN]
- Created full documentation set (AGENTS.md, CONTEXT.md, SETUP.md, .agents/rules/*, .antigravity/workflows/*, docs/*)
- Researched and recommended AI4Bharat ASR models over vanilla Whisper for dialect accuracy
- No code written yet
- Next session should start with: confirm target dialect (Open Decision #1), then scaffold repo structure

---

## 5. Known Risks / Things That Could Go Wrong

- **Dialect ASR accuracy is the single biggest technical risk.** Even AI4Bharat's best models have double-digit Word Error Rate on some regional benchmarks. Budget real time for a fallback UX (e.g., "did you mean...?" confirmation step) rather than assuming transcription will just work.
- **SMS/DLT registration in India takes real calendar time** (TRAI's DLT registration is not instant) — if this is a live demo needing real SMS delivery, start that registration immediately, don't leave it to the last day.
- **Razorpay test mode vs live mode** — test mode is fine for a hackathon demo; going live requires KYC/business verification that will not complete in hackathon timelines. Do not promise live payments in a demo unless this is already done.
- **"Shadow Credit Score" is a persuasive term, not a regulated one.** Be careful in any pitch/demo copy not to imply this is a recognized credit bureau score (CIBIL etc.) — it isn't, and overstating this could mislead judges or future users.
