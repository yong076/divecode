#!/usr/bin/env bash
# RED test for Slice 3 — lore cascade reader.

set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CITE="$DIVECODE_ROOT/bin/divecode-lore-cite"

PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-lore.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d"; echo "    expected: $n"; echo "    actual:   ${h:0:200}"; FAIL=$((FAIL+1)); fi; }
refute() { local d="$1" h="$2" n="$3"; if [[ "$h" != *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (unexpectedly found: $n)"; FAIL=$((FAIL+1)); fi; }

USER_LORE="$TMP/user/.divecode/lore"
PROJ="$TMP/proj"
PROJ_LORE="$PROJ/.divecode/lore"
mkdir -p "$USER_LORE" "$PROJ_LORE"

# User-global entries
cat > "$USER_LORE/never-mock-db.md" <<EOF
---
name: never-mock-db
kind: Constraint
scope: user
---
Integration tests must hit a real database, not mocks.
EOF

cat > "$USER_LORE/skip-shared.md" <<EOF
---
name: skip-shared
kind: Directive
scope: user
---
This entry exists in both scopes; project-local should win on duplicate.
PROVENANCE: user
EOF

# Project-local entries
cat > "$PROJ_LORE/cache-stampede.md" <<EOF
---
name: cache-stampede
kind: Directive
scope: project
---
All Redis caches use jittered TTL to avoid stampedes.
EOF

cat > "$PROJ_LORE/skip-shared.md" <<EOF
---
name: skip-shared
kind: Directive
scope: project
---
This entry exists in both scopes; project-local should win on duplicate.
PROVENANCE: project
EOF

cat > "$PROJ_LORE/unrelated.md" <<EOF
---
name: unrelated
kind: Constraint
scope: project
---
Use Korean for all customer support replies.
EOF

echo "▸ Test 1 — cascade reads both scopes (multi-keyword query)"
out=$(HOME="$TMP/user" bash "$CITE" "database cache" --project "$PROJ" 2>&1) || true
assert "cite includes user-scope db rule" "$out" "never-mock-db"
assert "cite includes project-scope cache rule" "$out" "cache-stampede"

echo "▸ Test 2 — project-local overrides user-global on same name (name-matching)"
out_dedup=$(HOME="$TMP/user" bash "$CITE" "skip-shared" --project "$PROJ" 2>&1) || true
assert "skip-shared cited" "$out_dedup" "skip-shared"
assert "project provenance wins" "$out_dedup" "PROVENANCE: project"
refute "user provenance does not appear" "$out_dedup" "PROVENANCE: user"

echo "▸ Test 3 — relevance ranking filters unrelated entries"
out2=$(HOME="$TMP/user" bash "$CITE" "database cache" --project "$PROJ" 2>&1) || true
refute "unrelated korean-support rule excluded" "$out2" "Use Korean for all customer"

echo "▸ Test 4 — output uses agent-flow 'Relevant lore' envelope"
assert "envelope marker present" "$out" "Relevant lore"

echo "▸ Test 5 — missing dirs degrade gracefully"
out3=$(HOME="$TMP/empty" bash "$CITE" "anything" --project "$TMP/empty-proj" 2>&1)
EXIT=$?
[ "$EXIT" -eq 0 ] && { echo "  ✓ exits 0 with no lore dirs"; PASS=$((PASS+1)); } || { echo "  ✗ exit $EXIT"; FAIL=$((FAIL+1)); }
assert "states no lore found" "$out3" "no lore"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
