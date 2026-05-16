#!/usr/bin/env bash
# RED test for Slice 4 — sibling repo discovery heuristic.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIB="$DIVECODE_ROOT/bin/divecode-sibling-repos"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-audit.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n / got: ${h:0:160})"; FAIL=$((FAIL+1)); fi; }
refute() { local d="$1" h="$2" n="$3"; if [[ "$h" != *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (unexpected: $n)"; FAIL=$((FAIL+1)); fi; }

mkdir -p "$TMP/agent-cat" "$TMP/agent-cat-windows" "$TMP/agent-cat-releases" \
         "$TMP/agentcat-connectors" "$TMP/agentcat-telemetry" \
         "$TMP/unrelated-project" "$TMP/AgentCatSite"

echo "▸ Test 1 — dashed prefix match (agent-cat → agent-cat-*)"
out=$(bash "$SIB" "$TMP/agent-cat" 2>&1) || true
assert "finds agent-cat-windows" "$out" "agent-cat-windows"
assert "finds agent-cat-releases" "$out" "agent-cat-releases"

echo "▸ Test 2 — collapsed prefix match (agentcat-*)"
assert "finds agentcat-connectors" "$out" "agentcat-connectors"
assert "finds agentcat-telemetry" "$out" "agentcat-telemetry"

echo "▸ Test 3 — title-cased variant (AgentCatSite)"
assert "finds AgentCatSite" "$out" "AgentCatSite"

echo "▸ Test 4 — unrelated project excluded"
refute "excludes unrelated-project" "$out" "unrelated-project"

echo "▸ Test 5 — does not list itself"
refute "does not include source project" "$out" "siblings: ... agent-cat$"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
