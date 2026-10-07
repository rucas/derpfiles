---
name: execute-task
description: Hand work off to a fresh Claude session running in its own git worktree and tmux session — a Jira ticket plus a plan doc, or just a sentence of intent. Sets up the worktree, stages a brief, starts Claude, and reports how to get there; it never implements the work itself.
disable-model-invocation: true
allowed-tools: [Bash, Read, Write, AskUserQuestion, mcp__plugin_hm_jira__jira_get_issue, mcp__plugin_hm_jira__jira_get_transitions, mcp__plugin_hm_jira__jira_transition_issue]
---

# Execute Task

You are the **launcher**, not the implementer. Collect the inputs, create an isolated worktree,
stage a brief, start Claude in a tmux session, and report. Do **not** start the work in this
session, and never write outside the new worktree — the files you are given are read-only inputs.

## Two shapes of work, one flow

The handoff is the same either way; only how much context there is to stage differs.

- **Planned work** — a Jira ticket, usually with a plan doc and other markdown beside it. The new
  session gets the ticket, the plan and the context files, and is told to execute the plan.
- **A plain task** — a sentence or two of intent, no ticket and no plan. The new session gets the
  task verbatim and is told to ask rather than guess.

Decide the shape from the inputs, not by asking which mode you are in. A ticket key found in
`$ARGUMENTS` (or on a norg `jira:` line) means planned work; nothing but prose means a plain task.
Never invent a ticket or a plan to get into planned mode, and never discard one the user gave you.

Ask with `AskUserQuestion` whenever you can offer real candidates (its `Other` escape takes a
free-form path); otherwise ask in plain text and stop for the answer. Never invent an answer or
push past an unanswered question.

## Prerequisites

Check these first and bail with a clear message if either fails:

- `git wt` on PATH (`command -v git-wt`) — it does the worktree + session creation.
- `tmux` on PATH.

## Steps

### 1. Read `$ARGUMENTS`

`$ARGUMENTS` is a head start, not the whole input: anything it already supplies pre-fills the
matching question below, which you then confirm rather than ask cold. Look for

- a **Jira key** — `[A-Z][A-Z0-9_]+-[0-9]+` matched case-insensitively, as a bare key or an
  `atlassian.net/browse/<key>` URL; normalize to upper-case. If several appear, the **first** one
  owns the handoff.
- **file paths** — a plan doc, other markdown, a repo or directory path.
- **prose** — what is left is the task text.
- `--attach` — switch into the new session at the end instead of leaving it detached.

`$ARGUMENTS` may instead arrive as a **norg task block**: nxvm's `<LocalLeader>nx` sends the task
under the cursor verbatim, so the first line carries its `****` stars and `(-)` marker and the
continuation lines carry `jira:` / `pr:` / `tmux:` links. (An INBOX item is scheduled onto today's
TODO by the keymap first, so it arrives in the same shape.) Treat the stars and the marker as
framing, not as part of the task; the links are real context. A `jira:` line is where the ticket
comes from — a block carrying one is planned work.

With no arguments at all, ask in plain text for the task or the ticket and stop for the answer.

### 2. Ask for the remaining inputs

Skip any round whose answer is already settled, and skip the whole step for a plain task with no
files named.

- **Ticket** — if `$ARGUMENTS` carries a key, show it and ask only for confirmation. Do not ask for
  one when there is none; a task without a ticket is the normal plain-task case.
- **Plan doc** — ask once when there is a ticket but no plan path. Offer as options any
  `~/.claude/plans/*.md` mentioning the key (`rg -l <KEY> ~/.claude/plans/*.md`), then the most
  recently modified plans (`ls -t ~/.claude/plans/*.md | head -3`), each labelled with its H1 and
  mtime. `Other` takes any path, and "none" is a valid answer — a ticket with no plan still hands
  off, the new session just works from the ticket.
- **Other markdown / context files** (optional) — when there is a plan doc, ask, and offer as
  multi-select the `*.md` files sitting next to it plus anything named in `$ARGUMENTS`. Accept
  "none".

If a named file does not exist, say so and re-ask — never silently drop an input or substitute a
different file.

### 3. Ask which repo

Offer candidates with `AskUserQuestion` (`Other` takes a free-form path):

- the repo containing `$PWD` — `git -C . rev-parse --show-toplevel`, labelled as the current repo
- any repo path named in `$ARGUMENTS` or in the plan doc
- the other checkouts under `~/Code` —
  `fd -t d -d 2 --hidden '^\.git$' ~/Code -x dirname {}`

Normalize the answer to the repo's **main** worktree, so a path at any depth — or a path that is
itself inside a worktree — resolves back to the real checkout:

```bash
main_wt=$(git -C <answer> worktree list --porcelain | head -1 | awk '{print $2}')
```

If the answer is not in a git repo, say so and ask again.

### 4. Settle on `rel` — where in the repo the session runs

`rel` is the working directory **relative to `main_wt`**; empty means the repo root. It decides
which `CLAUDE.md` chain the new session loads, so it is worth getting right.

**With a plan doc, ask.** A plan routinely points at a module you are not currently sitting in.
Offer: the repo root; the subdir of `$PWD` when it sits under `main_wt`
(`git -C . rev-parse --show-prefix`); and any module/service directory the plan doc points at.
`Other` takes a path. Strip a leading `main_wt/` if the user answers with an absolute path, and
verify `<main_wt>/<rel>` exists — if not, say so and re-ask.

**Without one, infer it.** When the chosen repo is the one containing `$PWD`, take
`rel = git -C . rev-parse --show-prefix`; for any other repo there is no subdir to infer, so start
at its root. A one-line task belongs where you are standing — do not spend a prompt on it.

### 5. Settle on a name

The worktree directory, the branch (`worktree-<name>`) and the tmux session all share one name.

- **With a ticket**, the name is the key.
- **Without one**, derive a slug from the task text: lowercase, non-alphanumeric runs collapsed to
  `-`, trimmed, at most ~5 words / 40 characters, meaningful words only (`add retry logic to the
  webhook client` → `retry-webhook-client`). Slug from the **prose only** — a norg block's stars,
  `(-)` marker, `#tags` and link lines are framing. Show the slug and ask once whether to keep it
  or use another: one prompt, with the slug as the default option.

### 6. Pre-flight — abort before creating anything

Report and stop if any holds:

- `tmux has-session -t "=<name>"` succeeds. A session already exists, possibly with a live Claude
  in it; **never send keys into it**. Suggest `tmux switch-client -t <name>` or
  `git wt kill <name>`.
- `<main_wt>/.claude/worktrees/<name>` exists.
- `git -C <main_wt> rev-parse --verify worktree-<name>` succeeds — the branch is already there.

A collision means picking a different name, not reusing the existing one. For a ticket the name is
fixed, so a collision means the ticket is already in flight: say so and stop.

### 7. Fetch the ticket, and move it to In Progress

Only when there is one. `jira_get_issue` on the key: summary, type, status, parent, description,
acceptance criteria, URL. If the MCP errors (e.g. expired OAuth), do not invent content — carry on
with just the key + browse URL and note in the brief that the new session must fetch it itself.

Then put the ticket's status where the work now is. Handing off *is* starting, so a ticket that is
still sitting in a To Do-category status should not stay there.

- Only when the fetched status is in the **To Do** category (`Open`, `Prioritized`, `Backlog`, …).
  A ticket already `In Progress`, or further along (`Ready For Review`, `Resolved`, …), is left
  exactly as it is — never walk a status backwards.
- `jira_get_transitions` on the key, then `jira_transition_issue` to the `In Progress` one. Match
  it by **name**, not by a hard-coded id: the ids are per-workflow and this skill runs against more
  than one project. If no transition named `In Progress` is offered, skip the move rather than
  guessing at a neighbouring status.
- No transition comment. The handoff is not news the ticket's watchers need.
- Best-effort, exactly like the fetch: a failed transition never blocks the handoff. Note it in the
  final report and carry on — the worktree is the point, the status is bookkeeping.

Do not ask before moving it. It is a reversible, one-field change on a ticket the user just chose
to start, and a prompt per handoff costs more than it protects.

### 8. Create the worktree + session

```bash
git wt new <name> <main_wt>                   # add --cd <rel> when rel is non-empty
```

Always pass `<main_wt>` explicitly as the repo argument — it also keeps `git wt new` from mistaking
a ticket-shaped or directory-shaped name for the repo path. `--cd <rel>` starts the tmux session in
the matching subdir **of the new worktree**, so Claude loads that subdir's `CLAUDE.md` chain. Then
set, and use for every path from here on:

- `wt` = `<main_wt>/.claude/worktrees/<name>` — verify it exists and matches the printed
  `Worktree:` line
- `target` = `<wt>/<rel>` — the directory the work happens in

If `git wt new` fails, STOP: report its output and leave the tree alone.

### 9. Stage the brief

Everything goes in `<wt>/.claude/execute-task/`, as copies rather than symlinks so the brief cannot
drift:

- `TICKET.md` — the fetched Jira content, or the key + URL when step 7 failed. Omit with no ticket.
- `PLAN.md` — the plan doc. Omit when there is none.
- `context/<basename>` — each extra file, de-duplicating colliding basenames. Omit when there are
  none.
- `PROMPT.md` — the kickoff brief from step 10.

### 10. Write `PROMPT.md`

Plain markdown, covering:

- **Ticket** — key, URL, summary. Omit the section entirely when there is no ticket.
- **Working directory** — the absolute `target`. All work happens there, inside the worktree on
  branch `worktree-<name>`. The original checkout is off limits; translate any path the plan or the
  task names from the original checkout into the worktree.
- **Read first** — the staged files that exist (`TICKET.md`, `PLAN.md`, each `context/*`), then the
  repo's own guidance: the `CLAUDE.md` chain from `target` up to the worktree root plus any
  `.claude/` rules that apply.
- **Task** —
  - *With a plan:* execute it end to end. Follow it rather than re-planning; if a step is ambiguous
    or turns out to be wrong, state the assumption or the problem and keep going with the rest.
    Stay in the plan's scope.
  - *Without one:* the task text verbatim, as given. Do not expand it into a plan or add steps the
    user did not ask for.
- **Ask, don't guess** — the user is in this tmux session and will join to guide the work. When the
  task is ambiguous, when it turns out to need a decision, or when it is larger than it looked, say
  so and wait rather than picking a direction.
- **Verify** — use the repo's own scoped build/lint/test commands for the affected module only, as
  documented in its `CLAUDE.md`.
- **Commit** — atomic commits per logical unit, repo commit conventions, no AI/Claude attribution.
  Do not push or open a PR unless asked.
- **Do not commit `.claude/execute-task/`** — it is scaffolding for this session.

### 11. Launch Claude in the session

Keep the sent line short — multi-line prompts through `send-keys` are quoting-fragile, so the brief
lives in the file and the prompt just points at it:

```bash
tmux send-keys -t "=<name>" 'claude "Read <wt>/.claude/execute-task/PROMPT.md and execute it."' Enter
```

`git wt new` leaves a single shell pane in the fresh session, so targeting the session is safe
here. Check it took with `tmux capture-pane -p -t "=<name>" | tail -5`. If the pane does not show
Claude starting, report that instead of claiming success.

### 12. Report

The ticket + URL when there is one, otherwise the task; then the repo, the branch, the worktree
path, `target`, the session name, and the staged files. Say what step 7 did to the ticket's status
— moved to `In Progress`, left alone because it was already past To Do, or failed and why.
Finish with how to get there —
`tmux switch-client -t <name>` inside tmux, `tmux attach -t <name>` outside. Leave the session
detached; only when `--attach` was passed in `$ARGUMENTS`, run that switch yourself as the final
action.
