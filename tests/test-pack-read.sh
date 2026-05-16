#!/usr/bin/env bash
# Slice 1 — pack reader + redis-cache seed verification.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READ="$DIVECODE_ROOT/bin/divecode-pack-read"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-pack-test.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n / got: ${h:0:200})"; FAIL=$((FAIL+1)); fi; }
ec() { local d="$1" exp="$2" act="$3"; if [ "$exp" = "$act" ]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (expected exit $exp, got $act)"; FAIL=$((FAIL+1)); fi; }

echo "▸ Test 1 — read redis-cache pack triggers"
out=$(bash "$READ" --triggers "$DIVECODE_ROOT/packs/redis-cache" 2>&1) || true
assert "includes 'redis' trigger" "$out" "redis"
assert "includes 'ttl' trigger" "$out" "ttl"
assert "includes 'upstash' trigger" "$out" "upstash"

echo "▸ Test 2 — read pack metadata (name + title)"
out=$(bash "$READ" --meta "$DIVECODE_ROOT/packs/redis-cache" 2>&1) || true
assert "name: redis-cache" "$out" "name: redis-cache"
assert "has title field" "$out" "title:"

echo "▸ Test 3 — read pack questions content"
out=$(bash "$READ" --questions "$DIVECODE_ROOT/packs/redis-cache" 2>&1) || true
assert "questions content present" "$out" "TTL"

echo "▸ Test 4 — missing pack.yml errors out cleanly"
mkdir -p "$TMP/empty-pack"
bash "$READ" --triggers "$TMP/empty-pack" > /dev/null 2>&1
ec "exits non-zero on missing pack.yml" "1" "$?"

echo "▸ Test 5 — pack with empty triggers fails validation"
mkdir -p "$TMP/no-triggers"
cat > "$TMP/no-triggers/pack.yml" <<EOF
name: no-triggers
title: Bad pack
triggers:
severity_default: info
EOF
bash "$READ" --triggers "$TMP/no-triggers" > /dev/null 2>&1
ec "exits non-zero on empty triggers" "1" "$?"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
