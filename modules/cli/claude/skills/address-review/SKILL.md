---
name: address-review
description: Triage open review threads on a PR, apply the clearly-valid low-risk fixes, and draft one reply per thread. Never posts a comment, submits a review, or pushes — local commits only.
---

# Address Review

Triage incoming review feedback on a PR, apply the clearly-valid low-risk fixes, and draft
replies. Never post or push by default.

`$ARGUMENTS` may carry a PR number, a PR URL, or a specific review/comment URL. Optional.

This repo's guidance — the `CLAUDE.md` chain and `.claude/rules/*` — is already loaded in
context; let its commands and conventions govern every step below. Where a repo ships
none, fall back to its Makefile / package.json / CI config.

## Steps

1. **Resolve the PR.** Use `$ARGUMENTS` if it names a PR/review/comment; otherwise current
   branch → `gh pr view --json number,headRepositoryOwner,headRepository` for owner/repo/
   number. If a specific review/comment URL was given, focus on that review.

2. **Fetch the feedback** via the github MCP `pull_request_read`:
   - `get_review_comments` — inline review threads. Each carries `isResolved` / `isOutdated`;
     skip resolved/outdated threads unless asked otherwise.
   - `get_reviews` — review-level summaries (and the specific review if a review URL was
     given).
   - `get_comments` — general PR comments, if relevant.

3. **Triage each open concern, one by one.** Give each a disposition — **valid** (actionable
   code change), **partial**, **discussion/invalid**, or **wontfix** — and tie it to the
   file:line or the relevant commit SHA. Be concrete; don't lump them together.

4. **Apply only the clearly-valid, low-risk fixes** in the working tree, following the repo's
   style conventions. For anything ambiguous, risky, or a judgment call, do NOT change code —
   flag it for the user instead.

5. **Commit the fixes with the `commit` skill — one thread, one commit.** Invoke it via the
   Skill tool (`commit`), passing a grouping hint that spells out the intended split, one
   entry per addressed thread:

   ```
   one commit per review thread: (1) null-check in parseConfig — src/config.ts;
   (2) drop unused retry branch — src/client.ts
   ```

   Scope the hint to the files you touched in step 4. The skill plans its split from the
   whole diff, so if the working tree already carried unrelated edits, name them as
   out of scope — leave them uncommitted rather than folding them into a review fix.

   The skill owns the commit mechanics — atomic staging (including `git add -p` when two
   fixes share a file), title conventions, `--no-verify`, no AI attribution. Do not
   hand-roll `git add` / `git commit` here, and do not restate its rules.

   Then map commits back to threads with `git log --oneline -<n>`; each thread's reply cites
   its own short SHA. Never batch two threads into one commit — but never leave a broken
   intermediate state either: if the hunks are genuinely interdependent, let them be one
   commit and cite it from both threads.

6. **Draft one reply per thread.** Read `references/reply-style.md` and follow it exactly.
   Keep the replies as drafts in your response.

7. **HARD DEFAULT — do not post or push.** Committing locally (step 5) is expected; going
   outward is not. Never add PR comments, submit a review, or push as part of this. Only post
   (e.g. via the github MCP pending-review tools) or push if the user EXPLICITLY confirms.

8. **Summarize:** per concern → disposition, the commit SHA (if any), and the draft reply.
