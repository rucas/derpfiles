Investigate failing CI for the current PR/branch, reproduce locally, fix, and verify green.

`$ARGUMENTS` may carry a PR number, a CI build/run URL or id, or a path to a saved log.
All optional.

## Steps

1. **Resolve the failing checks.**
   - If `$ARGUMENTS` names a build/run/PR/log, use it.
   - Otherwise: current branch → `gh pr view --json number,headRefName` → `gh pr checks`
     to list every check and find the red one(s). `gh pr checks` is CI-agnostic — it shows
     check runs regardless of which system produced them.

2. **Pull the failure detail using whatever CI integration is available** — don't assume a
   specific provider:
   - If a CI MCP server is connected (e.g. Buildkite), use it directly (build → failed
     executions → logs/annotations) rather than fishing for tools.
   - GitHub Actions → `gh run view <id> --log-failed` (or `--log`).
   - Otherwise follow the check's details URL via `gh api` / `gh pr checks --json` and read
     annotations.
   - If the integration errors (e.g. expired auth), STOP and report — don't guess from
     partial data.

3. **Classify each failing step** and map it to local scope: a unit/component **test**, a
   **lint** violation, **spec/codegen drift**, or a repo **rules/policy** check. Identify the
   responsible module/task or file.

4. **Reproduce + fix locally.** Read the repo's `CLAUDE.md` / `.claude/rules/*` for the
   build, lint, test, and codegen commands. Run the **scoped** command for the affected
   module only — never the whole repo. Reproduce the failure, fix the root cause, and re-run.
   Parse test results with the project's helper (e.g. `parse_junit.py`) rather than reading
   raw report files by hand.

5. **Iterate** until each failing step passes locally.

6. **Report** the root cause and fix per failing step. Do not push unless asked.

## Notes
- Fix the cause, not the symptom — don't disable tests, loosen rules, or suppress lint to
  make CI green.
- A green local scoped run is the bar; a full remote re-run is the user's call.
