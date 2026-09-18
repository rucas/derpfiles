# Claude Code commands

Type `/<name>` in Claude Code. Each `.md` here is one slash command, wired in by
`../default.nix` and toggled per host with
`programs.claude-code-custom.commands.<name>.enable`.

On by default: `note`, `commit`, `resolve-conflicts`. Everything else is opt-in.

## Pick one

| Command             | Use when                                       | Acts outward on its own |
| ------------------- | ---------------------------------------------- | ----------------------- |
| `/commit`           | Working tree is dirty and needs commits        | No — commits only        |
| `/note`             | You learned something worth keeping            | No — writes to ledger    |
| `/fix-ci`           | One CI check is red and you know it            | No — never pushes        |
| `/address-review`   | Review comments to triage, not yet answered    | No — never posts/pushes  |
| `/shepherd-pr`      | PR is stalled on mechanics, not judgement      | **Yes** — see below      |
| `/resolve-conflicts`| Mid-merge/rebase with conflict markers         | No — never pushes        |
| `/plan-to-jira`     | Plan is written and needs a ticket             | **Yes** — creates issue  |
| `/execute-plan`     | Ticket + plan ready to hand to a fresh session | No — local worktree only |

## Daily

### `/commit`

Splits the current diff into atomic commits.

1. Reads `git status` / `git diff`, plus `git log --author=rucas` to match your style
2. Groups files into logical units — one commit per concern, hunk-level (`git add -p`) when two changes share a file
3. Prints the plan, then **proceeds immediately**
4. Confirms with `git log --stat`

Pass `confirm` or `ask` as an argument to make it wait. Commits use `--no-verify`.
Never pushes, never adds AI attribution.

### `/note`

Saves one observation to the ledger.

1. Synthesizes title, slug, explanation, tags from the conversation
2. Writes `~/Code/ledger/notes/<YYYY-MM-DD>-<slug>.md`
3. Inserts a backlink under today's `NOTES` heading in the month's `.norg`

Argument is a short description of what to capture; empty means it asks.
Needs the month's norg file to exist already — otherwise it stops and tells you to
run `ldgr gen month <M> <Y>`.

## PR lifecycle

### `/fix-ci`

Takes one red check to green.

1. Finds the failing check (`gh pr checks`, or a PR/build/log you name)
2. Pulls the failure detail — CI MCP if connected, else `gh run view --log-failed`
3. Maps the failing step to a local command and reproduces it
4. Fixes the root cause and verifies locally

Reports the fix. **Does not push unless asked** — `/shepherd-pr` asks, so it pushes
there. If the only problem is that the branch is behind base, it says so instead of
inventing a code fix.

### `/address-review`

Triages review feedback without answering it.

1. Fetches inline threads, review summaries, and PR comments (skips resolved/outdated)
2. Gives each open concern a disposition: **valid**, **partial**, **discussion/invalid**, **wontfix**, tied to file:line
3. Applies only the clearly-valid low-risk fixes in the working tree
4. Drafts a reply per thread for you to review

**Hard default: never posts a comment, submits a review, or pushes.** Local commits
are expected; going outward needs an explicit yes.

### `/shepherd-pr`

The orchestrator — use it when you want the whole PR moved, not one problem fixed.
Delegates to `/fix-ci`, `/address-review`, `/commit`.

1. Un-stales the branch (`gh pr update-branch`); on conflict, merges base locally and runs `/resolve-conflicts`
2. Waits on checks (`gh pr checks --watch`), ignoring human gates — approvals, CODEOWNERS, CLA, manual environments
3. Hands real failures to `/fix-ci`, authorizing it to commit and push, then loops back to the wait
4. **Draft** → `gh pr ready`. **Under review** → one commit per actionable comment, then reply/resolve each thread

Runs as long as your CI does.

**Automatic:** branch updates, conflict resolution, `/fix-ci` commits and pushes.
**Gated:** pushing review-fix commits (once), then every reply/resolve (per thread).

Merges to clear conflicts, never rebases — a rebase would need
`git push --force-with-lease`, which the `Bash(git push --force*)` deny rule blocks.
Stops if a rebase is genuinely required, if base conflicts twice in one run, or
after 3 fix attempts.

### `/resolve-conflicts`

Finishes an in-progress merge, rebase, or cherry-pick.

1. Detects the operation from `.git/` state and lists conflicts with `git diff --name-only --diff-filter=U`
2. Resolves each file preserving both intents, asking when a resolution is ambiguous
3. Verifies no markers remain with `git diff --check`
4. Continues the original operation

Resolution only — never pushes or force-pushes. `/shepherd-pr` delegates to it after
merging base locally; its ambiguity gate still applies, so it will ask you rather
than guess.

## Planning handoff

### `/plan-to-jira`

Turns a plan file into a ticket, full plan as the description.

1. Resolves the plan — argument, else newest `~/.claude/plans/*.md`
2. Resolves the parent: explicit key > git branch > repo path > ask
3. **Always confirms the project prefix before creating** — the plan's project may not match your current branch
4. Converts markdown to Jira markup and creates the issue

Stops rather than creating an orphan if the parent 404s or the MCP is unauthed.

### `/execute-plan`

Launches a fresh Claude session on a plan, in its own worktree and tmux session.

1. Asks for inputs in three rounds — files, then repo, then where in the repo
2. Pre-flight checks, aborting before creating anything
3. Creates the worktree (`git wt new`) and stages a brief
4. Starts Claude in tmux and reports

It is the launcher, not the implementer: it never implements the plan in your
current session, never writes outside the new worktree, and never pushes or opens a
PR unless asked.

## Plugin skills

### `/i-have-adhd`

Reshapes output: next action first, numbered steps, state restated each turn, no
preamble or closers. Stays on for the whole session until you say
"stop adhd mode".

You must invoke it — it sets `disable-model-invocation: true`, so Claude cannot turn
it on itself. Enable with `programs.claude-code-custom.plugins.adhd.enable`.

## Adding a command

1. Drop `<name>.md` in this directory
2. Add it to `bundledCommands` in `../default.nix`
3. Add a `<name>.enable` option next to the others
4. Turn it on in the hosts that want it

`bundledCommands` maps each file explicitly, so this README is not shipped as a
command. For one-offs that do not belong in the repo, use
`programs.claude-code-custom.commands.extra`.
