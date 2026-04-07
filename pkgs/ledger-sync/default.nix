{
  writeShellApplication,
  git,
  openssh,
  coreutils,
  ...
}:

writeShellApplication {
  name = "ledger-sync";

  runtimeInputs = [
    git
    openssh
    coreutils
  ];

  text = ''
    LEDGER_PATH="''${LEDGER_PATH:-$HOME/Code/ledger}"
    LOG_FILE="''${LOG_FILE:-$HOME/.local/state/ledger-sync/sync.log}"

    mkdir -p "$(dirname "$LOG_FILE")"

    log() {
        local level="$1"
        shift
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $*" >> "$LOG_FILE"
    }

    log_info() {
        log "INFO" "$@"
    }

    log_warn() {
        log "WARN" "$@"
    }

    log_error() {
        log "ERROR" "$@"
    }

    rotate_logs() {
        if [[ -f "$LOG_FILE" ]]; then
            local log_size
            log_size=$(wc -l < "$LOG_FILE")
            if [[ $log_size -gt 10000 ]]; then
                tail -n 5000 "$LOG_FILE" > "$LOG_FILE.tmp"
                mv "$LOG_FILE.tmp" "$LOG_FILE"
                log_info "Rotated log file (kept last 5000 lines)"
            fi
        fi
    }

    sync_ledger() {
        log_info "Starting ledger sync"

        if [[ ! -d "$LEDGER_PATH" ]]; then
            log_error "Ledger directory not found: $LEDGER_PATH"
            return 1
        fi

        cd "$LEDGER_PATH" || {
            log_error "Failed to change to ledger directory"
            return 1
        }

        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            log_error "Not a git repository: $LEDGER_PATH"
            return 1
        fi

        log_info "Pulling latest changes from remote"
        if ! git pull --rebase origin main 2>&1 | tee -a "$LOG_FILE"; then
            local pull_status=''${PIPESTATUS[0]}
            if git status | grep -q "rebase in progress"; then
                log_error "Merge conflict during pull. Aborting rebase. Manual intervention required."
                git rebase --abort 2>&1 | tee -a "$LOG_FILE"
                return 1
            elif git status | grep -q "Your branch is up to date"; then
                log_info "Pull completed successfully (already up to date)"
            else
                log_warn "Pull command failed but not a rebase conflict (exit code: $pull_status)"
            fi
        else
            log_info "Pull completed successfully"
        fi

        local has_changes=false

        if git diff --name-only | grep -q '\.norg$'; then
            has_changes=true
        fi

        if git diff --cached --name-only | grep -q '\.norg$'; then
            has_changes=true
        fi

        if git ls-files --others --exclude-standard | grep -q '\.norg$'; then
            has_changes=true
        fi

        if [[ "$has_changes" == "false" ]]; then
            log_info "No .norg file changes detected, skipping commit"
            return 0
        fi

        log_info "Found .norg file changes, staging files"

        if ! git add -- '*.norg' '*/*.norg' 2>&1 | tee -a "$LOG_FILE"; then
            log_error "Failed to stage .norg files"
            return 1
        fi

        if git diff --cached --quiet; then
            log_info "No changes to commit after staging"
            return 0
        fi

        local commit_msg
        commit_msg="~ $(date '+%m/%d/%Y') ~"
        log_info "Creating commit: $commit_msg"

        if ! git commit -m "$commit_msg" 2>&1 | tee -a "$LOG_FILE"; then
            log_error "Failed to create commit (pre-commit hook may have failed)"
            return 1
        fi

        log_info "Commit created successfully"

        log_info "Pushing to origin/main"
        if ! git push origin main 2>&1 | tee -a "$LOG_FILE"; then
            local push_status=$?
            if git status | grep -q "Your branch is ahead"; then
                log_warn "Push failed (network issue or rejected), local commit preserved for next sync"
                return 0
            else
                log_error "Push failed with unexpected status (exit code: $push_status)"
                return 1
            fi
        fi

        log_info "Push completed successfully"
        log_info "Ledger sync completed successfully"
        return 0
    }

    rotate_logs

    if sync_ledger; then
        exit 0
    else
        exit 1
    fi
  '';
}
