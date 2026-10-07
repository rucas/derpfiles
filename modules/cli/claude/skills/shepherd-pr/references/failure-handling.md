# Failure handling

## Conflict on update

`gh pr update-branch` merges server-side and fails without touching your worktree, so a
reported conflict leaves **no local conflict state** — the `resolve-conflicts` skill would
find nothing and stop. Materialize the conflict first:

1. `git fetch origin`, then `git merge origin/<baseRefName>` to create the conflict
   locally.
2. Invoke the `resolve-conflicts` skill to resolve every file and complete the merge
   commit. Let it ask the user about any resolution it finds ambiguous — that is its own
   gate, and it stands.
3. `git push` (plain — no `--force`, no `--force-with-lease`), then return to the check
   wait loop for the fresh CI run.

If `resolve-conflicts` cannot finish (it asks and gets no answer, or the conflict needs a
decision you do not have), leave the merge in progress, STOP, and report which files are
still conflicted.

## Failing checks

- On a real (non-human-gate) check failure, first un-stale (if applicable), then hand off
  to the `fix-ci` skill rather than stopping. After it pushes, resume the wait loop.
- `fix-ci` needs to push for a new CI run to start, and this skill authorizes that push
  (see **Autonomy boundary**) — pass the instruction in its arguments rather than
  expecting its default. If it still cannot push, STOP and report; do not proceed to the
  finishing step.

## Stop conditions

Guard against infinite loops. STOP and report the outstanding failures with their `link`s
so the user can take over when:

- the **same** check fails again after a `fix-ci` attempt, or
- **3** total fix attempts have been made across the run, or
- the branch conflicts against base a **second** time in one run — base is moving faster
  than you can settle, and that needs the user, or
- the PR genuinely requires a rebase rather than a merge.

A conflict resolved under step 2 counts toward neither the per-check nor the 3-attempt fix
budget.
