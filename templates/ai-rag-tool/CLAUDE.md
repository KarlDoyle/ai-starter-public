# CLAUDE.md — ai-rag-tool

Local, source-backed Q&A starter. Boring and reusable on purpose.

**What this template does:** keyword (term-overlap) retrieval only, implemented
in `src/rag_tool/query.py`. LlamaIndex is used only to load documents. There
is no embedding model, vector store, or semantic search.

## Conventions

- Python 3.12 or later, managed with `uv`.
- Use Ruff for linting and formatting.
- Keep retrieval tests offline and based on local fixtures.
- Keep `data/` local and use only safe fixture documents.
- Never commit credentials; the secret-scan test checks committed files.
- Keep prompts in `prompts/` and evaluation fixtures in `evals/`.

## Before you commit

Run the same checks as CI:

```bash
uv run ruff check .
uv run ruff format --check .
uv run pytest
```

The pre-push hook runs Ruff and pytest. Enable it after installing dependencies:

```bash
./scripts/install-hooks.sh
```

This template can be extended with embeddings and an index, but those features
must be implemented and tested explicitly.
