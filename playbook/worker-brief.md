# Worker brief — retrieve and follow

The whole point of this playbook: **the heavy lifting is captured once, here. A
sub-agent reads the relevant pack, then executes it — it does not re-derive the
plan.** If you're an agent picking up work, your first move is to read the right
checklist below (plus `docs/standard.md`), then run the numbered steps and verify
each gate. Don't improvise a process that already exists.

## How to use this
1. Identify the task → pick the matching checklist below.
2. Read it + the standard + the relevant `playbook/` file. That's the "thinking".
3. Execute the numbered steps in order. Each ends in a **gate** — verify it before
   moving on. A step isn't done until its gate is green.
4. Finish with a delivery report (`delivery-template.md`).

Standing reference packs (read before the matching checklist):
- `docs/standard.md` — the four gates + the secret scan (always)
- `docs/project-generation.md` — the inheritance checklist (for standard work)
- `playbook/task-breakdown.md` — ownership + slicing by project type
- `docs/ways-of-working.md` — honesty/state discipline

---

## Checklist A — Build a CLI to the standard
Owner: **builder** (+ **standardizer** for the gates). Branch: `feat/<name>`.

1. Read this pack + `docs/standard.md` + the CLI slice in `task-breakdown.md`.
   **Gate:** you can name the four gates and the acceptance criteria.
2. Write/confirm the PRD (`prd-template.md`): problem, MVP, acceptance criteria.
   **Gate:** every criterion is objectively checkable.
3. Define the CLI contract: command(s), flags, `--help`, exit codes, stdout vs
   stderr. **Gate:** `--help` text written before logic.
4. Implement core logic behind that contract; errors → stderr + non-zero exit.
   **Gate:** the happy path runs by hand and does the thing.
5. (standardizer) Wire the standard: CI, `.githooks/pre-push` (`chmod +x`),
   biome/ruff, secret-scan test, `prepare` hook. **Gate:** `git config
   core.hooksPath` prints `.githooks`.
6. Tests: unit on the logic + one end-to-end invocation of the built binary.
   **Gate:** `pnpm test` (or `uv run pytest`) passes, secret scan included.
7. README: what it is, install, one real example. **Gate:** a stranger could run
   it from the README alone.
8. Run `bash .githooks/pre-push`. **Gate:** exit 0.
9. Delivery report. **Gate:** "not proven" section is filled in honestly.

## Checklist B — Put an existing repo on the standard
Owner: **standardizer**; **auditor** verifies. Branch: `standardize/<name>`.

1. Read `docs/project-generation.md` — the inheritance checklist is the source of
   truth. Pick the Node or Python track. **Gate:** you know which track.
2. Copy each `_standard/` file to its landing spot (see the checklist's table).
   Don't overwrite genuine project customisations — reconcile toward the standard
   (e.g. keep a vitest `external`, a `--experimental-sqlite` flag). **Gate:** all
   listed files present at their paths.
3. `chmod +x` the hook(s); add `package.json`/`pyproject` scripts (`typecheck`,
   `lint`, `test`, `build`) + the `prepare`/`install-hooks` wiring. **Gate:**
   scripts resolve.
4. Merge the `gitignore` snippet; add `reviews/log.jsonl` to `.gitignore` if using
   the standing reviewer. **Gate:** no generated/secret paths tracked.
5. Run install so `prepare` fires. **Gate:** `git config core.hooksPath` →
   `.githooks`.
6. Run the gates: `bash .githooks/pre-push` and the test runner. **Gate:** pre-push
   exit 0; secret scan passes.
7. (auditor) Independent pass: secret + standard + STATE audit. **Gate:** verdict
   CLEAR.
8. Delivery report listing which checklist items were applied + the gate results.

## Checklist C — Scaffold a new project from a template
Owner: **standardizer** (scaffold) → **builder** (real code). Branch: `feat/init`.

1. Read `docs/project-generation.md` "Recommended Flow" + the template's own
   `CLAUDE.md`. Pick the template (`ai-next-app` / `ai-python-service` /
   `ai-rag-tool`). **Gate:** template chosen for the right reason.
2. Copy the template directory to the new project dir. **Gate:** tree copied,
   `_standard`-derived files present (templates ship them wired).
3. Rename: README, package/`pyproject` metadata, prompts. Create `.env` from
   `.env.example` (local only; never commit it). **Gate:** no template name or
   placeholder left; no real `.env` tracked.
4. Install project-local deps (fires `prepare`). **Gate:** `git config
   core.hooksPath` → `.githooks`.
5. Run the template's gates as-shipped: typecheck/lint + test + build (or Python
   equiv). **Gate:** all green on a fresh scaffold.
6. (branding) Set the name + one-line positioning per `branding.md` before any
   public push. **Gate:** name-availability check done (npm + web + collision).
7. Hand to the **builder** for the first real slice (see `task-breakdown.md` for
   the project type). **Gate:** PRD written before building.
8. Delivery report: scaffold done, gates green, what the human still owns.
</content>
