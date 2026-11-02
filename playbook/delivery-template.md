# Delivery report template

Every writer ends a unit of work with one of these — it's the handoff. It lives
in the PR description or `docs/handoff.md`. The governing rule (from
`docs/ways-of-working.md`): **claims must equal reality.** "Verified" means you
ran it and watched it pass. "Not proven" is said out loud, not hidden.

Copy this:

---

## Delivery: <what this change is>

**Branch:** `<feat/…>`  **Spec:** `<link to PRD / the ask>`

### What I built
<Bullet list of what actually changed. Point at files. Match this to the
acceptance criteria — one line per criterion is ideal.>
- …

### What I verified (and how)
<Only things you actually observed. Name the command and the result.>
- [x] `pnpm test` → pass (N tests)
- [x] `bash .githooks/pre-push` → exit 0
- [x] <ran the tool/app and saw the expected behaviour: what you saw>

### Not proven / mocked / known gaps
<The honest section. What you did NOT verify, what's stubbed, what could break.
This is the most important part — a true claim that drifts into false here is the
failure mode we guard against.>
- <e.g. "CI YAML is valid but unrun — Actions only observable once pushed">
- <e.g. "error path on network timeout is untested">
- <e.g. "works on sample data only; not run against production-size input">

### The human's to-do
<What a person must do that an agent can't or shouldn't. Be specific.>
- <e.g. "push the branch and open the PR">
- <e.g. "add the real API key to the deploy env (only `.env.example` committed)">
- <e.g. "run the reviewer / approve the merge">

### Suggested next
<Optional. The obvious next slice, if any — so the next session starts warm.>
- …
</content>
