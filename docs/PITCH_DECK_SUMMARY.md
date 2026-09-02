# Pitch Deck Summary — Swara

Source: `Swara_Pitch_Deck.pptx` (Team Claude coders). This is a faithful summary for engineering reference, not a copy of the deck — check the original deck for exact wording/visuals if needed for a demo.

## Slide 1 — Title
**Swara: Voice-Native Micro-Commerce & Credit Engine.** A dialect-aware voice layer that turns spoken regional commerce into executable financial actions, giving rural micro-entrepreneurs a verifiable digital footprint for the first time.

## Slide 2 — The Core Problem ("Locked out by design")
- **Language & literacy walls:** digital-literacy demands lock out first-time smartphone users from typing invoices or navigating banking apps; standard-language, text-heavy UIs exclude dialect-only speakers who can't type.
- **Invisible to banks:** no verifiable transaction history means banks have nothing to underwrite a loan against.
- **No time to learn apps:** manual UI navigation is a dealbreaker for merchants juggling customers, stock, and cash all day.

## Slide 3 — The Solution
- **Voice-first, not app-first:** bypasses UI entirely.
- **Dialect-aware by design:** regional phrasing, local speech patterns, and colloquial pricing terms are understood natively.
- Spoken commands become executable financial actions instantly, via a hyper-minimalist, audio-only interface — no menus, no typing.

## Slide 4 — The Voice Ledger (functional flow)
1. **Speak the sale:** merchant taps one button, speaks e.g. "Sold 50 kilos of rice to Ramesh for 2000 rupees."
2. **NLP extraction:** dialect-aware speech recognition extracts intent, item quantities, and pricing entities from regional phrasing.
3. **Automated settlement:** system logs the sale instantly and SMS's a localized payment link straight to the buyer's phone.

## Slide 5 — MVP Technical Architecture (as originally pitched)
- Frontend — React (hyper-minimalist, audio-first, for low-literacy users)
- Backend & Auth — Flask, Clerk (handles NLP pipeline, intent routing, API connections, merchant onboarding)
- Voice Engine — Whisper (dialect-aware speech recognition, optimized for local commerce phrasing)
- Payments & DB — Razorpay (dynamic payment links) + MySQL (merchant ledger storage)

**Engineering note:** this doc preserves the original pitch for reference. The actual build plan has since moved backend/DB to Supabase and the ASR recommendation to AI4Bharat's Indic models over plain Whisper — see `CONTEXT.md` §Decision History and `docs/ASR_DECISION.md` for why, and treat `AGENTS.md` §3 as the current source of truth for stack choices, not this slide.

## Slide 6 — Shadow Credit Scoring
- **Structured data, continuously:** every voice transaction converts into structured ledger data over time, building an alternative credit profile.
- **Risk-assessment dashboard:** the accumulating footprint exports as a clear risk profile banks can actually read.
- **Underwriting for the unbanked:** partner banks use the exported profile to underwrite micro-loans for merchants with no prior credit history.

## Slide 7 — Why This Wins
- A genuinely hard AI/ML problem (dialect-aware speech processing) packaged inside a deployable full-stack app.
- Attacks a massive real barrier: financial inclusion for millions of offline micro-entrepreneurs currently locked out of formal credit.
- **Open question posed to the room:** which local dialect or regional focus would make the most compelling proof-of-concept for the ML model? — this is tracked as `CONTEXT.md` Open Decision #1 and should be resolved before ASR-specific work begins.
