#!/usr/bin/env bash
# RED test for Slice 11 — pr-watch status routing.
# Mocks gh responses via fixture files; verifies status + suggested route.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PR_WATCH="$DIVECODE_ROOT/bin/divecode-pr-watch"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-pr-watch.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

contains() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n / got: ${h:0:160})"; FAIL=$((FAIL+1)); fi; }

# Fixture 1 — green PR
cat > "$TMP/green.json" <<'EOF'
{"state":"OPEN","mergeable":"MERGEABLE","reviewDecision":"APPROVED","statusCheckRollup":[{"name":"ci","conclusion":"SUCCESS"}],"reviews":[],"comments":[]}
EOF

# Fixture 2 — has_comments PR
cat > "$TMP/comments.json" <<'EOF'
{"state":"OPEN","mergeable":"MERGEABLE","reviewDecision":"CHANGES_REQUESTED","statusCheckRollup":[{"name":"ci","conclusion":"SUCCESS"}],"reviews":[{"id":"r1","body":"please fix line 42"}],"comments":[{"id":"c1","body":"why this approach?"}]}
EOF

# Fixture 3 — ci_failed PR
cat > "$TMP/ci_failed.json" <<'EOF'
{"state":"OPEN","mergeable":"MERGEABLE","reviewDecision":"REVIEW_REQUIRED","statusCheckRollup":[{"name":"ci","conclusion":"FAILURE"},{"name":"lint","conclusion":"SUCCESS"}],"reviews":[],"comments":[]}
EOF

# Fixture 4 — pending CI
cat > "$TMP/pending.json" <<'EOF'
{"state":"OPEN","mergeable":"UNKNOWN","reviewDecision":null,"statusCheckRollup":[{"name":"ci","conclusion":null,"status":"IN_PROGRESS"}],"reviews":[],"comments":[]}
EOF

# Fixture 5 — closed (not merged)
cat > "$TMP/closed.json" <<'EOF'
{"state":"CLOSED","mergeable":"MERGEABLE","reviewDecision":"APPROVED","statusCheckRollup":[],"reviews":[],"comments":[]}
EOF

# Fixture 6 — merged
cat > "$TMP/merged.json" <<'EOF'
{"state":"MERGED","mergeable":"MERGEABLE","reviewDecision":"APPROVED","statusCheckRollup":[],"reviews":[],"comments":[]}
EOF

echo "▸ Test 1 — green PR"
out=$(bash "$PR_WATCH" --fixture "$TMP/green.json" 2>&1) || true
contains "status: green" "$out" "status: green"
contains "route: merge" "$out" "route: merge"

echo "▸ Test 2 — has_comments"
out=$(bash "$PR_WATCH" --fixture "$TMP/comments.json" 2>&1) || true
contains "status: has_comments" "$out" "status: has_comments"
contains "route: fix-loop" "$out" "route: fix-loop"

echo "▸ Test 3 — ci_failed"
out=$(bash "$PR_WATCH" --fixture "$TMP/ci_failed.json" 2>&1) || true
contains "status: ci_failed" "$out" "status: ci_failed"
contains "route: fix-loop" "$out" "route: fix-loop"
contains "failed check listed" "$out" "ci"

echo "▸ Test 4 — pending"
out=$(bash "$PR_WATCH" --fixture "$TMP/pending.json" 2>&1) || true
contains "status: pending" "$out" "status: pending"
contains "route: block" "$out" "route: block"

echo "▸ Test 5 — closed (not merged)"
out=$(bash "$PR_WATCH" --fixture "$TMP/closed.json" 2>&1) || true
contains "status: closed" "$out" "status: closed"
contains "route: block" "$out" "route: block"

echo "▸ Test 6 — merged"
out=$(bash "$PR_WATCH" --fixture "$TMP/merged.json" 2>&1) || true
contains "status: merged" "$out" "status: merged"
contains "route: cleanup" "$out" "route: cleanup"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
