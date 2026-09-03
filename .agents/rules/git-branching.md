# Rule: Git Branching

Applies to every commit the agent makes. This is a hard rule, not a suggestion — violating it (e.g. committing straight to `main`) should be treated as a mistake to self-correct immediately, not something to wait for the human to catch.

## Branch Model

One long-lived branch:

- `main` — always deployable. Only ever updated via a merged PR. Never has a direct commit.

Everything else is a short-lived feature branch off `main`.

## Naming Convention

```
<type>/<short-kebab-description>
```

| Type | Use for |
|---|---|
| `feature/` | new functionality — e.g. `feature/voice-capture-ui` |
| `fix/` | bug fixes — e.g. `fix/ledger-double-write` |
| `chore/` | tooling, deps, config, docs — e.g. `chore/update-context-md` |
| `spike/` | throwaway exploration/research code, never merged as-is — e.g. `spike/bhashini-latency-test` |

Keep the description under ~5 words. No ticket numbers unless the human's workflow uses them (none defined yet — ask before inventing a scheme).

## Workflow

```bash
git checkout main
git pull origin main
git checkout -b feature/voice-capture-ui
# ... work, commit per git-commit-and-push.md ...
git push -u origin feature/voice-capture-ui
# open PR: feature/voice-capture-ui -> main
```

Rules:

1. **Always branch from an up-to-date `main`.** `git pull origin main` before cutting a new branch, every time.
2. **One branch, one concern.** If a task grows into two unrelated changes mid-flight, stop and split it into two branches rather than piling both onto one PR.
3. **Never merge your own PR into `main` without approval.** Agent-authored PRs target `main`.
4. **Rebase, don't merge, to catch up a feature branch** with `main`, to keep history readable: `git fetch origin && git rebase origin/main`. If a rebase produces conflicts the agent isn't confident resolving correctly (especially in `supabase/migrations/` or anything payments-related), stop and ask rather than guessing at a resolution.
5. **Delete the branch after merge** (`git branch -d feature/x` locally, and via the "delete branch" option on the PR/merge UI remotely) to keep the branch list readable.
6. **Never force-push to `main`.** Force-push (`--force-with-lease`, never bare `--force`) is only ever acceptable on the agent's own feature branch, and only before it's been reviewed.

## When `CONTEXT.md` needs updating as part of a branch

If a session's work changes an Open Decision, adds a Decision History row, or meaningfully moves Current State forward, update `CONTEXT.md` **in the same branch/PR** as the code change — not as a separate later cleanup commit. Context drift is the main way multi-session agent work degrades.
