import { main } from "./main.ts";

const result = await main(
  Deno.env.get("SYNCHRONY_USERNAME") ?? "",
  Deno.env.get("SYNCHRONY_PASSWORD") ?? "",
  Deno.env.get("ACTUAL_SERVER_URL") ?? "http://localhost:5006",
  Deno.env.get("ACTUAL_PASSWORD") ?? "",
  Deno.env.get("BUDGET_SYNC_ID") ?? "",
  Deno.env.get("ACCOUNT_NAME") ?? "Amazon Credit Card",
  true,
);

console.log(JSON.stringify(result, null, 2));
