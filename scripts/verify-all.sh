#!/usr/bin/env bash
#
# verify-all.sh — run the local quality gates for one or more repositories.
#
# It runs typecheck, lint and tests for Node projects, and pytest for Python
# projects. Pass project directories as arguments; without arguments, it checks
# this repository. See docs/verify-all.md.
#
# The local-runner fallback keeps checks working when corepack cannot use a
# repository's pinned pnpm version.
#
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/verify-all.sh [--no-color] [PROJECT_DIR...]

Checks the current repository by default. Pass one or more project directories
to check a selected set of Node or Python projects.
USAGE
}

REPOS=()
USE_COLOR=1
while (($#)); do
  case "$1" in
    --no-color) USE_COLOR=0 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "verify-all: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) REPOS+=("$1") ;;
  esac
  shift
done

if ((${#REPOS[@]} == 0)); then
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  REPOS=("$repo_root")
fi

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

[ -t 1 ] || USE_COLOR=0
if [ "$USE_COLOR" = "1" ]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_GREEN=""; C_RED=""; C_DIM=""; C_BOLD=""; C_RST=""
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Run a node-stack script (from package.json) WITHOUT going through corepack:
# put the repo's node_modules/.bin on PATH (exactly what pnpm/npm do) and run
# the script body directly. Bypasses any pnpm version pin entirely.
run_local_script() {
  local dir="$1" script="$2"
  ( cd "$dir" && PATH="$dir/node_modules/.bin:$PATH" bash -c "$script" )
}

# Read a package.json script body ("" if absent).
pkg_script() {
  local dir="$1" name="$2"
  node -e "try{const p=require('$dir/package.json');process.stdout.write((p.scripts&&p.scripts['$name'])||'')}catch(e){}" 2>/dev/null
}

# Extract a human test-count summary from captured output.
parse_counts() {
  local out line
  # Strip ANSI color codes first — some vitest configs colorize even when piped.
  out="$(printf '%s' "$1" | sed -E $'s/\033\\[[0-9;]*m//g')"
  # vitest:  "Tests  521 passed (521)"  or "Tests  2 failed | 519 passed (521)"
  line=$(printf '%s\n' "$out" | grep -E '^[[:space:]]*Tests[[:space:]]' | tail -1)
  if [ -n "$line" ]; then
    printf '%s' "$line" | sed -E 's/^[[:space:]]*Tests[[:space:]]+//; s/[[:space:]]+$//'
    return
  fi
  # node --test: "# pass 12" (tap reporter) or "ℹ pass 12" (spec reporter)
  if printf '%s\n' "$out" | grep -qE '^(# |ℹ )tests [0-9]'; then
    local t p f
    t=$(printf '%s\n' "$out" | grep -E '^(# |ℹ )tests ' | tail -1 | grep -oE '[0-9]+')
    p=$(printf '%s\n' "$out" | grep -E '^(# |ℹ )pass '  | tail -1 | grep -oE '[0-9]+')
    f=$(printf '%s\n' "$out" | grep -E '^(# |ℹ )fail '  | tail -1 | grep -oE '[0-9]+')
    printf '%s passed, %s failed (%s)' "${p:-?}" "${f:-?}" "${t:-?}"
    return
  fi
  # pytest:  "=== 12 passed in 0.34s ==="  / "1 failed, 11 passed"
  line=$(printf '%s\n' "$out" | grep -E '[0-9]+ (passed|failed|error)' | tail -1)
  if [ -n "$line" ]; then
    printf '%s' "$line" | sed -E 's/=+//g; s/^[[:space:]]+//; s/[[:space:]]+$//'
    return
  fi
  printf 'counts n/a'
}

# Run one node gate (typecheck|lint|test). Tries `pnpm <name>` first; if that
# fails because corepack couldn't honor the pin (or for any reason), retries
# with the repo-local runner. Returns 0/1; echoes captured output to $GATE_OUT.
GATE_OUT=""
run_node_gate() {
  local dir="$1" name="$2" script
  script="$(pkg_script "$dir" "$name")"
  [ -z "$script" ] && { GATE_OUT=""; return 200; }   # 200 = gate not defined

  local out code
  out="$( cd "$dir" && COREPACK_ENABLE_DOWNLOAD_PROMPT=0 pnpm run "$name" 2>&1 )"
  code=$?
  if [ $code -ne 0 ] && printf '%s\n' "$out" | grep -qiE 'corepack|packageManager|this project is configured to use|download|Cannot find matching|Usage Error|Internal Error|ERR_PNPM'; then
    # Looks like a package-manager/corepack problem, not a real gate failure —
    # fall back to the local runner so a pin can't mask the true result.
    out="$( run_local_script "$dir" "$script" 2>&1 )"
    code=$?
  fi
  GATE_OUT="$out"
  return $code
}

# ---------------------------------------------------------------------------
# Per-repo verification
# ---------------------------------------------------------------------------
RESULT_LINES=()
FAIL_COUNT=0
PASS_COUNT=0
SKIP_COUNT=0

verify_repo() {
  local dir="$1"
  local name; name="$(basename "$dir")"

  if [ ! -d "$dir" ]; then
    RESULT_LINES+=("${C_DIM}SKIP${C_RST}  $(printf '%-22s' "$name")  directory not found")
    SKIP_COUNT=$((SKIP_COUNT+1)); return
  fi

  local stack="unknown"
  if [ -f "$dir/package.json" ]; then stack="node"
  elif [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ]; then stack="python"
  fi

  local repo_ok=1 counts="" notes=""

  if [ "$stack" = "node" ]; then
    # typecheck (cheap, optional)
    run_node_gate "$dir" "typecheck"; local tc=$?
    if [ "$tc" = "200" ]; then notes="${notes}typecheck:${C_DIM}n/a${C_RST} "
    elif [ "$tc" = "0" ]; then notes="${notes}typecheck:${C_GREEN}ok${C_RST} "
    else notes="${notes}typecheck:${C_RED}FAIL${C_RST} "; repo_ok=0; fi

    # lint (cheap, optional)
    run_node_gate "$dir" "lint"; local ln=$?
    if [ "$ln" = "200" ]; then notes="${notes}lint:${C_DIM}n/a${C_RST} "
    elif [ "$ln" = "0" ]; then notes="${notes}lint:${C_GREEN}ok${C_RST} "
    else notes="${notes}lint:${C_RED}FAIL${C_RST} "; repo_ok=0; fi

    # test (the gate that produces counts)
    run_node_gate "$dir" "test"; local te=$?
    if [ "$te" = "200" ]; then
      counts="no test script"; repo_ok=0
    else
      counts="$(parse_counts "$GATE_OUT")"
      [ "$te" = "0" ] || { repo_ok=0; LAST_FAIL_OUT="$GATE_OUT"; }
    fi

  elif [ "$stack" = "python" ]; then
    local out code
    if command -v uv >/dev/null 2>&1; then
      out="$( cd "$dir" && uv run pytest -q 2>&1 )"; code=$?
    elif [ -x "$dir/.venv/bin/pytest" ]; then
      out="$( cd "$dir" && .venv/bin/pytest -q 2>&1 )"; code=$?
    else
      out="$( cd "$dir" && python3 -m pytest -q 2>&1 )"; code=$?
    fi
    counts="$(parse_counts "$out")"
    [ "$code" = "0" ] || { repo_ok=0; LAST_FAIL_OUT="$out"; }

  else
    RESULT_LINES+=("${C_DIM}SKIP${C_RST}  $(printf '%-22s' "$name")  unknown stack")
    SKIP_COUNT=$((SKIP_COUNT+1)); return
  fi

  if [ "$repo_ok" = "1" ]; then
    RESULT_LINES+=("${C_GREEN}PASS${C_RST}  $(printf '%-22s' "$name")  ${C_BOLD}${counts}${C_RST}  ${C_DIM}[${stack}]${C_RST}  ${notes}")
    PASS_COUNT=$((PASS_COUNT+1))
  else
    RESULT_LINES+=("${C_RED}FAIL${C_RST}  $(printf '%-22s' "$name")  ${C_BOLD}${counts}${C_RST}  ${C_DIM}[${stack}]${C_RST}  ${notes}")
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
echo
echo "${C_BOLD}verify-all${C_RST} — checking ${#REPOS[@]} project(s)"
echo "${C_DIM}gates: typecheck → lint → test (corepack-pin-proof; local-runner fallback)${C_RST}"
echo

LAST_FAIL_OUT=""
for repo in "${REPOS[@]}"; do
  printf '%s· verifying %s …%s\n' "$C_DIM" "$(basename "$repo")" "$C_RST"
  verify_repo "$repo"
done

echo
echo "${C_BOLD}── dashboard ─────────────────────────────────────────────${C_RST}"
for line in "${RESULT_LINES[@]}"; do echo "$line"; done
echo "${C_BOLD}──────────────────────────────────────────────────────────${C_RST}"
printf '%ssummary:%s %s%d PASS%s  %s%d FAIL%s  %s%d SKIP%s\n' \
  "$C_BOLD" "$C_RST" \
  "$C_GREEN" "$PASS_COUNT" "$C_RST" \
  "$C_RED" "$FAIL_COUNT" "$C_RST" \
  "$C_DIM" "$SKIP_COUNT" "$C_RST"
echo

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
