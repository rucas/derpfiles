server_url="$1"
password="$2"
budget_sync_id="$3"

CACHE_DIR="/tmp/actual-budget-sync"
mkdir -p "$CACHE_DIR/data"

cd "$CACHE_DIR" && node "$SYNC_APP/sync.mjs" "$server_url" "$password" "$budget_sync_id"
