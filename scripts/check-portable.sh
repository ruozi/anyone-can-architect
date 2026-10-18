#!/usr/bin/env bash
# check-portable.sh — lint: user-facing scripts must support both GNU(Linux) + BSD(macOS)
#
# ── Forward engineering standards(#30) ──────────────────────────────────────────────
# All user-facing shell scripts under `scripts/` `bin/` `.ci/` **must support both GNU coreutils
# (Linux) and BSD/macOS coreutils**, because Anyone Can Architect users work on both Mac and Linux machines
# Ban GNU-only syntax; use these portable alternatives:
#
#   sed -i "EXPR" file   → tmp=$(mktemp); sed "EXPR" file > "$tmp" && mv "$tmp" file
#                          (or `sed -i.bak "EXPR" file && rm -f file.bak`, or `perl -pi -e`)
#   grep -P PATTERN      → POSIX character classes([[:digit:]] / [[:alpha:]] …)
#   date -d STR          → date -j -f FMT(or detect GNU `gdate`)
#   stat -c %Y file      → stat -c %Y file 2>/dev/null || stat -f %m file
#   readlink -f path     → pure sh resolution(or detect `greadlink -f`)
#   xargs -r             → printf '%s\n' "$x" | xargs(handle empty input)
#
# Turn "convention" into "enforcement": CI runs this lint on push and PR (see .github/workflows/ci.yml) and fails on violations
# Usage: bash scripts/check-portable.sh
# ────────────────────────────────────────────────────────────────────
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

violations=0

# Scan for a GNU-only pattern; report matches (exclude full-line comments + this script itself)
scan() {
  pattern="$1"; desc="$2"; fix="$3"
  hits=$(grep -rnE "$pattern" scripts bin .ci 2>/dev/null \
           | grep -vE ':[0-9]+:[[:space:]]*#' \
           | grep -v 'scripts/check-portable.sh' || true)
  if [ -n "$hits" ]; then
    echo "✗ GNU-only: $desc"
    echo "  → Use: $fix"
    printf '%s\n' "$hits" | sed 's/^/    /'
    echo ""
    violations=$((violations + 1))
  fi
}

# `sed -i ` / `sed -i"` / `sed -i'` = GNU syntax or fails on BSD (portable syntax uses `sed -i.bak` with a suffix)
scan 'sed[[:space:]]+-i[[:space:]"'"'"']'   "sed -i without a backup suffix(unterminated on BSD/macOS)" "tmp+mv / sed -i.bak ... && rm / perl -pi"
scan 'grep[[:space:]]+-[A-Za-z]*P'          "grep -P(no PCRE on BSD)"                              "POSIX character classes such as [[:digit:]]"
scan 'date[[:space:]]+-d[[:space:]]'        "date -d(unsupported on BSD)"                              "date -j -f / detect gdate"
scan 'stat[[:space:]]+-c[[:space:]]'        "stat -c(BSD uses -f; fallback required)"                  "stat -c %Y 2>/dev/null || stat -f %m"
scan 'readlink[[:space:]]+-f[[:space:]]'    "readlink -f(no -f on BSD)"                           "pure sh resolution / detect greadlink"

if [ "$violations" -gt 0 ]; then
  echo "❌ check-portable: found $violations categories of GNU-only syntax — see fixes above(user-facing scripts must support both GNU+BSD)"
  exit 1
fi
echo "✓ check-portable: no GNU-only syntax in scripts/ bin/ .ci/"
