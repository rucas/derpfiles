{
  writeShellApplication,
  git,
  gh,
  gawk,
  tmux,
  jq,
  ...
}:

writeShellApplication {
  name = "git-wt";

  runtimeInputs = [
    git
    gh
    gawk
    tmux
    jq
  ];

  text = ''
        _millis() { local e=$EPOCHREALTIME; echo $(( ''${e/./} / 1000 )); }

        _elapsed() {
          local t0=$1 t1=$2
          local ms=$(( t1 - t0 ))
          echo "''${ms}ms"
        }

        _main_branch() {
          local branch="master"
          if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
            branch="main"
            if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
              echo "Error: neither 'master' nor 'main' branch found" >&2
              exit 1
            fi
          fi
          echo "$branch"
        }

        _main_wt() {
          git worktree list --porcelain | head -1 | awk '{print $2}'
        }

        _session_name() {
          local name
          name="$(basename "$1")"
          name="''${name#worktree_}"
          name="''${name#worktree-}"
          echo "$name"
        }

        _worktrees() {
          local main_wt
          main_wt="$(_main_wt)"
          git worktree list --porcelain | \
            awk -v main="$main_wt" '
              /^worktree /{path=$2; branch=""}
              /^branch /{branch=$2}
              /^detached/{branch="(detached)"}
              /^$/{
                if (path != "" && path != main && branch != "" && branch != "refs/heads/master" && branch != "refs/heads/main")
                  print path, branch
                path=""; branch=""
              }
              END{
                if (path != "" && path != main && branch != "" && branch != "refs/heads/master" && branch != "refs/heads/main")
                  print path, branch
              }
            '
        }

        _claude_status() {
          local wt_path="$1"
          local sessions_dir="$HOME/.claude/sessions"
          [ -d "$sessions_dir" ] || return
          for session_file in "$sessions_dir"/*.json; do
            [ -f "$session_file" ] || continue
            local pid cwd status
            read -r pid cwd status < <(jq -r '[.pid, .cwd, .status] | @tsv' "$session_file")
            case "$cwd" in
              "''${wt_path}"/*|"''${wt_path}") ;;
              *) continue ;;
            esac
            kill -0 "$pid" 2>/dev/null || continue
            case "$status" in
              busy)    printf '\033[1;33m[BUSY]\033[0m' ;;
              idle)    printf '\033[1;32m[IDLE]\033[0m' ;;
              waiting) printf '\033[1;31m[WAITING]\033[0m' ;;
              *)       printf '[?]' ;;
            esac
            return
          done
        }

        ls() {
          local main_wt
          main_wt="$(_main_wt)"

          local all_wts=()
          while read -r wt_path branch_ref; do
            all_wts+=("$wt_path $branch_ref")
          done < <(
            git worktree list --porcelain | \
              awk '
                /^worktree /{path=$2; branch=""}
                /^branch /{branch=$2}
                /^detached/{branch="(detached)"}
                /^$/{if (path != "" && branch != "") print path, branch; path=""; branch=""}
                END{if (path != "" && branch != "") print path, branch}
              '
          )

          if [ "''${#all_wts[@]}" -eq 0 ]; then
            echo "No worktrees found."
            return
          fi

          local max_session=0 max_branch=0 max_claude=0
          local -a claude_statuses=()
          for wt in "''${all_wts[@]}"; do
            read -r wt_path branch_ref <<< "$wt"
            local session branch claude_status
            session="$(_session_name "$wt_path")"
            branch="''${branch_ref#refs/heads/}"
            branch="''${branch#worktree_}"
            branch="''${branch#worktree-}"
            claude_status="$(_claude_status "$wt_path")" || true
            claude_statuses+=("$claude_status")
            [ "''${#session}" -gt "$max_session" ] && max_session=''${#session}
            [ "''${#branch}" -gt "$max_branch" ] && max_branch=''${#branch}
            [ "''${#claude_status}" -gt "$max_claude" ] && max_claude=''${#claude_status}
          done

          _claude_sort_key() {
            case "$1" in
              *WAITING*) echo 0 ;;
              *BUSY*)    echo 1 ;;
              *IDLE*)    echo 2 ;;
              *)         echo 3 ;;
            esac
          }

          local dim=$'\033[2m' reset=$'\033[0m'
          if [ "$max_claude" -gt 0 ]; then
            printf "  ''${dim}%-''${max_session}s  %-''${max_branch}s  %-4s  %s''${reset}\n" "NAME" "BRANCH" "TMUX" "CLAUDE"
          else
            printf "  ''${dim}%-''${max_session}s  %-''${max_branch}s  %s''${reset}\n" "NAME" "BRANCH" "TMUX"
          fi

          local idx=0
          local lines=()
          for wt in "''${all_wts[@]}"; do
            read -r wt_path branch_ref <<< "$wt"
            local session branch marker tmux_col claude_col sort_key
            session="$(_session_name "$wt_path")"
            branch="''${branch_ref#refs/heads/}"
            branch="''${branch#worktree_}"
            branch="''${branch#worktree-}"
            claude_col="''${claude_statuses[$idx]}"
            sort_key="$(_claude_sort_key "$claude_col")"

            marker="  "
            [ "$wt_path" = "$main_wt" ] && marker="* "

            tmux_col="    "
            if [ "$wt_path" != "$main_wt" ]; then
              tmux has-session -t "=$session" 2>/dev/null && tmux_col="✓   "
            fi

            local line
            if [ "$max_claude" -gt 0 ]; then
              line="$(printf "%s%-''${max_session}s  %-''${max_branch}s  %s  %s" "$marker" "$session" "$branch" "$tmux_col" "$claude_col")"
            else
              line="$(printf "%s%-''${max_session}s  %-''${max_branch}s  %s" "$marker" "$session" "$branch" "$tmux_col")"
            fi
            lines+=("$sort_key $line")

            (( idx++ )) || true
          done

          printf '%s\n' "''${lines[@]}" | sort -t ' ' -k1,1n | cut -d ' ' -f2-
        }

        new() {
          if [ $# -eq 0 ]; then
            echo "Usage: git wt new <branch>... [repo-path]"
            exit 1
          fi

          local args=("$@")
          local repo=""
          local names=()

          local last="''${args[-1]}"
          if [ -d "$last" ]; then
            repo="$last"
            names=("''${args[@]:0:$((''${#args[@]}-1))}")
          else
            names=("''${args[@]}")
          fi

          if [ "''${#names[@]}" -eq 0 ]; then
            echo "Usage: git wt new <branch>... [repo-path]"
            exit 1
          fi

          local main_wt
          if [ -n "$repo" ]; then
            main_wt="$(git -C "$repo" worktree list --porcelain | head -1 | awk '{print $2}')"
          else
            main_wt="$(_main_wt)"
          fi

          mkdir -p "$main_wt/.claude/worktrees"

          for name in "''${names[@]}"; do
            local branch="$name"
            if [[ "$branch" != worktree-* ]]; then
              branch="worktree-$name"
            fi

            local wt_path="$main_wt/.claude/worktrees/$name"
            git -C "$main_wt" worktree add -b "$branch" "$wt_path"

            local session
            session="$(_session_name "$wt_path")"
            tmux new-session -d -s "$session" -c "$wt_path"
            printf "Worktree: %s\n" "$wt_path"
            printf "Session:  %s\n" "$session"
            echo ""
          done
        }

        spawn() {
          local worktrees=()
          while read -r wt_path branch_ref; do
            worktrees+=("$wt_path $branch_ref")
          done < <(_worktrees)

          if [ "''${#worktrees[@]}" -eq 0 ]; then
            echo "No worktrees to spawn sessions for."
            return
          fi

          local created=0 skipped=0
          for wt in "''${worktrees[@]}"; do
            read -r wt_path _ <<< "$wt"
            local session
            session="$(_session_name "$wt_path")"

            if tmux has-session -t "=$session" 2>/dev/null; then
              printf "  skip  %s (session exists)\n" "$session"
              (( skipped++ )) || true
            else
              tmux new-session -d -s "$session" -c "$wt_path"
              printf "  new   %s\n" "$session"
              (( created++ )) || true
            fi
          done

          echo ""
          echo "Created $created session(s), skipped $skipped."
        }

        sync() {
          local mode="merge"
          local use_ai=0
          local patterns=()
          for arg in "$@"; do
            if [ "$arg" = "--rebase" ]; then
              mode="rebase"
            elif [ "$arg" = "--ai" ]; then
              use_ai=1
            else
              patterns+=("$arg")
            fi
          done

          if [ "''${#patterns[@]}" -eq 0 ]; then
            local cwd
            cwd="$(git rev-parse --show-toplevel)"
            patterns+=("$(_session_name "$cwd")")
          fi

          local branch
          branch="$(_main_branch)"
          git fetch --quiet origin "$branch"

          local worktrees=()
          while read -r wt_path branch_ref; do
            worktrees+=("$wt_path $branch_ref")
          done < <(_worktrees)

          if [ "''${#worktrees[@]}" -eq 0 ]; then
            echo "No worktrees found."
            return
          fi

          for wt in "''${worktrees[@]}"; do
            read -r wt_path _ <<< "$wt"
            local session
            session="$(_session_name "$wt_path")"

            local matched=0
            for pat in "''${patterns[@]}"; do
              pat_re="^''${pat//\*/.*}$"
              if [[ "$session" =~ $pat_re ]]; then matched=1; break; fi
            done
            [ "$matched" -eq 0 ] && continue

            echo "Syncing $session..."
            local sync_failed=0
            if [ "$mode" = "rebase" ]; then
              git -C "$wt_path" rebase "origin/$branch" > /dev/null 2>&1 || sync_failed=1
            else
              git -C "$wt_path" merge --quiet "origin/$branch" 2>/dev/null || sync_failed=1
            fi

            if [ "$sync_failed" -eq 1 ] && [ "$use_ai" -eq 1 ]; then
              echo "Merge conflict in $session — launching claude in tmux session..."

              if ! tmux has-session -t "=$session" 2>/dev/null; then
                tmux new-session -d -s "$session" -c "$wt_path"
              fi

              # The resolve-conflicts procedure is baked in at build time (single source of
              # truth: modules/cli/claude/commands/resolve-conflicts.md), so --ai always has
              # it regardless of whether the /resolve-conflicts slash command is enabled.
              tmux send-keys -t "$session" "claude --append-system-prompt-file '${./../../modules/cli/claude/commands/resolve-conflicts.md}' 'Resolve the merge conflicts'" Enter
            elif [ "$sync_failed" -eq 1 ]; then
              echo "Merge conflict in $session — resolve manually or re-run with --ai"
            fi
          done
        }

        clean() {
          dry_run=1
          verbose=0
          for arg in "$@"; do
            [ "$arg" = "--execute" ] && dry_run=0
            [ "$arg" = "--verbose" ] && verbose=1
          done

          _log() { [ "$verbose" -eq 1 ] && echo "  ⏱  $1" >&2 || true; }

          t_start=$(_millis)
          t0=$t_start

          _main_branch >/dev/null

          worktrees=()
          while read -r wt_path branch_ref; do
            worktrees+=("$wt_path $branch_ref")
          done < <(_worktrees)

          t1=$(_millis); _log "list worktrees: $(_elapsed "$t0" "$t1")"; t0=$t1

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

          t1=$(_millis); _log "parse remote: $(_elapsed "$t0" "$t1")"; t0=$t1

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

            t1=$(_millis); _log "graphql api: $(_elapsed "$t0" "$t1")"; t0=$t1

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
            session="$(_session_name "$wt_path")"
            title="$session  $pr_url"
            len=''${#title}
            if [ "$len" -gt "$max_title" ]; then max_title=$len; fi
          done

          prefix=""
          if [ "$dry_run" -eq 1 ]; then prefix="[dry-run] "; fi

          for entry in "''${entries[@]}"; do
            IFS='|' read -r wt_path branch_ref pr_url <<< "$entry"
            branch="''${branch_ref#refs/heads/}"
            session="$(_session_name "$wt_path")"
            title="$session  $pr_url"
            has_tmux=0
            tmux has-session -t "=$session" 2>/dev/null && has_tmux=1

            tmux_col="      "; if [ "$has_tmux" -eq 1 ]; then tmux_col="tmux ✓"; fi

            printf "%s%-''${max_title}s  worktree ✓  %s  branch ✓\n" "$prefix" "$title" "$tmux_col"
          done

          if [ "$dry_run" -eq 0 ]; then
            trash="$(mktemp -d)"
            for entry in "''${entries[@]}"; do
              IFS='|' read -r wt_path _ _ <<< "$entry"
              session="$(_session_name "$wt_path")"
              tmux kill-session -t "=$session" 2>/dev/null || true
              mv "$wt_path" "$trash/" 2>/dev/null || rm -rf "$wt_path"
            done

            t1=$(_millis); _log "move worktrees: $(_elapsed "$t0" "$t1")"; t0=$t1

            git worktree prune

            t1=$(_millis); _log "worktree prune: $(_elapsed "$t0" "$t1")"; t0=$t1

            for entry in "''${entries[@]}"; do
              IFS='|' read -r _ branch_ref _ <<< "$entry"
              git branch -D "''${branch_ref#refs/heads/}" 2>/dev/null || true
            done

            t1=$(_millis); _log "delete branches: $(_elapsed "$t0" "$t1")"; t0=$t1

            rm -rf "$trash" &
            disown
          fi

          t_end=$(_millis); _log "total: $(_elapsed "$t_start" "$t_end")"

          if [ "$dry_run" -eq 1 ]; then
            echo ""
            echo "Run 'git wt clean --execute' to apply."
          fi
        }

        help() {
          echo "Usage: git wt <subcommand>"
          echo ""
          echo "Subcommands:"
          echo "    new <branch>... [repo]  Create worktree(s) + tmux session(s) in <repo>/.claude/worktrees/"
          echo "    ls                  List all worktrees with branch, Claude, and tmux status"
          echo "    spawn               Create tmux sessions for worktrees missing one"
          echo "    sync [--rebase] [--ai] [pattern...]"
          echo "                        Fetch main branch and merge (or rebase) into worktrees"
          echo "                        Defaults to current worktree; pass globs to match others"
          echo "                        --ai launches claude in tmux to resolve merge conflicts"
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
