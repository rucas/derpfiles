Create a git commit for the staged changes (or all changes if nothing is staged).

`$ARGUMENTS` is an optional hint about what to emphasize in the message. If empty, infer everything from the diff.

## Steps

1. **Inspect the changes** in parallel:
   - `git status` to see staged vs unstaged files
   - `git diff --staged` (and `git diff` if nothing is staged)
   - `git log --author=rucas --pretty=format:"%s" -20` to match the established style

2. **Stage if needed**: If nothing is staged, stage the relevant changes with `git add`. Do not stage unrelated files.

3. **Write the title** following rucas's conventions:
   - 50 characters maximum — this is a hard limit
   - Lowercase, concise, no trailing period
   - Describe what the change does (e.g. `fix nix warnings`, `add chronosphere mcp package`)
   - Scope a focused change when it reads naturally (e.g. `git wt new, spawn, ls commands`)

5. **Write a body only when the change genuinely needs one** (multiple distinct changes, non-obvious rationale):
   - Separate from the title with a blank line
   - Use `*` sub-list bullets, one per discrete change or point
   - Wrap each bullet at 80 characters; indent continuation lines to align under the text
   - Keep it terse; skip the body entirely for simple single-purpose commits

6. **Commit** with `git commit --no-verify` (use a HEREDOC or `-m` per line to preserve the body):
   - Pass `--no-verify` to bypass pre-commit hooks.
   - Never add a `Co-Authored-By` trailer or any AI attribution.

7. **Confirm** by showing the resulting commit with `git log -1 --stat`.

## Example

```
add commit command for claude

* infer title from the staged diff, capped at 50 characters
* support an optional body with `*` bullets wrapped at 80 characters
* commit with --no-verify; never append AI attribution
```
