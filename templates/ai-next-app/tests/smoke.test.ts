import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { promptFiles, systemPrompt } from "../src/lib/ai/prompts";
import { getChatModel, getModelName } from "../src/lib/ai/provider";

function readJsonl(path: string) {
  return readFileSync(path, "utf8")
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => JSON.parse(line) as { id: string; prompt: string });
}

describe("starter smoke checks", () => {
  it("exposes prompt metadata", () => {
    expect(promptFiles).toEqual(["prompts/system.md"]);
    expect(systemPrompt).toContain("concise product-minded assistant");
  });

  it("reads the eval fixture", () => {
    const cases = readJsonl("evals/smoke.jsonl");
    expect(cases).toHaveLength(2);
    expect(cases[0]?.id).toBe("greeting");
  });

  it("computes the model name without calling the provider", () => {
    expect(getModelName()).toBe("gpt-4.1-mini");
    expect(typeof getChatModel).toBe("function");
  });
});
