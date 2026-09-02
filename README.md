# Swara

Voice-native micro-commerce & credit engine for rural Indian micro-entrepreneurs. Speak a sale in your own dialect; Swara transcribes it, logs it, collects payment, and builds a bank-readable credit footprint over time.

## Start Here

- **First time opening this in Antigravity?** Paste `MASTER_PROMPT.md` into a fresh chat.
- **Coming back to an existing session?** `AGENTS.md` loads automatically — it tells the agent to read `CONTEXT.md` for current status.
- **Setting up your machine by hand?** See `SETUP.md`.
- **Want the product pitch?** See `docs/PITCH_DECK_SUMMARY.md`.

## Doc Map

| File | What it's for |
|---|---|
| `AGENTS.md` | Standing rules the AI agent follows every session |
| `CONTEXT.md` | Living memory — current state, open decisions, session log |
| `SETUP.md` | Environment setup, dependencies, verification checklist |
| `MASTER_PROMPT.md` | One-time bootstrap prompt for a new Antigravity workspace |
| `.agents/rules/` | Git branching, commit/push, coding standards, stop-and-ask boundaries |
| `.antigravity/workflows/` | Repeatable step sequences for new features / bug fixes |
| `docs/` | Domain docs — ASR choice, NLU approach, credit scoring, privacy, API contracts |

This repo does not have application code yet — see `CONTEXT.md` §Current State for exactly where things stand.
