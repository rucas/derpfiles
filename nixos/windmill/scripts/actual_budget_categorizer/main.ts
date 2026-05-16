import * as api from "@actual-app/api";
import { mkdirSync } from "node:fs";

interface CategoryInfo {
  id: string;
  name: string;
  group: string;
}

interface Suggestion {
  transaction_id: string;
  payee: string;
  amount: number;
  suggested_category: string;
  category_id: string;
  confidence: string;
  applied: boolean;
}

interface CategorizationResult {
  success: boolean;
  message: string;
  total_uncategorized: number;
  categorized: number;
  skipped: number;
  details: Suggestion[];
}

const BATCH_SIZE = 10;

export async function main(
  actual_server_url: string = "http://localhost:5006",
  actual_password: string,
  budget_sync_id: string,
  ollama_url: string = "http://localhost:11434",
  ollama_model: string = "qwen2.5:7b",
  account_name: string = "",
  lookback_days: number = 90,
  dry_run: boolean = false,
): Promise<CategorizationResult> {
  const dataDir = "/tmp/actual-budget-categorizer/data";
  mkdirSync(dataDir, { recursive: true });

  try {
    await api.init({
      dataDir,
      serverURL: actual_server_url,
      password: actual_password,
    });
    await api.downloadBudget(budget_sync_id);

    const categoryGroups = await api.getCategoryGroups();
    const { categoryMap, promptText } = buildCategoryData(categoryGroups);

    if (categoryMap.size === 0) {
      return {
        success: false,
        message: "No categories found in Actual Budget",
        total_uncategorized: 0,
        categorized: 0,
        skipped: 0,
        details: [],
      };
    }

    const accounts = await api.getAccounts();
    const targetAccounts = account_name
      ? accounts.filter((a: any) => a.name === account_name)
      : accounts.filter((a: any) => !a.closed);

    if (targetAccounts.length === 0) {
      return {
        success: false,
        message: account_name
          ? `Account "${account_name}" not found`
          : "No open accounts found",
        total_uncategorized: 0,
        categorized: 0,
        skipped: 0,
        details: [],
      };
    }

    const payees = await api.getPayees();
    const payeeMap = new Map<string, string>();
    for (const p of payees) {
      payeeMap.set(p.id, p.name);
    }

    const today = new Date();
    const startDate = new Date(today);
    startDate.setDate(startDate.getDate() - lookback_days);
    const startStr = formatDate(startDate);
    const endStr = formatDate(today);

    const uncategorized: Array<{
      id: string;
      payee: string;
      amount: number;
      date: string;
    }> = [];

    for (const account of targetAccounts) {
      const transactions = await api.getTransactions(
        account.id,
        startStr,
        endStr,
      );

      for (const t of transactions) {
        if (t.category || t.is_parent || t.transfer_id) continue;

        const payeeName =
          (t as any).imported_payee ||
          payeeMap.get(t.payee ?? "") ||
          "Unknown";

        uncategorized.push({
          id: t.id,
          payee: payeeName,
          amount: t.amount,
          date: t.date,
        });
      }
    }

    if (uncategorized.length === 0) {
      return {
        success: true,
        message: "No uncategorized transactions found",
        total_uncategorized: 0,
        categorized: 0,
        skipped: 0,
        details: [],
      };
    }

    console.log(
      `Found ${uncategorized.length} uncategorized transactions across ${targetAccounts.length} account(s)`,
    );

    const allSuggestions: Suggestion[] = [];

    for (let i = 0; i < uncategorized.length; i += BATCH_SIZE) {
      const batch = uncategorized.slice(i, i + BATCH_SIZE);
      console.log(
        `Processing batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(uncategorized.length / BATCH_SIZE)}`,
      );

      const suggestions = await categorizeBatch(
        batch,
        promptText,
        categoryMap,
        ollama_url,
        ollama_model,
      );

      for (let j = 0; j < batch.length; j++) {
        const tx = batch[j];
        const suggestion = suggestions[j];

        if (!suggestion || !suggestion.category_id) {
          allSuggestions.push({
            transaction_id: tx.id,
            payee: tx.payee,
            amount: tx.amount,
            suggested_category: suggestion?.suggested_category ?? "unknown",
            category_id: "",
            confidence: "low",
            applied: false,
          });
          continue;
        }

        if (!dry_run) {
          await api.updateTransaction(tx.id, {
            category: suggestion.category_id,
            notes: `[auto-categorized: ${suggestion.confidence}]`,
          });
        }

        allSuggestions.push({
          ...suggestion,
          transaction_id: tx.id,
          payee: tx.payee,
          amount: tx.amount,
          applied: !dry_run,
        });
      }
    }

    if (!dry_run) {
      await api.sync();
    }

    const categorized = allSuggestions.filter((s) => s.category_id).length;
    const skipped = allSuggestions.length - categorized;

    return {
      success: true,
      message: dry_run
        ? `Dry run: ${categorized} categorizable, ${skipped} skipped out of ${uncategorized.length} transactions`
        : `Categorized ${categorized} transactions, skipped ${skipped}`,
      total_uncategorized: uncategorized.length,
      categorized,
      skipped,
      details: allSuggestions,
    };
  } finally {
    try {
      await api.shutdown();
    } catch {}
  }
}

function buildCategoryData(categoryGroups: any[]): {
  categoryMap: Map<string, CategoryInfo>;
  promptText: string;
} {
  const categoryMap = new Map<string, CategoryInfo>();
  const lines: string[] = [];

  for (const group of categoryGroups) {
    if (!group.categories?.length) continue;

    lines.push(`\n## ${group.name}`);

    for (const cat of group.categories) {
      if (cat.hidden) continue;
      const info: CategoryInfo = {
        id: cat.id,
        name: cat.name,
        group: group.name,
      };
      categoryMap.set(cat.name.toLowerCase(), info);
      lines.push(`- ${cat.name}`);
    }
  }

  return { categoryMap, promptText: lines.join("\n") };
}

async function categorizeBatch(
  batch: Array<{ id: string; payee: string; amount: number; date: string }>,
  categoryList: string,
  categoryMap: Map<string, CategoryInfo>,
  ollamaUrl: string,
  ollamaModel: string,
): Promise<
  Array<{
    suggested_category: string;
    category_id: string;
    confidence: string;
  } | null>
> {
  const systemPrompt = `You are a financial transaction categorizer. Assign each transaction to the most appropriate budget category from the list below.

Available categories (grouped):
${categoryList}

Respond with a JSON object containing a "results" array. Each element must have:
- "index": the transaction number (0-based)
- "category": the exact category name from the list above
- "confidence": "high", "medium", or "low"

If you cannot determine a category, set category to null and confidence to "low".

IMPORTANT: Only use category names exactly as listed above. Do not invent new categories.
Respond ONLY with the JSON object, no other text.`;

  const userMessage = batch
    .map((tx, i) => {
      const dollars = (Math.abs(tx.amount) / 100).toFixed(2);
      const sign = tx.amount < 0 ? "-" : "";
      return `${i}. Payee: "${tx.payee}", Amount: ${sign}$${dollars}, Date: ${tx.date}`;
    })
    .join("\n");

  try {
    const response = await fetch(`${ollamaUrl}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: ollamaModel,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: `Categorize these transactions:\n\n${userMessage}` },
        ],
        stream: false,
        format: "json",
        options: { temperature: 0.1 },
      }),
    });

    if (!response.ok) {
      console.error(`Ollama returned ${response.status}: ${await response.text()}`);
      return batch.map(() => null);
    }

    const data = await response.json();
    const content = data.message?.content ?? "";
    const parsed = JSON.parse(content);
    const results: Array<{ index: number; category: string | null; confidence: string }> =
      parsed.results ?? parsed;

    return batch.map((_, i) => {
      const result = results.find((r) => r.index === i);
      if (!result?.category) return null;

      const matched = findCategory(result.category, categoryMap);
      if (!matched) {
        console.log(`No category match for "${result.category}"`);
        return {
          suggested_category: result.category,
          category_id: "",
          confidence: result.confidence ?? "low",
        };
      }

      return {
        suggested_category: matched.name,
        category_id: matched.id,
        confidence: result.confidence ?? "medium",
      };
    });
  } catch (err) {
    console.error(`Ollama batch failed: ${err}`);
    return batch.map(() => null);
  }
}

function findCategory(
  name: string,
  categoryMap: Map<string, CategoryInfo>,
): CategoryInfo | null {
  const lower = name.toLowerCase().trim();

  const exact = categoryMap.get(lower);
  if (exact) return exact;

  for (const [key, value] of categoryMap) {
    if (key.includes(lower) || lower.includes(key)) {
      return value;
    }
  }

  return null;
}

function formatDate(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}
