import { convertToModelMessages, streamText, type UIMessage } from "ai";
import type { NextRequest } from "next/server";
import { systemPrompt } from "@/lib/ai/prompts";
import { getChatModel } from "@/lib/ai/provider";

type Body = {
  messages?: UIMessage[];
};

export async function POST(request: NextRequest) {
  const body = (await request.json()) as Body;
  const result = streamText({
    model: getChatModel(),
    system: systemPrompt,
    messages: await convertToModelMessages(body.messages ?? []),
  });

  return result.toUIMessageStreamResponse();
}
