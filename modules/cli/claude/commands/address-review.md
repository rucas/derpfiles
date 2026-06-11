Triage incoming review feedback on a PR, apply the clearly-valid low-risk fixes, and draft
replies. Never post or push by default.

`$ARGUMENTS` may carry a PR number, a PR URL, or a specific review/comment URL. Optional.

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
   `CLAUDE.md` / `.claude/rules/*` and style conventions. For anything ambiguous, risky, or a
   judgment call, do NOT change code — flag it for the user instead.

5. **Draft a concise reply per thread** — what changed (with the commit SHA) or why not.
   Keep them as drafts in your response.

6. **HARD DEFAULT — do not post or push.** Never add PR comments, submit a review, or push
   commits as part of this. Only post (e.g. via the github MCP pending-review tools) or push
   if the user EXPLICITLY confirms.

7. **Summarize:** per concern → disposition, what you changed (if anything), and the draft
   reply.
