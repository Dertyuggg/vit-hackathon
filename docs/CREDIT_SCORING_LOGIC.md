# Credit Scoring Logic — The "Shadow Credit Score"

This is the product's core trust claim (pitch deck slide 6), so per `AGENTS.md` Golden Rule #5 and `.agents/rules/stop-and-ask.md` item #9: any change here gets explained to the human in plain terms before shipping.

## What This Is (and Isn't)

**Is:** a transparent, formula-derived summary of a merchant's recorded transaction history, exported in a format a partner bank's underwriter can read.

**Isn't:** a regulated credit bureau score (like CIBIL). Never label it that way in code, UI copy, or pitch materials — call it a "risk profile," "transaction footprint summary," or "Shadow Credit Score" (as the deck names it), never "credit score" unqualified, to avoid implying regulatory status it doesn't have.

## MVP Formula (starting point — expect to iterate with the human, don't treat as final)

Compute over a merchant's `ledger_entries` for a trailing window (e.g. 90 days):

| Signal | What it captures | Direction |
|---|---|---|
| Transaction frequency | count of ledger entries in window | more = healthier, active business |
| Transaction consistency | standard deviation of days-between-entries | lower = more predictable cash flow |
| Average transaction value | mean `total_amount` | context, not inherently good/bad |
| Revenue trend | linear trend of weekly totals over the window | upward/flat = healthier than declining |
| Payment completion rate | % of `payment_links` that reached `status = 'paid'` vs `expired`/`failed` | higher = buyers reliably pay, less counterparty risk |
| Ledger tenure | days since first ledger entry | longer = more data to trust |

Combine into a bounded score (e.g. 0-100) with a simple, disclosed weighting — not a black-box model. **A bank underwriter (or a hackathon judge) should be able to look at the weights and the inputs and reconstruct the score by hand.** This is a deliberate design choice, not a limitation: opacity here would undermine the "verifiable, trustworthy footprint" pitch.

Do not use an ML model to produce this score for the MVP. A hand-specified, disclosed formula is the right level of sophistication for "shadow credit scoring for the unbanked" — it's auditable, explainable to a merchant in one sentence, and defensible in front of a judge asking "how did you get this number."

## Export Format

The bank-facing export (`docs/API_CONTRACTS.md` should define this endpoint's exact shape once built) should include:
- The final score
- Every input signal's raw value
- The formula/weights used to combine them
- The date range the data covers
- A note that this is not a regulated bureau score

## Guardrails

- Never fabricate or hardcode a "demo" score that isn't computed from real seeded ledger data — if a demo needs a compelling number, seed realistic ledger entries and let the real formula compute it, per `AGENTS.md` Golden Rule #5.
- Recompute, don't accumulate — this should be a pure function of ledger history, not a mutable running counter that could drift from the underlying data.
