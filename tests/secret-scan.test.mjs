import { readFile, readdir, stat } from "node:fs/promises";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";
import assert from "node:assert/strict";

/**
 * Dogfood: the ai-starter *standard* secret-scan, applied to ai-starter itself.
 *
 * The repo whose job is enforcing quality must pass its own bar. This is the
 * `_standard/secret-scan.test.ts` scanner (same patterns, same skip list),
 * pointed at the WHOLE repo — including every `templates/*` copy and `_standard/`
 * itself — so a credential committed anywhere here fails the build too.
 *
 * Kept dependency-free on purpose (node:test, no vitest/node_modules at the
 * root) so `node --test` runs it from a bare clone. Deliberately pattern-based,
 * no entropy heuristics: cheap, deterministic, catches the shapes that leak.
 */
const REPO_ROOT = fileURLToPath(new URL("../", import.meta.url)).replace(/\/$/, "");

const SELF = "tests/secret-scan.test.mjs";

// Build/vendor/VCS dirs that aren't committed source — never scanned.
const SKIP_DIRS = new Set([
  ".git",
  "node_modules",
  ".venv",
  "__pycache__",
  ".pytest_cache",
  ".ruff_cache",
  ".mypy_cache",
  ".next",
  "dist",
  "build",
  "coverage",
]);

const TOKEN_PATTERNS = [
  { name: "anthropic api key", re: /\bsk-ant-[A-Za-z0-9-]{20,}\b/ },
  { name: "openai-style api key", re: /\bsk-[A-Za-z0-9]{20,}\b/ },
  { name: "github personal access token (classic)", re: /\bghp_[A-Za-z0-9]{30,}\b/ },
  { name: "github fine-grained token", re: /\bgithub_pat_[A-Za-z0-9_]{60,}\b/ },
  { name: "github oauth/server token", re: /\bgh[ous]_[A-Za-z0-9]{30,}\b/ },
  { name: "aws access key id", re: /\bAKIA[0-9A-Z]{16}\b/ },
  { name: "private key block", re: /-----BEGIN [A-Z ]*PRIVATE KEY-----/ },
];

const SKIP_SUFFIXES = [".lock", ".lockb"];
const SKIP_FILES = ["pnpm-lock.yaml", "package-lock.json", "yarn.lock"];

async function listScannableFiles() {
  const out = [];
  async function walk(dir) {
    let entries;
    try {
      entries = await readdir(dir);
    } catch {
      return;
    }
    for (const name of entries) {
      const full = join(dir, name);
      const stats = await stat(full);
      if (stats.isDirectory()) {
        if (SKIP_DIRS.has(name)) continue;
        await walk(full);
        continue;
      }
      const rel = relative(REPO_ROOT, full).replace(/\\/g, "/");
      if (rel === SELF) continue;
      if (SKIP_FILES.includes(name)) continue;
      if (SKIP_SUFFIXES.some((s) => rel.endsWith(s))) continue;
      out.push(full);
    }
  }
  await walk(REPO_ROOT);
  return out;
}

test("no real-looking tokens or private keys are present anywhere in ai-starter", async () => {
  const files = await listScannableFiles();
  const findings = [];
  for (const file of files) {
    const contents = await readFile(file, "utf8").catch(() => "");
    for (const { name, re } of TOKEN_PATTERNS) {
      const m = re.exec(contents);
      if (m) {
        findings.push({
          file: relative(REPO_ROOT, file),
          pattern: name,
          match: `${m[0].slice(0, 12)}…`,
        });
      }
    }
  }
  assert.deepEqual(findings, [], `possible secrets committed: ${JSON.stringify(findings)}`);
});
