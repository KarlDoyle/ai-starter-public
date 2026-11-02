#!/usr/bin/env bash
# scripts/setup-branch-protection.sh
#
# Idempotent. Stamps branch protection + auto-merge enablement on a repo's
# default branch where GitHub actually offers it (public repos, or any plan
# with the branch-protection entitlement).
#
# On GitHub Free PRIVATE repos, branch protection / required status checks /
# CODEOWNERS review enforcement are unavailable (verified: the protection
# API returns HTTP 403, "Upgrade to GitHub Pro or make this repository
# public to enable this feature"). This script detects that and prints an
# honest report instead of failing silently — on a private repo, the
# .github/workflows/automerge.yml enabling workflow (which always executes
# the version committed to the default branch) is the sole structural
# enforcement point, by design.
#
# Usage:
#   scripts/setup-branch-protection.sh [owner/repo] [branch] [check ...]
#
#   owner/repo  defaults to the current repo (gh repo view)
#   branch      defaults to the repo's default branch
#   check ...   optional explicit required-check names (the job `name:` or
#               key as it appears in the Checks tab). If omitted, this
#               script best-effort auto-detects job names from
#               .github/workflows/ci.yml's `jobs:` keys — pass explicit
#               names if that guess is wrong for your workflow.
#
# Note on GitHub's native "auto-merge" (allow_auto_merge / gh pr merge
# --auto): this script enables the allow_auto_merge REPO SETTING so a human
# can tick the "Enable auto-merge" checkbox in the GitHub UI for their own
# PRs if they want it. The automerge.yml pattern itself never uses
# `gh pr merge --auto` and does not depend on this setting — it always
# merges explicitly after its own in-code gate checks. The two are
# independent; this script sets the convenience toggle because the
# packet spec calls for it, not because automerge.yml requires it.

set -euo pipefail

REPO="${1:-}"
BRANCH="${2:-}"
if [ "$#" -gt 2 ]; then
  shift 2
  CHECKS=("$@")
else
  CHECKS=()
fi

if [ -z "$REPO" ]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

VISIBILITY="$(gh repo view "$REPO" --json visibility -q .visibility)"

if [ -z "$BRANCH" ]; then
  BRANCH="$(gh repo view "$REPO" --json defaultBranchRef -q .defaultBranchRef.name)"
fi

echo "Repo:       $REPO"
echo "Visibility: $VISIBILITY"
echo "Branch:     $BRANCH"
echo

if [ "$VISIBILITY" = "PRIVATE" ] || [ "$VISIBILITY" = "INTERNAL" ]; then
  cat <<EOF
PROTECTION UNAVAILABLE — GitHub Free does not offer branch protection,
required status checks, or CODEOWNERS review enforcement on private repos
(verified: applying protection rules returns HTTP 403 "Upgrade to GitHub Pro
or make this repository public to enable this feature").

Structural enforcement on this repo therefore runs entirely through
.github/workflows/automerge.yml: it reads the merge policy from the DEFAULT
branch only (a PR editing the policy or the workflow itself cannot affect
the run that judges it), verifies author allow-list + same-repo-only +
path allow/deny (including rename smuggling) + green checks in code before
ever merging anything, and is the sole gate. CODEOWNERS and this script's
branch-protection step are inert here until the repo goes public or the
plan changes.

No settings were changed. Exiting 0 — this is the expected, correct state
for a private repo, not an error.
EOF
  exit 0
fi

echo "Repo is $VISIBILITY — branch protection is available. Applying."
echo

if [ "${#CHECKS[@]}" -eq 0 ]; then
  echo "No required checks named explicitly — auto-detecting job names from .github/workflows/ci.yml"
  if [ -f .github/workflows/ci.yml ]; then
    mapfile -t CHECKS < <(python3 - ".github/workflows/ci.yml" <<'PY'
import sys
import yaml

with open(sys.argv[1]) as f:
    doc = yaml.safe_load(f) or {}
jobs = doc.get("jobs", {}) or {}
for key, val in jobs.items():
    print((val or {}).get("name") or key)
PY
    )
  fi
  if [ "${#CHECKS[@]}" -eq 0 ]; then
    echo "Could not auto-detect any job names from .github/workflows/ci.yml." >&2
    echo "Pass check names explicitly: $0 $REPO $BRANCH <check1> [check2 ...]" >&2
    exit 1
  fi
fi

echo "Required checks: ${CHECKS[*]}"
echo

BODY_JSON="$(python3 - "${CHECKS[@]}" <<'PY'
import json
import sys

contexts = sys.argv[1:]
body = {
    "required_status_checks": {"strict": True, "contexts": contexts},
    "enforce_admins": True,
    "required_pull_request_reviews": {
        "required_approving_review_count": 1,
        "require_code_owner_reviews": True,
    },
    "restrictions": None,
    "allow_force_pushes": False,
    "allow_deletions": False,
}
print(json.dumps(body))
PY
)"

echo "Applying branch protection to $REPO:$BRANCH ..."
echo "$BODY_JSON" | gh api --method PUT "repos/$REPO/branches/$BRANCH/protection" --input - >/dev/null

echo "Enabling repo-level allow_auto_merge setting ..."
gh api --method PATCH "repos/$REPO" -F allow_auto_merge=true >/dev/null

echo
echo "Done. Branch protection applied to $BRANCH; allow_auto_merge enabled."
echo "automerge.yml still makes the actual Tier 0/1 merge decision explicitly —"
echo "this only adds a human-usable native auto-merge toggle and a real"
echo "enforcement backstop (required checks + CODEOWNERS review + no force-push)."
