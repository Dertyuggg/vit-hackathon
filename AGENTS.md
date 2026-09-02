# AGENTS.md — Swara

This file is read automatically by Antigravity (and any AGENTS.md-compatible agent) on every session. It is the contract the agent must follow. If anything here conflicts with a one-off instruction in chat, ask before overriding — don't silently pick one.

Read order for a new session: this file → `CONTEXT.md` → `.agents/rules/*.md` → whichever `docs/` file is relevant to the task at hand.

---

## 1. What Swara Is

Swara is a voice-native micro-commerce and credit engine for rural Indian micro-entrepreneurs (kirana stores, cart vendors, small traders) who are locked out of formal credit because they (a) can't type invoices in a standard-language, text-heavy UI, and (b) have no verifiable digital transaction history for a bank to underwrite against.

Swara replaces the UI with a single button. The merchant taps it and speaks a sale in their own dialect — e.g. "50 kilo chawal Ramesh ko do hazaar mein becha" — and the system:

1. Transcribes the dialectal speech (ASR)
2. Extracts structured intent — item, quantity, unit price, buyer name — from the transcript (NLU/NLP)
3. Writes an immutable ledger entry for the merchant
4. Sends the buyer an SMS with a localized Razorpay payment link
5. Over time, aggregates the ledger into a structured, exportable "Shadow Credit Score" that partner banks can use to underwrite micro-loans

Full narrative and slide-by-slide content: see `docs/PITCH_DECK_SUMMARY.md`.

**Non-goals for MVP** (do not build these unless the human explicitly asks):
- Full multi-language support for all 22 scheduled languages — MVP targets ONE dialect end-to-end, chosen and confirmed with the human before ASR work starts
- A native mobile app — MVP is a mobile-web PWA
- Real loan disbursal or any lending-license-requiring feature — Swara only *exports a risk profile*; it never issues credit itself
- Multi-tenant bank dashboards — MVP has one simple merchant-facing surface and one flat CSV/JSON export for the "bank" side

---

## 2. Golden Rules (non-negotiable)

1. **Never commit secrets.** No API keys, Supabase service-role keys, Razorpay keys, or `.env` contents ever get committed. Check `git diff --staged` before every commit for anything resembling a key.
2. **Never touch `main` directly.** All work happens on a feature branch and lands via PR. See `.agents/rules/git-branching.md`.
3. **Never invent a library, endpoint, or model behavior you haven't verified.** If unsure whether a package version, API shape, or model output format is correct, say so and check docs/the web rather than guessing. This app touches payments and financial-inclusion claims — confident wrong answers cause real harm here.
4. **Ledger entries are append-only.** Never write code that mutates or deletes a past ledger row. Corrections are new offsetting entries, never edits. This is what makes the credit-scoring story honest.
5. **No fabricated "credit score."** Any risk-profile number the app produces must be traceable to real ledger data and a documented formula in `docs/CREDIT_SCORING_LOGIC.md`. Never hardcode a demo number that looks like a real score in a way that could be mistaken for real output.
6. **Low-literacy-first UI.** Every merchant-facing screen must work for someone who cannot read the language it's rendered in. Icons + voice + audio confirmation are primary; text is secondary. Before adding any merchant-facing screen that relies on reading text to operate, flag it.
7. **Dialect data handling.** Any recorded audio of a real person's voice is sensitive. Never commit sample audio files containing a real person's voice to the repo. Use synthetic/consented test fixtures only, documented in `docs/DATA_AND_PRIVACY.md`.
8. **Stop and ask** before: changing the DB schema in a way that loses data, changing the ASR/NLU provider, or changing anything in the payments flow. These are listed in full in `.agents/rules/stop-and-ask.md`.

---

## 3. Tech Stack (current — see `CONTEXT.md` §Decisions for history)

| Layer | Choice | Notes |
|---|---|---|
| Frontend | React + Vite, TypeScript, Tailwind CSS | PWA, audio-first UI, installable on Android |
| Backend | Supabase (Postgres + Auth + Edge Functions + Storage) | Replaces the original Flask + Clerk plan from the pitch deck — see `CONTEXT.md` |
| ASR (dialect speech-to-text) | AI4Bharat **IndicConformer** or **IndicWhisper** (primary) with OpenAI Whisper as a generic fallback | See `docs/ASR_DECISION.md` for why AI4Bharat over vanilla Whisper |
| NLU (intent/entity extraction from transcript) | Rule-based/regex extraction for MVP, prompt-based LLM extraction as a fallback for messy transcripts | Keep this swappable — see `docs/NLU_APPROACH.md` |
| Payments | Razorpay Payment Links API | Test mode until explicitly told to go live |
| SMS | MSG91 or Twilio (decide in Week 1, log the decision in `CONTEXT.md`) | Needs to support regional-language SMS templates |
| Hosting | Vercel (frontend) + Supabase (backend) | |
| Package manager | pnpm | Do not switch to npm/yarn without updating this file and the lockfile in the same commit |

Full install steps and versions: `SETUP.md`.

---

## 4. Repository Structure

```
swara/
├── AGENTS.md                  # this file
├── CONTEXT.md                 # living project memory — READ AND UPDATE THIS
├── SETUP.md                   # environment setup, one-time
├── .agents/
│   └── rules/
│       ├── git-branching.md
│       ├── git-commit-and-push.md
│       ├── coding-standards.md
│       └── stop-and-ask.md
├── .antigravity/
│   └── workflows/
│       ├── new-feature.md
│       └── fix-bug.md
├── docs/
│   ├── PITCH_DECK_SUMMARY.md
│   ├── ASR_DECISION.md
│   ├── NLU_APPROACH.md
│   ├── CREDIT_SCORING_LOGIC.md
│   ├── DATA_AND_PRIVACY.md
│   └── API_CONTRACTS.md
├── apps/
│   └── web/                   # React + Vite PWA
├── supabase/
│   ├── migrations/
│   └── functions/             # Edge Functions (voice-ingest, nlu-extract, payment-link, sms-send)
├── packages/
│   └── shared/                # shared TS types between web + edge functions
└── .env.example
```

Do not create top-level folders outside this structure without updating this section.

---

## 5. Session Startup Checklist (do this every time, silently, before writing code)

1. Read `CONTEXT.md` in full — it holds current status, open decisions, and "last session ended here."
2. Run `git status` and `git branch --show-current`. If on `main`, stop and create a branch per `.agents/rules/git-branching.md` before making any change.
3. Check `docs/` for a file relevant to the task. If the task touches ASR, read `ASR_DECISION.md` first. If it touches money, read `API_CONTRACTS.md`'s payments section first.
4. If `CONTEXT.md` says a decision is "open" that your task depends on, stop and ask the human rather than assuming an answer.
5. At the end of the session (or after a meaningful chunk of work), update `CONTEXT.md`'s "Session Log" and "Current State" sections before finishing. This is not optional — it is how the next session avoids repeating work or re-litigating decisions.

---

## 6. Definition of Done (for any feature)

- [ ] Code builds and lints clean (`pnpm lint`, `pnpm build`)
- [ ] No secrets in diff
- [ ] Feature works with a screen reader / audio-only path if it's merchant-facing
- [ ] Manual test of the happy path performed and described in the PR description
- [ ] `CONTEXT.md` updated
- [ ] Branch pushed per `.agents/rules/git-commit-and-push.md`, PR opened against `develop` (never `main`)

---

## 7. Where the Human Wants Rigor

Per how this human works: comprehensive, visually complete deliverables over partial ones; honest evaluation over confident guessing; proactive flagging of your own mistakes; iterative refinement after a big first pass is expected and welcome. Applied here: don't ship a stub NLU parser and call it done — build the whole documented flow, and say plainly if a piece (e.g., dialect ASR accuracy) is genuinely uncertain rather than presenting it as solved.
