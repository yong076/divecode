#!/usr/bin/env bash
# Slice 5 — checklists → packs migration.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIG="$DIVECODE_ROOT/bin/divecode-pack-migrate"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-pack-mig.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

afile() { if [ -f "$2" ]; then echo "  ✓ $1"; PASS=$((PASS+1)); else echo "  ✗ $1 (missing: $2)"; FAIL=$((FAIL+1)); fi; }
nofile() { if [ ! -f "$2" ]; then echo "  ✓ $1"; PASS=$((PASS+1)); else echo "  ✗ $1 (unexpected: $2)"; FAIL=$((FAIL+1)); fi; }
contains() { if [[ "$2" == *"$3"* ]]; then echo "  ✓ $1"; PASS=$((PASS+1)); else echo "  ✗ $1 (need: $3)"; FAIL=$((FAIL+1)); fi; }

# Fixture: 3 checklists, 1 already mapped (redis), 2 new (security, perf)
mkdir -p "$TMP/checklists" "$TMP/packs/redis-cache"
echo "# Redis checklist" > "$TMP/checklists/redis.md"
echo "# Security checklist" > "$TMP/checklists/security.md"
echo "# Perf checklist" > "$TMP/checklists/perf.md"
cat > "$TMP/packs/redis-cache/pack.yml" <<EOF
name: redis-cache
title: existing pack
triggers: redis
EOF

echo "▸ Test 1 — creates packs for new checklists"
bash "$MIG" --checklists "$TMP/checklists" --packs "$TMP/packs" > "$TMP/out1" 2>&1 || true
afile "security pack created" "$TMP/packs/security/pack.yml"
afile "security questions populated" "$TMP/packs/security/questions.md"
afile "perf pack created" "$TMP/packs/performance/pack.yml"

echo "▸ Test 2 — skips already-packed checklists"
# redis pack pre-existed; should not be overwritten
out=$(cat "$TMP/packs/redis-cache/pack.yml")
contains "existing redis-cache pack preserved" "$out" "existing pack"

echo "▸ Test 3 — idempotent (re-run is a no-op)"
bash "$MIG" --checklists "$TMP/checklists" --packs "$TMP/packs" > "$TMP/out2" 2>&1 || true
contains "second-run reports skipping" "$(cat "$TMP/out2")" "skipped"

echo "▸ Test 4 — questions.md copied from checklist content"
contains "security pack carries checklist content" "$(cat "$TMP/packs/security/questions.md")" "Security checklist"

echo "▸ Test 5 — scaffold contains failure-modes/test-ideas/example-patterns stubs"
afile "security failure-modes stub" "$TMP/packs/security/failure-modes.md"
afile "security test-ideas stub" "$TMP/packs/security/test-ideas.md"
afile "security example-patterns stub" "$TMP/packs/security/example-patterns.md"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
