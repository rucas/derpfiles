{
  writeShellApplication,
  lib,
  ledger-sync,
  coreutils,
  fswatch ? null,
  inotify-tools ? null,
  ...
}:

assert fswatch != null || inotify-tools != null;

writeShellApplication {
  name = "ledger-watch";

  runtimeInputs = [
    ledger-sync
    coreutils
  ]
  ++ lib.optional (fswatch != null) fswatch
  ++ lib.optional (inotify-tools != null) inotify-tools;

  text = ''
    LEDGER_PATH="''${LEDGER_PATH:-$HOME/Code/ledger}"
    LOG_FILE="''${WATCHER_LOG_FILE:-$HOME/.local/state/ledger-sync/watch.log}"
    DEBOUNCE_SECONDS="''${DEBOUNCE_SECONDS:-180}"

    TIMER_PID_FILE="/tmp/ledger-watch-timer.pid"

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
                log_info "Rotated watcher log file (kept last 5000 lines)"
            fi
        fi
    }

    kill_timer() {
        if [[ -f "$TIMER_PID_FILE" ]]; then
            local timer_pid
            timer_pid=$(cat "$TIMER_PID_FILE")
            if kill -0 "$timer_pid" 2>/dev/null; then
                kill "$timer_pid" 2>/dev/null || true
                log_info "Killed existing debounce timer (PID: $timer_pid)"
            fi
            rm -f "$TIMER_PID_FILE"
        fi
    }

    start_timer() {
        (
            sleep "$DEBOUNCE_SECONDS"
            log_info "Debounce timer expired, triggering sync"
            if ledger-sync; then
                log_info "Sync completed successfully"
            else
                log_error "Sync failed with exit code $?"
            fi
            rm -f "$TIMER_PID_FILE"
        ) &

        local timer_pid=$!
        echo "$timer_pid" > "$TIMER_PID_FILE"
        log_info "Started debounce timer (PID: $timer_pid, ''${DEBOUNCE_SECONDS}s)"
    }

    handle_change() {
        local changed_file="$1"

        if [[ ! "$changed_file" =~ \.norg$ ]]; then
            return
        fi

        log_info "File change detected: $changed_file"

        kill_timer
        start_timer
    }

    cleanup() {
        log_info "Watcher shutting down"
        kill_timer
        exit 0
    }

    trap cleanup SIGTERM SIGINT

    log_info "Starting ledger file watcher"
    log_info "Watching: $LEDGER_PATH"
    log_info "Debounce period: ''${DEBOUNCE_SECONDS}s"

    rotate_logs

    if [[ ! -d "$LEDGER_PATH" ]]; then
        log_error "Ledger directory not found: $LEDGER_PATH"
        exit 1
    fi

    log_info "Watcher ready, monitoring for changes..."

    if command -v fswatch &> /dev/null; then
        fswatch -r \
            -e '\.git/' \
            -l 0.5 \
            --event Updated \
            --event Created \
            "$LEDGER_PATH" | while read -r changed_file; do
            handle_change "$changed_file"
        done
    elif command -v inotifywait &> /dev/null; then
        inotifywait -m -r \
            -e modify,create \
            --format '%w%f' \
            --exclude '\.git/' \
            "$LEDGER_PATH" | while read -r changed_file; do
            handle_change "$changed_file"
        done
    else
        log_error "No file watcher found (need fswatch or inotifywait)"
        exit 1
    fi
  '';
}
