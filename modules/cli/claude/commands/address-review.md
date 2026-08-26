Triage incoming review feedback on a PR, apply the clearly-valid low-risk fixes, and draft
replies. Never post or push by default.

`$ARGUMENTS` may carry a PR number, a PR URL, or a specific review/comment URL. Optional.

## Context first

Before doing anything else, load this repo's own guidance so your work follows its
conventions: read the repo-root `CLAUDE.md` and any `.claude/` context that applies
(`.claude/CLAUDE.md`, `.claude/rules/*`). Let those commands, conventions, and
policies govern every step below. If none exist, fall back to the Makefile /
package.json / CI config.

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

6. **Draft one reply per thread**, following **Reply style** below. Keep them as drafts in
   your response.

7. **HARD DEFAULT — do not post or push.** Committing locally (step 5) is expected; going
   outward is not. Never add PR comments, submit a review, or push as part of this. Only post
   (e.g. via the github MCP pending-review tools) or push if the user EXPLICITLY confirms.

8. **Summarize:** per concern → disposition, the commit SHA (if any), and the draft reply.

## Reply style

Shape every drafted reply with the `i-have-adhd` skill's rules: the outcome is the first
line, no preamble, no recap, no closing pleasantry, no hedging adverbs, matter-of-fact on
errors. That skill sets `disable-model-invocation`, so you cannot call it as a tool — read
its `SKILL.md` from the installed `i-have-adhd` plugin if you need the full rules (and if
`/i-have-adhd` is already active this session, it is already governing your output). The
rules below are what those come down to for review replies.

**Fixed → one line.** Do not restate the reviewer's point, explain the fix, or thank them.

```
Fixed in abc1234.
```

Step 5 means the SHA always exists by the time you draft. Use the literal placeholder only
when a fix was deliberately left uncommitted, and say why in the same line:

```
Fixed in [SHA] — holding the commit until the API change in #412 lands.
```

Add one short clause only when the SHA alone is misleading — the fix landed somewhere the
reviewer would not expect:

```
Fixed in abc1234 (moved the guard into `parseConfig` instead of the caller).
```

**Wontfix, feedback is wrong, or you took a different direction → 1-3 sentences.** Be
concrete, not longer. Say what you did instead (if anything) and the reason that decides
it — a constraint, a repo convention, a measurement, a call site. Cite `file:line` or the
rule when that settles the point. Offering an alternative is fine; padding is not.

```
Left as-is: `retryCount` is read by the scheduler at scheduler.rs:88, so making it private
breaks that call site. Can add a getter if you would rather it not be a public field.
```

```
Went the other way in abc1234 — memoizing here would keep the whole response body alive
between renders. Cached just the parsed header instead, which is what the hot path reads.
```

Never write: "Great catch", "Thanks for the review", "You're absolutely right", "Let me
know what you think", or an apology.
