{
  writeShellApplication,
  git,
  gh,
  gawk,
  tmux,
  ...
}:

writeShellApplication {
  name = "git-wt";

  runtimeInputs = [
    git
    gh
    gawk
    tmux
  ];

  text = ''
    clean() {
      dry_run=1
      for arg in "$@"; do
        [ "$arg" = "--execute" ] && dry_run=0
      done

      main_branch="master"
      if ! git rev-parse --verify "$main_branch" >/dev/null 2>&1; then
        main_branch="main"
        if ! git rev-parse --verify "$main_branch" >/dev/null 2>&1; then
          echo "Error: neither 'master' nor 'main' branch found"
          exit 1
        fi
      fi

      main_wt="$(git worktree list --porcelain | head -1 | awk '{print $2}')"

      local_merged="$(git branch --merged "$main_branch" | sed 's/^[* ]*//')"

      worktrees=()
      while read -r wt_path branch_ref; do
        worktrees+=("$wt_path $branch_ref")
      done < <(
        git worktree list --porcelain | \
          awk -v main="$main_wt" '
            /^worktree /{path=$2}
            /^branch /{
              branch=$2
              if (path != main && branch != "refs/heads/master" && branch != "refs/heads/main")
                print path, branch
            }
          '
      )

      if [ "''${#worktrees[@]}" -eq 0 ]; then
        echo "No worktrees found."
        return
      fi

      tmpdir="$(mktemp -d)"
      trap 'rm -rf "$tmpdir"' RETURN

      api_branches=()
      for wt in "''${worktrees[@]}"; do
        read -r _ branch_ref <<< "$wt"
        branch="''${branch_ref#refs/heads/}"
        if echo "$local_merged" | grep -Fxq "$branch"; then
          echo "(merged)" > "$tmpdir/$branch"
        else
          api_branches+=("$branch")
        fi
      done

      if [ "''${#api_branches[@]}" -gt 0 ]; then
        repo_nwo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"

        query="{"
        for i in "''${!api_branches[@]}"; do
          branch="''${api_branches[$i]}"
          safe_branch="''${branch//\\/\\\\}"
          safe_branch="''${safe_branch//\"/\\\"}"
          query+=" b''${i}: search(query: \"repo:''${repo_nwo} is:pr is:merged head:''${safe_branch}\", type: ISSUE, first: 1) { nodes { ... on PullRequest { url } } }"
        done
        query+=" }"

        result="$(gh api graphql -f query="$query" --jq '
          [.data | to_entries[] | select(.value.nodes | length > 0) |
           {key: (.key | ltrimstr("b")), value: .value.nodes[0].url}] |
          .[] | "\(.key)\t\(.value)"
        ' 2>/dev/null)" || result=""

        while IFS=$'\t' read -r idx url; do
          [ -z "$idx" ] && continue
          branch="''${api_branches[$idx]}"
          echo "$url" > "$tmpdir/$branch"
        done <<< "$result"
      fi

      entries=()
      for wt in "''${worktrees[@]}"; do
        read -r wt_path branch_ref <<< "$wt"
        branch="''${branch_ref#refs/heads/}"
        pr_url="$(cat "$tmpdir/$branch" 2>/dev/null)" || true
        if [ -n "$pr_url" ]; then
          entries+=("$wt_path|$branch_ref|$pr_url")
        fi
      done

      if [ "''${#entries[@]}" -eq 0 ]; then
        echo "No merged worktrees found."
        return
      fi

      max_title=0
      for entry in "''${entries[@]}"; do
        IFS='|' read -r wt_path _ pr_url <<< "$entry"
        session="$(basename "$wt_path")"
        title="$session  $pr_url"
        len=''${#title}
        if [ "$len" -gt "$max_title" ]; then max_title=$len; fi
      done

      prefix=""
      if [ "$dry_run" -eq 1 ]; then prefix="[dry-run] "; fi

      for entry in "''${entries[@]}"; do
        IFS='|' read -r wt_path branch_ref pr_url <<< "$entry"
        branch="''${branch_ref#refs/heads/}"
        session="$(basename "$wt_path")"
        title="$session  $pr_url"
        has_tmux=0
        tmux has-session -t "$session" 2>/dev/null && has_tmux=1

        tmux_col="      "; if [ "$has_tmux" -eq 1 ]; then tmux_col="tmux ✓"; fi

        if [ "$dry_run" -eq 1 ]; then
          printf "%s%-''${max_title}s  worktree ✓  %s  branch ✓\n" "$prefix" "$title" "$tmux_col"
        else
          if [ "$has_tmux" -eq 1 ]; then
            tmux kill-session -t "$session"
          fi
          git worktree remove --force "$wt_path" 2>/dev/null || rm -rf "$wt_path"
          if ! git branch -d "$branch" 2>/dev/null; then
            git branch -D "$branch"
          fi
          printf "%-''${max_title}s  worktree ✓  %s  branch ✓\n" "$title" "$tmux_col"
        fi
      done

      if [ "$dry_run" -eq 0 ]; then
        git worktree prune
      fi

      if [ "$dry_run" -eq 1 ]; then
        echo ""
        echo "Run 'git wt clean --execute' to apply."
      fi
    }

    help() {
      echo "Usage: git wt <subcommand>"
      echo ""
      echo "Subcommands:"
      echo "    clean [--execute]   Remove worktrees with branches merged into master"
      echo "                        Dry-run by default; pass --execute to apply"
    }

    subcommand="''${1:-}"
    case "$subcommand" in
      ""|"-h"|"--help")
        help
        ;;
      *)
        shift
        "$subcommand" "$@"
        ;;
    esac
  '';
}
