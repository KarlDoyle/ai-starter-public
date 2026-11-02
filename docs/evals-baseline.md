# Smoke fixtures and evaluation limits

Each template includes a small JSONL fixture in `evals/`. Cases contain a prompt
or query and a `checks` list of expected signals. The current tests do not execute
these cases against a model or score the `checks` lists.

## What the tests check today

| Template | Current smoke-test coverage |
| --- | --- |
| Next.js app | Prompt metadata and in-code prompt text; JSONL parsing, case count and a case identifier; the default model name and presence of the model factory function. |
| Python service | Default settings; loading the prompt file; fixture line count and a case identifier. |
| Keyword retrieval | Discovering a temporary Markdown source; retrieving a matching document and checking its source ID and formatted output; fixture line count and a case identifier. |

Run `pnpm test` in the Next.js template or `uv run pytest` in either Python
template. These commands also run the template's secret scan.

## Limits

The smoke tests make no live model calls. They do not verify provider credentials,
model availability, response quality, factual accuracy, safety or the expected
signals listed in the JSONL cases. Only the Next.js test parses the fixture as
JSON; the Python tests inspect lines and a case identifier.

The retrieval tests exercise local behavior on small fixtures. They do not
measure retrieval quality across a representative corpus or comprehensively
validate citation correctness.

Passing these checks demonstrates only the behavior covered by their assertions.
It is not a benchmark or a production-readiness assessment.

Keep fixtures small, readable and safe to commit. Add project-specific evaluation
criteria when the application has concrete requirements.
