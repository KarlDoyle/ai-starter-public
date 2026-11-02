"use client";

import { type UIMessage, useChat } from "@ai-sdk/react";
import { type FormEvent, useState } from "react";

function textOf(message: UIMessage): string {
  return message.parts.map((part) => (part.type === "text" ? part.text : "")).join("");
}

export default function Page() {
  // v5+: useChat no longer owns input state or a submit handler — the app does.
  const { messages, sendMessage, status } = useChat();
  const [input, setInput] = useState("");
  const busy = status === "submitted" || status === "streaming";

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const text = input.trim();
    if (!text || busy) {
      return;
    }
    sendMessage({ text });
    setInput("");
  }

  return (
    <main className="shell">
      <section className="panel">
        <div className="eyebrow">ai-next-app</div>
        <h1>Clean starter for AI web apps</h1>
        <p className="lede">
          Next.js, the Vercel AI SDK, project-local dependencies, and a prompt-first structure.
        </p>

        <div className="chat" aria-live="polite">
          {messages.map((message) => (
            <article key={message.id} className={`message ${message.role}`}>
              <span className="role">{message.role}</span>
              {/* A message's text parts are one stream of text arriving in chunks, so they
                  render as a single paragraph. Rendering one <p> per part would need a key,
                  and the only thing to key on would be the array index — which reorders and
                  loses state mid-stream. */}
              <p>{textOf(message)}</p>
            </article>
          ))}
        </div>

        <form className="composer" onSubmit={onSubmit}>
          <label className="sr-only" htmlFor="message">
            Message
          </label>
          <textarea
            id="message"
            name="message"
            value={input}
            onChange={(event) => setInput(event.target.value)}
            placeholder="Ask for a draft, summary, plan, or structured output."
            rows={4}
          />
          <button type="submit" disabled={busy}>
            {busy ? "Sending..." : "Send"}
          </button>
        </form>
      </section>
    </main>
  );
}
