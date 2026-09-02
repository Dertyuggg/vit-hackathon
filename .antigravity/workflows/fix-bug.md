# Workflow: Fix a Bug

Trigger this when the human reports something broken (invoke as `/fix-bug <description>` if bound, otherwise follow as a checklist).

## Steps

1. **Reproduce first.** Don't patch based on a guess about the cause — confirm you can actually trigger the bug (manually, or with a failing test) before changing code. If you can't reproduce it, say so and ask for more detail (steps, error message, browser/device) rather than making a speculative fix.
2. **Branch.** `git checkout develop && git pull origin develop && git checkout -b fix/<short-name>`.
3. **Find the root cause, not just the symptom.** If the bug is a duplicate ledger entry, understand *why* (race condition? missing idempotency key? UI double-submit?) before writing the fix — a patch that hides the symptom without fixing the cause tends to resurface elsewhere.
4. **Write a regression test** that fails before the fix and passes after, where the bug is in testable logic (edge functions, NLU extraction, ledger writes). UI-only bugs can skip this if there's no reasonable automated way to catch it — say so rather than skipping silently.
5. **Fix it.**
6. **Check for the same bug pattern elsewhere in the codebase.** If the root cause was "no idempotency key on a write endpoint," check the other edge functions for the same gap and flag them even if fixing all of them isn't in scope for this branch.
7. **Lint and build clean.**
8. **Update `CONTEXT.md` Session Log** with what broke and what fixed it — this kind of note is disproportionately useful for future debugging.
9. **Commit** with a `fix(scope): ...` message describing the root cause, not just "fix bug."
10. **Push and open a PR** against `develop`, describing repro steps and how they were verified fixed.
