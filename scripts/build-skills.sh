#!/usr/bin/env bash
# Anyone Can Architect skill builder
#
# Generate SKILL.md from .tmpl templates, with mustache placeholders + RESOLVERS + --host switching
#
# Usage:
#   bash scripts/build-skills.sh                          # Default host: all (prevent stale output)
#   bash scripts/build-skills.sh --host claude            # Build claude only (output in skills/{name}/SKILL.md)
#   bash scripts/build-skills.sh --host codex             # Build codex only (output in dist/codex/{name}/SKILL.md)
#   bash scripts/build-skills.sh --host cursor            # Build cursor only (output in dist/cursor/{name}/SKILL.md)
#   bash scripts/build-skills.sh --host grok              # Build grok only (output in dist/grok/{name}/SKILL.md)
#   bash scripts/build-skills.sh --host all               # Generate all host versions at once
#
# Custom output directory:
#   bash scripts/build-skills.sh --host claude --output /path/to/output-dir
#
# Runtime resolution model (v2.0):
#   Skill builds no longer inline CONTEXT or copies of repo-type rules
#   Each business skill reads these as needed within its own workflow (no shared force-load preamble):
#     1. <cwd>/CONTEXT.md (project glossary, read when needed)
#     2. <aca-skill-root>/aca/doc-design/repo-types/$TYPE.md (this repo's repo-type workflow, read in the phase that uses it)
#   Single source of truth = the Anyone Can Architect repo itself; updates only require /aca-update, with no project-side rerendering
#
# Placeholder convention: {{PLACEHOLDER_NAME}} (on its own line)
# Each placeholder maps to a resolve_NAME() bash function; the function takes host as an argument

set -euo pipefail

# Capture the original cwd to resolve relative paths for --with-context / --output
ORIGINAL_CWD="$(pwd)"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ─── Parse args ───────────────────────────────────────────
HOST="all"
OUTPUT_DIR=""
LANG_CODE="en"
while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    --lang=*) LANG_CODE="${1#--lang=}"; shift ;;
    --host) HOST="$2"; shift 2 ;;
    --host=*) HOST="${1#--host=}"; shift ;;
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    --output=*) OUTPUT_DIR="${1#--output=}"; shift ;;
    *) shift ;;
  esac
done

case "$HOST" in
  claude|codex|cursor|grok|antigravity|antigravity-cli|all) ;;
  *) echo "Error: Unknown --host '$HOST' (expected claude / codex / cursor / grok / antigravity / antigravity-cli / all)" >&2; exit 1 ;;
esac

# Language selects the content source directory: en uses the repo root, zh uses zh-CN/; output goes back to the corresponding source directory
case "$LANG_CODE" in
  en) SRC_ROOT="$ROOT" ;;
  zh) SRC_ROOT="$ROOT/zh-CN" ;;
  *) echo "Error: Unknown --lang '$LANG_CODE' (expected en / zh)" >&2; exit 1 ;;
esac
cd "$SRC_ROOT"

# Resolve relative path to absolute (based on the original cwd, not ROOT)
if [ -n "$OUTPUT_DIR" ] && [ "${OUTPUT_DIR:0:1}" != "/" ]; then
  OUTPUT_DIR="$ORIGINAL_CWD/$OUTPUT_DIR"
fi

# ─── RESOLVERS (placeholder → content generator) ───────────────────────

# host → aca skill installation root, using the shared mapping
# For non-claude host builds, use it to replace hardcoded ~/.claude/skills paths in the body as a fallback
host_skill_root() {
  HOME='~' bash "$ROOT/bin/aca-host-skill-root" "$1"
}

# Convert relative links from the source directory to installation paths when injecting axioms
emit_AXIOM() { sed 's|(../SSOT.md#|(~/.claude/skills/aca/SSOT.md#|g' "$1"; }

# Inject by phase: completeness axioms only into solution design, writing axioms only into doc writing; remove axiom titles, turn internal headings into bold lines, and embed the body directly in the section
resolve_AXIOM_BOIL() { emit_AXIOM axioms/boil-the-ocean.md | sed -e '1{/^#/d;}' | sed -E -e '1{/^$/d;}' -e 's/^#{1,6} (.*)$/**\1**/'; }
resolve_AXIOM_WRITING() { emit_AXIOM axioms/writing.md | sed -e '1{/^#/d;}' | sed -E -e '1{/^$/d;}' -e 's/^#{1,6} (.*)$/**\1**/'; }
# Cross-repo issue operations: specify / implement share one source with neutral wording ("handling approach" covers design resolution / temporary handling)
resolve_PRECHECK() { cat partials/precheck.md; }

# Define the field-report body only once in partials/field-report-body.md
emit_FIELD_REPORT_BODY() { cat partials/field-report-body.md; }

# L2 aca-feedback uses the complete report template
resolve_FIELD_REPORT_TEMPLATE() {
  cat partials/field-report-head.md
  emit_FIELD_REPORT_BODY
  printf '%s
' '```'
}

# Extension point: add future host-specific placeholders here (since v2.0, each skill reads CONTEXT / repo-type rules as needed within its workflow, with no build-time inlining)

# ─── Single-file build ─────────────────────────────────────────
build_one() {
  local tmpl="$1"
  local host="$2"
  local out_base_dir
  local skill_name
  skill_name=$(basename "$(dirname "$tmpl")")

  if [ -n "$OUTPUT_DIR" ]; then
    # Custom output: $OUTPUT_DIR/{skill_name}/SKILL.md (host-independent; the caller handles isolation)
    out_base_dir="$OUTPUT_DIR/$skill_name"
    mkdir -p "$out_base_dir"
  elif [ "$host" = "claude" ]; then
    # claude is the default host; output stays in the skill source directory (also for developer previews)
    out_base_dir="$(dirname "$tmpl")"
  else
    # Collect non-claude host output in dist/<host>/<skill_name>/SKILL.md
    out_base_dir="$SRC_ROOT/dist/$host/$skill_name"
    mkdir -p "$out_base_dir"
  fi

  local out="$out_base_dir/SKILL.md"

  # State: 0 = inside (or before) frontmatter, 1 = after frontmatter
  local state=0
  local fm_count=0

  : > "$out"

  while IFS= read -r line || [ -n "$line" ]; do
    # Handle Windows CRLF working trees (git autocrlf=true)
    line="${line%$'\r'}"
    if [ "$state" -eq 0 ]; then
      if [ "$line" = "---" ]; then
        fm_count=$((fm_count + 1))
        if [ "$fm_count" -eq 2 ]; then
          # Inject per-host fields before closing frontmatter
          # cursor: disable-model-invocation requires explicit / invocation of aca skills, preventing automatic triggering by Cursor
          [ "$host" = "cursor" ] && echo "disable-model-invocation: true" >> "$out"
          echo "$line" >> "$out"
          {
            echo "<!-- AUTO-GENERATED from $(basename "$tmpl") — do not edit directly -->"
            echo "<!-- Regenerate: bash scripts/build-skills.sh --host $host -->"
          } >> "$out"
          state=1
        else
          echo "$line" >> "$out"
        fi
      else
        echo "$line" >> "$out"
      fi
    else
      if [[ "$line" =~ ^\{\{([A-Z_]+)\}\}$ ]]; then
        local name="${BASH_REMATCH[1]}"
        if declare -f "resolve_$name" > /dev/null 2>&1; then
          "resolve_$name" "$host" >> "$out"
        else
          echo "<!-- BUILD WARN: unknown placeholder {{$name}} (preserved for later resolution) -->" >&2
          echo "$line" >> "$out"
        fi
      else
        echo "$line" >> "$out"
      fi
    fi
  done < "$tmpl"

  # Non-claude hosts: replace hardcoded ~/.claude/skills paths in the body with the host's installation root as a fallback
  if [ "$host" != "claude" ]; then
    local skill_root; skill_root="$(host_skill_root "$host")"
    # Portable in-place editing (tmp + mv) — avoid sed -i: GNU (expression directly after -i) and
    # BSD/macOS (backup suffix required immediately after -i) use incompatible syntax; plain sed -i fails on mac
    local _tmp; _tmp=$(mktemp)
    sed "s|~/\.claude/skills|$skill_root|g" "$out" > "$_tmp" && mv "$_tmp" "$out"
  fi

  echo "[built] $out (host: $host)"
}

# ─── Main loop ───────────────────────────────────────────────
count=0
hosts_to_build=()
if [ "$HOST" = "all" ]; then
  hosts_to_build=(claude codex cursor grok antigravity antigravity-cli)
else
  hosts_to_build=("$HOST")
fi

for host in "${hosts_to_build[@]}"; do
  # Scan business skills (skills/) + utility / router skills (meta-skills/)
  for tmpl in skills/*/SKILL.md.tmpl meta-skills/*/SKILL.md.tmpl; do
    if [ -f "$tmpl" ]; then
      build_one "$tmpl" "$host"
      count=$((count + 1))
    fi
  done
done

echo "[done] built $count skill files"
