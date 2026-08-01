import * as api from "@actual-app/api";

const [serverURL, password, budgetSyncId] = process.argv.slice(2);

try {
  await api.init({ dataDir: "./data", serverURL, password });
  await api.downloadBudget(budgetSyncId);
  await api.runBankSync();
  await api.sync();
  console.log(JSON.stringify({ success: true, message: "Bank sync completed" }));
} finally {
  try {
    await api.shutdown();
  } catch {}
}
