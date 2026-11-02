# CLAUDE.md — ai-next-app

Next.js + Vercel AI SDK starter. Boring and reusable on purpose.

## Conventions
- TypeScript, ES modules, `strict` on. No `any` (biome enforces `noExplicitAny`).
- Format + lint with **biome** (`pnpm lint`, autofix with `pnpm lint:fix`). 2-space
  indent, double quotes, semicolons, 100-col.
- Tests with **vitest** in `tests/` (`*.test.ts`). Keep the smoke + secret-scan
  tests green. `tests/setup-env.ts` strips the git variables a pre-push hook
  exports — do not remove it.
- Styles: **Tailwind 4** is CSS-first. There is no `tailwind.config`; the theme is
  the `@theme` block in `src/app/globals.css`.
- Provider/secret config comes from `.env` (copy `.env.example`). Never commit a
  real key — the secret-scan test will fail the build if you do.
- Prompts live in `prompts/`, eval fixtures in `evals/`.

## Before you commit
Run the same gates CI runs, in order:

```bash
pnpm typecheck  # tsc --noEmit
pnpm lint       # biome
pnpm test       # vitest (unit + secret-scan)
pnpm build      # next build (Turbopack)
```

The **pre-push hook blocks drift**: `.githooks/pre-push` re-runs typecheck + test
on every `git push`, so a red change can't reach the remote. It's wired
automatically by the `prepare` script (`git config core.hooksPath .githooks`) on
`pnpm install`. Emergency bypass: `git push --no-verify`.

These files are inherited from the ai-starter standard (`_standard/`); see
`docs/standard.md`.
