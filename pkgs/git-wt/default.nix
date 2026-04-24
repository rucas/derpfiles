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
    _elapsed() {
      local t0=$1 t1=$2
      local ms=$(( t1 - t0 ))
      echo "''${ms}ms"
    }

    clean() {
      dry_run=1
      verbose=0
      for arg in "$@"; do
        [ "$arg" = "--execute" ] && dry_run=0
        [ "$arg" = "--verbose" ] && verbose=1
      done

      _log() { [ "$verbose" -eq 1 ] && echo "  ⏱  $1" >&2; }

      t_start=$((EPOCHREALTIME * 1000))
      t0=$t_start

      main_branch="master"
      if ! git rev-parse --verify "$main_branch" >/dev/null 2>&1; then
        main_branch="main"
        if ! git rev-parse --verify "$main_branch" >/dev/null 2>&1; then
          echo "Error: neither 'master' nor 'main' branch found"
          exit 1
        fi
      fi

      main_wt="$(git worktree list --porcelain | head -1 | awk '{print $2}')"

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

      t1=$((EPOCHREALTIME * 1000)); _log "list worktrees: $(_elapsed $t0 $t1)"; t0=$t1

      if [ "''${#worktrees[@]}" -eq 0 ]; then
        echo "No worktrees found."
        return
      fi

      tmpdir="$(mktemp -d)"
      trap 'rm -rf "$tmpdir"' RETURN

      api_branches=()
      for wt in "''${worktrees[@]}"; do
        read -r _ branch_ref <<< "$wt"
        api_branches+=("''${branch_ref#refs/heads/}")
      done

      repo_nwo="$(git remote get-url origin | sed -E 's#.*github\.com[:/]##; s#\.git$##')"

      t1=$((EPOCHREALTIME * 1000)); _log "parse remote: $(_elapsed $t0 $t1)"; t0=$t1

      if [ "''${#api_branches[@]}" -gt 0 ]; then

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

        t1=$((EPOCHREALTIME * 1000)); _log "graphql api: $(_elapsed $t0 $t1)"; t0=$t1

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

        printf "%s%-''${max_title}s  worktree ✓  %s  branch ✓\n" "$prefix" "$title" "$tmux_col"
      done

      if [ "$dry_run" -eq 0 ]; then
        trash="$(mktemp -d)"
        for entry in "''${entries[@]}"; do
          IFS='|' read -r wt_path _ _ <<< "$entry"
          session="$(basename "$wt_path")"
          tmux kill-session -t "$session" 2>/dev/null || true
          mv "$wt_path" "$trash/" 2>/dev/null || rm -rf "$wt_path"
        done

        t1=$((EPOCHREALTIME * 1000)); _log "move worktrees: $(_elapsed $t0 $t1)"; t0=$t1

        git worktree prune

        t1=$((EPOCHREALTIME * 1000)); _log "worktree prune: $(_elapsed $t0 $t1)"; t0=$t1

        for entry in "''${entries[@]}"; do
          IFS='|' read -r _ branch_ref _ <<< "$entry"
          git branch -D "''${branch_ref#refs/heads/}" 2>/dev/null || true
        done

        t1=$((EPOCHREALTIME * 1000)); _log "delete branches: $(_elapsed $t0 $t1)"; t0=$t1

        rm -rf "$trash" &
        disown
      fi

      t_end=$((EPOCHREALTIME * 1000)); _log "total: $(_elapsed $t_start $t_end)"

      if [ "$dry_run" -eq 1 ]; then
        echo ""
        echo "Run 'git wt clean --execute' to apply."
      fi
    }

    help() {
      echo "Usage: git wt <subcommand>"
      echo ""
      echo "Subcommands:"
      echo "    clean [--execute] [--verbose]"
      echo "                        Remove worktrees with branches merged into master"
      echo "                        Dry-run by default; pass --execute to apply"
      echo "                        --verbose shows timing for each phase"
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
