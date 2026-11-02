# The Standard

> **Before building anything, read the relevant [`playbook/`](../playbook/README.md) pack + this standard first.** The playbook holds the reusable thinking (task breakdown, templates, agent roster, branding); see also [`docs/ways-of-working.md`](ways-of-working.md).

This is the shared build standard for the AI Starter templates and projects
created from them. It is intentionally small, copy-based, and boring: there is no shared package, no generator, no
version to chase. Every template — and every repo generated from one — inherits
a known set of operational files from `_standard/`.

> **You may not need everything here, but the defaults are the defaults.** Start
> from the standard and remove what a given project genuinely doesn't need;
> don't reinvent the gates per project.

## What the standard guarantees
Template CI runs the checks below in order. Local pre-push hooks run a subset:
typecheck and tests for Node; Ruff lint and pytest for Python. Ruff checks Python
lint and formatting; it is not a Python type checker.

1. **Typecheck** (TS: `tsc --noEmit`; Python: no type checker included)
2. **Lint + format** (TS: biome; Python: ruff)
3. **Test** (TS: vitest; Python: pytest) — always includes a **secret scan**
4. **Build** (TS: framework build; Python: n/a — covered by lint+test)

Cheapest, fastest signal first; each step only runs if the previous passed.

## The files (canonical source: `_standard/`)

### Node / TypeScript
| Standard file | Lands at | Role |
| --- | --- | --- |
| `_standard/ci.yml` | `.github/workflows/ci.yml` | Sequential CI gates (typecheck → lint → test → build) |
| `_standard/pre-push` | `.githooks/pre-push` | Local subset of CI; **robust no-op** if no deps/pm installed |
| `_standard/biome.json` | `biome.json` | Lint + format (2-space, double quotes, 100-col, `noExplicitAny`) |
| `_standard/vitest.config.ts` | `vitest.config.ts` | Node test env; coverage thresholds documented, off by default |
| `_standard/setup-env.ts` | `tests/setup-env.ts` | Strips the git variables a pre-push hook exports (see below) |
| `_standard/secret-scan.test.ts` | `tests/secret-scan.test.ts` | Generic committed-credential scan |
| `_standard/gitignore.node` | merge into `.gitignore` | Ignore snippet |

Plus a `package.json` `prepare` script: `git config core.hooksPath .githooks || true`.

### Python
| Standard file | Lands at | Role |
| --- | --- | --- |
| `_standard/python/ci.yml` | `.github/workflows/ci.yml` | Sequential CI gates (ruff → ruff format → pytest) via uv |
| `_standard/python/pre-push` | `.githooks/pre-push` | Local subset of CI; **robust no-op** if uv not installed |
| `_standard/python/ruff.toml` | `ruff.toml` | Lint + format (biome's counterpart) |
| `_standard/python/test_secret_scan.py` | `tests/test_secret_scan.py` | pytest port of the secret scan |
| `_standard/python/install-hooks.sh` | `scripts/install-hooks.sh` | uv-equivalent of `prepare` (sets `core.hooksPath`) |
| `_standard/gitignore.python` | merge into `.gitignore` | Ignore snippet |

## The secret scan
Pattern-based, deterministic, no entropy guessing. It fails the build if any of
these credential shapes appear in committed source (including `.env.example`,
which must only hold empty/placeholder values):

- `sk-ant-…` (Anthropic API key)
- `sk-…` (OpenAI-style API key)
- `ghp_…` / `github_pat_…` / `gho_/ghs_/ghu_…` (GitHub tokens)
- `AKIA…` (AWS access key id)
- `-----BEGIN … PRIVATE KEY-----` (private key blocks)

It scans the dirs a project actually commits (`src`, `app`, `tests`, `scripts`,
`prompts`, `evals`, `docs`, `.github`); missing dirs are skipped, so the same
file drops into any repo unchanged.

## Pulled verification (no GitHub = pull the truth)
Not every repo lives on GitHub, so there isn't always a hosted CI to *push* a
status to you. `scripts/verify-all.sh` is the complement: one command that runs
the gates across the selected project directories and prints a green/red dashboard,
exiting non-zero if any repo is red. Run it on demand to answer "is everything
actually green right now?" across the fleet. Full write-up: [`docs/verify-all.md`](verify-all.md).

## Pinned versions (reviewed 2026-09-19)

| Thing | Value | Why this one |
| --- | --- | --- |
| Node | **24** — `engines.node: ">=24"`, CI `node-version: "24"` | Active LTS. 26 becomes LTS on 28 Oct 2026; move then, not before. |
| pnpm | **`"packageManager": "pnpm@11.5.2"`** | Single source of truth: `pnpm/action-setup@v6` reads it, and **fails outright if the workflow also sets `version:`**. Do not set both. |
| TypeScript | **7.x** | Stable since 8 Jul 2026, 5–10× faster on these repos. The one blocker is tooling that uses TS's *programmatic API* (typescript-eslint, ts-node, api-extractor) — that API is not stable until 7.1, so such a repo stays on 5.9. |
| Vitest | **5.x** | Needs Node ≥22.12 and `vite` as a real devDependency (it became a peer). `clearMocks` now defaults to **true**, and `sequential` is gone. |
| Biome | **2.x** | `npx biome migrate --write`, then exclude worktrees with the **anchored** `"!.claude/worktrees"` — the glob form `"!**/.claude/worktrees"` silently matches nothing. |
| `@types/node` | **tracks the runtime (24)**, not the newest release | Dependabot is told to skip its majors; the types move when Node does. |

### Reversal: `packageManager` is now pinned
This section previously said *do not pin `packageManager`*, because an exact corepack pin
made a fresh or offline clone block while corepack fetched that version — it caused failures in earlier projects. That rule is withdrawn. The pin is back because CI now
derives pnpm from it (action-setup v6), and because the alternative is stating the version in
two places, which is what actually broke CI on 2026-09-19. `engines.pnpm` stays as an
advisory floor, and the committed `pnpm-lock.yaml` remains the thing that makes a build
reproducible.

## One linter, one framework
- **Biome is the only linter and formatter in every Node/TypeScript repo**, including the
  Next.js app. ESLint and `eslint-config-next` were removed on 2026-09-19: two linters meant
  two configs, two upgrade paths and two sets of rules disagreeing about the same file.
- **The web standard is Next.js (App Router) + React + TypeScript + Tailwind.** There is no
  second way to build a page in this estate. A throwaway demo can be a single HTML file; a
  page anyone else will see is a Next app.
- **Python repos keep ruff** — same idea, one tool per language.

## Tests must not inherit a hook's git environment
When git runs a hook it exports `GIT_DIR`, `GIT_INDEX_FILE` and friends, pointing at the
repository being pushed. Any test that builds a throwaway repo in a temp directory will then
operate on the *real* repository instead. On 2026-09-19 this rewrote a branch tip and wrote
changes to the wrong repository configuration — a failure that only appeared when pushing from
a git worktree, where `GIT_DIR` is absolute. Ship `_standard/setup-env.ts` as
`tests/setup-env.ts` and reference it from `vitest.config.ts`. Code that shells out to git
itself must strip the same variables at the call site.

## How we know the gates trigger
- **pre-push**: a real git hook at `.githooks/pre-push`, made executable and
  wired via `core.hooksPath`. On `git push` it runs typecheck/lint + tests and
  exits non-zero (aborting the push) on failure. If deps/tooling aren't installed
  it warns and lets the push through — CI is the backstop — so a fresh clone
  isn't bricked.
- **CI**: the same gates run on every push/PR in GitHub Actions. The YAML is
  syntactically valid; Actions themselves can only be observed once pushed to
  GitHub (can't run the runner locally).
- **secret scan**: runs as part of `pnpm test` / `uv run pytest`, so it triggers
  on every local test run, every pre-push, and every CI run.

## The standing reviewer (opt-in)
On top of the always-on deterministic gates, the standard ships an **opt-in,
local, advisory reviewer**: `scripts/review.mjs` sends a diff +
optional spec + the human-owned rubric (`docs/review-rubric.md`) to a **local
Ollama** model and prints `VERDICT: ACCEPT|REJECT` with a 0–5 score per rubric
dimension. Run it with `pnpm review`. It is **advisory** (a human merges) and
degrades gracefully when Ollama isn't running.

It uses a local model so diffs and specifications are not sent to a hosted
LLM. The consequence is that it is **not** a CI gate: hosted runners do not
have the local model service available. Run it manually with `pnpm review` before pushing, or use the
`.claude/agents/reviewer.md` subagent. The
rubric is **human-owned**: it changes only by a deliberate commit; the reviewer
may *suggest* additions but never self-edits. Full write-up:
`docs/standing-reviewer.md`. Canonical inherited copies live in `_standard/`.

| Standard file | Lands at | Role |
| --- | --- | --- |
| `_standard/review.mjs` | `scripts/review.mjs` | Local Ollama reviewer runner (zero deps) |
| `_standard/review-rubric.md` | `docs/review-rubric.md` | Human-owned review bar (versioned) |

## Coverage thresholds
`vitest.config.ts` ships with coverage thresholds **commented out** so a fresh
template is green from commit one. Turn them on (and scope `include` to your
safety-critical module) once that code exists — behaviour over a coverage number
you haven't earned. (coverage thresholds are enabled when a project has a meaningful baseline.)

**Coverage is a floor + ratchet, not a target.** Set thresholds at/just-below the
coverage you already have so the repo is green now and can only rise; gate the
**diff** (new/changed code), weight toward what runs in production, and pair the
number with the standing reviewer for test *quality* — the percentage is gameable
on its own. Full reasoning and the practical default for our repos:
[`playbook/testing-and-coverage.md`](../playbook/testing-and-coverage.md).

## ai-rag-tool: scope + extension points
The `ai-rag-tool` template ships a **deliberately-minimal keyword (term-overlap)
retriever** (`src/rag_tool/query.py`) — no embeddings, no vector store, no
semantic search. That is the whole template; the claim equals the code.

When you outgrow keyword retrieval and want a full local-first RAG
implementation, add the required components deliberately. The template does *not*
implement these features; they are possible extension points:
- **node:sqlite + sqlite-vec + FTS5** as an embedded hybrid store (no DB server,
  no native compile). Run TS with `--experimental-sqlite`.
- **Local embeddings** (transformers.js / on-device model) — no SaaS, no API key;
  indexing and search work offline.
- **Offline tests**: prove the retrieval pipeline end-to-end with no network and
  no LLM; exercise the LLM `analyze` step separately (it needs a key/local model).

See `templates/ai-rag-tool/README.md` for the template's scope.

## Provenance

The standard is self-contained. Its templates and documentation can be used
without access to any other repository or private project material.
