import { test } from "node:test";
import assert from "node:assert/strict";

import {
  DIMENSIONS,
  buildLogLine,
  buildPrompt,
  callOllama,
  formatReport,
  isDaemonReachable,
  parseArgs,
  parseVerdict,
} from "../scripts/review.mjs";

/**
 * Deterministic tests for the standing reviewer runner. No Ollama, no network,
 * no clock: the model boundary is a fake `fetchImpl`, and timestamps are passed
 * in explicitly — so these exercise the real parse/build/transport logic, not a
 * mock of it, and would fail if that logic broke.
 */

test("parseArgs: defaults and overrides", () => {
  const d = parseArgs([]);
  assert.equal(d.base, "main");
  assert.equal(d.rubric, "docs/review-rubric.md");
  assert.equal(d.noLog, false);

  const o = parseArgs(["--base", "develop", "--spec", "s.md", "--no-log", "--model", "m"]);
  assert.equal(o.base, "develop");
  assert.equal(o.spec, "s.md");
  assert.equal(o.noLog, true);
  assert.equal(o.model, "m");

  assert.throws(() => parseArgs(["--bogus"]), /unknown argument/);
});

test("buildPrompt: embeds rubric, diff, and every dimension; notes missing spec", () => {
  const p = buildPrompt({ rubric: "RUBRIC-BODY", diff: "DIFF-BODY" });
  assert.match(p, /RUBRIC-BODY/);
  assert.match(p, /DIFF-BODY/);
  assert.match(p, /none provided/);
  for (const dim of DIMENSIONS) assert.ok(p.includes(dim), `prompt mentions ${dim}`);

  const withSpec = buildPrompt({ rubric: "R", diff: "D", spec: "ACCEPTANCE-X" });
  assert.match(withSpec, /ACCEPTANCE-X/);
  assert.doesNotMatch(withSpec, /none provided/);
});

test("parseVerdict: reads ACCEPT, scores, reasons", () => {
  const text = [
    "SCORES:",
    "claims_vs_reality: 5",
    "tests_real: 4/5",
    "security: 5",
    "no_secrets: 5",
    "spec_adherence: 5",
    "honest_docs: 4",
    "VERDICT: ACCEPT",
    "REASONS:",
    "- watch the edge case in foo.ts",
  ].join("\n");
  const r = parseVerdict(text);
  assert.equal(r.verdict, "ACCEPT");
  assert.equal(r.scores.tests_real, 4);
  assert.equal(r.scores.claims_vs_reality, 5);
  assert.equal(r.overall, 4.67);
  assert.deepEqual(r.reasons, ["watch the edge case in foo.ts"]);
});

test("parseVerdict: fails closed to REJECT when verdict is unclear", () => {
  const r = parseVerdict("the model rambled and never said the magic word");
  assert.equal(r.verdict, "REJECT");
  assert.equal(r.overall, null);
  assert.deepEqual(r.scores, {});
});

test("parseVerdict: clamps out-of-range scores to 0..5", () => {
  const r = parseVerdict("security: 9\nVERDICT: REJECT");
  assert.equal(r.scores.security, 5);
});

test("buildLogLine: deterministic given an explicit timestamp", () => {
  const line = buildLogLine({
    timestamp: "2026-06-29T00:00:00.000Z",
    branch: "feat/standing-reviewer",
    model: "qwen2.5:3b-instruct",
    verdict: "REJECT",
    overall: 3.5,
    scores: { security: 4 },
  });
  assert.ok(line.endsWith("\n"));
  const parsed = JSON.parse(line);
  assert.equal(parsed.ts, "2026-06-29T00:00:00.000Z");
  assert.equal(parsed.branch, "feat/standing-reviewer");
  assert.equal(parsed.verdict, "REJECT");
  assert.equal(parsed.score, 3.5);
  assert.deepEqual(parsed.dimensions, { security: 4 });
});

test("formatReport: shows every dimension and the verdict", () => {
  const out = formatReport({
    verdict: "ACCEPT",
    scores: { security: 5 },
    overall: 5,
    reasons: ["all good"],
  });
  assert.match(out, /VERDICT: ACCEPT/);
  for (const dim of DIMENSIONS) assert.ok(out.includes(dim));
});

test("isDaemonReachable: true on ok, false on throw (graceful degrade)", async () => {
  const okFetch = async () => ({ ok: true });
  const downFetch = async () => {
    throw new Error("ECONNREFUSED");
  };
  assert.equal(await isDaemonReachable("http://x", okFetch), true);
  assert.equal(await isDaemonReachable("http://x", downFetch), false);
});

test("callOllama: posts to /api/generate and returns .response", async () => {
  let captured;
  const fakeFetch = async (url, init) => {
    captured = { url, body: JSON.parse(init.body) };
    return { ok: true, json: async () => ({ response: "MODEL-OUTPUT" }) };
  };
  const out = await callOllama({
    url: "http://127.0.0.1:11434",
    model: "test-model",
    system: "sys",
    prompt: "hi",
    fetchImpl: fakeFetch,
  });
  assert.equal(out, "MODEL-OUTPUT");
  assert.match(captured.url, /\/api\/generate$/);
  assert.equal(captured.body.model, "test-model");
  assert.equal(captured.body.stream, false);
});

test("callOllama: throws on non-ok and on body error", async () => {
  await assert.rejects(
    callOllama({
      model: "m",
      prompt: "p",
      fetchImpl: async () => ({ ok: false, status: 500, text: async () => "boom" }),
    }),
    /Ollama returned 500/,
  );
  await assert.rejects(
    callOllama({
      model: "m",
      prompt: "p",
      fetchImpl: async () => ({ ok: true, json: async () => ({ error: "no model" }) }),
    }),
    /Ollama error: no model/,
  );
});
