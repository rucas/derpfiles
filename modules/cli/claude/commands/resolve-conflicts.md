Resolve the in-progress git merge/rebase/cherry-pick conflicts in the current repo,
verify the result, and continue the operation.

`$ARGUMENTS` may carry extra guidance (e.g. a preferred side for a specific file). Optional.

## Steps

1. **Identify the operation and the conflicts.**
   - Detect the in-progress op so you know how to continue later: `.git/MERGE_HEAD` →
     merge, `.git/rebase-merge` or `.git/rebase-apply` → rebase, `.git/CHERRY_PICK_HEAD`
     → cherry-pick.
   - List conflicted files with `git diff --name-only --diff-filter=U` — NOT `git status`,
     whose output gets truncated and silently drops files.
   - If there are none, say so and stop.

2. **Resolve each conflicted file.**
   - Read it and understand both sides (`<<<<<<<` ours / `=======` / `>>>>>>>` theirs;
     with diff3 there is also a `|||||||` base section). Use `git log --oneline -5` on each
     side for intent when it's unclear.
   - Resolve preserving both intents where possible, and remove ALL markers — including the
     diff3 base. Never leave `<<<`, `|||`, `===`, or `>>>` behind.
   - If a resolution is ambiguous or involves logic you're unsure about, ASK rather than
     guess.

3. **Confirm no markers remain.** Run `git diff --check` — it flags leftover conflict
   markers and whitespace errors. Fix whatever it reports. Don't hand-roll greps for this.

4. **Project-specific fixups.** Read the repo's `CLAUDE.md` and `.claude/rules/*` and apply
   any convention the conflicted files trigger (e.g. regenerate a lockfile if a dependency
   manifest conflicted, bump a version/config field the project requires).

5. **Validate the touched scope.** Using the commands in `CLAUDE.md` (or Makefile /
   package.json / CI config if there's no CLAUDE.md), compile + lint + test ONLY the
   affected modules — never the whole repo. Iterate until green. Parse test results with the
   project's helper (e.g. a `parse_junit.py`) rather than reading XML by hand.

6. **Stage and continue.**
   - `git add` the resolved files.
   - Continue the detected op non-interactively: merge → `git commit --no-edit`; rebase →
     `GIT_EDITOR=true git rebase --continue`; cherry-pick → `GIT_EDITOR=true git
     cherry-pick --continue`.
   - If a rebase or cherry-pick then surfaces the next conflicted commit, loop back to
     step 1 until the operation completes.

7. **Report** what you resolved, any non-obvious decisions, and anything you flagged for the
   user.

## Notes
- Resolution only — never `git push` or force-push as part of this.
- For the "my PR contains other people's commits" cleanup, surface it and propose a
  rebase/squash plan rather than silently rewriting history.
