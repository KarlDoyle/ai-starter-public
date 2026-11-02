# Reviewer agent — accruing state

Repo-local, tracked memory for the `reviewer` agent (`.claude/agents/reviewer.md`).
The reviewer reads this file at the start of every review to apply what past reviews
learned, and appends any new recurring finding as its final step. This is the
supported way to give a subagent state that accrues across runs — a tracked file the
agent reads and updates. There is no `memory:` / `persistentMemory:` frontmatter field
in Claude Code; this file is the real equivalent.

Keep it lean: one line per durable lesson, newest last. Prune anything no longer true.

## Recurring issues seen in this repo

*(append-only; each entry: `date · the pattern · where it bit`)*

- *none recorded yet — the first review to spot a repeated defect adds the first line.*

## Conventions learned

*(durable facts about how this repo is built, so the reviewer stops re-deriving them)*

- The single build standard lives in `_standard/`; a template that drifts from it fails the gate.
- Every template must ship `prompts/`, `evals/`, `tests/`, and `SECURITY.md`.
- Only `.env.example` belongs in a template — never a real `.env`, token, or secret.
- No private notes or personal records are copied into any template.
