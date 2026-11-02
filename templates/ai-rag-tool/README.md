# ai-rag-tool

Deliberately-minimal starter for local, source-backed Q&A. It ingests a local
`data/` folder and answers with a simple, dependency-light **keyword retrieval**
scorer (term-overlap ranking in `src/rag_tool/query.py`), with citations back to
the source files.

## What this is (and isn't)

This template is intentionally a **keyword-retrieval** starter: no embeddings, no
vector store, no semantic search. It gives you the boring scaffolding — ingest,
source registry, citations, evals, tests, the standard gates — without committing
you to a heavy RAG stack on day one. The claim equals the code.

To add semantic retrieval, introduce an embedding model and index deliberately,
then update the tests and documentation. Its current scope remains keyword matching.

## Default Stack

- Python, managed with uv
- LlamaIndex `SimpleDirectoryReader` for document loading only (not retrieval)
- keyword (term-overlap) retrieval — see `src/rag_tool/query.py`
- local `data/` folder + source registry
- citations and source references
- retrieval smoke evals in `evals/`
- basic tests in `tests/`
- no personal context copied by default

## Setup

```bash
uv sync
```

## Run

```bash
uv run rag-tool "What sources are available?"
```

## Validate

```bash
uv run pytest
```

## Prompt And Eval Files

- `prompts/query.md`
- `evals/retrieval-smoke.jsonl`

## Data Rule

Keep `data/` local and populate it only with safe fixture documents.

## License

This template's original files are MIT-licensed. Third-party dependencies retain
their own licenses; review them when extending the template.
