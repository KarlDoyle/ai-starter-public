# CLAUDE.md — ai-python-service

Python AI service / CLI starter (Pydantic AI). Boring and reusable on purpose.

## Conventions
- Python ≥ 3.12, managed with **uv** (`uv sync --dev`).
- Lint + format with **ruff** (`uv run ruff check .`, `uv run ruff format .`).
  ruff is this template's single style tool — the counterpart to biome on the TS
  templates. Config in `ruff.toml` (100-col, double quotes).
- Tests with **pytest** in `tests/`. Keep the smoke + secret-scan tests green.
- Config/secrets come from `.env` (copy `.env.example`). Never commit a real key
  — `tests/test_secret_scan.py` fails the build if you do.
- Prompts live in `prompts/`, eval fixtures in `evals/`.

## Before you commit
Run the same gates CI runs, in order:

```bash
uv run ruff check .          # lint
uv run ruff format --check . # format
uv run pytest                # tests (unit + secret-scan)
```

The **pre-push hook blocks drift**: `.githooks/pre-push` re-runs ruff + pytest on
every `git push`, so a red change can't reach the remote. Enable it once after
`uv sync` (the uv-equivalent of npm's `prepare`):

```bash
./scripts/install-hooks.sh   # git config core.hooksPath .githooks
```

Emergency bypass: `git push --no-verify`.

These files are inherited from the ai-starter standard (`_standard/python/`); see
`docs/standard.md`.
