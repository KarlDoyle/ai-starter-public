# Security Baseline

These templates must stay free of secrets and private machine state.

## Never Commit

- real `.env` files
- API keys, tokens, private endpoints, or production credentials
- MCP JSON
- browser profiles
- keychains
- app databases
- SSH private keys
- private notes or personal records

## Required Pattern

- commit `.env.example`
- document variable names only
- keep environment wiring local to each project
- keep LiteLLM project-local only if a project needs it later
- keep optional local model experiments separate from the default template

## RAG Data Rule

`ai-rag-tool` starts with empty, local `data/` scaffolding.

Only add fixture data that is safe to commit.
Do not seed the template with personal files, customer data, or private context.

