# Project Generation

`ai-starter` is a template repo, not a framework generator. A new project is a
**copy** of a template, and it inherits the operational standard (CI, hooks,
lint/format, secret scan) from `_standard/`. See `docs/standard.md` for the
canonical description of that standard.

## Recommended Flow

1. Copy the template directory into a new project directory.
2. Rename the project in `README.md`, package metadata, and prompts.
3. Create a local `.env` from `.env.example`.
4. Install project-local dependencies.
5. Enable the pre-push hook (see the inheritance checklist below).
6. Run the template's gates: typecheck/lint + test + build (or the Python equiv).

## Inheritance Checklist (what a new repo copies from `_standard/`)

The templates already ship with these files, so a copy inherits them
automatically. This checklist is the source of truth for bringing an existing
project into alignment without replacing its project-specific configuration.

### Node / TypeScript project
- [ ] `_standard/ci.yml` → `.github/workflows/ci.yml`
- [ ] `_standard/pre-push` → `.githooks/pre-push` (then `chmod +x`)
- [ ] `_standard/biome.json` → `biome.json` (add framework-artifact ignores,
      e.g. `.next`, `next-env.d.ts`)
- [ ] `_standard/vitest.config.ts` → `vitest.config.ts`
- [ ] `_standard/secret-scan.test.ts` → `tests/secret-scan.test.ts`
- [ ] merge `_standard/gitignore.node` into `.gitignore`
- [ ] `package.json` scripts: `typecheck`, `lint` (`biome check .`), `test`
      (`vitest run`), `build`, and `prepare`: `git config core.hooksPath .githooks || true`
- [ ] `package.json` devDeps: `@biomejs/biome`, `vitest`, `typescript`
- [ ] run install (fires `prepare`) → confirm: `git config core.hooksPath` prints `.githooks`

#### Standing reviewer (opt-in, both stacks — local/free, no key)
- [ ] `_standard/review.mjs` → `scripts/review.mjs` (then `chmod +x`)
- [ ] `_standard/review-rubric.md` → `docs/review-rubric.md` (the human-owned bar)
- [ ] add a `review` script: `node scripts/review.mjs` (Node) / a thin wrapper (Python)
- [ ] add `reviews/log.jsonl` to `.gitignore`
- [ ] it needs no deps and is **not** in CI by design (local Ollama only — see
      `docs/standing-reviewer.md`). The CI backstop stays the deterministic gates.

### Python project (uv)
- [ ] `_standard/python/ci.yml` → `.github/workflows/ci.yml`
- [ ] `_standard/python/pre-push` → `.githooks/pre-push` (then `chmod +x`)
- [ ] `_standard/python/ruff.toml` → `ruff.toml`
- [ ] `_standard/python/test_secret_scan.py` → `tests/test_secret_scan.py`
- [ ] `_standard/python/install-hooks.sh` → `scripts/install-hooks.sh` (then `chmod +x`)
- [ ] merge `_standard/gitignore.python` into `.gitignore`
- [ ] `pyproject.toml` dev group: `ruff>=0.6`, `pytest>=8`
- [ ] `uv sync --dev`, then `./scripts/install-hooks.sh`
- [ ] confirm: `git config core.hooksPath` prints `.githooks`

### Verify the gates trigger (both stacks)
- [ ] `bash .githooks/pre-push` runs the typecheck/lint + test logic
- [ ] the secret-scan test passes under the test runner (`pnpm test` / `uv run pytest`)
- [ ] CI YAML is syntactically valid (Actions only observable once pushed to GitHub)

## Template-Specific Notes

- `ai-next-app`: install with pnpm through Corepack. `prepare` wires the hook on install.
- `ai-python-service`: create and sync the project-local `.venv` with `uv sync --dev`,
  then run `./scripts/install-hooks.sh`.
- `ai-rag-tool`: a deliberately-minimal **keyword-retrieval** starter (no embeddings
  or vector store). Keep `data/` local with safe fixtures only. Add embeddings
and an index only as a deliberate, tested extension.

## Rules

- do not copy secrets
- do not copy personal context by default
- do not add MCP JSON
- do not add a large shared framework layer
- add provider-specific extras only inside the target project
