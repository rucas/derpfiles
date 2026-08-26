Hand a Jira ticket + plan off to a fresh Claude session running in its own worktree and tmux session.

This command **asks for its inputs** in three rounds — the files, then the repo, then where
in the repo to work — and waits for each answer before moving on. `$ARGUMENTS` is only a
head start: anything it already supplies (a Jira key, file paths, a directory) pre-fills
the matching question, which you then confirm rather than ask cold.

## Your job

You are the **launcher**, not the implementer. You collect the inputs, set up an isolated
worktree, stage a brief, start Claude in a tmux session, and report. Do **not** start
implementing the plan in this session, and never write outside the new worktree (the files
you're given are read-only inputs).

Ask with `AskUserQuestion` whenever you can offer real candidates (use its `Other` escape
for a free-form path); otherwise ask in plain text and stop for the answer. Never invent an
answer or push past an unanswered question.

## Steps

1. **Ask for the inputs** — Jira ticket, plan doc, and any other markdown/context files.
   - **Ticket** (required) — match `[A-Z][A-Z0-9_]+-[0-9]+` case-insensitively, accepting a
     bare key or an `atlassian.net/browse/<key>` URL; normalize to upper-case. If
     `$ARGUMENTS` already carries one, show it and ask only for confirmation.
   - **Plan doc** (required) — offer as options any `~/.claude/plans/*.md` mentioning the
     ticket key (`rg -l <KEY> ~/.claude/plans/*.md`), then the most recently modified plans
     (`ls -t ~/.claude/plans/*.md | head -3`), each labelled with its H1 and mtime. `Other`
     takes any path.
   - **Other markdown / context files** (optional) — ask, and offer as multi-select the
     `*.md` files sitting next to the plan doc plus anything named in `$ARGUMENTS`. Accept
     "none".
   - If a named file does not exist, say so and re-ask — never silently drop an input or
     substitute a different file.

2. **Ask which repo** the worktree should be created in.
   - Offer the repo containing `$PWD` (via `git -C . rev-parse --show-toplevel`) and any
     repo paths named in `$ARGUMENTS` or the plan doc; `Other` takes a path.
   - Normalize the answer to the repo's **main** worktree:
     `main_wt` = `git -C <answer> worktree list --porcelain | head -1 | awk '{print $2}'`.
     This is correct for a path at any depth, and when the answer is itself inside a
     worktree it points back at the real checkout rather than the worktree.
   - If the answer is not in a git repo, say so and re-ask.

3. **Ask where in the repo** the Claude session should run — the directory the work
   actually happens in.
   - Offer: the repo root; the subdir of `$PWD` if it sits under `main_wt`
     (`git -C . rev-parse --show-prefix`); and any module/service directory the plan doc
     points at. `Other` takes a path.
   - Store the answer as `rel`, **relative to `main_wt`** (strip a leading `main_wt/` if the
     user gave an absolute path; empty means the repo root).
   - Verify `<main_wt>/<rel>` exists; if not, say so and re-ask.

4. **Pre-flight — abort before creating anything.** Report and stop if any holds:
   - `tmux has-session -t "=<KEY>"` succeeds. A session already exists, possibly with a
     live Claude in it; **never send keys into it**. Suggest `tmux switch-client -t <KEY>`
     or `git wt kill <KEY>`.
   - `<main_wt>/.claude/worktrees/<KEY>` exists.
   - `git -C <main_wt> rev-parse --verify worktree-<KEY>` succeeds (branch already there).

5. **Fetch the ticket** with `jira_get_issue` on the key: summary, type, status, parent,
   description, acceptance criteria, URL. If the MCP errors (e.g. expired OAuth), do not
   invent content — carry on with just the key + browse URL and note in the brief that the
   new session must fetch it itself.

6. **Create the worktree + session.**

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

7. **Stage the brief** in `<wt>/.claude/execute-plan/` (copies, not symlinks, so the brief
   can't drift):
   - `TICKET.md` — the fetched Jira content, or the key + URL if step 5 failed
   - `PLAN.md` — the plan doc
   - `context/<basename>` — each extra file (de-duplicate colliding basenames)
   - `PROMPT.md` — the kickoff brief from step 8

8. **Write `PROMPT.md`** covering, as plain markdown:
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

9. **Launch Claude in the session.** Keep the sent line short — multi-line prompts through
   `send-keys` are quoting-fragile, so the brief lives in the file and the prompt just
   points at it:

```bash
tmux send-keys -t "=<KEY>" 'claude "Read <wt>/.claude/execute-plan/PROMPT.md and execute it."' Enter
```

Then check it took: `tmux capture-pane -p -t "=<KEY>" | tail -5`. If the pane doesn't show
Claude starting, report that instead of claiming success.

10. **Report** the ticket + URL, branch, worktree path, `target`, session name, and the
    staged files. Finish with how to get there: `tmux switch-client -t <KEY>` (inside tmux)
    or `tmux attach -t <KEY>`. Only when `--attach` was passed in `$ARGUMENTS`, run that
    switch yourself as the final action.
