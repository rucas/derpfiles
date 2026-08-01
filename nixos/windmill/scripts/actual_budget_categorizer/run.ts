import { main } from "./main.ts";

const result = await main(
  process.env.ACTUAL_SERVER_URL ?? "http://localhost:5006",
  process.env.ACTUAL_PASSWORD ?? "",
  process.env.BUDGET_SYNC_ID ?? "",
  process.env.OLLAMA_URL ?? "http://localhost:11434",
  process.env.OLLAMA_MODEL ?? "qwen2.5:7b",
  process.env.ACCOUNT_NAME ?? "",
  Number(process.env.LOOKBACK_DAYS ?? "90"),
  process.env.DRY_RUN === "true",
);

console.log(JSON.stringify(result));
