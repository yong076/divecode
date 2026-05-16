#!/usr/bin/env bash
# RED test driver for Slice 1 — Profile foundation.
# Asserts that bin/divecode-detect:
#   1. recommends "light" on a fresh solo repo
#   2. recommends "standard" on an active team repo
#   3. recommends "strict" on a production repo with CI + ARCH + CONTRIBUTING
#   4. writes .divecode/profile.yml on --confirm
#   5. skips detection when .divecode/profile.yml already exists

set -uo pipefail

DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DETECT="$DIVECODE_ROOT/bin/divecode-detect"

PASS=0
FAIL=0
TMP_ROOT=$(mktemp -d -t divecode-test-detect.XXXXXX)
trap 'rm -rf "$TMP_ROOT"' EXIT

assert_contains() {
  local desc="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  ✓ $desc"
    PASS=$((PASS+1))
  else
    echo "  ✗ $desc"
    echo "    expected to contain: $needle"
    echo "    actual: $haystack"
    FAIL=$((FAIL+1))
  fi
}

assert_file_exists() {
  local desc="$1" path="$2"
  if [ -f "$path" ]; then
    echo "  ✓ $desc"
    PASS=$((PASS+1))
  else
    echo "  ✗ $desc"
    echo "    missing file: $path"
    FAIL=$((FAIL+1))
  fi
}

git_init_quiet() {
  git init -q -b main "$1"
  git -C "$1" config user.email "test@local"
  git -C "$1" config user.name "Test"
  git -C "$1" config commit.gpgsign false
}

commit_as() {
  local repo="$1" email="$2" name="$3" msg="$4"
  GIT_AUTHOR_EMAIL="$email" GIT_AUTHOR_NAME="$name" \
  GIT_COMMITTER_EMAIL="$email" GIT_COMMITTER_NAME="$name" \
  git -C "$repo" commit -q -m "$msg"
}

setup_fresh_solo() {
  local d="$1"
  git_init_quiet "$d"
  echo "# test" > "$d/README.md"
  git -C "$d" add -A
  commit_as "$d" "solo@local" "Solo" "initial"
}

setup_active_team() {
  local d="$1"
  setup_fresh_solo "$d"
  mkdir -p "$d/tests" "$d/.github/workflows"
  echo "name: ci" > "$d/.github/workflows/ci.yml"
  echo "# tests" > "$d/tests/README.md"
  printf '# Big README\n%.0s' {1..200} > "$d/README.md"
  for i in 1 2 3 4 5; do
    echo "$i" > "$d/f$i.txt"
    git -C "$d" add -A
    commit_as "$d" "dev$((i%3))@team" "Dev$((i%3))" "commit $i"
  done
}

setup_production() {
  local d="$1"
  setup_active_team "$d"
  echo "# ARCHITECTURE" > "$d/ARCHITECTURE.md"
  echo "# CONTRIBUTING" > "$d/CONTRIBUTING.md"
  mkdir -p "$d/docs"
  echo "# docs" > "$d/docs/index.md"
  git -C "$d" add -A
  commit_as "$d" "lead@team" "Lead" "docs"
}

run_detect() {
  ( cd "$1" && bash "$DETECT" "${@:2}" )
}

echo "▸ Test 1 — fresh solo repo recommends light"
D1="$TMP_ROOT/fresh-solo"
setup_fresh_solo "$D1"
out=$(run_detect "$D1" 2>&1) || true
assert_contains "recommendation: light" "$out" "recommendation: light"

echo "▸ Test 2 — active team repo recommends standard"
D2="$TMP_ROOT/active-team"
setup_active_team "$D2"
out=$(run_detect "$D2" 2>&1) || true
assert_contains "recommendation: standard" "$out" "recommendation: standard"

echo "▸ Test 3 — production repo recommends strict"
D3="$TMP_ROOT/production"
setup_production "$D3"
out=$(run_detect "$D3" 2>&1) || true
assert_contains "recommendation: strict" "$out" "recommendation: strict"

echo "▸ Test 4 — --confirm persists to .divecode/profile.yml"
D4="$TMP_ROOT/persist"
setup_active_team "$D4"
run_detect "$D4" --confirm > /dev/null 2>&1 || true
assert_file_exists "profile.yml created" "$D4/.divecode/profile.yml"
if [ -f "$D4/.divecode/profile.yml" ]; then
  assert_contains "profile.yml has 'kind: standard'" "$(cat "$D4/.divecode/profile.yml")" "kind: standard"
fi

echo "▸ Test 5 — existing profile.yml skips re-detection"
D5="$TMP_ROOT/already-set"
setup_fresh_solo "$D5"
mkdir -p "$D5/.divecode"
echo "kind: strict" > "$D5/.divecode/profile.yml"
out=$(run_detect "$D5" 2>&1) || true
assert_contains "already configured" "$out" "already configured"
assert_contains "preserves explicit profile" "$out" "kind: strict"

echo ""
echo "─────────────────────────────"
echo " PASS: $PASS   FAIL: $FAIL"
echo "─────────────────────────────"
[ "$FAIL" -eq 0 ]
