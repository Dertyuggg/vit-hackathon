# Workflow: New Feature

Trigger this when the human asks for a new feature (invoke as `/new-feature <description>` if Antigravity's slash-command binding is set up, otherwise just follow it as a checklist when starting feature work).

## Steps

1. **Read context.** Load `CONTEXT.md`, and any `docs/` file relevant to the feature area (ASR, NLU, payments, credit scoring).
2. **Check for blocking open decisions.** If the feature depends on an item in `CONTEXT.md` §Open Decisions, stop and ask before proceeding.
3. **Branch.** `git checkout develop && git pull origin develop && git checkout -b feature/<short-name>` per `.agents/rules/git-branching.md`.
4. **Write the contract first, if the feature is an edge function or API surface.** Add/update its entry in `docs/API_CONTRACTS.md` before writing implementation code.
5. **Implement** per `.agents/rules/coding-standards.md`.
6. **Self-review against `.agents/rules/stop-and-ask.md`** — did this feature touch any of the listed categories without pausing? If so, stop now, before committing, and check in.
7. **Test the happy path manually** and, where the feature warrants it, add automated tests per the Testing section of `coding-standards.md`.
8. **Lint and build.** `pnpm lint && pnpm build` must pass clean.
9. **Update `CONTEXT.md`** — Current State, and a new Session Log entry. Add a Decision History row if a real decision was made along the way.
10. **Commit** in reviewable chunks per `.agents/rules/git-commit-and-push.md`.
11. **Push and open a PR** against `develop`, filling in the Definition of Done checklist from `AGENTS.md` §6 in the PR description.
