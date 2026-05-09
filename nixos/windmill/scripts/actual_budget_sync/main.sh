server_url="$1"
password="$2"
budget_sync_id="$3"

CACHE_DIR="/tmp/actual-budget-sync"
DATA_DIR="$CACHE_DIR/data"
mkdir -p "$DATA_DIR"

if [ ! -d "$CACHE_DIR/node_modules/@actual-app/api" ]; then
  cd "$CACHE_DIR" || exit
  npm init -y > /dev/null 2>&1
  npm install @actual-app/api > /dev/null 2>&1
fi

cat > "$CACHE_DIR/sync.mjs" << 'SCRIPT'
import * as api from "@actual-app/api";
const [serverURL, password, budgetSyncId] = process.argv.slice(2);
try {
  await api.init({ dataDir: "./data", serverURL, password });
  await api.downloadBudget(budgetSyncId);
  await api.runBankSync();
  await api.sync();
  console.log(JSON.stringify({ success: true, message: "Bank sync completed" }));
} finally {
  try { await api.shutdown(); } catch {}
}
SCRIPT

cd "$CACHE_DIR" && node sync.mjs "$server_url" "$password" "$budget_sync_id"
