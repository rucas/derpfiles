---
description: Split the working tree into atomic git commits, one per logical unit of work.
argument-hint: "[grouping hint | confirm]"
---

Create one or more git commits from the current changes, broken into atomic logical units.

`$ARGUMENTS` is an optional hint about grouping or what to emphasize. If empty, infer everything from the diff.

## Steps

1. **Inspect the changes** in parallel:
   - `git status` to see staged vs unstaged files
   - `git diff --staged` (and `git diff` if nothing is staged)
   - `git log --author=rucas --pretty=format:"%s" -20` to match the established style

2. **Plan atomic commits**: Analyze the full diff and group files into logical units of work. Each
   group should be a self-contained change that could be reviewed independently. Good split signals:
   - Different features, fixes, or concerns (e.g. a dep bump vs a bug fix)
   - Config changes vs code changes when they're unrelated
   - Multiple unrelated files touched in the same session

   If everything is one coherent change, make a single commit — don't split for the sake of splitting.

3. **Present the plan**: Before committing, output a brief numbered list showing each proposed commit
   and which files it covers. Example:
   ```
   1. add garmin-express cask — homebrew.nix
   2. fix nix post-build hook — system.nix
   ```
   Then proceed immediately — do not wait for confirmation unless `$ARGUMENTS` says "confirm" or "ask".

4. **Execute each commit in order**:
   - `git add <files>` for only the files in that group
   - When two logical changes live in the same file, stage individual hunks with
     `git-surgeon` — see **Hunk-level staging** below — so each commit is a
     coherent, self-contained unit rather than lumping unrelated edits together
   - Commit with `git commit --no-verify`
   - Title conventions (apply to every commit):
     - 50 characters maximum — hard limit
     - Lowercase, concise, no trailing period
     - Describe what the change does
   - Write a body only when the change genuinely needs one (non-obvious rationale, multiple
     sub-changes within the group):
     - Separate from title with a blank line
     - `*` bullets, one per point, wrapped at 80 characters

5. **Confirm** by showing all new commits with `git log -<n> --stat` where n is the number of
   commits made.

## Hunk-level staging

`git add -p` and `git checkout -p` only answer to an interactive TTY prompt, so they are
not usable here. Use `git-surgeon`, which addresses hunks by a content-derived 7-char id:

```sh
git-surgeon hunks                      # list unstaged hunks: <id> <file> [fn] (+n -n)
git-surgeon hunks --file <path>        # narrow to one file
git-surgeon show <id>                  # full hunk diff, 1-based line numbers for --lines
git-surgeon stage <id> [<id>...]       # stage whole hunks
git-surgeon stage <id> --lines 5-30    # stage part of one hunk
git-surgeon unstage <id>               # back out a staging mistake
```

Then commit the staged result with `git commit --no-verify` as usual.

**Use it only for hunk selection.** `git-surgeon` also has `commit`, `split`, `fold`,
`amend`, `squash`, `reword`, `move` and `undo` subcommands — do not reach for them here.
Two reasons: this command's job is to build commits from the working tree, not to rewrite
history; and `git-surgeon commit` takes no `--no-verify`, so it would run the hooks this
repo's convention skips.

Ids are stable across line shifts but change when the hunk's own content changes, so
re-run `git-surgeon hunks` after each commit rather than reusing ids from an earlier
listing.

## Notes

- Prefer file-level splitting, but reach for hunk-level staging when two logical
  changes share a file and can be cleanly separated. Never leave a broken intermediate state — if
  the hunks are interdependent, keep them in one commit instead.
- Never add a `Co-Authored-By` trailer or any AI attribution.
- Pass `--no-verify` on every `git commit`.

## Example output (two-commit split)

```
Plan:
1. add garmin-express cask — modules/darwin/homebrew.nix
2. fix nix post-build hook — modules/darwin/system.nix

[commits...]
```
