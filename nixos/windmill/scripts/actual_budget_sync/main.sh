# TODO: Pre-build better-sqlite3 with Nix and switch to Deno to avoid runtime npm install
# TODO: Switch from session_token to password auth (requires ACTUAL_LOGIN_METHOD=password or allowing password login alongside OIDC)
server_url="$1"
session_token="$2"
budget_sync_id="$3"

CACHE_DIR="/tmp/actual-budget-sync"
DATA_DIR="$CACHE_DIR/data"
mkdir -p "$DATA_DIR"

if [ ! -d "$CACHE_DIR/node_modules/@actual-app/api" ]; then
  cd "$CACHE_DIR"
  npm init -y > /dev/null 2>&1
  npm install @actual-app/api > /dev/null 2>&1
fi

cat > "$CACHE_DIR/sync.mjs" << 'SCRIPT'
import * as api from "@actual-app/api";
const [serverURL, sessionToken, budgetSyncId] = process.argv.slice(2);
try {
  await api.init({ dataDir: "./data", serverURL, sessionToken });
  await api.downloadBudget(budgetSyncId);
  await api.runBankSync();
  await api.sync();
  console.log(JSON.stringify({ success: true, message: "Bank sync completed" }));
} finally {
  try { await api.shutdown(); } catch {}
}
SCRIPT

cd "$CACHE_DIR" && node sync.mjs "$server_url" "$session_token" "$budget_sync_id"
