Loop on a draft PR until all test/lint checks pass, then mark it ready for review.

`$ARGUMENTS` may carry a PR number or URL. Optional — defaults to the PR for the
current branch.

## Goal

Wait for every automated **test** and **lint** check to go green, then run
`gh pr ready`. Ignore checks that can only be satisfied by a human — review
approvals, CODEOWNERS sign-off, and manual/environment approval gates. Marking the
PR ready is itself what unblocks reviewers, so never wait on them.

## Steps

1. **Resolve the PR.**
   - If `$ARGUMENTS` names a PR, use it. Otherwise use the current branch.
   - `gh pr view $ARGUMENTS --json number,isDraft,headRefName,url,state` (omit
     `$ARGUMENTS` to use the branch).
   - If `state` is not `OPEN`, STOP and report — nothing to do.
   - If `isDraft` is already `false`, report that it is already ready and STOP
     unless the user explicitly asked to re-run.

2. **Wait for checks to reach a terminal state.**
   - Prefer blocking: `gh pr checks <pr> --watch --interval 60`. This returns when
     no check is still `pending`/`in_progress`/`queued`.
   - `--watch` exits non-zero if any check failed; that is expected — do **not**
     treat the non-zero exit as an error, inspect the results in the next step.
   - If `--watch` hangs (checks stuck in a non-terminal action-required state) or is
     unavailable, fall back to polling `gh pr checks <pr>` every ~60s in a loop and
     re-classify each round.

3. **Classify every check** from `gh pr checks <pr> --json name,state,bucket,link,workflow,description`.
   `bucket` is `gh`'s own rollup — use it as the primary signal:
   - `pass` / `skipping` → satisfied.
   - `fail` → a real failure. STOP the loop and report (see step 5). Do not mark
     ready.
   - `pending` → still running; keep waiting (loop back to step 2).
   - **Human-input gates** → ignore for the green decision. Identify these by:
     - raw `state` of `ACTION_REQUIRED` or `WAITING` (manual approval / environment
       protection / deployment gate), or
     - a name that is clearly a human/approval gate rather than a test or lint
       job (e.g. `*approve*`, `*review*`, CODEOWNERS, `license/cla`, `dco`,
       size/label bots). When unsure whether a check is human-gated vs a stuck
       automated job, report it and ask rather than silently skipping.

4. **Decide.**
   - If any check is still `pending` (and not a human gate), go back to step 2.
   - If any real check is `fail`, **fix it**: invoke `/fix-ci` with the failing
     check(s) (pass the check name / `link` as its `$ARGUMENTS`). Let it reproduce
     locally, fix the root cause, and push. Once it has pushed a fix, go back to
     step 2 to wait for the new run. See the failure-handling rules below.
   - If every non-human check is `pass`/`skipping`, mark ready:
     `gh pr ready <pr>`. Then confirm with `gh pr view <pr> --json isDraft,url`.

5. **Report** a short summary:
   - The PR and its final state (marked ready / still draft).
   - Per-check outcome grouped as passed / skipped / ignored-human-gate / failed.
   - Any failures that were fixed via `/fix-ci`, and what the fix was.

## Failure handling

- On a real (non-human-gate) check failure, hand off to `/fix-ci` rather than
  stopping. After `/fix-ci` pushes, resume the wait loop (step 2) so the command
  drives the PR all the way to green → ready.
- Guard against infinite loops: if the **same** check fails again after a `/fix-ci`
  attempt, or after **3** total fix attempts across the run, STOP and report the
  outstanding failures with their `link`s so the user can take over.
- `/fix-ci` needs to push for a new CI run to start. If it declines to push or
  cannot, STOP and report — do not mark ready.

## Notes

- Never mark a PR ready while any automated test or lint check is failing or still
  running.
- Review approvals and CODEOWNERS are *expected* to be unmet on a draft — they are
  not blockers for this command.
- Prefer `--interval 60` on `--watch` so the loop is responsive without hammering
  the API. For very long suites, a longer interval is fine.
- This command only flips draft → ready. It does not push, retry, or fix checks.
