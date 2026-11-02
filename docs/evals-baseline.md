# Evals Baseline

The `evals/` directories are for small smoke checks, not benchmark theater.

## What A Smoke Eval Is

- a tiny JSONL file
- one line per case
- a fixed prompt or query
- a small set of expected signals
- deterministic enough to catch wiring regressions

## What It Should Catch

- prompt loading mistakes
- provider configuration mistakes
- obvious response-shape regressions
- retrieval failures
- missing citations or source references

## What It Should Not Be

- a giant benchmark harness
- a scorekeeping framework
- a public dataset dump
- a store for sensitive or private context

Keep the evals short and readable so they can be reviewed with the template.

