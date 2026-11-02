import { createOpenAI } from "@ai-sdk/openai";

function requiredEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new Error(`${name} is required for ai-next-app`);
  }
  return value;
}

export function getChatModel() {
  const apiKey = requiredEnv("OPENAI_API_KEY");
  const baseURL = process.env.OPENAI_BASE_URL?.trim();
  const model = process.env.OPENAI_MODEL?.trim() || "gpt-4.1-mini";
  const openai = createOpenAI({
    apiKey,
    baseURL: baseURL || undefined,
  });

  return openai(model);
}

export function getModelName() {
  return process.env.OPENAI_MODEL?.trim() || "gpt-4.1-mini";
}
