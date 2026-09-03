# BUILD_GUIDE.md — Swara, Two-Person Build Plan

**Team:** Oviam + Dhyanesh ("Team Claude coders")

This guide splits the work defined in `CONTEXT.md` §1 ("What's next") and `AGENTS.md` §4 (repo structure) across two people so you can build in parallel instead of serially. It does not replace any existing file — it sits on top of `AGENTS.md`, `CONTEXT.md`, `SETUP.md`, `.agents/rules/*`, `.antigravity/workflows/*`, and `docs/*`, and defers to all of them on anything this file doesn't cover. If this guide ever conflicts with `AGENTS.md`, `AGENTS.md` wins — flag the conflict and fix this file, don't silently follow this one instead.

Read this after `AGENTS.md` and `CONTEXT.md`, before writing code.

---

## 1. The Split, In One Sentence

**Oviam owns everything the merchant sees and speaks to** (frontend, voice capture UX, NLU extraction, confirmation flow). **Dhyanesh owns everything that makes it real** (Supabase infra, ASR provider integration, payments, SMS, credit-scoring computation).

This isn't an arbitrary 50/50 — it follows the actual seam in `AGENTS.md` §4's folder structure: Oviam lives mostly in `apps/web/` + the `nlu-extract` function; Dhyanesh lives mostly in `supabase/` (migrations, RLS, and the `voice-ingest`, `payment-link`, `sms-send` functions) + provider accounts. The seam between you is `packages/shared/` — the typed contracts in `docs/API_CONTRACTS.md` — so you can both build against an agreed shape without blocking on each other.

---

## 2. Role Assignments

### Oviam — Frontend, Voice UX & NLU
- `apps/web/` — the entire React + Vite + TypeScript PWA
- `supabase/functions/nlu-extract/` — transcript → structured sale data (per `docs/NLU_APPROACH.md`)
- Owns: `docs/NLU_APPROACH.md` as decisions get made (ambiguity handling, confirmation copy)
- Owns: the merchant-facing confirmation/audio-playback UX (Golden Rule #6 in `AGENTS.md` — low-literacy-first)

### Dhyanesh — Backend, Infra, Money & Voice Engine
- `supabase/migrations/` — schema, RLS policies
- `supabase/functions/voice-ingest/`, `payment-link/`, `sms-send/`
- Provider accounts and integration: Supabase project, Razorpay, SMS provider, ASR provider (Bhashini or self-hosted AI4Bharat)
- Owns: `docs/ASR_DECISION.md`, `docs/CREDIT_SCORING_LOGIC.md`, `docs/DATA_AND_PRIVACY.md` as decisions get made

### Shared / Either Person
- `packages/shared/` — typed contracts (both of you import from here; whoever touches a shape first opens the PR, the other reviews it same-day since it blocks both sides)
- `CONTEXT.md` — **both of you update this**, every session, per `AGENTS.md` §5. This is the one file where "shared ownership" doesn't mean "nobody's job" — see §6 below for how to avoid clobbering each other.
- `docs/API_CONTRACTS.md` — written together before either side implements a function it defines (per `.agents/rules/coding-standards.md`)
- `docs/CREDIT_SCORING_LOGIC.md` final review — Dhyanesh drafts the computation, Oviam reviews the export UI implications, since it's the product's core trust claim (`AGENTS.md` Golden Rule #5)

---

## 3. Day 0 — Before Anyone Writes Code (do together, same sitting)

Both of you should be in the room (or call) for this — it's the one part of the plan that doesn't parallelize.

1. Read `AGENTS.md`, `CONTEXT.md`, all of `.agents/rules/`, all of `.antigravity/workflows/`, and all of `docs/` — both of you, in full, not skimmed.
2. Resolve `CONTEXT.md` Open Decision #1 (target dialect). This blocks Dhyanesh's ASR work and Oviam's NLU dictionary work equally — nothing dialect-specific gets built until this is answered.
3. Resolve Open Decision #4 (auth mode) — affects Oviam's onboarding screen and Dhyanesh's RLS policies simultaneously.
4. Divide who creates which provider accounts (`SETUP.md` §1's `[HUMAN]` list) — don't duplicate signups.
5. Run `MASTER_PROMPT.md` once, together, in the shared Antigravity workspace, so the repo scaffold and initial `develop` branch exist before you fork off into parallel work.
6. Agree on a daily 10-minute sync time. Two people building against a shared contract without syncing is how the contract silently drifts — see §6.

Do not proceed to §4/§5 until steps 1-5 above are actually done, not just skimmed.

---

## 4. Oviam's Track — Phase by Phase

Each phase is a `feature/` branch per `.agents/rules/git-branching.md`, run through `.antigravity/workflows/new-feature.md`.

### Phase O1 — Frontend Scaffold & Shell
- Scaffold `apps/web` per `SETUP.md` §3 (Vite + React + TS + Tailwind + PWA plugin)
- Build the app shell: routing (`react-router-dom`), a `zustand` store for session state, base layout
- No real screens yet — just navigable placeholders for: onboarding, main voice-capture screen, ledger history, credit-profile view
- **Definition of done:** `pnpm --filter web dev` runs, all four placeholder screens are reachable

### Phase O2 — One-Button Voice Capture UI (mocked)
- Build the actual capture screen: single large tap target, `MediaRecorder` API for audio capture, recording-state UI (idle / listening / processing)
- Mock the transcript response for now (hardcoded string) — don't wait on Dhyanesh's `voice-ingest` function to exist
- Follows `.agents/rules/coding-standards.md` accessibility requirements: 44x44px+ tap targets, non-text affordances, aria-labels in target dialect once Open Decision #1 is resolved
- **Definition of done:** tapping the button records audio and shows a mocked transcript; works on a real Android phone, not just desktop Chrome (test this — desktop `MediaRecorder` behavior is not a reliable proxy for mobile)

### Phase O3 — NLU Extraction Function
- Write `docs/API_CONTRACTS.md`'s `nlu-extract` section for real (it's currently a skeleton) before writing code
- Implement Tier 1 (rule-based) extraction per `docs/NLU_APPROACH.md` for the confirmed dialect
- Implement Tier 2 (LLM fallback) for low-confidence cases
- Write the test set: real or realistic sample transcripts, including messy/ambiguous ones, per `.agents/rules/coding-standards.md` Testing section
- **Definition of done:** function takes a transcript, returns the `ExtractedSale` shape from `docs/NLU_APPROACH.md`, tests pass on the sample set

### Phase O4 — Confirmation Flow (the trust-critical UX)
- Build the "50 kilo rice, 2000 rupees total, correct?" confirmation step described in `docs/NLU_APPROACH.md` — audio playback or single-tap confirm, not a form
- Wire real extraction (Phase O3's function) in, replacing the Phase O2 mock
- Handle the `priceType` ambiguity case explicitly in the UI, not just in the NLU logic
- **Definition of done:** a spoken sale flows end-to-end from tap → mock-transcript-replaced-by-real-ASR-once-Dhyanesh's-function-lands → extraction → confirmation → (stub) ledger write

### Phase O5 — Ledger History & Credit Profile Views
- Build the merchant's own ledger history screen (read-only list of past `ledger_entries`, RLS-scoped — depends on Dhyanesh's Phase D2 schema)
- Build the credit-profile export view once Dhyanesh's computation (Phase D5) exists — this is a read-only display of Dhyanesh's output, not a place to compute or fudge numbers client-side (`AGENTS.md` Golden Rule #5)
- **Definition of done:** both screens render real data from Supabase, not mocks

### Phase O6 — Polish & Demo Readiness
- Loading states, error toasts, retry affordances
- Full pass against `AGENTS.md` §6 Definition of Done checklist on every screen
- Rehearse the live demo flow end-to-end with Dhyanesh's backend live, not mocked

---

## 5. Dhyanesh's Track — Phase by Phase

Each phase is a `feature/` branch per `.agents/rules/git-branching.md`, run through `.antigravity/workflows/new-feature.md`.

### Phase D1 — Supabase Project & Auth
- `[HUMAN]` steps from `SETUP.md` §1 and §4: create Supabase project, `supabase login`, `supabase init`, `supabase link`
- Stand up auth per Open Decision #4's resolution (phone-OTP most likely)
- **Definition of done:** a merchant can sign up / log in against the real Supabase project from a bare test page

### Phase D2 — Schema & RLS
- Write `supabase/migrations/0001_init.sql` per the table shapes in `SETUP.md` §4 (`merchants`, `buyers`, `ledger_entries`, `payment_links`)
- Row Level Security on every table before any client query is written against it — a merchant reads only their own rows
- Confirm the append-only guarantee on `ledger_entries` per `AGENTS.md` Golden Rule #4 (no update/delete path exposed)
- **Definition of done:** migration applies clean via `supabase db push`; a manual attempt to update/delete a `ledger_entries` row from the client is rejected; RLS verified by testing as two different merchant accounts

### Phase D3 — ASR Integration (`voice-ingest`)
- Blocked on Open Decision #1 (dialect) and #3 (hosted vs self-hosted) — resolve before starting real work; a thin pass-through stub can exist earlier if it unblocks Oviam
- Implement per `docs/ASR_DECISION.md`'s recommendation (AI4Bharat primary, Whisper fallback) and whichever delivery mode (`SETUP.md` §5 Path A or B) was chosen
- Write `docs/API_CONTRACTS.md`'s `voice-ingest` section for real before/alongside implementation
- Measure actual WER on the team's own sample audio for the chosen dialect — do not quote a benchmark-paper number in the demo without having measured it yourselves (`docs/ASR_DECISION.md` "What NOT to Do")
- **Definition of done:** a real recorded audio clip in the target dialect returns a transcript through this function; accuracy has been manually checked against a handful of known-good samples

### Phase D4 — Payments & SMS
- `payment-link`: Razorpay integration, test mode only (`.agents/rules/stop-and-ask.md` #4 — going live requires an explicit stop-and-ask)
- `sms-send`: provider per Open Decision #2; requires DLT registration lead time — start that registration the moment the provider is chosen, per `CONTEXT.md` Known Risks
- Write both functions' `docs/API_CONTRACTS.md` sections for real
- **Definition of done:** a confirmed ledger entry produces a real Razorpay test-mode link and a real (or provider-sandbox) SMS send

### Phase D5 — Credit Scoring Computation
- Implement the formula from `docs/CREDIT_SCORING_LOGIC.md` as a pure function over `ledger_entries` + `payment_links` — recomputed, not accumulated (per that doc's Guardrails)
- Seed realistic demo ledger data so the exported score is real output, never a hardcoded demo number (`AGENTS.md` Golden Rule #5)
- Build the export endpoint per `docs/API_CONTRACTS.md`'s credit-profile-export section (design it here — it's currently unwritten)
- **Definition of done:** the export shows a score, every input signal's raw value, and the formula/weights, computed from real seeded data

### Phase D6 — Reliability Pass
- Idempotency keys on `voice-ingest` and `payment-link` (protects against the double-submit / retry bug class called out in `.agents/rules/git-commit-and-push.md`'s example commit message)
- Error handling audit: every edge function returns the typed error shape from `docs/API_CONTRACTS.md`, never a bare 500
- Load a realistic volume of seed data and confirm nothing in D2's RLS or D5's scoring falls over

---

## 6. Working Without Colliding

Two people editing a small shared repo is where most of the real risk is — not in either person's individual code. These rules exist specifically for that.

1. **`packages/shared/` types are the contract.** If Oviam's UI needs a field Dhyanesh's function doesn't return yet, that's a same-day Slack/call, not a silent guess on either side. Whoever needs the change proposes the type edit as a small PR; the other approves it before either builds against the new shape.
2. **`CONTEXT.md` gets one edit at a time.** Before editing it, `git pull` and check the other person hasn't just pushed a change to it. If you're both updating it at end-of-day, do it sequentially on a call rather than both opening editors at once — this file is exactly the kind of thing that silently loses the other person's update in a bad merge.
3. **Never both touch `supabase/migrations/` in flight at once.** Migrations are ordered and additive (`.agents/rules/coding-standards.md`); two uncoordinated migration files racing to be "the next one" is a real mess. This is Dhyanesh's folder — if Oviam ever needs a schema change, ask, don't add a migration file directly.
4. **Branch names say whose track they're on**, on top of the existing convention in `.agents/rules/git-branching.md`: `feature/oviam-voice-capture-ui`, `feature/dhyanesh-asr-integration`. This makes the PR list scannable for who's mid-flight on what.
5. **PRs into `develop` get reviewed by the other person**, not self-merged, even under time pressure — a second pair of eyes is exactly what two-person teams are for, and it's cheap for a repo this size.
6. **If a `.agents/rules/stop-and-ask.md` trigger fires on either track** (schema-destructive migration, ASR/NLU provider swap, anything payments-related, going live, dialect choice, new core dependency, `.env.example` changes, deleting Decision History, credit-scoring logic changes) — that's a joint decision, not a unilateral one, even though the rule file phrases it as "ask the human." Whoever hits it loops the other person in before proceeding, not just the human/product owner if that's a third party.

---

## 7. Milestone Checkpoints (both people, together)

Don't let the tracks run fully independently all the way to the end — check in at these natural integration points:

| Checkpoint | What must be true | Blocks |
|---|---|---|
| **M1 — Foundation** | O1 + D1 + D2 done | Nothing further can build without real auth + schema |
| **M2 — First real voice round-trip** | O2 (capture) + D3 (ASR) both done, wired together (Oviam swaps the mock for Dhyanesh's real function) | O4 needs real transcripts to build confirmation UX against |
| **M3 — End-to-end sale** | O3 + O4 + D4 done | This is the first point the actual pitch-deck flow (slide 4) works live, tap-to-SMS |
| **M4 — Credit story complete** | O5 + D5 done | This is the differentiator (slide 6) — don't let it be the last thing built the night before |
| **M5 — Demo-ready** | O6 + D6 done | Full run-through, both of you, on the actual device you'll demo on |

At each checkpoint, update `CONTEXT.md`'s Current State and Session Log together, per §6 rule 2 above.
