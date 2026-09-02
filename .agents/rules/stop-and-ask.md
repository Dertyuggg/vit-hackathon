# Rule: When to Stop and Ask Instead of Deciding Alone

Antigravity agents default to autonomous action. For most of this codebase that's the right default. These specific situations are exceptions — stop, explain the fork in the road, and wait for the human, rather than picking the most-likely-correct option and continuing.

## Always stop for:

1. **Any DB migration that drops or alters a column/table in a way that could lose data.** Additive migrations (new table, new column, new index) don't need to stop.
2. **Changing the ASR or NLU provider** after one has been chosen and integrated. Swapping is a real cost (re-testing accuracy, re-writing the adapter) — confirm it's worth it first.
3. **Anything in the payments flow** — Razorpay key handling, amount calculation, currency handling, webhook signature verification. Money bugs are the least forgivable kind here.
4. **Going from Razorpay test mode to live mode**, or any change that would let real money move.
5. **The target dialect/language for the MVP** — this is currently an open question (see `CONTEXT.md`); do not silently pick one and start building dialect-specific logic.
6. **Adding a new top-level dependency** that isn't already listed in `SETUP.md` — a new state-management library, a new UI kit, a new backend service. Small utility additions (e.g. a date-formatting helper) don't need to stop; something that becomes core infrastructure does.
7. **Any change to `.env.example` variable names** that would require the human to go re-fetch a new credential — flag it clearly so they're not stuck debugging a silently-missing env var.
8. **Deleting a `CONTEXT.md` Decision History row.** These are append-only. If a decision changes, add a new row and mark the old one as superseded; never remove history.
9. **Anything that touches how the "Shadow Credit Score" is computed or presented**, since that's the product's core trust claim. New logic there should be explained to the human in plain terms before being wired into the UI.

## Don't stop for (just use good judgment and proceed):

- Component structure, file organization within the agreed folder layout, variable naming
- Adding a loading spinner, an error toast, a retry button — normal UX polish
- Writing tests
- Fixing an obvious bug in code you just wrote
- Formatting/lint fixes
- Updating `CONTEXT.md` itself

## How to Ask

Be concrete. Don't ask "what should I do about the database?" — ask "Migration X would drop the `dialect_code` column on `merchants` because Y. Is that safe, or does that data need to be preserved/migrated first?" Give the human a real decision to make, not a vague status update disguised as a question.
