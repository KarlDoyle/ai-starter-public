# ai-python-service

Starter template for Python AI tools, CLIs, services, and automations.

## Default Stack

- Python
- uv
- Pydantic AI
- pytest
- project-local `.venv`
- structured prompts in `prompts/`
- smoke evals in `evals/`
- basic tests in `tests/`
- optional LiteLLM later, but not global

## Setup

```bash
uv sync
cp .env.example .env
```

## Run

```bash
uv run ai-python-service "Say hello in one sentence."
```

## Validate

```bash
uv run pytest
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
