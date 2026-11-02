# ai-next-app

Starter template for AI web apps, chat UIs, dashboards, and SaaS prototypes.

## Default Stack

- Node 24, pnpm 11 (pinned by `packageManager`; committed `pnpm-lock.yaml`)
- TypeScript 7
- Next.js 16 App Router (Turbopack) + React 19
- Tailwind 4, CSS-first — the theme lives in `src/app/globals.css`, no `tailwind.config`
- Vercel AI SDK
- Biome 2 — the only linter and formatter, no ESLint
- Vitest 5
- project-local dependencies
- structured prompts in `prompts/`
- smoke evals in `evals/`
- basic tests in `tests/`
- no auth, payment, or database by default

## Setup

```bash
corepack enable
pnpm install
cp .env.example .env.local
```

## Run

```bash
pnpm dev
```

## Validate

Run the full CI checks in this order. The pre-push hook runs typecheck and tests.

```bash
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

## Prompt And Eval Files

- `prompts/system.md`
- `evals/smoke.jsonl`

## Security

Do not commit real API keys, production credentials, private endpoints, or
personal context.

## License

This template's original files are MIT-licensed. Third-party dependencies retain
their own licenses; review them when extending the template.
