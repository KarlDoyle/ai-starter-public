# The Standing Reviewer

An **opt-in local AI reviewer** providing advisory feedback. After a change is built,
it judges the diff against a human-owned rubric (and an optional spec) and prints
a terse `VERDICT: ACCEPT | REJECT` with a 0–5 score per rubric dimension and
reasons that cite the specific gap. It is **advisory** — a human still makes the
merge call.

It exists because the author of a change is the worst judge of whether it's
actually done: effort feels like progress, claims drift from reality, tests turn
into theatre. A second set of eyes that has no stake in shipping catches that.

## Why local

The reviewer talks **only to a local [Ollama](https://ollama.com) daemon** on
`127.0.0.1:11434`. Diffs and specifications stay on the local machine; no
hosted model or API key is used.

If the daemon isn't running it **degrades gracefully**: a clear message telling
you to start Ollama, and a non-zero exit (`2`) — never a crash and never a
silent "looks fine".

## The pieces

| File | Role |
| --- | --- |
| `docs/review-rubric.md` | The **human-owned bar** (versioned). The reviewer scores against this. |
| `scripts/review.mjs` | The runner (zero deps: native `fetch` + `node:` builtins). |
| `reviews/log.jsonl` | Append-only score log, one JSON line per run (git-ignored). |
| `.claude/agents/reviewer.md` | The reviewer **persona** — the same advisory stance, for when you'd rather run the review as a Claude Code subagent. |
| `tests/review.test.mjs` | Deterministic tests for the runner (fake fetch, fixed timestamps — no Ollama needed). |

## The human-owned-rubric guardrail

`docs/review-rubric.md` is the spec for "done and honest". The single most
important property: **the rubric changes only by a deliberate human commit.** The
runner *reads* it and may *suggest* additions in its output, but it never edits
the file. A self-amending rubric is a reviewer grading its own homework — so the
bar is owned by a person and moves only as a reviewable diff (with a version
bump). See the guardrail section at the top of the rubric.

## Usage

```bash
# Ollama must be running:  ollama serve   (and a model pulled, e.g. ollama pull qwen2.5:3b-instruct)

# Review this branch against main, using docs/review-rubric.md:
pnpm review                       # = node scripts/review.mjs

# Against an explicit spec / acceptance-criteria file:
pnpm review --spec docs/feature-x-acceptance.md

# Review a specific diff (file or stdin):
git diff main...HEAD > /tmp/d.diff && node scripts/review.mjs --diff /tmp/d.diff
git diff main...HEAD | node scripts/review.mjs --diff -

# Pick the model / base / Ollama URL:
node scripts/review.mjs --base develop --model llama3.1:latest
```

Exit codes: `0` ACCEPT, `1` REJECT, `2` could-not-review (Ollama down / error) —
so you *can* wire it into a script, but see the CI caveat below.

### Determinism

The log timestamp comes from `--timestamp <iso>`, not `Date.now()`, so test/CI
output is reproducible. Ad-hoc local runs fall back to the current time. The
model itself is non-deterministic (it's an LLM); the verdict is advisory signal,
not a hash.

## The CI caveat

**The LLM reviewer is not a CI gate.** Hosted runners do not have the local
model service available. The deterministic typecheck, lint, test, and build
checks remain the gate of record.

So the standing reviewer runs **where the model lives**: on your machine, before
you push (run `pnpm review`), or as the `reviewer` Claude Code subagent. The CI
backstop stays what it already is — the deterministic gates (typecheck, lint,
test, **secret scan**) in `docs/standard.md`, which need no LLM and no key. If a
key ever becomes available, the same `scripts/review.mjs` could be pointed at a
hosted endpoint and added as a CI step.

## Relationship to the standard

The standing reviewer is **opt-in**, layered on top of the always-on
deterministic gates — it doesn't replace them. It's part of what new repos can
inherit from `_standard/` (`_standard/review.mjs`, `_standard/review-rubric.md`);
see the inheritance checklist in `docs/project-generation.md`.
