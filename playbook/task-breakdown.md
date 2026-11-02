# Task breakdown

How to decompose a build into tasks and assign each to an agent. The point is to
make the thinking reusable: decide the shape once, here, so any session/model can
pick up the same decomposition instead of re-deriving it.

## The isolation rule (read first, non-negotiable)
**One writer per repo at a time. Each writer works on its own branch.**

- A single repo never has two agents editing it concurrently. Parallelism happens
  across *separate* repos/worktrees or across *read-only* explorers, never two
  builders on the same working tree.
- Every unit of work lands on a branch (`feat/…`, `fix/…`, `standardize/…`),
  never directly on `main`.
- Read-only agents (explorer, auditor) may run in parallel with anything — they
  don't write, so they can't collide.
- Hand off between writers via the branch + a delivery report (see
  `delivery-template.md`), not by sharing a live working tree.

## Ownership map (which agent owns which task)
| Task kind | Owner | Why |
| --- | --- | --- |
| Real implementation, design judgement, tricky logic | **builder** (Opus/high) | needs judgement, not just pattern-matching |
| Find where something lives / how it works / prior art | **explorer** (read-only) | breadth, no writes, cheap |
| Apply the standard, scaffold fixtures, mechanical rote edits | **standardizer** (Sonnet/low) | deterministic; cheap model is enough |
| Secret / standard / STATE audit before merge or release | **auditor** (read-only) | independent check, no stake in shipping |
| Acceptance review against the spec | **reviewer** (see `.claude/agents/reviewer.md`) | independent ACCEPT/REJECT gate |

## Decompose by project type
Each type below lists the natural task slices and the owner. Slice so each task is
independently verifiable (has a gate) and small enough to land on one branch.

### CLI tool
1. Arg/flag parsing + `--help` + exit codes — **builder**
2. Core command logic (the actual thing it does) — **builder**
3. I/O boundaries (stdin/stdout/files, errors to stderr) — **builder**
4. Standard gates wired (CI, pre-push, lint, secret scan) — **standardizer**
5. Tests: unit on logic + one end-to-end invocation — **builder**
6. README usage + examples — **standardizer**

### Library / package
1. Public API surface (types + signatures) — **builder** (design-heavy, do first)
2. Implementation behind the API — **builder**
3. Standard gates + `package.json`/`pyproject` metadata — **standardizer**
4. Tests against the *public* API only — **builder**
5. Examples / quickstart in README — **standardizer**
6. Naming + positioning — **branding.md** (one-liner before publish)

### Web app
1. Routes / pages skeleton — **builder**
2. Data layer (fetching, schema, validation) — **builder**
3. UI components + states (loading/empty/error) — **builder**
4. Standard gates + framework build wired — **standardizer**
5. Tests: data-layer logic + one critical-path flow — **builder**
6. Landing/hero copy — **branding.md**

### Data pipeline
1. Source contract (what comes in, schema, bad-input policy) — **builder**
2. Transform steps, each pure + testable — **builder**
3. Sink + idempotency/rerun semantics — **builder**
4. Standard gates + secret scan (pipelines leak creds) — **standardizer**
5. Tests: per-transform fixtures + one end-to-end on sample data — **builder**
6. Observability (counts, failures logged) — **builder**

### Automation / script
1. Trigger + inputs (cron, hook, manual) — **builder**
2. The action + a dry-run / `--check` mode — **builder**
3. Failure handling (idempotent, safe to re-run) — **builder**
4. Standard gates + secret scan — **standardizer**
5. Tests on the action logic with mocked side effects — **builder**

## How to slice (rules)
- **Every task has a gate.** If you can't say how it's verified, it's not a task
  yet — split it until each piece has a check (a test, a typecheck, a run).
- **API/contract before implementation.** Lock the shape (types, signatures,
  schema) first; implementation and tests hang off it.
- **Standard work is its own task, owned by the standardizer.** Don't fold "wire
  the gates" into a feature task — it's mechanical and belongs to a cheaper model.
- **Order: explore → contract → build → standardize → audit/review.** Explorers
  and auditors bracket the builders; standardizer runs alongside or after.
</content>
</invoke>
