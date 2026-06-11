Create a Jira ticket from a plan file, using the full plan as the ticket description.

`$ARGUMENTS` may contain a plan file (path or name) and/or a parent issue (a bare key
like `ABC-123` or an `atlassian.net/browse/ABC-123` URL). Both are optional.

## Steps

1. **Resolve the plan file.**
   - If `$ARGUMENTS` names a file, use it (accept a bare name, a path, or
     `~/.claude/plans/<name>.md`).
   - Otherwise default to the most recently modified `*.md` in `~/.claude/plans/`
     (`ls -t ~/.claude/plans/*.md | head -1`) and state which file you picked.
   - Read the whole file.

2. **Resolve the parent issue** (try these in order; match `[A-Z][A-Z0-9_]+-[0-9]+`
   case-insensitively, normalize to upper-case):
   1. An explicit key or browse URL in `$ARGUMENTS` — always wins.
   2. The current git branch: `git rev-parse --abbrev-ref HEAD`.
   3. The worktree/repo path: `git rev-parse --show-toplevel`, then `$PWD`.
   - If nothing is found, ask the user.
   - Derive `project_key` from the key's prefix (the part before the `-`, e.g. the
     three-or-more-letter project code).
   - **Always confirm the project prefix before creating** — show the parsed prefix and
     full parent key (and, if derived from branch/path, where it came from), and ask the
     user to verify it's the right project. Only proceed once confirmed. The plan's
     intended parent/project may differ from the current branch/work ticket.

3. **Fetch parent context.** Call `jira_get_issue` on the parent to confirm it exists
   and to pick up project/component defaults. If it 404s or the MCP errors (e.g. expired
   OAuth), STOP and report — never create a partial or orphan ticket.

4. **Pick the summary and type.**
   - Summary: the plan's H1 (`# …`); fall back to the filename in Title Case.
   - Issue type: `Task` by default; use `Bug` only if the plan is clearly a bug fix or
     `$ARGUMENTS` says so.

5. **Create the issue** with `jira_create_issue`:
   - `project_key` = derived project, `summary` = step 4, `issue_type` = step 4
   - `description` = the FULL plan markdown, verbatim. The Jira MCP renders Markdown →
     Jira wiki markup itself, so do NOT pre-convert or summarize.
   - `additional_fields` = `{"parent": "<parent-key>"}`
   - End the description with an attribution line noting it was authored via Claude Code
     (per the repo's Jira/PR attribution rule).

6. **Link back and report.**
   - Record the created issue key + browse URL near the top of the plan file (in
     frontmatter if present, else a `**Jira:** <url>` line under the H1). If a Jira link
     is already there, update it.
   - Print the created issue key and URL.
