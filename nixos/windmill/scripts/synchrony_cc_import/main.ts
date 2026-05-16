import { chromium, type Page, type Response } from "npm:playwright";
import * as api from "npm:@actual-app/api";
import { createHash } from "node:crypto";
import { mkdirSync, readdirSync } from "node:fs";

interface Transaction {
  date: string;
  payee_name: string;
  amount: number;
  imported_id: string;
}

export async function main(
  synchrony_username: string,
  synchrony_password: string,
  actual_server_url: string = "http://localhost:5006",
  actual_password: string = "",
  budget_sync_id: string = "",
  account_name: string = "Amazon Credit Card",
  dry_run: boolean = false,
): Promise<{
  success: boolean;
  message: string;
  added?: number;
  updated?: number;
  transactions?: Transaction[];
}> {
  const dataDir = "/tmp/synchrony-cc-import/data";
  mkdirSync(dataDir, { recursive: true });

  const transactions = await downloadTransactionsFromSynchrony(
    synchrony_username,
    synchrony_password,
  );

  if (dry_run) {
    return {
      success: true,
      message: `Dry run: found ${transactions.length} transactions`,
      transactions,
    };
  }

  if (transactions.length === 0) {
    return { success: true, message: "No transactions found to import" };
  }

  try {
    await api.init({
      dataDir,
      serverURL: actual_server_url,
      password: actual_password,
    });
    await api.downloadBudget(budget_sync_id);

    const accounts = await api.getAccounts();
    let account = accounts.find((a: any) => a.name === account_name);

    if (!account) {
      const id = await api.createAccount(
        { name: account_name, type: "credit" },
        0,
      );
      account = { id, name: account_name };
    }

    const { added, updated } = await api.importTransactions(
      account.id,
      transactions,
    );
    await api.sync();

    return {
      success: true,
      message: `Imported ${added} new, updated ${updated} transactions`,
      added,
      updated,
    };
  } finally {
    try {
      await api.shutdown();
    } catch {}
  }
}

function findChromiumExecutable(): string | undefined {
  const browsersPath = Deno.env.get("PLAYWRIGHT_BROWSERS_PATH");
  if (!browsersPath) return undefined;
  const entries = readdirSync(browsersPath);
  const chromiumDir = entries.find(
    (e) => e.startsWith("chromium-") && !e.includes("headless"),
  );
  if (!chromiumDir) return undefined;
  return `${browsersPath}/${chromiumDir}/chrome-linux64/chrome`;
}

const STEALTH_SCRIPT = `
  Object.defineProperty(navigator, 'webdriver', { get: () => false });

  Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
  Object.defineProperty(navigator, 'language', { get: () => 'en-US' });

  Object.defineProperty(navigator, 'plugins', {
    get: () => {
      const plugins = [
        { name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
        { name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai', description: '' },
        { name: 'Native Client', filename: 'internal-nacl-plugin', description: '' },
      ];
      plugins.length = 3;
      return plugins;
    },
  });

  if (!window.chrome) window.chrome = {};
  if (!window.chrome.runtime) window.chrome.runtime = { connect: () => {}, sendMessage: () => {} };

  const originalQuery = window.navigator.permissions?.query?.bind(window.navigator.permissions);
  if (originalQuery) {
    window.navigator.permissions.query = (params) =>
      params.name === 'notifications'
        ? Promise.resolve({ state: Notification.permission })
        : originalQuery(params);
  }

  const getParameter = WebGLRenderingContext.prototype.getParameter;
  WebGLRenderingContext.prototype.getParameter = function (param) {
    if (param === 37445) return 'Google Inc. (NVIDIA)';
    if (param === 37446) return 'ANGLE (NVIDIA, NVIDIA GeForce GTX 1650 Direct3D11 vs_5_0 ps_5_0, D3D11)';
    return getParameter.call(this, param);
  };
`;

async function downloadTransactionsFromSynchrony(
  username: string,
  password: string,
): Promise<Transaction[]> {
  const executablePath = findChromiumExecutable();
  const baseDir = Deno.env.get("XDG_DATA_HOME")
    ?? (Deno.env.get("HOME") ? `${Deno.env.get("HOME")}/.local/share` : "/tmp");
  const profileDir = `${baseDir}/synchrony-cc-import/browser-profile`;
  mkdirSync(profileDir, { recursive: true });
  console.log(`Using chromium at: ${executablePath ?? "default"}`);

  const context = await chromium.launchPersistentContext(profileDir, {
    headless: true,
    executablePath,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-blink-features=AutomationControlled",
    ],
    userAgent:
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    viewport: { width: 1920, height: 1080 },
    locale: "en-US",
    timezoneId: "America/New_York",
    colorScheme: "light",
  });

  try {
    await context.addInitScript(STEALTH_SCRIPT);
    const page = context.pages()[0] ?? await context.newPage();
    await login(page, username, password);

    const transactions = await scrapeActivity(page);
    console.log(
      `Scraped ${transactions.length} transactions from activity page`,
    );
    return transactions;
  } finally {
    await context.close();
  }
}

function randomDelay(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function humanType(page: Page, selector: string, text: string) {
  const locator = page.locator(selector);
  await locator.click();
  await page.waitForTimeout(randomDelay(200, 500));
  for (const char of text) {
    await locator.pressSequentially(char, { delay: randomDelay(50, 150) });
  }
}

async function login(page: Page, username: string, password: string) {
  const response = await page.goto("https://amazon.syf.com", {
    timeout: 90000,
    waitUntil: "commit",
  });
  console.log(
    `Initial navigation: status=${response?.status()}, url=${page.url()}`,
  );
  await page.waitForTimeout(randomDelay(8000, 12000));
  console.log(`After wait: url=${page.url()}`);
  await screenshot(page, "login-page");

  await page.mouse.move(randomDelay(300, 600), randomDelay(200, 400));
  await page.waitForTimeout(randomDelay(500, 1500));

  await humanType(page, '[data-test="login-userid"]', username);
  await page.waitForTimeout(randomDelay(800, 2000));

  await humanType(page, '[data-test="login-password"]', password);
  await page.waitForTimeout(randomDelay(500, 1200));
  await screenshot(page, "pre-submit");
  await page.mouse.move(randomDelay(400, 700), randomDelay(500, 700));
  await page.waitForTimeout(randomDelay(300, 800));
  await page.getByRole("button", { name: /log in|sign in|secure login|submit/i }).click();
  await page.waitForTimeout(randomDelay(8000, 12000));
  console.log(`Post-login URL: ${page.url()}`);
  await screenshot(page, "post-login");

  const pageText = await page.textContent("body");
  if (
    pageText &&
    /verify your identity|security code|one.time/i.test(pageText)
  ) {
    throw new Error("2FA challenge detected — cannot proceed in headless mode");
  }
}

async function scrapeActivity(page: Page): Promise<Transaction[]> {
  const apiResponses: { url: string; data: unknown }[] = [];
  page.on("response", async (resp: Response) => {
    const url = resp.url();
    const contentType = resp.headers()["content-type"] ?? "";
    if (resp.status() === 200 && contentType.includes("application/json")) {
      try {
        const data = await resp.json();
        apiResponses.push({ url, data });
      } catch {}
    }
  });

  await page.getByRole("link", { name: "Activity" }).click();
  await page.waitForTimeout(8000);
  console.log(`Activity page URL: ${page.url()}`);
  await screenshot(page, "activity-page");

  console.log(`Intercepted ${apiResponses.length} JSON API responses`);
  for (const { url, data } of apiResponses) {
    console.log(`API: ${url}`);
    console.log(`Shape: ${JSON.stringify(summarizeShape(data))}`);
  }

  const transactions = extractTransactionsFromApi(apiResponses);
  if (transactions.length > 0) {
    return transactions;
  }

  console.log("No transactions from API responses, trying DOM scrape...");
  return scrapeTransactionsFromDom(page);
}

function summarizeShape(obj: unknown, depth = 0): unknown {
  if (depth > 3) return "...";
  if (Array.isArray(obj)) {
    return obj.length > 0 ? [summarizeShape(obj[0], depth + 1)] : [];
  }
  if (obj && typeof obj === "object") {
    const result: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
      result[key] = summarizeShape(value, depth + 1);
    }
    return result;
  }
  return typeof obj;
}

function extractTransactionsFromApi(
  responses: { url: string; data: unknown }[],
): Transaction[] {
  for (const { data } of responses) {
    const arrays = findTransactionArrays(data);
    for (const arr of arrays) {
      const transactions = tryParseTransactionArray(arr);
      if (transactions.length > 0) return transactions;
    }
  }
  return [];
}

function findTransactionArrays(obj: unknown, depth = 0): unknown[][] {
  const results: unknown[][] = [];
  if (depth > 5) return results;
  if (Array.isArray(obj) && obj.length > 0 && typeof obj[0] === "object") {
    results.push(obj);
  }
  if (obj && typeof obj === "object") {
    for (const value of Object.values(obj as Record<string, unknown>)) {
      results.push(...findTransactionArrays(value, depth + 1));
    }
  }
  return results;
}

function tryParseTransactionArray(arr: unknown[]): Transaction[] {
  const transactions: Transaction[] = [];
  for (const item of arr) {
    if (!item || typeof item !== "object") continue;
    const rec = item as Record<string, unknown>;

    const dateVal = findField(rec, [
      "date",
      "transactionDate",
      "transDate",
      "postDate",
      "postingDate",
    ]);
    const descVal = findField(rec, [
      "description",
      "merchantName",
      "merchant",
      "payee",
      "transactionDescription",
    ]);
    const amountVal = findField(rec, [
      "amount",
      "transactionAmount",
      "transAmount",
    ]);

    if (!dateVal || amountVal === undefined) continue;

    const date = parseDate(String(dateVal));
    const description = descVal ? String(descVal) : "Amazon Synchrony";
    const raw =
      typeof amountVal === "number"
        ? amountVal
        : parseFloat(String(amountVal).replace(/[,$]/g, ""));
    if (isNaN(raw)) continue;
    const cents = Math.round(raw * 100);

    transactions.push({
      date,
      payee_name: description,
      amount: cents,
      imported_id: makeImportedId(date, description, cents),
    });
  }
  return transactions;
}

function findField(
  obj: Record<string, unknown>,
  candidates: string[],
): unknown {
  for (const key of candidates) {
    const lower = key.toLowerCase();
    for (const [k, v] of Object.entries(obj)) {
      if (k.toLowerCase() === lower) return v;
    }
  }
  return undefined;
}

async function scrapeTransactionsFromDom(page: Page): Promise<Transaction[]> {
  const bodyText = await page.locator("body").innerText();
  console.log(
    `Activity page text (first 1000 chars): ${bodyText.slice(0, 1000)}`,
  );

  const rows = await page
    .locator(
      "[class*='transaction'], [class*='activity'], [data-testid*='transaction'], tr",
    )
    .evaluateAll((els) => els.map((el) => el.textContent?.trim() ?? ""));
  console.log(`Found ${rows.length} potential transaction rows`);
  for (const row of rows.slice(0, 5)) {
    console.log(`Row: ${row.slice(0, 200)}`);
  }

  return [];
}

function parseDate(dateStr: string): string {
  const parts = dateStr.split("/");
  if (parts.length !== 3) return dateStr;
  const [month, day, year] = parts;
  const fullYear = year.length === 2 ? `20${year}` : year;
  return `${fullYear}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
}

function makeImportedId(
  date: string,
  description: string,
  amount: number,
): string {
  const hash = createHash("sha256")
    .update(`${date}|${description}|${amount}`)
    .digest("hex")
    .slice(0, 12);
  return `synchrony-${hash}`;
}

async function screenshot(page: Page, name: string) {
  try {
    await page.screenshot({
      path: `/tmp/synchrony-cc-import/${name}.png`,
      fullPage: true,
    });
  } catch {}
}
