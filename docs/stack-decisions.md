# Stack Decisions

These templates are intentionally small. They are starter layers, not a shared
framework.

## `ai-next-app`

- TypeScript
- Next.js App Router
- Vercel AI SDK
- pnpm through Corepack
- project-local dependencies
- structured prompts in `prompts/`
- smoke evals in `evals/`
- basic tests in `tests/`
- no auth, payment, or database by default

Use this template for chat UIs, AI dashboards, SaaS prototypes, and thin web
products.

## `ai-python-service`

- Python
- uv
- Pydantic AI
- pytest
- project-local `.venv`
- structured prompts in `prompts/`
- smoke evals in `evals/`
- basic tests in `tests/`
- no global LiteLLM

Use this template for tools, CLIs, services, and automations.

## `ai-rag-tool`

- Python
- uv
- LlamaIndex
- local `data/` folder
- source registry
- citations and source references
- retrieval smoke evals
- no personal context copied by default

Use this template for local context search, markdown search, and source-backed
Q&A.

## Model Policy

Start with the smallest thing that works.

- use project-local dependencies first
- keep provider wiring inside the project
- use Ollama and `qwen3:4b` for private experiments only
- do not treat local experiments as the final authority for reusable defaults

