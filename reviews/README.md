# Review score log

`scripts/review.mjs` appends one JSON line per run to `reviews/log.jsonl`
(JSON Lines — one object per line, append-only) so review quality is tracked
over time. Each line looks like:

```json
{"ts":"2026-06-29T00:00:00.000Z","branch":"feat/x","model":"qwen2.5:3b-instruct","verdict":"REJECT","score":3.5,"dimensions":{"claims_vs_reality":4,"tests_real":2,"security":4,"no_secrets":5,"spec_adherence":3,"honest_docs":4}}
```

| field | meaning |
| --- | --- |
| `ts` | timestamp — taken from the `--timestamp` arg, not `Date.now`, so test/CI runs are deterministic (falls back to now only for ad-hoc local runs) |
| `branch` | git branch the review ran on |
| `model` | the local Ollama model that produced the verdict |
| `verdict` | `ACCEPT` or `REJECT` |
| `score` | overall = mean of the per-dimension scores (0–5) |
| `dimensions` | per-rubric-dimension scores (0–5), keyed by the rubric's machine ids |

`log.jsonl` is git-ignored by default (see `.gitignore`): it's a local history,
not source. Commit it deliberately if you want the trend in version control.
