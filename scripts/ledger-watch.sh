#!/usr/bin/env bash

set -euo pipefail

# Configuration
LEDGER_PATH="${LEDGER_PATH:-$HOME/Code/ledger}"
SYNC_SCRIPT="${SYNC_SCRIPT:-$HOME/Code/derpfiles/scripts/ledger-sync.sh}"
LOG_FILE="${WATCHER_LOG_FILE:-$HOME/Library/Logs/ledger-watch.log}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-180}"  # Default: 3 minutes

# PID file for debounce timer
TIMER_PID_FILE="/tmp/ledger-watch-timer.pid"

# Logging functions
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

# Rotate logs (keep last 5000 lines)
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

# Kill existing debounce timer if running
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

# Start new debounce timer
start_timer() {
    # Start background process that waits DEBOUNCE_SECONDS then calls sync script
    (
        sleep "$DEBOUNCE_SECONDS"
        log_info "Debounce timer expired, triggering sync"
        if "$SYNC_SCRIPT"; then
            log_info "Sync completed successfully"
        else
            log_error "Sync failed with exit code $?"
        fi
        rm -f "$TIMER_PID_FILE"
    ) &

    local timer_pid=$!
    echo "$timer_pid" > "$TIMER_PID_FILE"
    log_info "Started debounce timer (PID: $timer_pid, ${DEBOUNCE_SECONDS}s)"
}

# Handle file change event
handle_change() {
    local changed_file="$1"

    # Filter: only process .norg files
    if [[ ! "$changed_file" =~ \.norg$ ]]; then
        return
    fi

    log_info "File change detected: $changed_file"

    # Kill existing timer and start new one (debouncing)
    kill_timer
    start_timer
}

# Cleanup on exit
cleanup() {
    log_info "Watcher shutting down"
    kill_timer
    exit 0
}

trap cleanup SIGTERM SIGINT

# Main execution
main() {
    log_info "Starting ledger file watcher"
    log_info "Watching: $LEDGER_PATH"
    log_info "Debounce period: ${DEBOUNCE_SECONDS}s"
    log_info "Sync script: $SYNC_SCRIPT"

    rotate_logs

    # Check if ledger directory exists
    if [[ ! -d "$LEDGER_PATH" ]]; then
        log_error "Ledger directory not found: $LEDGER_PATH"
        exit 1
    fi

    # Check if sync script exists and is executable
    if [[ ! -x "$SYNC_SCRIPT" ]]; then
        log_error "Sync script not found or not executable: $SYNC_SCRIPT"
        exit 1
    fi

    # Check if fswatch is available
    if ! command -v fswatch &> /dev/null; then
        log_error "fswatch not found in PATH"
        exit 1
    fi

    log_info "Watcher ready, monitoring for changes..."

    # Use fswatch to monitor ledger directory
    # -r: recursive
    # -e: exclude pattern (exclude .git directory)
    # -l: latency (0.5 seconds between event batches)
    # --event Updated,Created: only watch for file updates and creation
    fswatch -r \
        -e '\.git/' \
        -l 0.5 \
        --event Updated \
        --event Created \
        "$LEDGER_PATH" | while read -r changed_file; do
        handle_change "$changed_file"
    done
}

main "$@"
