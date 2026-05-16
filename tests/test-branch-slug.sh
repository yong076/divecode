#!/usr/bin/env bash
# RED test for Slice 7 — branch slug derivation.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUG="$DIVECODE_ROOT/bin/divecode-branch-slug"
PASS=0; FAIL=0

eq() { local d="$1" exp="$2" act="$3"; if [ "$exp" = "$act" ]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (expected: '$exp' got: '$act')"; FAIL=$((FAIL+1)); fi; }

echo "▸ Test 1 — kebab case"
eq "simple title" "add-insights-v2-panels" "$(bash "$SLUG" 'Add Insights v2 panels')"

echo "▸ Test 2 — strip articles"
eq "strip 'the'" "quick-brown-fox" "$(bash "$SLUG" 'The quick brown fox')"
eq "strip 'a'" "fix-bug" "$(bash "$SLUG" 'A fix bug')"
eq "strip 'an'" "implement-api" "$(bash "$SLUG" 'An implement API')"

echo "▸ Test 3 — collapse special chars"
eq "punctuation" "fix-login-error" "$(bash "$SLUG" 'Fix: login & error!')"
eq "multi space" "compact-spaces" "$(bash "$SLUG" '  compact   spaces  ')"

echo "▸ Test 4 — max length without word break"
eq "truncated at word boundary" "quick-brown-fox-jumps-over" "$(bash "$SLUG" 'The quick brown fox jumps over the lazy dog repeatedly' 30)"

echo "▸ Test 5 — short title untouched"
eq "below limit" "tiny" "$(bash "$SLUG" 'tiny' 50)"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
