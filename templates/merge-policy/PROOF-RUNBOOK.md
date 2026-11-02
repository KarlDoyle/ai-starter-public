# Merge-policy proof runbook

The exact sequence to prove the tiered merge policy actually works on a repo
it's been stamped onto — for Karl, or a later session, to run once the
`l5c/merge-policy` PR (or the equivalent stamp-in on another repo) is merged.

Run these from the target repo, `gh` authed as the repo owner.

## (a) Merge the policy PR

Merge the PR that added `.github/automerge-policy.yml`,
`.github/workflows/automerge.yml`, `.github/workflows/seed-tier0-test.yml`,
and `.github/CODEOWNERS` to this repo. This step is the one deliberately
manual, human step — everything after it is not.

```
gh pr merge <policy-pr-number> --squash --delete-branch
```

## (b) Fire the Tier-0 proof

```
gh workflow run seed-tier0-test.yml
```

This writes one timestamped line to `reports/automerge-seed-test.md`, opens
a PR for it (authored by `github-actions[bot]`, from a same-repo branch,
touching only `reports/**`), and — if the CI-kick step is still present —
dispatches this repo's CI workflow against the seed branch so a real check
run attaches to the PR's head SHA.

## (c) Watch it merge itself

```
gh pr list --state open
gh run watch   # or: gh pr checks <seed-pr-number>
```

Once the CI check on the seed PR goes green, `automerge.yml` (triggered by
that CI run's `workflow_run` completion, or by its own hourly schedule as a
backstop) should merge and delete the seed branch with **zero human touch**.
Confirm:

```
gh pr view <seed-pr-number> --json state,mergedBy
```

`state` should be `MERGED`, `mergedBy` should show `github-actions[bot]`
(the Actions bot, driven by the workflow's `GITHUB_TOKEN` — not a human
account).

## (d) Prove Tier-2 refuses a workflow edit

Open a whitespace-only PR against `.github/workflows/automerge.yml` (or
`.github/automerge-policy.yml`) from a same-repo branch, authored as
yourself:

```
git checkout -b prove-tier2-refusal
printf '\n' >> .github/workflows/automerge.yml
git commit -am "prove: tier2 refuses .github/ edits"
git push -u origin prove-tier2-refusal
gh pr create --title "prove: tier2 refuses .github edits" --body "Deliberate Tier-2 probe — should never auto-merge." --base main
```

Confirm automerge.yml's next run logs this PR as `skip: touches deny-listed
path(s) [...] — Tier 2, never auto-merges` (check the workflow run logs —
`gh run list --workflow=automerge.yml` then `gh run view <id> --log`), and
that the PR remains open indefinitely regardless of CI status or author.
Close it without merging once confirmed:

```
gh pr close prove-tier2-refusal --delete-branch
```

If the repo is public and branch-protected (via
`scripts/setup-branch-protection.sh`), also confirm the PR shows the
CODEOWNERS review requirement in the GitHub UI even before automerge.yml's
own check runs.

## (e) Revert path

Disabling the pattern entirely, from most to least drastic:

- **One-file rollback:** delete `.github/workflows/automerge.yml`. Nothing
  auto-merges anywhere on this repo again; every PR (Tier 0/1/2 alike)
  reverts to fully human-reviewed, propose-only. The policy file and
  CODEOWNERS can stay in place harmlessly (inert without the workflow).
- **Pause without deleting:** comment out (or remove) the `workflow_run` and
  `schedule` triggers, leaving only `workflow_dispatch` — the workflow still
  exists and can be run by hand for a one-off catch-up merge, but nothing
  fires it automatically.
- **Full removal:** delete `.github/automerge-policy.yml`,
  `.github/workflows/automerge.yml`, `.github/workflows/seed-tier0-test.yml`,
  and `.github/CODEOWNERS`, then run
  `scripts/setup-branch-protection.sh <owner/repo>` (from ai-starter) if
  branch protection was ever applied and needs unwinding manually via the
  GitHub UI (this script only ever adds protection, it does not remove it).
