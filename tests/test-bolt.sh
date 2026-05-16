#!/usr/bin/env bash
# RED test for Slice 2 — bolt mechanic.

set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOLT_NEW="$DIVECODE_ROOT/bin/divecode-bolt-new"
BOLT_CURRENT="$DIVECODE_ROOT/bin/divecode-bolt-current"

PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-bolt.XXXXXX)
export DIVECODE_STATE_DIR="$TMP/state"
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (expected: $n / actual: $h)"; FAIL=$((FAIL+1)); fi; }
assert_file() { local d="$1" p="$2"; if [ -f "$p" ]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (missing: $p)"; FAIL=$((FAIL+1)); fi; }

PROJ="$TMP/proj"
mkdir -p "$PROJ"

echo "▸ Test 1 — bolt-new creates bolt directory"
out=$(bash "$BOLT_NEW" --profile standard --size M --project "$PROJ" 2>&1) || true
assert "bolt-new prints bolt id" "$out" "bolt:"
BOLT_ID=$(echo "$out" | grep '^bolt:' | head -1 | awk '{print $2}')
assert_file "bolt.yml exists" "$DIVECODE_STATE_DIR/bolts/$BOLT_ID/bolt.yml"

echo "▸ Test 2 — bolt.yml has required fields"
if [ -f "$DIVECODE_STATE_DIR/bolts/$BOLT_ID/bolt.yml" ]; then
  body=$(cat "$DIVECODE_STATE_DIR/bolts/$BOLT_ID/bolt.yml")
  assert "has kind" "$body" "kind: standard"
  assert "has size" "$body" "size: M"
  assert "has project_path" "$body" "project_path:"
  assert "has status active" "$body" "status: active"
fi

echo "▸ Test 3 — bolt-new on same project resumes existing"
out2=$(bash "$BOLT_NEW" --profile standard --size M --project "$PROJ" 2>&1) || true
BOLT_ID2=$(echo "$out2" | grep '^bolt:' | head -1 | awk '{print $2}')
if [ "$BOLT_ID" = "$BOLT_ID2" ]; then echo "  ✓ same bolt id reused"; PASS=$((PASS+1)); else echo "  ✗ new bolt created instead of resume ($BOLT_ID vs $BOLT_ID2)"; FAIL=$((FAIL+1)); fi
assert "output says resumed" "$out2" "resumed"

echo "▸ Test 4 — bolt-current returns active bolt for project"
out3=$(bash "$BOLT_CURRENT" --project "$PROJ" 2>&1) || true
assert "bolt-current returns bolt id" "$out3" "$BOLT_ID"

echo "▸ Test 5 — bolt-current with no active bolt returns nothing"
PROJ2="$TMP/proj-empty"
mkdir -p "$PROJ2"
out4=$(bash "$BOLT_CURRENT" --project "$PROJ2" 2>&1) || true
assert "no active bolt message" "$out4" "no active bolt"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
