# Playbook

The reusable thinking for building things to project standards. The point: **the
heavy thinking lives here in the repo — retrievable by any agent, session, or
model — not in one model's head.** Sub-agents *retrieve and follow* these packs;
they don't re-derive the plan each time.

## The governing rule
> **Before building anything, read the relevant playbook + the standard first.**

Not optional. If you're an agent (or a person) starting work, your first move is
to read the matching file below plus `docs/standard.md`. The plan already exists;
follow it.

## Index
| File | What it's for | Read it when |
| --- | --- | --- |
| [`worker-brief.md`](worker-brief.md) | The retrieve-and-follow pattern + 3 concrete checklists (build a CLI, put a repo on-standard, scaffold from a template) | starting any unit of work |
| [`task-breakdown.md`](task-breakdown.md) | Decompose by project type → tasks → which agent owns each; the isolation rule | planning a build |
| [`prd-template.md`](prd-template.md) | Lean spec: problem, who, MVP, acceptance criteria, DoD, out-of-scope | before building a feature |
| [`delivery-template.md`](delivery-template.md) | The honest delivery-report format (built / verified / not proven / human's to-do) | finishing a unit of work |
| [`branding.md`](branding.md) | Naming + positioning + landing-page standard, grounded in Product Hunt winners | before naming or publishing |
| [`testing-and-coverage.md`](testing-and-coverage.md) | Coverage-as-risk: floor + ratchet, diff-gated, production-weighted, AI-assisted, paired with the reviewer; don't chase 100% | adding/raising a coverage gate or arguing a number in review |
| [`demo-fixtures.md`](demo-fixtures.md) | Seeded, deterministic sample-data generation for demo-first products | building demo/sample data for a walkthrough or screenshot |

## The agent roster (`.claude/agents/`)
Each agent pins model + effort + tools + role. Match the task to the owner
(see `task-breakdown.md`'s ownership map):

| Agent | Model / effort | Writes? | Role |
| --- | --- | --- | --- |
| [`builder`](../.claude/agents/builder.md) | Opus / high | yes | real builds, judgement, API design |
| [`explorer`](../.claude/agents/explorer.md) | Explore / inherit | no | read-only breadth, find/map |
| [`standardizer`](../.claude/agents/standardizer.md) | Sonnet / low | yes | mechanical: apply the standard, fixtures |
| [`auditor`](../.claude/agents/auditor.md) | Sonnet or Explore | no | read-only secret / standard / STATE audit |
| [`reviewer`](../.claude/agents/reviewer.md) | (see file) | no | independent acceptance gate vs the spec |

## Also read
- [`docs/standard.md`](../docs/standard.md) — the four gates + secret scan (the standard itself)
- [`docs/ways-of-working.md`](../docs/ways-of-working.md) — context/memory engineering, the honesty rule
- [`docs/project-generation.md`](../docs/project-generation.md) — the inheritance checklist
</content>
