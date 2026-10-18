#!/usr/bin/env bash
# Update behavior regression with isolated HOME, a mock npm, and an isolated install fixture
# No network access or changes to real installed skills

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPDATE_CHECK="$ROOT/bin/aca-update-check"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
OUT="$WORK/out.txt"

PASS=0
FAIL=0
RC=0

run() {  # run <cmd...> ;output goes to $OUT, exit code to $RC (without triggering set -e)
  RC=0
  "$@" > "$OUT" 2>&1 || RC=$?
}

check() {  # check <name> <expected_rc> [required string]... ;prefix "!" = must not contain
  local name="$1" want_rc="$2"; shift 2
  local ok=1 pat
  [ "$RC" = "$want_rc" ] || ok=0
  for pat in "$@"; do
    case "$pat" in
      !*) grep -qF -- "${pat#!}" "$OUT" && ok=0 ;;
      *)  grep -qF -- "$pat" "$OUT" || ok=0 ;;
    esac
  done
  if [ "$ok" -eq 1 ]; then
    PASS=$((PASS + 1)); echo "ok - $name"
  else
    FAIL=$((FAIL + 1)); echo "NOT OK - $name (rc=$RC want=$want_rc)"
    sed 's/^/    | /' "$OUT"
  fi
}

new_tree() {  # new_tree <name> → global D=new directory
  D="$WORK/$1"; rm -rf "$D"; mkdir -p "$D"
}

# Mock npm: `npm view <pkg> version` prints $FAKE_LATEST (empty = registry unavailable)
MOCK_NPM="$WORK/npm"
printf '#!/usr/bin/env bash\n[ "$1 $3" = "view version" ] || exit 2\n[ -n "${FAKE_LATEST:-}" ] || exit 1\necho "$FAKE_LATEST"\n' > "$MOCK_NPM"
chmod +x "$MOCK_NPM"

uc() {  # uc <home> <latest> → run the update check
  run env HOME="$1" ACA_NPM="$MOCK_NPM" FAKE_LATEST="$2" bash "$UPDATE_CHECK"
}

# ════════════════ aca-update-check ════════════════

new_tree updatecheck
UP_HOME="$D/home"
mkdir -p "$UP_HOME/.codex/skills/aca" "$UP_HOME/.codex/skills/aca-release"
printf '4.11.1\n' > "$UP_HOME/.codex/skills/aca/VERSION"
printf 'aca-release\n' > "$UP_HOME/.codex/skills/aca/MANIFEST"
printf '4.11.0\n' > "$UP_HOME/.codex/skills/aca-release/.aca-version"
uc "$UP_HOME" 4.11.1
check "update: one outdated installed skill still prompts reinstallation" 0 "UPDATE_AVAILABLE 4.11.0 4.11.1"
printf '4.11.1\n' > "$UP_HOME/.codex/skills/aca-release/.aca-version"
uc "$UP_HOME" 4.11.1
check "update: explicitly reports when all installed skills match the latest release" 0 "UP_TO_DATE 4.11.1"
uc "$UP_HOME" 4.12.0
check "update: newer npm release prompts update" 0 "UPDATE_AVAILABLE 4.11.1 4.12.0"

# Antigravity directories must participate in global update checks
for h in antigravity antigravity-cli; do
  skill_root=$(HOME="$UP_HOME" bash "$ROOT/bin/aca-host-skill-root" "$h")
  mkdir -p "$skill_root/aca" "$skill_root/aca-release"
  printf '4.11.1\n' > "$skill_root/aca/VERSION"
  printf 'aca-release\n' > "$skill_root/aca/MANIFEST"
  printf '4.11.0\n' > "$skill_root/aca-release/.aca-version"
  uc "$UP_HOME" 4.11.1
  check "update: $h stale marker requests repair" 0 "UPDATE_AVAILABLE 4.11.0 4.11.1"
  printf '4.11.1\n' > "$skill_root/aca-release/.aca-version"
  uc "$UP_HOME" 4.11.1
  check "update: $h matching markers are current" 0 "UP_TO_DATE 4.11.1"
done

# Partial installs
rm "$UP_HOME/.codex/skills/aca-release/.aca-version"
uc "$UP_HOME" 4.11.1
check "update: skill listed in the manifest without a marker requests repair" 0 "UPDATE_AVAILABLE unknown 4.11.1"
printf '4.11.1\n' > "$UP_HOME/.codex/skills/aca-release/.aca-version"
rm "$UP_HOME/.codex/skills/aca/MANIFEST"
uc "$UP_HOME" 4.11.1
check "update: install without a manifest requests repair" 0 "UPDATE_AVAILABLE 4.11.1 4.11.1"

# Explicit failure states
uc "$UP_HOME" ""
check "update: registry unavailable is not up to date" 1 "CHECK_FAILED REGISTRY_UNAVAILABLE"
run env HOME="$UP_HOME" ACA_NPM="$D/no-npm" bash "$UPDATE_CHECK"
check "update: missing npm is not up to date" 1 "CHECK_FAILED NPM_UNAVAILABLE"
uc "$D/empty-home" 4.11.1
check "update: nothing installed is reported, not up to date" 1 "CHECK_FAILED NOT_INSTALLED"

# ════════════════ scripts/install.sh ════════════════

# Isolated package fixture: real install.sh and host paths, mock setup.sh that records calls and writes install state
new_tree installflow
PKG="$D/pkg"
UP_HOME="$D/home"
mkdir -p "$PKG/scripts" "$PKG/bin" "$UP_HOME/.codex/skills/aca" "$UP_HOME/.claude/skills/aca"
cp "$ROOT/scripts/install.sh" "$PKG/scripts/install.sh"
cp "$ROOT/bin/aca-host-skill-root" "$PKG/bin/"
for h in antigravity antigravity-cli; do
  skill_root=$(HOME="$UP_HOME" bash "$ROOT/bin/aca-host-skill-root" "$h")
  mkdir -p "$skill_root/aca"
done
printf '1.1.0\n' > "$PKG/VERSION"
cat > "$PKG/scripts/setup.sh" <<'EOF'
#!/usr/bin/env bash
host="" ; lang=""
while [ $# -gt 0 ]; do
  case "$1" in --host) host="$2"; shift 2 ;; --lang) lang="$2"; shift 2 ;; *) shift ;; esac
done
[ "$host" = auto ] && host=claude
[ "${FAIL_HOST:-}" = "$host" ] && { echo "setup failed:$host" >&2; exit 1; }
root=$(bash bin/aca-host-skill-root "$host")
version=$(cat VERSION)
echo "setup:$host:${lang:-default}" >> "$HOME/events"
mkdir -p "$root/aca" "$root/aca-demo"
printf '%s\n' "$version" > "$root/aca/VERSION"
printf 'aca-demo\n' > "$root/aca/MANIFEST"
if [ "${OMIT_MARKER:-0}" != 1 ]; then
  printf '%s\n' "$version" > "$root/aca-demo/.aca-version"
fi
EOF

run env HOME="$UP_HOME" bash "$PKG/scripts/install.sh"
check "install: refreshes every installed host" 0 "[done] Anyone Can Architect 1.1.0 installed"
run bash -c 'for h in codex claude antigravity antigravity-cli; do grep -q "^setup:$h:default$" "$1/events" || exit 1; done' _ "$UP_HOME"
check "install: codex, claude and both Antigravity targets refreshed" 0
uc "$UP_HOME" 1.1.0
check "install: update check is current after install" 0 "UP_TO_DATE 1.1.0"

: > "$UP_HOME/events"
run env HOME="$UP_HOME" bash "$PKG/scripts/install.sh" --host codex --lang zh
check "install: explicit host and language" 0 "installed for codex"
run bash -c 'test "$(cat "$1/events")" = "setup:codex:zh"' _ "$UP_HOME"
check "install: only the explicit host, language passed to setup" 0

rm -f "$UP_HOME/.codex/skills/aca-demo/.aca-version"
run env HOME="$UP_HOME" OMIT_MARKER=1 bash "$PKG/scripts/install.sh" --host codex
check "install: successful setup with missing marker still fails" 1 "installed skill missing or version differs"

: > "$UP_HOME/events"
run env HOME="$UP_HOME" FAIL_HOST=codex bash "$PKG/scripts/install.sh"
check "install: one failing host does not stop the others" 1 "install failed for hosts: codex"
run grep -q "^setup:claude:" "$UP_HOME/events"
check "install: other hosts still installed after a failure" 0

FRESH="$D/fresh"
mkdir -p "$FRESH"
run env HOME="$FRESH" bash "$PKG/scripts/install.sh" --lang zh
check "install: fresh machine falls back to host detection" 0 "[done] Anyone Can Architect 1.1.0 installed"
run grep -q "^setup:claude:zh$" "$FRESH/events"
check "install: detected host installed with the requested language" 0

run env HOME="$UP_HOME" bash "$PKG/scripts/install.sh" --bogus
check "install: unknown argument rejected" 1 "unknown argument"

echo "SUMMARY pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
