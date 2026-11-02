# _standard — the copy source

These are the canonical, proven operational files every ai-starter template (and
every repo generated from one) inherits. They are **copied**, not packaged: there
is no shared dependency, no generator, no version to bump. A repo owns its copy.

| File | Goes to | Purpose |
| --- | --- | --- |
| `ci.yml` | `.github/workflows/ci.yml` | Node sequential gates: typecheck → lint → test → build |
| `pre-push` | `.githooks/pre-push` | Local mirror of CI (typecheck + test); robust no-op if deps missing |
| `biome.json` | repo root | Lint + format (Node/TS) |
| `vitest.config.ts` | repo root | Test runner; coverage thresholds documented but off by default |
| `secret-scan.test.ts` | `tests/secret-scan.test.ts` | Generic committed-credential scan |
| `gitignore.node` / `gitignore.python` | merge into `.gitignore` | Ignore snippets |
| `python/ci.yml` | `.github/workflows/ci.yml` | Python equivalent: ruff + pytest (uv) |
| `python/pre-push` | `.githooks/pre-push` | Python local gate (ruff + pytest) |
| `python/ruff.toml` | repo root | Lint + format (Python) — biome's counterpart |
| `python/test_secret_scan.py` | `tests/test_secret_scan.py` | pytest port of the secret scan |
| `python/install-hooks.sh` | `scripts/install-hooks.sh` | uv-equivalent of npm `prepare` (sets `core.hooksPath`) |
| `review.mjs` | `scripts/review.mjs` | **Opt-in** standing reviewer — local/free Ollama acceptance-gate (zero deps) |
| `review-rubric.md` | `docs/review-rubric.md` | Human-owned review bar (versioned); see `docs/standing-reviewer.md` |
| `observability.md` | `docs/observability.md` | Logging/usage-log/health-surface/alerting minimum for every repo |

See `docs/standard.md` for the canonical "this is the standard, here are the
defaults, you may not need everything" guidance, and `docs/project-generation.md`
for the inheritance checklist a new repo follows.
