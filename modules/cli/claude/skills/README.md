# Claude Code skills

Each directory here is one skill: a `SKILL.md` with YAML frontmatter, wired in by
`../default.nix` and toggled per host with
`programs.claude-code-custom.skills.<name>.enable`, exactly as `../commands/` does.
All of them are opt-in.

A skill is the same `/<name>` invocation a slash command gets, plus frontmatter: a
written `description`, its own `allowed-tools`, and `disable-model-invocation`.

Picking a command instead does **not** keep something out of Claude's reach. Commands
are surfaced in the same model-invocable listing as skills; with no frontmatter, each
one just advertises its truncated first line as the description. So the choice is
about frontmatter, not reachability — and the way to make something explicit-only is
`disable-model-invocation: true`, not a different directory.

## Pick one

| Skill            | Use when                                        | Acts outward on its own |
| ---------------- | ----------------------------------------------- | ----------------------- |
| `/execute-task`  | Work is ready to hand to a fresh Claude session | No — local worktree only |

You must invoke it — it sets `disable-model-invocation: true`, so Claude cannot start
a handoff on its own. A worktree, a branch, a tmux session and a second Claude are
real artifacts to leave lying around, so the trigger stays in your hands.

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

## Adding a skill

1. Create `<name>/SKILL.md` in this directory, frontmatter first
2. Add the directory to `bundledSkills` in `../default.nix`
3. Add a `<name>.enable` option next to the others
4. Turn it on in the hosts that want it

`bundledSkills` maps whole directories, so a skill can grow `references/` beside its
`SKILL.md`. It also maps each entry explicitly, so this README is not shipped as a
skill. For one-offs that do not belong in the repo, use
`programs.claude-code-custom.skills.extra`.
