# Claude Code skills

Each directory here is one skill: a `SKILL.md` with YAML frontmatter, optionally with
`references/` beside it, wired in by `../default.nix` and toggled per host with
`programs.claude-code-custom.skills.<name>.enable`, exactly as `../commands/` does.
All of them are opt-in.

## What actually separates a skill from a command

Less than it looks. Probed against Claude Code 2.1.289, a **command** accepts the same
frontmatter a skill does — `description`, `allowed-tools`, and `disable-model-invocation`
(which really does hide it from the model-invocable listing). `$ARGUMENTS` interpolates in
a `SKILL.md` body just as it does in a command. Commands and skills are surfaced in the
same listing, and a command with no frontmatter simply advertises its first physical line.

So the choice is **not** about reachability, and not about frontmatter either. The one
capability a command does not have:

> A skill is a **directory**, so it can carry `references/` — material that is read only
> at the step that needs it, instead of riding along in the body on every invocation.

That is the whole test. Something with a linear procedure and no conditional reference
material belongs in `../commands/`. Something with a long appendix — a style guide, a list
of converter quirks, a failure-handling policy — belongs here.

(`allowed-tools` parses in both, but does not restrict the toolset; it is a permission
grant, and a no-op under this repo's `defaultMode = "auto"` with `Bash(*)` allowed. Don't
add it expecting a sandbox.)

## Pick one

| Skill               | Use when                                        | Acts outward on its own |
| ------------------- | ----------------------------------------------- | ----------------------- |
| `/execute-task`     | Work is ready to hand to a fresh Claude session | No — local worktree only |
| `/address-review`   | Review comments to triage, not yet answered     | No — never posts/pushes |
| `/shepherd-pr`      | PR is stalled on mechanics, not judgement       | **Yes** — pushes, marks ready |
| `/plan-to-jira`     | Plan is written and needs a ticket              | **Yes** — creates issue |

`/execute-task`, `/shepherd-pr` and `/plan-to-jira` set `disable-model-invocation: true`,
so you must invoke them. Each leaves something real behind — a worktree and a second
Claude, a pushed branch and a PR marked ready, a Jira issue — so the trigger stays in your
hands. `/address-review` stops at the working tree, so it is model-invocable.

### `/execute-task`

Launches a fresh Claude session on a piece of work, in its own worktree and tmux
session. It covers both shapes of handoff and picks between them from the inputs:

- **a Jira ticket + plan doc** — fetches the ticket, stages the plan and any context
  files, and tells the new session to execute the plan
- **a plain task** — a sentence of intent, no ticket and no plan; stages the task
  verbatim and tells the new session to ask rather than guess

1. Reads `$ARGUMENTS` for a Jira key, file paths and prose — including a norg task
   block sent by nxvm's `<LocalLeader>nx`, whose `jira:` line supplies the ticket
2. Asks for whatever is missing — plan doc, context files, repo, and (with a plan)
   where in the repo to work
3. Pre-flight checks, aborting before creating anything
4. Creates the worktree (`git wt new`) and stages the brief under
   `<worktree>/.claude/execute-task/`
5. Starts Claude in tmux and reports how to get there

It is the launcher, not the implementer: it never does the work in your current
session, never writes outside the new worktree, and never pushes or opens a PR
unless asked. Needs `git wt` and `tmux`; the Jira half degrades to the bare key and
a browse URL when the MCP is unauthed.

### `/address-review`

Triages review feedback without answering it.

1. Fetches inline threads, review summaries, and PR comments (skips resolved/outdated)
2. Gives each open concern a disposition: **valid**, **partial**, **discussion/invalid**, **wontfix**, tied to file:line
3. Applies only the clearly-valid low-risk fixes in the working tree
4. Commits via the `commit` skill — one thread, one commit
5. Drafts a reply per thread for you to review

**Hard default: never posts a comment, submits a review, or pushes.** Local commits
are expected; going outward needs an explicit yes.

`references/reply-style.md` holds the reply rules, read at the drafting step. They used to
live inline and defer to the `i-have-adhd` plugin's `SKILL.md`, which coupled this skill to
an unrelated option — they are self-contained now.

### `/shepherd-pr`

The orchestrator — use it when you want the whole PR moved, not one problem fixed.
Delegates to `/fix-ci`, `/address-review`, `/resolve-conflicts`, `/commit`, so
`skills.shepherd-pr.enable` pulls all four in via `mkDefault`.

1. Un-stales the branch (`gh pr update-branch`); on conflict, merges base locally and runs `/resolve-conflicts`
2. Waits on checks (`gh pr checks --watch`), ignoring human gates — approvals, CODEOWNERS, CLA, manual environments
3. Hands real failures to `/fix-ci`, authorizing it to commit and push, then loops back to the wait
4. **Draft** → `gh pr ready`. **Under review** → one commit per actionable comment, then reply/resolve each thread

Runs as long as your CI does.

**Automatic:** branch updates, conflict resolution, `/fix-ci` commits and pushes.
**Gated:** pushing review-fix commits (once), then every reply/resolve (per thread).

Merges to clear conflicts, never rebases — a rebase would need
`git push --force-with-lease`, which the `Bash(git push --force*)` deny rule blocks.
`references/failure-handling.md` holds the conflict-materialization procedure and the stop
conditions (same check twice, 3 attempts, second conflict, rebase required).

### `/plan-to-jira`

Turns a plan file into a ticket, full plan as the description.

1. Resolves the plan — argument, else newest `~/.claude/plans/*.md`
2. Resolves the parent: explicit key > git branch > repo path > ask
3. **Always confirms the project prefix before creating** — the plan's project may not match your current branch
4. Conforms the description to `references/jira-markup.md` and creates the issue

Stops rather than creating an orphan if the parent 404s or the MCP is unauthed.

`references/jira-markup.md` is the list of ways the Jira MCP's Markdown→wiki converter
breaks (fences under list items, `**bold**`, bare `*` in globs and `/* */` comments, prose
punctuation in code comments) and how to avoid each.

Once the ticket exists, `/execute-task` takes it and the plan to a fresh session.

## Adding a skill

1. Create `<name>/SKILL.md` in this directory, frontmatter first
2. Add the directory to `bundledSkills` in `../default.nix`
3. Add a `<name>.enable` option next to the others
4. Turn it on in the hosts that want it

Put the long appendix in `<name>/references/` and point at it from the step that needs it
— that is the reason to be here rather than in `../commands/`.

`bundledSkills` maps whole directories, so a skill can grow `references/` beside its
`SKILL.md`. It also maps each entry explicitly, so this README is not shipped as a
skill. For one-offs that do not belong in the repo, use
`programs.claude-code-custom.skills.extra`.
