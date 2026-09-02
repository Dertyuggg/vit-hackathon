# Rule: Git Commits & Pushing

## Before Every Commit — Mandatory Pre-Flight

Run, in order, and actually read the output rather than assuming it's clean:

```bash
git status
git diff --staged
```

Check the staged diff for:
1. **Secrets** — any string that looks like an API key, JWT, connection string, or matches a pattern from `.env.example`'s variable names. If found, unstage it (`git restore --staged <file>`) and fix the leak (add to `.gitignore`, rotate the key if it's real) before proceeding.
2. **Accidental large/binary files** — audio samples, `node_modules`, build output. These should already be gitignored; if one slipped through, stop and fix `.gitignore` first.
3. **Unrelated changes** — a commit for a feature branch should not also include stray formatting-only changes to unrelated files. Split with `git add -p` if needed.

Only after this check: `git commit`.

## Commit Message Format

Conventional Commits, strictly:

```
<type>(<scope>): <short summary, imperative mood, no period>

<optional body — the why, not the what, wrap at ~72 chars>

<optional footer — e.g. "Refs: CONTEXT.md Open Decision #1">
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`

**Scopes** (use the closest match, add new ones to this list if genuinely needed): `web`, `edge-fn`, `db`, `asr`, `nlu`, `payments`, `sms`, `docs`, `deps`

Examples:
```
feat(web): add one-button voice capture screen

fix(edge-fn): prevent duplicate ledger_entries on network retry

Race condition where a client retry after a slow response created
two entries for one spoken sale. Added idempotency key on the
voice-ingest function keyed to a client-generated request UUID.

docs(context): record dialect decision and update session log
```

Never write a commit message that just restates the diff ("update file.ts") — say what changed in behavior/intent.

## Push Rules

1. Push only from a feature branch (never `main`, essentially never `develop` directly — see branching rules).
2. First push of a new branch: `git push -u origin <branch-name>`.
3. Before every push, pull/rebase first if the remote branch might have moved (e.g. after a human pushed a fixup): `git pull --rebase origin <branch-name>`.
4. **Never push with `--force`** except `--force-with-lease` on your own not-yet-reviewed feature branch, and say so out loud when you do it, since it rewrites history the human might be looking at.
5. After pushing, if a PR doesn't already exist for the branch, open one targeting `develop` with:
   - A short description of what changed and why
   - Which `AGENTS.md` Definition of Done checklist items were verified
   - Any `CONTEXT.md` updates included in the diff, called out explicitly

## Commit Granularity

Commit at the level of "one reviewable idea," not "one file" and not "the whole feature." A feature branch implementing voice capture might reasonably be 3-6 commits: scaffold the component, wire the recording logic, add error states, add tests, update docs. Squash-merge is fine at PR-merge time if the human's remote settings do that automatically — the agent doesn't need to pre-squash its own branch.
