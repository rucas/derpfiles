Shepherd a PR toward merge: keep it un-stale and green, mark drafts ready, and
drive unresolved review feedback to resolution.

`$ARGUMENTS` may carry a PR number or URL. Optional — defaults to the PR for the
current branch.

## Goal

Take an open PR — **draft or already under review** — and move it forward:

- Keep the branch up to date with its base (un-stale it).
- Get every automated **test** and **lint** check green, fixing real failures via
  `/fix-ci`.
- If the PR is still a **draft** and everything is green, mark it ready
  (`gh pr ready`).
- If the PR is **under review** and green, work through unresolved review comments
  via `/address-review` — one commit per actionable comment, push only on
  confirmation, then reply/resolve each thread one by one with the user's approval.

Ignore checks that can only be satisfied by a human — review approvals, CODEOWNERS
sign-off, and manual/environment approval gates. Never wait on those.

## Context first

Before doing anything else, load this repo's own guidance so your work follows its
conventions: read the repo-root `CLAUDE.md` and any `.claude/` context that applies
(`.claude/CLAUDE.md`, `.claude/rules/*`). Let those commands, conventions, and
policies govern every step below. If none exist, fall back to the Makefile /
package.json / CI config. (The delegated commands — `/fix-ci`, `/address-review`,
`/resolve-conflicts` — load the same context on their own.)

## Steps

1. **Resolve the PR.**
   - If `$ARGUMENTS` names a PR, use it. Otherwise use the current branch.
   - `gh pr view $ARGUMENTS --json number,isDraft,headRefName,url,state,mergeStateStatus,labels,reviewDecision`
     (omit `$ARGUMENTS` to use the branch).
   - If `state` is not `OPEN`, STOP and report — nothing to do.
   - Record the **mode**: `draft` if `isDraft` is `true`, otherwise `review`. This
     decides the finishing step (7a vs 7b).

2. **Bring the branch up to date if it is stale.**
   - Treat the branch as stale if **any** of these hold:
     - `mergeStateStatus` is `BEHIND` (authoritative — the branch is behind base),
     - a label matches `*stale*` (case-insensitive), or
     - a recent PR comment asks to rebase/merge from the base branch (e.g. "Please
       rebase or merge the latest changes from master"). Check with
       `gh pr view <pr> --json comments --jq '.comments[-10:] | .[].body'` and look
       for a rebase/merge-from-base request.
   - If not stale, skip to step 3.
   - If stale, update the branch by merging the base:
     `gh pr update-branch <pr>`. If the base must be rebased instead (or the user
     asked for a rebase), use `gh pr update-branch <pr> --rebase`.
   - If the update reports a **conflict** (non-zero exit / "merge conflict"), STOP
     and report — resolving conflicts needs the user (or `/resolve-conflicts`). Do
     not force anything.
   - After a successful update, the base merge/rebase triggers a fresh CI run, so
     fall through to step 3 and wait for it. Bots usually drop the `stale` label on
     their own; if it lingers after the update, note it in the report rather than
     removing it.

3. **Wait for checks to reach a terminal state.**
   - Prefer blocking: `gh pr checks <pr> --watch --interval 60`. This returns when
     no check is still `pending`/`in_progress`/`queued`.
   - `--watch` exits non-zero if any check failed; that is expected — do **not**
     treat the non-zero exit as an error, inspect the results in the next step.
   - If `--watch` hangs (checks stuck in a non-terminal action-required state) or is
     unavailable, fall back to polling `gh pr checks <pr>` every ~60s in a loop and
     re-classify each round.

4. **Classify every check** from `gh pr checks <pr> --json name,state,bucket,link,workflow,description`.
   `bucket` is `gh`'s own rollup — use it as the primary signal:
   - `pass` / `skipping` → satisfied.
   - `fail` → a real failure. Handle it in step 5.
   - `pending` → still running; keep waiting (loop back to step 3).
   - **Human-input gates** → ignore for the green decision. Identify these by:
     - raw `state` of `ACTION_REQUIRED` or `WAITING` (manual approval / environment
       protection / deployment gate), or
     - a name that is clearly a human/approval gate rather than a test or lint
       job (e.g. `*approve*`, `*review*`, CODEOWNERS, `license/cla`, `dco`,
       size/label bots). When unsure whether a check is human-gated vs a stuck
       automated job, report it and ask rather than silently skipping.

5. **Fix failing checks.**
   - If any check is still `pending` (and not a human gate), go back to step 3.
   - If any real check is `fail`:
     - **First, un-stale.** If step 2 did not already update the branch this round
       and the branch is now `BEHIND`, update it (step 2) and go back to step 3 —
       being behind base is a common cause of failures, so let the fresh run settle
       before touching code.
     - If it still fails after that (or the branch was already current), invoke
       `/fix-ci` with the failing check(s) (pass the check name / `link` as its
       `$ARGUMENTS`). Let it reproduce locally, fix the root cause, and push. Once it
       has pushed a fix, go back to step 3. See the failure-handling rules below.
   - When every non-human check is `pass`/`skipping`, the PR is **green** →
     go to step 6.

6. **Confirm still-current, then finish.**
   - Re-check staleness once on a fresh `gh pr view` (the step 2 check). If the
     branch went stale again while checks ran, go back to step 2.
   - Otherwise proceed to the finishing step for the PR's mode: 7a for `draft`, 7b
     for `review`.

7a. **Draft → ready.**
   - Mark ready: `gh pr ready <pr>`. Confirm with
     `gh pr view <pr> --json isDraft,url`. Then report (step 8).

7b. **Review → drive unresolved comments to resolution.**
   - Fetch unresolved feedback and hand off to `/address-review` (pass the PR as its
     `$ARGUMENTS`) to triage every open thread and produce dispositions + draft
     replies. Only actionable (**valid** / **partial**) threads get code changes;
     discussion/invalid/wontfix threads get a reply, not a commit.
   - **One commit per actionable comment.** For each actionable thread, make the
     change and commit it on its own (use `/commit`) so the thread maps to a single
     SHA. Keep unrelated changes out of that commit. If two threads truly require the
     same edit, note that and share the SHA.
   - **Wait for confirmation to push.** Show the user the planned commits (SHA →
     which comment each addresses) and STOP for explicit approval. Do not push until
     they confirm. If they want changes, adjust and re-confirm.
   - **Push** once approved, then wait for the new CI run to settle (loop back to
     step 3 as needed so you don't reply on a red build).
   - **Reply/resolve each thread one by one.** Go comment by comment; for each,
     show the drafted reply referencing the SHA that addressed it (e.g. "addressed
     in commit abc123", "fixed in 123adf") and ask the user to approve **before**
     posting. On approval, post the reply and resolve the thread (github MCP
     `add_reply_to_pull_request_comment`, then resolve). For threads with no code
     change, post the explanation reply instead of resolving unless the user says to
     resolve. Never post or resolve without that per-thread approval.

8. **Report** a short summary:
   - The PR, its mode (draft/review), and final state (marked ready / replies posted
     / still open).
   - Whether the branch was updated for staleness (and how — merge vs rebase), or
     blocked on a conflict.
   - Per-check outcome grouped as passed / skipped / ignored-human-gate / failed.
   - Any failures fixed via `/fix-ci`, and the fix.
   - For review mode: per comment → the commit that addressed it (or why not), and
     whether its reply was posted / thread resolved.

## Failure handling

- On a real (non-human-gate) check failure, first un-stale (if applicable), then
  hand off to `/fix-ci` rather than stopping. After `/fix-ci` pushes, resume the
  wait loop (step 3).
- Guard against infinite loops: if the **same** check fails again after a `/fix-ci`
  attempt, or after **3** total fix attempts across the run, STOP and report the
  outstanding failures with their `link`s so the user can take over.
- `/fix-ci` needs to push for a new CI run to start. If it declines to push or
  cannot, STOP and report — do not proceed to the finishing step.

## Notes

- Never mark a draft ready, and never post review replies, while any automated test
  or lint check is failing or still running.
- Review approvals and CODEOWNERS are *expected* to be unmet on a draft — they are
  not blockers for this command.
- Prefer `--interval 60` on `--watch` so the loop is responsive without hammering
  the API. For very long suites, a longer interval is fine.
- Writes are gated: the branch update (step 2) and `/fix-ci` pushes are automatic,
  but pushing review-fix commits and posting/resolving review threads (step 7b)
  **always** require explicit user confirmation — pushing once for the commits, and
  again per thread before replying/resolving.
