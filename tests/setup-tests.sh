#!/usr/bin/env bash
# Real installation checks in an isolated source copy and HOME
set -euo pipefail
export LC_ALL=C
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
SRC="$WORK/source"
mkdir -p "$SRC"
for item in VERSION SSOT.md CONTEXT.md skills meta-skills doc-design axioms templates partials bin scripts dist zh-CN; do
  cp -R "$ROOT/$item" "$SRC/"
done
hosts=0
for lang in en zh; do
case "$lang" in en) LSRC="$SRC" ;; zh) LSRC="$SRC/zh-CN" ;; esac
for host in claude codex cursor grok antigravity antigravity-cli; do
  INSTALL_HOME="$WORK/home-$lang-$host"
  mkdir -p "$INSTALL_HOME"
  if ! HOME="$INSTALL_HOME" ACA_STATE_DIR="$INSTALL_HOME/.aca" bash "$SRC/scripts/setup.sh" --host "$host" --lang "$lang" --force > "$WORK/setup-$lang-$host.log" 2>&1; then
    cat "$WORK/setup-$lang-$host.log"
    exit 1
  fi
  SKILL_ROOT=$(HOME="$INSTALL_HOME" bash "$SRC/bin/aca-host-skill-root" "$host")
  case "$host" in
    antigravity) test "$SKILL_ROOT" = "$INSTALL_HOME/.gemini/config/skills" ;;
    antigravity-cli) test "$SKILL_ROOT" = "$INSTALL_HOME/.gemini/antigravity-cli/skills" ;;
  esac
  if [ "$host" = antigravity ] || [ "$host" = antigravity-cli ]; then
    literal_root=$(HOME='~' bash "$SRC/bin/aca-host-skill-root" "$host")
    grep -qF "$literal_root/aca/bin/aca-update-check" "$SKILL_ROOT/aca-update/SKILL.md"
    if grep -rqF '~/.claude/skills' "$SKILL_ROOT" --include=SKILL.md; then
      echo "FAIL: wrong runtime skill root for $host"; exit 1
    fi
  fi
  cmp "$LSRC/SSOT.md" "$SKILL_ROOT/aca/SSOT.md"
  test "$(HOME="$INSTALL_HOME" ACA_STATE_DIR="$INSTALL_HOME/.aca" bash "$SRC/bin/aca-config" get lang)" = "$lang"
  test "$(tr -d '[:space:]' < "$SKILL_ROOT/aca/VERSION")" = "$(tr -d '[:space:]' < "$SRC/VERSION")"
  while IFS= read -r tmpl; do
    skill=$(basename "$(dirname "$tmpl")")
    test -f "$SKILL_ROOT/$skill/SKILL.md"
    test "$(tr -d '[:space:]' < "$SKILL_ROOT/$skill/.aca-version")" = "$(tr -d '[:space:]' < "$SRC/VERSION")"
  done < <(find "$LSRC/skills" "$LSRC/meta-skills" -name SKILL.md.tmpl)
  # MANIFEST lists exactly the managed skills (aca-update-check relies on it to find partial installs)
  diff <(sort "$SKILL_ROOT/aca/MANIFEST") <(find "$LSRC/skills" "$LSRC/meta-skills" -name SKILL.md.tmpl -exec dirname {} \; | xargs -n1 basename | sort)
  HOME="$INSTALL_HOME" bash "$SRC/bin/aca-doc-graph-check" "$SKILL_ROOT/aca/doc-design" > "$WORK/graph-$lang-$host.log"
  grep -qF '](../../SSOT.md#' "$SKILL_ROOT/aca/doc-design/documents/interface.md"
  echo "ok - setup: $lang $host skill versions, SSOT and installed document links"
  hosts=$((hosts + 1))
done
done
echo "SETUP_HOSTS=$hosts RESULT OK"
