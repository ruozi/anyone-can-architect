#!/usr/bin/env bash
# i18n-parity — every zh-CN source has an English counterpart with the same structure
#
# For each authored source under zh-CN/ (Markdown, skill templates, examples; generated SKILL.md and dist/ excluded):
#   MISSING_EN <path>        the English file at the same path under the repo root is missing
#   HEADINGS <path> zh/en    the number of headings outside code fences differs
#   LINKS <path> zh/en       the number of inline Markdown links differs
#   LEFTOVER_ZH <path> <n>   the English file still contains Chinese characters outside code fences
#                            (files may opt out of specific lines with <!-- i18n-keep --> on the same line)
# Output ends with RESULT OK | FAIL; exit 1 on FAIL
set -euo pipefail
export LC_ALL=C
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZH="$ROOT/zh-CN"

count() {  # $1=file $2=heading|link|cjk
  awk -v mode="$2" '
    /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    mode == "heading" && /^#{1,6} / { n++ }
    mode == "link" { s = $0; while (match(s, /\]\([^)]+\)/)) { n++; s = substr(s, RSTART + RLENGTH) } }
    mode == "cjk" && !/i18n-keep/ && /[\xe4-\xe9][\x80-\xbf][\x80-\xbf]/ { n++ }
    END { print n + 0 }' "$1"
}

fail=0
while IFS= read -r -d '' f; do
  rel="${f#$ZH/}"
  case "$rel" in dist/*|*/SKILL.md) continue ;; esac
  en="$ROOT/$rel"
  if [ ! -f "$en" ]; then echo "MISSING_EN $rel"; fail=1; continue; fi
  hz=$(count "$f" heading); he=$(count "$en" heading)
  [ "$hz" = "$he" ] || { echo "HEADINGS $rel $hz/$he"; fail=1; }
  lz=$(count "$f" link); le=$(count "$en" link)
  [ "$lz" = "$le" ] || { echo "LINKS $rel $lz/$le"; fail=1; }
  cj=$(count "$en" cjk)
  [ "$cj" = 0 ] || { echo "LEFTOVER_ZH $rel $cj"; fail=1; }
done < <(find "$ZH" -type f \( -name '*.md' -o -name '*.tmpl' -o -name '*.example' \) -print0 | sort -z)

if [ "$fail" -eq 0 ]; then echo "RESULT OK"; else echo "RESULT FAIL"; exit 1; fi
