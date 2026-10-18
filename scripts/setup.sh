#!/usr/bin/env bash
# Anyone Can Architect installation script
#
# Install built SKILL.md files into one host's skill directory
# Also deploy bin/ tools (aca-update-check / aca-config) alongside the aca entry skill
# Users run it through `npx anyone-can-architect install` (scripts/install.sh picks the hosts)
#
# Usage:
#   bash scripts/setup.sh                          # auto detect host
#   bash scripts/setup.sh --host claude            # explicitly specify host
#   bash scripts/setup.sh --host claude --force    # force reinstall (ignore version check)
#   bash scripts/setup.sh --lang zh                # install the Chinese skills
#
# Version check: write .aca-version beside each installed skill (value = Anyone Can Architect VERSION file contents)
# The next setup skips matching versions (idempotent + cheap)
#
# Use cp instead of ln -s (Windows compatibility / explicit independent copies)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ─── Parse args ───────────────────────────────────────────
HOST="auto"
FORCE=0
LANG_CODE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    --lang=*) LANG_CODE="${1#--lang=}"; shift ;;
    --host) HOST="$2"; shift 2 ;;
    --host=*) HOST="${1#--host=}"; shift ;;
    --force) FORCE=1; shift ;;
    *) shift ;;
  esac
done

# ─── Language ─────────────────────────────────────────────
# If unspecified, reuse the last installation's language; default to English on first install
if [ -z "$LANG_CODE" ] && [ -f "$ROOT/bin/aca-config" ]; then
  LANG_CODE=$(bash "$ROOT/bin/aca-config" get lang 2>/dev/null || true)
fi
LANG_CODE="${LANG_CODE:-en}"
case "$LANG_CODE" in
  en) SRC_ROOT="$ROOT" ;;
  zh) SRC_ROOT="$ROOT/zh-CN" ;;
  *) echo "Error: Unknown --lang '$LANG_CODE' (expected en / zh)" >&2; exit 1 ;;
esac

# ─── Auto detect ──────────────────────────────────────────
if [ "$HOST" = "auto" ]; then
  if command -v claude > /dev/null 2>&1; then
    HOST="claude"
  elif command -v codex > /dev/null 2>&1; then
    HOST="codex"
  elif command -v cursor > /dev/null 2>&1; then
    HOST="cursor"
  elif command -v grok > /dev/null 2>&1; then
    HOST="grok"
  elif command -v agy > /dev/null 2>&1; then
    HOST="antigravity-cli"
  elif command -v antigravity > /dev/null 2>&1; then
    HOST="antigravity"
  else
    echo "Error: Auto-detect failed. Use --host claude / codex / cursor / grok / antigravity / antigravity-cli explicitly." >&2
    exit 1
  fi
  echo "[auto] detected host: $HOST"
fi

# ─── Host-specific install paths ──────────────────────────
SKILLS_DIR=$(bash "$ROOT/bin/aca-host-skill-root" "$HOST")

# ─── Read current Anyone Can Architect VERSION ─────────────────────
CUR_VERSION=$(cat "$ROOT/VERSION" 2>/dev/null || echo "unknown")

# ─── Install each skill ───────────────────────────────────
mkdir -p "$SKILLS_DIR"
installed=0
skipped=0

for skill_dir in "$SRC_ROOT"/skills/*/ "$SRC_ROOT"/meta-skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  # Artifact source: claude uses the skill source directory; other hosts use dist/<host>/<skill>/
  case "$HOST" in
    claude) src="$skill_dir/SKILL.md" ;;
    *)      src="$SRC_ROOT/dist/$HOST/$skill_name/SKILL.md" ;;
  esac

  if [ ! -f "$src" ]; then
    echo "WARN: $src not found, skipping $skill_name (run: bash scripts/build-skills.sh --host $HOST)" >&2
    continue
  fi

  dst_dir="$SKILLS_DIR/$skill_name"
  version_file="$dst_dir/.aca-version"

  # Version check: skip matching versions (unless --force)
  if [ "$FORCE" -eq 0 ] && [ -f "$version_file" ]; then
    installed_ver=$(cat "$version_file" 2>/dev/null || echo "")
    if [ "$installed_ver" = "$CUR_VERSION" ]; then
      echo "[skip] $skill_name (already at $CUR_VERSION)"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  mkdir -p "$dst_dir"
  cp "$src" "$dst_dir/SKILL.md"
  echo "$CUR_VERSION" > "$version_file"
  echo "[installed] $skill_name → $dst_dir/SKILL.md"
  installed=$((installed + 1))
done

# ─── Prune aca-managed skills removed/renamed in the source ───────────
# Delete only directories marked with .aca-version (installed by aca) with no source in skills/ or meta-skills/
# Leave users' own skills untouched and retain the aca entry skill (including bin/doc-design/templates/scripts)
pruned=0
for dst in "$SKILLS_DIR"/*/; do
  [ -d "$dst" ] || continue
  name=$(basename "$dst")
  [ "$name" = "aca" ] && continue
  [ -f "$dst/.aca-version" ] || continue
  if [ ! -d "$SRC_ROOT/skills/$name" ] && [ ! -d "$SRC_ROOT/meta-skills/$name" ]; then
    rm -rf "$dst"
    echo "[pruned] $name (source removed/renamed)"
    pruned=$((pruned + 1))
  fi
done

# ─── Deploy bin/ alongside the aca skill ───────────────────
# Deploy all bin/* alongside the aca entry skill,
# because skill bodies / explicit commands (/aca-update, /aca-review, /aca-feedback) reference absolute paths ${SKILLS_DIR}/aca/bin/...
ACA_BIN_DIR="$SKILLS_DIR/aca/bin"
if [ -d "$ROOT/bin" ]; then
  rm -rf "$ACA_BIN_DIR"   # Recreate from scratch to remove old scripts deleted from the repo (such as aca-context-check)
  mkdir -p "$ACA_BIN_DIR"
  for binfile in "$ROOT/bin"/*; do
    [ -f "$binfile" ] || continue
    cp "$binfile" "$ACA_BIN_DIR/$(basename "$binfile")"
    chmod +x "$ACA_BIN_DIR/$(basename "$binfile")" 2>/dev/null || true
  done
  echo "[installed] bin/ → $ACA_BIN_DIR/"
fi

# ─── Deploy doc-design/ alongside the aca skill ────────
# doc-design/* contains repo-type rule sources that the main agent force-loads at runtime,
# with the same lifecycle as the aca skill (/aca-update reinstalls both)
ACA_DOC_DIR="$SKILLS_DIR/aca/doc-design"
# doc-governance was renamed to doc-design in v5.0.0; remove the old directory to prevent duplicate doc designs
[ -d "$SKILLS_DIR/aca/doc-governance" ] && rm -rf "$SKILLS_DIR/aca/doc-governance" && echo "[pruned] doc-governance/ (renamed to doc-design in v5)"
if [ -d "$SRC_ROOT/doc-design" ]; then
  rm -rf "$ACA_DOC_DIR"   # Recreate from scratch to remove old doc designs
  cp -r "$SRC_ROOT/doc-design" "$ACA_DOC_DIR"
  # Inject writing axioms (axioms/writing.md) into each doc design —
  # Axioms travel with doc designs, so agents see writing axioms at the top when opening a doc design
  # Keep one source in axioms/, without duplication in doc designs; setup injects after each fresh cp, idempotently
  if [ -f "$SRC_ROOT/axioms/writing.md" ]; then
    ax_injected=0
    while IFS= read -r ol; do
      { sed 's|(../SSOT.md#|(../../SSOT.md#|g' "$SRC_ROOT"/axioms/writing.md; printf '\n\n'; cat "$ol"; } > "$ol.tmp" && mv "$ol.tmp" "$ol"
      ax_injected=$((ax_injected + 1))
    done < <(find "$ACA_DOC_DIR/documents" -name '*.md' 2>/dev/null)
    echo "[injected] writing axioms → $ax_injected doc designs"
  fi
  echo "[installed] doc-design/ → $ACA_DOC_DIR/"
fi

# ─── Deploy skills/references/ alongside the aca skill ────
# Shared references for all skills live here only; mirror them unchanged to aca/skills/references/ so their position relative to aca/doc-design
# matches the repo after installation, allowing relative links between doc-design ↔ references to resolve without rewriting
ACA_REF_ROOT="$SKILLS_DIR/aca/skills"
rm -rf "$ACA_REF_ROOT"
if [ -d "$SRC_ROOT/skills/references" ]; then
  mkdir -p "$ACA_REF_ROOT"
  cp -r "$SRC_ROOT/skills/references" "$ACA_REF_ROOT/references"
  echo "[installed] skills/references/ → $ACA_REF_ROOT/references/"
fi

# ─── Deploy CONTEXT.md alongside the aca skill ─────────────
# Anyone Can Architect's own glossary; terminology links in doc-design, references, and all skills point to aca/CONTEXT.md
mkdir -p "$SKILLS_DIR/aca"
cp "$SRC_ROOT/CONTEXT.md" "$SKILLS_DIR/aca/CONTEXT.md"
cp "$SRC_ROOT/SSOT.md" "$SKILLS_DIR/aca/SSOT.md"
echo "[installed] SSOT.md → $SKILLS_DIR/aca/SSOT.md"
echo "[installed] CONTEXT.md → $SKILLS_DIR/aca/CONTEXT.md"

# ─── Deploy templates/ alongside the aca skill ─────────────
# templates/* provides starting templates for aca-init to copy project-level files by Repo-Type; guideline does not copy ROADMAP.md
ACA_TPL_DIR="$SKILLS_DIR/aca/templates"
if [ -d "$SRC_ROOT/templates" ]; then
  rm -rf "$ACA_TPL_DIR"
  cp -r "$SRC_ROOT/templates" "$ACA_TPL_DIR"
  echo "[installed] templates/ → $ACA_TPL_DIR/"
fi

# ─── Deploy scripts/ alongside the aca skill ───────────────
# Runtime scripts in scripts/ deployed alongside the aca skill (build / check-portable / update, etc.)
ACA_SCRIPTS_DIR="$SKILLS_DIR/aca/scripts"
if [ -d "$ROOT/scripts" ]; then
  rm -rf "$ACA_SCRIPTS_DIR"
  cp -r "$ROOT/scripts" "$ACA_SCRIPTS_DIR"
  echo "[installed] scripts/ → $ACA_SCRIPTS_DIR/"
fi

# ─── Deploy VERSION alongside the aca skill ────────────────
# aca-init reads ~/.claude/skills/aca/VERSION to write the footer; without it, the footer shows vunknown
# Same lifecycle as doc-design / templates / scripts (/aca-update reinstalls all)
if [ -f "$ROOT/VERSION" ]; then
  mkdir -p "$SKILLS_DIR/aca"
  cp "$ROOT/VERSION" "$SKILLS_DIR/aca/VERSION"
  echo "[installed] VERSION → $SKILLS_DIR/aca/VERSION ($CUR_VERSION)"
fi

# ─── Deploy MANIFEST alongside the aca skill ───────────────
# Lists every managed skill; aca-update-check uses it to find skills missing from a partial install
for skill_dir in "$SRC_ROOT"/skills/*/ "$SRC_ROOT"/meta-skills/*/; do
  [ -f "$skill_dir/SKILL.md.tmpl" ] && basename "$skill_dir"
done > "$SKILLS_DIR/aca/MANIFEST"
echo "[installed] MANIFEST → $SKILLS_DIR/aca/MANIFEST"

# ─── Remember the language for the next install / update ───
if [ -f "$ROOT/bin/aca-config" ]; then
  bash "$ROOT/bin/aca-config" set lang "$LANG_CODE" || true
fi

echo "[done] installed $installed / skipped $skipped / pruned ${pruned:-0} (host '$HOST', lang $LANG_CODE, version $CUR_VERSION)"

