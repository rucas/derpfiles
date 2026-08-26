Hand a Jira ticket + plan off to a fresh Claude session running in its own worktree and tmux session.

`$ARGUMENTS` may contain, in any order: a Jira key (`ABC-1234`) or browse URL, a plan
markdown file, any number of extra context files, and a path to do the work in. Flags:
`--dir PATH` (work path), `--plan PATH`, `--attach`.

## Your job

You are the **launcher**, not the implementer. You set up an isolated worktree, stage a
brief, start Claude in a tmux session, and report. Do **not** start implementing the plan
in this session, and never write outside the new worktree (the files you're given are
read-only inputs).

## Steps

1. **Parse `$ARGUMENTS`.**
   - **Ticket** — match `[A-Z][A-Z0-9_]+-[0-9]+` case-insensitively (bare key or
     `atlassian.net/browse/<key>` URL), normalize to upper-case. Required; ask if absent.
   - **Work path** — `--dir PATH`, else the one argument that is an existing *directory*,
     else `$PWD`. Expand `~`.
   - **Plan** — `--plan PATH`, else the first `*.md` file argument. If none was given,
     search `~/.claude/plans/` for a plan mentioning the ticket key
     (`rg -l <KEY> ~/.claude/plans/*.md`), falling back to the most recently modified
     (`ls -t ~/.claude/plans/*.md | head -1`). Whenever you guessed, say which file you
     picked and confirm before continuing.
   - **Context files** — every remaining existing file path.
   - If an explicitly named file or directory does not exist, STOP and report — never
     silently drop an input or substitute another file.

2. **Resolve the repo and the target subdir.** From the work path:
   - `main_wt` = `git -C <work-path> worktree list --porcelain | head -1 | awk '{print $2}'`
     — the repo's **main** worktree. This is correct from any depth, and also when the work
     path is inside an existing worktree (then it points back at the real checkout, not the
     worktree).
   - `rel` = `git -C <work-path> rev-parse --show-prefix` — the path relative to the repo
     root (empty when at the root).
   - If the work path is not in a git repo, STOP.
   - Confirm `<main_wt>/<rel>` exists.

3. **Pre-flight — abort before creating anything.** Report and stop if any holds:
   - `tmux has-session -t "=<KEY>"` succeeds. A session already exists, possibly with a
     live Claude in it; **never send keys into it**. Suggest `tmux switch-client -t <KEY>`
     or `git wt kill <KEY>`.
   - `<main_wt>/.claude/worktrees/<KEY>` exists.
   - `git -C <main_wt> rev-parse --verify worktree-<KEY>` succeeds (branch already there).

4. **Fetch the ticket** with `jira_get_issue` on the key: summary, type, status, parent,
   description, acceptance criteria, URL. If the MCP errors (e.g. expired OAuth), do not
   invent content — carry on with just the key + browse URL and note in the brief that the
   new session must fetch it itself.

5. **Create the worktree + session.**

```bash
git wt new <KEY> <main_wt> --cd <rel>          # omit --cd when rel is empty
```

Always pass `<main_wt>` explicitly as the repo argument (it also keeps `git wt new` from
mistaking a ticket-shaped directory name for the repo path). `--cd <rel>` starts the tmux
session in the matching subdir **of the new worktree**, so Claude loads that subdir's
`CLAUDE.md` chain. Then set, and use for every path from here on:

- `wt` = `<main_wt>/.claude/worktrees/<KEY>` (verify it exists and matches the printed
  `Worktree:` line)
- `target` = `<wt>/<rel>` — the directory the work happens in

If `git wt new` fails, STOP: report its output and leave the tree alone.

6. **Stage the brief** in `<wt>/.claude/execute-plan/` (copies, not symlinks, so the brief
   can't drift):
   - `TICKET.md` — the fetched Jira content, or the key + URL if step 4 failed
   - `PLAN.md` — the plan file
   - `context/<basename>` — each context file (de-duplicate colliding basenames)
   - `PROMPT.md` — the kickoff brief from step 7

7. **Write `PROMPT.md`** covering, as plain markdown:
   - **Ticket** — key, URL, summary.
   - **Working directory** — the absolute `target`. All work happens there, inside the
     worktree on branch `worktree-<KEY>`. The original checkout is off limits. If the plan
     names paths from the original checkout, translate them into the worktree.
   - **Read first** — `TICKET.md`, `PLAN.md`, each `context/*` file, then the repo's own
     guidance: the `CLAUDE.md` chain from `target` up to the worktree root plus any
     `.claude/` rules that apply.
   - **Task** — execute the plan end to end. Follow it rather than re-planning; if a step
     is ambiguous or turns out to be wrong, state the assumption or the problem and keep
     going with the rest. Stay in the plan's scope.
   - **Verify** — use the repo's own scoped build/lint/test commands for the affected
     module only, as documented in its `CLAUDE.md`.
   - **Commit** — atomic commits per logical unit, repo commit conventions, no AI/Claude
     attribution. Do not push or open a PR unless asked.
   - **Do not commit `.claude/execute-plan/`** — it's scaffolding for this session.

8. **Launch Claude in the session.** Keep the sent line short — multi-line prompts through
   `send-keys` are quoting-fragile, so the brief lives in the file and the prompt just
   points at it:

```bash
tmux send-keys -t "=<KEY>" 'claude "Read <wt>/.claude/execute-plan/PROMPT.md and execute it."' Enter
```

Then check it took: `tmux capture-pane -p -t "=<KEY>" | tail -5`. If the pane doesn't show
Claude starting, report that instead of claiming success.

9. **Report** the ticket + URL, branch, worktree path, `target`, session name, and the
   staged files. Finish with how to get there: `tmux switch-client -t <KEY>` (inside tmux)
   or `tmux attach -t <KEY>`. Only when `--attach` was passed, run that switch yourself as
   the final action.
