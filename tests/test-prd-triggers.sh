#!/usr/bin/env bash
# Slice 2 — trigger matcher.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRIG="$DIVECODE_ROOT/bin/divecode-prd-triggers"
FIXTURE="$DIVECODE_ROOT/tests/fixtures/prd-admin-dashboard.md"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-trig-test.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n)"; FAIL=$((FAIL+1)); fi; }
refute() { local d="$1" h="$2" n="$3"; if [[ "$h" != *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (unexpected: $n)"; FAIL=$((FAIL+1)); fi; }

echo "▸ Test 1 — admin dashboard PRD fires redis-cache pack"
out=$(bash "$TRIG" --prd "$FIXTURE" --packs-dir "$DIVECODE_ROOT/packs" 2>&1) || true
assert "pack listed" "$out" "pack: redis-cache"
assert "redis trigger matched" "$out" "redis"
assert "ttl trigger matched" "$out" "ttl"
assert "upstash trigger matched" "$out" "upstash"

echo "▸ Test 2 — word boundary: 'ttl' should NOT match 'throttle'"
cat > "$TMP/throttle-only.md" <<EOF
# PRD
We need throttle and rate limits.
No caching.
EOF
out=$(bash "$TRIG" --prd "$TMP/throttle-only.md" --packs-dir "$DIVECODE_ROOT/packs" 2>&1) || true
refute "no redis-cache pack fired" "$out" "pack: redis-cache"

echo "▸ Test 3 — empty PRD → no matches"
echo "" > "$TMP/empty.md"
out=$(bash "$TRIG" --prd "$TMP/empty.md" --packs-dir "$DIVECODE_ROOT/packs" 2>&1) || true
assert "reports no packs matched" "$out" "no packs"

echo "▸ Test 4 — case insensitivity"
cat > "$TMP/caps.md" <<EOF
# PRD: REDIS-based caching layer with TTL of 5 min.
EOF
out=$(bash "$TRIG" --prd "$TMP/caps.md" --packs-dir "$DIVECODE_ROOT/packs" 2>&1) || true
assert "redis-cache matched on REDIS uppercase" "$out" "pack: redis-cache"

echo "▸ Test 5 — multi-word trigger (cache stampede)"
cat > "$TMP/stampede.md" <<EOF
# PRD: prevent cache stampede when keys expire under load.
EOF
out=$(bash "$TRIG" --prd "$TMP/stampede.md" --packs-dir "$DIVECODE_ROOT/packs" 2>&1) || true
assert "matches multi-word trigger" "$out" "cache stampede"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
