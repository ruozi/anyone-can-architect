#!/usr/bin/env bash
# Anyone Can Architect install / update for every installed host
#
# Run by `npx anyone-can-architect install`; /aca-update runs the same command with @latest
# Workflow: pick hosts → setup --force per host → verify installed versions
#
# Usage:
#   bash scripts/install.sh                      # all installed hosts; auto detect on a fresh machine
#   bash scripts/install.sh --host claude        # only this host
#   bash scripts/install.sh --lang zh            # install the Chinese skills (default: last used language, else English)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ─── Parse args ───────────────────────────────────────────
HOST="auto"
LANG_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --host=*) HOST="${1#--host=}"; shift ;;
    --lang) LANG_ARGS=(--lang "$2"); shift 2 ;;
    --lang=*) LANG_ARGS=(--lang "${1#--lang=}"); shift ;;
    *) echo "Error: unknown argument: $1" >&2; exit 1 ;;
  esac
done

VERSION=$(tr -d '[:space:]' < "$ROOT/VERSION")
HOSTS="claude codex cursor grok antigravity antigravity-cli"
echo "[install] Anyone Can Architect $VERSION"

# Verify installed root and every managed skill marker
verify_host() {
  local host="$1" skill_root skill marker
  skill_root=$(bash "$ROOT/bin/aca-host-skill-root" "$host") || return 1
  if [ ! -r "$skill_root/aca/VERSION" ] || [ "$(tr -d '[:space:]' < "$skill_root/aca/VERSION")" != "$VERSION" ]; then
    echo "Error: installed root version differs for $host." >&2
    return 1
  fi
  [ -r "$skill_root/aca/MANIFEST" ] || { echo "Error: installed manifest missing for $host." >&2; return 1; }
  while IFS= read -r skill; do
    [ -n "$skill" ] || continue
    marker="$skill_root/$skill/.aca-version"
    if [ ! -r "$marker" ] || [ "$(tr -d '[:space:]' < "$marker")" != "$VERSION" ]; then
      echo "Error: installed skill missing or version differs: $host/$skill." >&2
      return 1
    fi
  done < "$skill_root/aca/MANIFEST"
}

install_host() {
  bash "$ROOT/scripts/setup.sh" --host "$1" --force ${LANG_ARGS[@]+"${LANG_ARGS[@]}"} && verify_host "$1"
}

if [ "$HOST" != "auto" ]; then
  install_host "$HOST"
  echo "[done] Anyone Can Architect $VERSION installed for $HOST"
  exit 0
fi

# bug #20: auto installs **all installed hosts**, otherwise an update run from codex may refresh only ~/.claude
any=0; failures=""
for h in $HOSTS; do
  skills_root=$(bash "$ROOT/bin/aca-host-skill-root" "$h")
  [ -d "$skills_root/aca" ] || continue
  echo "  → host $h"
  # A failure on one host must not stop the others
  if install_host "$h"; then any=1; else failures="$failures $h"; fi
done

# No installed host (and no failures) → fresh machine: let setup detect the host
if [ "$any" -eq 0 ] && [ -z "$failures" ]; then
  bash "$ROOT/scripts/setup.sh" --host auto --force ${LANG_ARGS[@]+"${LANG_ARGS[@]}"}
  detected=0
  for h in $HOSTS; do
    skills_root=$(bash "$ROOT/bin/aca-host-skill-root" "$h")
    [ -d "$skills_root/aca" ] || continue
    verify_host "$h"
    detected=1
  done
  [ "$detected" -eq 1 ] || { echo "Error: no installed host found after setup." >&2; exit 1; }
fi
if [ -n "$failures" ]; then
  echo "Error: install failed for hosts:$failures (all other installed hosts were attempted)" >&2
  exit 1
fi
echo "[done] Anyone Can Architect $VERSION installed"
