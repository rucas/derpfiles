# Claude Code commands

Type `/<name>` in Claude Code. Each `.md` here is one slash command, wired in by
`../default.nix` and toggled per host with
`programs.claude-code-custom.commands.<name>.enable`.

All four are on by default.

Skills live in `../skills/` and are listed in their own README. The two directories are
the *same* mechanism — see that README for what actually distinguishes them.

## Pick one

| Command              | Use when                                 | Acts outward on its own |
| -------------------- | ---------------------------------------- | ----------------------- |
| `/commit`            | Working tree is dirty and needs commits  | No — commits only       |
| `/note`              | You learned something worth keeping      | No — writes to ledger   |
| `/fix-ci`            | One CI check is red and you know it      | No — never pushes       |
| `/resolve-conflicts` | Mid-merge/rebase with conflict markers   | No — never pushes       |

PR shepherding, review triage, Jira handoff and session handoff are all skills — see
`../skills/README.md`.

## Frontmatter

Every command carries YAML frontmatter with at least a `description`. That is not
cosmetic: **without it, a command advertises its first physical line as its description**,
and since these files hard-wrap at ~90 characters that yields a truncated, mid-sentence
description — which is exactly the text Claude matches against when deciding whether to
reach for the command on its own.

`disable-model-invocation: true` works here too, and genuinely removes the command from
the model-invocable listing. `allowed-tools` parses but does **not** restrict the toolset
— it is a permission grant, and a no-op under this repo's `defaultMode = "auto"`.

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

### `/resolve-conflicts`

Finishes an in-progress merge, rebase, or cherry-pick.

1. Detects the operation from `.git/` state and lists conflicts with `git diff --name-only --diff-filter=U`
2. Resolves each file preserving both intents, asking when a resolution is ambiguous
3. Verifies no markers remain with `git diff --check`
4. Continues the original operation

Resolution only — never pushes or force-pushes. `/shepherd-pr` delegates to it after
merging base locally; its ambiguity gate still applies, so it will ask you rather
than guess.

## Plugin skills

### `/i-have-adhd`

Reshapes output: next action first, numbered steps, state restated each turn, no
preamble or closers. Stays on for the whole session until you say
"stop adhd mode".

You must invoke it — it sets `disable-model-invocation: true`, so Claude cannot turn
it on itself. Enable with `programs.claude-code-custom.plugins.adhd.enable`.

## Adding a command

1. Drop `<name>.md` in this directory, frontmatter first
2. Add it to `bundledCommands` in `../default.nix`
3. Add a `<name>.enable` option next to the others
4. Turn it on in the hosts that want it (or give it `default = true`)

Reach for `../skills/` instead when the thing wants conditional reference material —
that is the one capability a command does not have.

`bundledCommands` maps each file explicitly, so this README is not shipped as a
command. For one-offs that do not belong in the repo, use
`programs.claude-code-custom.commands.extra`.

## Repo context is already loaded

Do **not** open a command with "first, read the repo's `CLAUDE.md` and `.claude/rules/*`".
Claude Code auto-loads the `CLAUDE.md` chain and every `.claude/rules/*.md` into the
session before the command body runs, so that instruction only buys a redundant `Read` at
the top of every invocation. One line noting that the guidance governs the steps is
enough.
