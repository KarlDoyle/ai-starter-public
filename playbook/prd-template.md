# PRD template (lean)

Copy this into the repo (e.g. `docs/prd.md`) before building. Keep it to one
page. If a section needs more than a few lines, the scope is probably too big —
split it. This is the spec the reviewer (`.claude/agents/reviewer.md`) judges
against, so be concrete enough that "done" is checkable.

---

## <Project / feature name>

**One-liner:** <what it is, in one sentence — the positioning line from `branding.md`>

### Problem
<What hurts today. The concrete pain, not a feature wish. 2-3 sentences.>

### Who it's for
<The specific user/persona. "Me, when I…" is fine. Not "everyone".>

### MVP (the smallest thing that solves the problem)
<Bullet list of what's in v1. Each bullet is a capability, not a task.>
- …
- …

### Acceptance criteria (checkable)
<Each must be objectively true/false — the reviewer checks these one by one.>
- [ ] <observable behaviour, e.g. "`tool foo --json` prints valid JSON to stdout">
- [ ] <…>
- [ ] <…>

### Definition of done
- [ ] All acceptance criteria met and demonstrated (not just claimed)
- [ ] Standard gates green (typecheck → lint → test → build; secret scan passes)
- [ ] Tests cover the core logic + one end-to-end path
- [ ] README updated: what it is, how to run it, one example
- [ ] Delivery report written (`delivery-template.md`) — honest about what's unproven

### Out of scope (explicit)
<What v1 deliberately does NOT do. This is what stops scope creep — name the
tempting things you're not building.>
- …
- …

### Open questions
<Anything undecided that could change the build. Resolve before, or flag as risk.>
- …
</content>
