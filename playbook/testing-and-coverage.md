# Testing & Coverage

> **Coverage is a risk instrument, not a vanity metric.** It tells you where
> code runs untested — that's it. It cannot tell you the tests are any good. So
> we treat coverage as a **floor with a ratchet**, gate it on the **diff**, weight
> it toward **what actually runs in production**, and pair it with an
> independent reviewer that judges test *quality*. We do **not** chase 100%.

This is the reusable thinking for how projects can test and measure coverage.
Read it before adding a coverage gate, raising a threshold, or arguing about a
number in a review.

## The one-paragraph philosophy

A coverage percentage answers exactly one question — "how much of this code
executed while the tests ran?" — and it answers it honestly. Everything people
*want* it to mean ("the code works", "the tests are good", "we're safe to ship")
it does **not** mean. High coverage with worthless assertions is the most common
form of test theatre, and it's invisible to the number. So coverage is useful as
a **risk map** (untested code is where surprises live) and dangerous as a
**target** (Goodhart: the moment a number is a target, people game it). We keep
it useful by treating it as a floor that can only rise, and by never letting the
number stand in for a judgement about whether the tests are real.

## Five principles

### 1. Coverage is a floor + a ratchet (and it's gameable)
Set the threshold **at or just below where you already are**, then forbid it from
dropping. That's a ratchet: it locks in progress, can't regress, and creates
gentle upward pressure without demanding a heroic sprint to some round number.
It is explicitly **not** a stretch goal — a stretch goal that fails the build is
just a broken build.

Because the number is **gameable** (assert nothing, cover everything), the
ratchet is necessary but not sufficient. It must be paired with the
[standing reviewer](../docs/standing-reviewer.md), whose job includes judging
whether new tests actually assert behaviour or just execute lines. Coverage
guards the floor; the reviewer guards the *meaning*.

### 2. Diff-gated, not whole-repo
The question that matters on a change is **"is the new and changed code
covered?"** — not "what's the repo-wide percentage?". Whole-repo % punishes you
for legacy you didn't touch and lets a badly-tested new feature hide inside a big
green codebase. **Gate the diff:** new/changed lines must be covered to merge;
the repo total is a slower-moving ratchet underneath. This is also the only
coverage rule that scales to a large or inherited codebase without a demoralising
"raise everything to 80%" migration.

### 3. Production-weighted — test what actually runs
Not all uncovered lines carry equal risk. A line on a hot path that runs a
thousand times a day in production is a different risk than a branch in a script
nobody calls. **Weight coverage by what production actually executes**, and spend
test effort where the traffic and the blast radius are.

The reference implementation of this idea is **Datadog's CI Visibility** and its
**Test Optimization** / **Intelligent Test Runner** features: they instrument
real production execution and the test suite together, so they can tell you which
code paths are hot, which tests are flaky, and which tests are safe to *skip* for
a given change because that change can't affect them. That's the mature end-state
— coverage and test selection driven by production signal, not by a flat
percentage. We don't run Datadog on these local-first repos, but it's the model
we're approximating: *cover the code that runs, prove the paths that matter.*

### 4. AI-assisted — judge quality, fill the gaps on critical paths
An LLM is genuinely useful for two coverage jobs, and weak at a third:
- **Judging test quality** (good): does this test assert real behaviour, or did
  it just call the function and check it didn't throw? This is exactly what the
  standing reviewer does against the human-owned rubric.
- **Filling gaps on critical paths** (good): "here are the uncovered branches in
  the payment path — write the missing cases." Targeted, high-value, human-checked.
- **Bulk-generating tests to hit a number** (bad): this is automated test
  theatre — it moves the metric and adds maintenance cost without adding signal.
  Don't.

Use AI to make tests *better* and to cover the paths that *matter*; never to
manufacture a percentage.

### 5. Don't chase 100%
The last 10–20% of coverage is mostly defensive branches, unreachable
error-handling, and glue — expensive to cover and low-signal. 100% is a smell: it
usually means either trivial code or tests written to the metric. Pick a floor
that reflects the **risk** of the module (a payments core earns a high bar; a CLI
wrapper does not), ratchet it, and put the saved effort into *better assertions on
the paths that matter*. Behaviour over a number you didn't earn.

## The practical default

For small projects, the implementation can stay deliberately simple:

1. **Tooling:** `vitest` + `@vitest/coverage-v8` (already in the
   [standard](../docs/standard.md)). Coverage thresholds live in
   `vitest.config.ts`.
2. **Floor + ratchet on the core:** measure current coverage of `src/`, set the
   thresholds **just below the measured numbers** (e.g. measured − ~2pts, floored
   sensibly) so the repo is **green right now**. Scope `include` to the
   safety-critical module(s) when one module clearly carries the risk; otherwise
   ratchet the whole of `src/`. **Never commit a red gate** — if a threshold would
   make the build red, set it lower and record the real number. A red ratchet is
   a broken build, not a goal.
3. **Make the gate real:** run coverage in the test gate (`vitest run
   --coverage`) so the existing sequential CI / pre-push gate actually enforces
   the floor. A threshold that never runs is decoration.
4. **Record the honest number:** write the measured % into the repo's `STATE.md`
   or `README.md`. If coverage is low, say so — the ratchet's job is to stop it
   dropping, not to imply it's high.
5. **Pair it with the reviewer:** the deterministic floor catches *regression*;
   the [standing reviewer](../docs/standing-reviewer.md) catches *theatre*. You
   need both — coverage proves lines ran, the reviewer proves the tests mean
   something.
6. **Raise, never lower:** thresholds go up as you add real tests. Lowering a
   threshold is a reviewable decision with a reason, not a quiet fix to make a red
   build green.

### Why diff-gating isn't (yet) wired into our CI
Per-diff coverage enforcement needs a base-vs-head coverage comparison in CI
(the Datadog/Codecov-style "patch coverage" check). Our repos don't all live on
GitHub and we don't run a coverage SaaS, so today the enforced mechanism is the
**whole-`src/` ratchet** above, with diff-coverage applied *by the reviewer's
judgement* on each change rather than by an automated patch-% gate. The ratchet
is the floor; the reviewer is the diff check. If a repo graduates to hosted CI
with a coverage service, add the automated patch-coverage gate then.

## Zero-dependency mocking: injected fetch

For lean CLIs, prefer **dependency injection over a mocking library**: give
every live fetcher an `options.fetch` (defaulting to the global `fetch`), and
tests pass a fake implementation. This gives fully offline, no-network tests
with zero added dependencies — no MSW, no interceptor setup. Reach for a
mocking library only once the surface (multiple hosts, streaming, retries)
outgrows a plain injected function. Use this pattern where network requests need to be tested offline.

## What "good" looks like in a review

- New behaviour ships **with tests that assert that behaviour** (not just execute it).
- The **changed code is covered**; the repo ratchet didn't drop.
- The threshold reflects the module's **risk**, not a round number.
- Nobody bulk-generated tests to move the metric.
- The honest coverage number is written down, low or high.

## See also
- [`../docs/standard.md`](../docs/standard.md) — the four gates + the coverage-threshold lever.
- [`../docs/standing-reviewer.md`](../docs/standing-reviewer.md) — the independent test-*quality* gate that coverage can't replace.
- [`../docs/review-rubric.md`](../docs/review-rubric.md) — the human-owned bar the reviewer scores against.
