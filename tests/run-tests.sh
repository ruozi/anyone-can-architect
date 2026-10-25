#!/usr/bin/env bash
# tests/run-tests.sh — regression test suite for bin scripts
#
# Covers:aca-doc-graph-check(link graph / fenced and inline code exemptions / exclusions / five registry states),
#      aca-feedback-submit(offline paths),aca-update-check(npm release / installation drift),
#      aca-context-check(CONTEXT structure),aca-tag-notify-check(release summary structure),aca-release-notify-check / aca-tag-notify-extract(announcement integration)
# Fully offline:no network or real HOME / token access(submit tests explicitly isolate HOME + ACA_STATE_DIR)
#
# Usage: bash tests/run-tests.sh   (exit 1 if any test fails;see .github/workflows/ci.yml for CI)
# Dependencies: bash 4+ / git / awk / find / sort(same as the bin scripts)

set -u

# Isolate Git credential helpers as well as HOME in offline fixtures.
export LC_ALL=C
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Content regression tests use the Chinese source (English is a translation; bilingual alignment tests check structural consistency)
ZH="$ROOT/zh-CN"
DGC="$ROOT/bin/aca-doc-graph-check"
SUB="$ROOT/bin/aca-feedback-submit"
UPDATE_CHECK="$ROOT/bin/aca-update-check"
VERSION_SYNC="$ROOT/bin/aca-readme-version-sync"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
OUT="$WORK/out.txt"

PASS=0
FAIL=0
RC=0

run() {  # run <cmd...> ;output goes to $OUT,exit code to $RC(without triggering set -e)
  RC=0
  "$@" > "$OUT" 2>&1 || RC=$?
}

check() {  # check <name> <expected-rc> [required-string]... ;string prefix "!" = must not contain
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

# ════════════════ aca-doc-graph-check ════════════════

new_tree clean
printf '# Entry\n\n- [x](x.md)\n' > "$D/README.md"
printf '# X\n\n[Back](README.md)\n' > "$D/x.md"
run bash "$DGC" "$D"
check "dgc: clean tree OK" 0 "RESULT OK" "FILES 2"

new_tree broken
printf '# Entry\n\n- [Missing](gone.md)\n' > "$D/README.md"
run bash "$DGC" "$D"
check "dgc: real broken link FAIL" 1 "BROKEN_LINK README.md -> gone.md" "RESULT FAIL"

new_tree html
printf '# Entry\n\n<p align="center"><a href="x.md">X</a> · <A class="c" HREF='"'"'y.md#y'"'"'>Y</A></p>\n' > "$D/README.md"
printf '# X\n' > "$D/x.md"
printf '# Y\n' > "$D/y.md"
run bash "$DGC" "$D"
check "dgc: HTML links <a href> join the graph" 0 "RESULT OK" "REACHABLE 3"
printf '<a href="gone.md">G</a> <a href="x.md#none">N</a>\n' >> "$D/README.md"
run bash "$DGC" "$D"
check "dgc: broken HTML links and missing anchors also FAIL" 1 "BROKEN_LINK README.md -> gone.md" "x.md#none" "RESULT FAIL"

new_tree anchor
printf '# Entry

- [Term](ctx.md#my-term)
- [Chinese](ctx.md#中文词条)
' > "$D/README.md"
printf '# Ctx

## Language

### my-term

Definition

### 中文词条

Definition

[Back](README.md)
' > "$D/ctx.md"
run bash "$DGC" "$D"
check "dgc: existing anchor OK" 0 "RESULT OK"

new_tree anchor-missing
printf '# Entry

- [Term](ctx.md#nope)
' > "$D/README.md"
printf '# Ctx

### my-term

[Back](README.md)
' > "$D/ctx.md"
run bash "$DGC" "$D"
check "dgc: missing anchor FAIL" 1 "BROKEN_ANCHOR README.md -> ctx.md#nope" "RESULT FAIL"

# #467:「你」contains the UTF-8 continuation byte 0xA0; whitespace character classes must not truncate link targets
new_tree unicode-title
printf '# Entry\n\n[Chinese path](你.md "Description")\n[Chinese anchor](你.md#你好\t"Description")\n' > "$D/README.md"
printf '# 你好\n\n[Back](README.md)\n' > "$D/你.md"
run bash "$DGC" "$D"
check "dgc: preserve Chinese paths and anchors with space and tab title separators" 0 "RESULT OK" "FILES 2"

printf '\n[Missing file](你不存在.md "Description")\n[Missing anchor](你.md#你不存在\t"Description")\n' >> "$D/README.md"
run bash "$DGC" "$D"
check "dgc: real Chinese broken links and missing anchors still FAIL" 1 "BROKEN_LINK README.md -> 你不存在.md" "BROKEN_ANCHOR README.md -> 你.md#你不存在" "RESULT FAIL"

new_tree unicode-registry-title
mkdir -p "$D/服务/你"
printf '# Entry\n\n<!-- aca-registry: 服务 -->\n[Chinese entry](服务/你/README.md\t"Description")\n<!-- /aca-registry -->\n' > "$D/README.md"
printf '# Services\n\n[Back](../../README.md)\n' > "$D/服务/你/README.md"
run bash "$DGC" "$D"
check "dgc: registry preserves Chinese targets and strips titles" 0 "RESULT OK" "!REGISTRY_GHOST" "!REGISTRY_MISSING"

new_tree orphan
printf '# Entry\n' > "$D/README.md"
printf '# Orphan\n' > "$D/lost.md"
run bash "$DGC" "$D"
check "dgc: orphan FAIL" 1 "ORPHAN lost.md" "RESULT FAIL"

new_tree unreach
printf '# Entry\n' > "$D/README.md"
printf '# A\n\n[b](b.md)\n' > "$D/a.md"
printf '# B\n\n[a](a.md)\n' > "$D/b.md"
run bash "$DGC" "$D"
check "dgc: mutually linked but unreachable FAIL" 1 "UNREACHABLE a.md" "UNREACHABLE b.md" "RESULT FAIL"

new_tree noentry
printf '# Some File\n' > "$D/other.md"
run bash "$DGC" "$D"
check "dgc: missing entry FAIL" 1 "MISSING_ENTRY README.md" "RESULT FAIL"

new_tree fence
cat > "$D/README.md" <<'EOF'
# Entry

```markdown
[Fake link inside fence](fenced-fake.md)
```

Inline example: the format is `[Description](inline-fake.md#a)`
EOF
run bash "$DGC" "$D"
check "dgc: fenced and inline code links are exempt" 0 "RESULT OK" "!BROKEN_LINK"

new_tree prune
printf '# Entry\n' > "$D/README.md"
mkdir -p "$D/.claude/agents" "$D/.aca/field-reports"
printf '[Sample broken link](nope.md)\n' > "$D/.claude/agents/t.md"
printf '# Queue File\n' > "$D/.aca/field-reports/r.md"
run bash "$DGC" "$D"
check "dgc: tool directories excluded by default" 0 "RESULT OK" "FILES 1"

new_tree excl
printf '# Entry\n' > "$D/README.md"
mkdir -p "$D/private"
printf '# Orphan\n' > "$D/private/p.md"
run bash "$DGC" "$D"
check "dgc: orphans still reported without exclusion" 1 "ORPHAN private/p.md"
run bash "$DGC" "$D" --exclude private
check "dgc: --exclude takes effect" 0 "RESULT OK" "FILES 1"

new_tree unsupported
printf '# Entry\n\n[Odd](a(b).md)\n' > "$D/README.md"
run bash "$DGC" "$D"
check "dgc: parenthesized target fail-closed" 1 "UNSUPPORTED_LINK" "RESULT FAIL"

new_tree facade
printf '# Entry\n\n## ✨ 这是什么\n\n- [x](x.md)\n' > "$D/README.md"
printf '# X\n\n[Back](README.md)\n' > "$D/x.md"
run bash "$DGC" "$D"
check "dgc: front page section FAIL" 1 "FACADE_HEADING" "RESULT FAIL"

run bash "$DGC" "$WORK/nonexistent-directory"
check "dgc: no docs exit 2" 2 "NO_DOCS"

# —— Five registry states ——

new_tree regok
mkdir -p "$D/services/mod-a" "$D/services/mod-b" "$D/services/.hidden-ci"
cat > "$D/README.md" <<'EOF'
# Overview

<!-- aca-registry: services -->
- [A](services/mod-a/)
- [B](services/mod-b/)
<!-- /aca-registry -->
EOF
run bash "$DGC" "$D"
check "registry: all valid + hidden directories exempt" 0 "REGISTRY README.md root=services entries=2" "RESULT OK"

new_tree regghost
mkdir -p "$D/services/mod-a"
printf '# Overview\n\n<!-- aca-registry: services -->\n- [A](services/mod-a/)\n- [Ghost](services/ghost/)\n<!-- /aca-registry -->\n' > "$D/README.md"
run bash "$DGC" "$D"
check "registry: ghost entry FAIL" 1 "REGISTRY_GHOST README.md :: services/ghost/" "RESULT FAIL"

new_tree regmiss
mkdir -p "$D/services/mod-a" "$D/services/mod-b"
printf '# Overview\n\n<!-- aca-registry: services -->\n- [A](services/mod-a/)\n<!-- /aca-registry -->\n' > "$D/README.md"
run bash "$DGC" "$D"
check "registry: missing entry FAIL" 1 "REGISTRY_MISSING README.md :: services/mod-b" "RESULT FAIL"

new_tree regunclosed
mkdir -p "$D/services"
printf '# Overview\n\n<!-- aca-registry: services -->\n- Unclosed\n' > "$D/README.md"
run bash "$DGC" "$D"
check "registry: unclosed block fail-closed" 1 "REGISTRY_UNCLOSED README.md" "RESULT FAIL"

new_tree regbadroot
printf '# Overview\n\n<!-- aca-registry: nowhere -->\n<!-- /aca-registry -->\n' > "$D/README.md"
run bash "$DGC" "$D"
check "registry: missing root FAIL" 1 "REGISTRY_BAD_ROOT README.md :: nowhere" "RESULT FAIL"

new_tree regfence
mkdir -p "$D/services/mod-a"
cat > "$D/README.md" <<'EOF'
# Overview

<!-- aca-registry: services -->
- [A](services/mod-a/)
<!-- /aca-registry -->

Convention example(should not trigger):

```markdown
<!-- aca-registry: fake-directory -->
- [x](nowhere/)
<!-- /aca-registry -->
```
EOF
run bash "$DGC" "$D"
check "registry: fenced example exempt" 0 "RESULT OK" "!REGISTRY_BAD_ROOT"

# ════════════════ aca-feedback-submit(offline path)════════════════
# Queue = user-level outbox ~/.aca/outbox/(outside the project), so isolating HOME isolates the queue
# Isolate HOME / ACA_STATE_DIR: never read real tokens or access the network. No credentials → main path fails → pending

new_tree subproj
FAKEHOME="$WORK/fakehome"; mkdir -p "$FAKEHOME/.aca/outbox/corrections"
# Credential lookup is an explicit test double, never an interactive helper.
export REAL_GIT=$(command -v git)
MOCK_BIN="$WORK/mock-bin"; mkdir -p "$MOCK_BIN"
cat > "$MOCK_BIN/git" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = credential ] && [ "$2" = fill ]; then
  cat >/dev/null
  exit 1
fi
exec "$REAL_GIT" "$@"
EOF
chmod +x "$MOCK_BIN/git"
# Mock gh as logged out too, so a locally authenticated GitHub CLI cannot supply a real token to the no-credentials test
printf '#!/usr/bin/env bash\nexit 1\n' > "$MOCK_BIN/gh"
chmod +x "$MOCK_BIN/gh"
export PATH="$MOCK_BIN:$PATH"
printf -- '---\ntype: correction\nts: 2026-01-01T00:00:00Z\n---\n\n# Correction: Test\n' > "$FAKEHOME/.aca/outbox/corrections/t.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" GITHUB_TOKEN='<placeholder>' GH_TOKEN='' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB'"
check "submit: no credentials leaves pending" 0 "pending=1"

new_tree subempty
rm -rf "$FAKEHOME/.aca/outbox"
run bash -c "cd '$D' && env HOME='$FAKEHOME' ACA_STATE_DIR='$FAKEHOME/.aca' bash '$SUB'"
check "submit: no outbox silently exits 0" 0

# upstream-issues: missing target_repo → skip upload, leave pending and warn(#331)
new_tree subupnorepo
mkdir -p "$FAKEHOME/.aca/outbox/upstream-issues"
printf -- '---\ncreated_at: 2026-01-01T00:00:00Z\nrepo: owner/consumer\n---\n\n# Upstream: Invalid file missing target_repo\n' \
  > "$FAKEHOME/.aca/outbox/upstream-issues/bad.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" GITHUB_TOKEN='<placeholder>' GH_TOKEN='' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB'"
check "submit: upstream missing target_repo leaves pending" 0 "missing target_repo" "pending=1"
[ -f "$FAKEHOME/.aca/outbox/upstream-issues/bad.md" ] \
  && { echo "ok - submit: upstream file missing target_repo retained"; PASS=$((PASS+1)); } \
  || { echo "FAIL - submit: upstream file missing target_repo retained(deleted by mistake)"; FAIL=$((FAIL+1)); }
rm -f "$FAKEHOME/.aca/outbox/upstream-issues/bad.md"

# upstream-issues: target_repo present but no credentials → upload fails, leave pending(no missing-field warning)
new_tree subupok
printf -- '---\ntarget_repo: owner/upstream\ncreated_at: 2026-01-02T00:00:00Z\nrepo: owner/consumer\n---\n\n# Upstream: Valid upstream issue\n' \
  > "$FAKEHOME/.aca/outbox/upstream-issues/good.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" GITHUB_TOKEN='<placeholder>' GH_TOKEN='' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB'"
check "submit: upstream without credentials leaves pending" 0 "pending=1" "!missing target_repo"
[ -f "$FAKEHOME/.aca/outbox/upstream-issues/good.md" ] \
  && { echo "ok - submit: upstream file without credentials retained"; PASS=$((PASS+1)); } \
  || { echo "FAIL - submit: upstream file without credentials retained(deleted by mistake)"; FAIL=$((FAIL+1)); }
rm -rf "$FAKEHOME/.aca/outbox/upstream-issues"

# Duplicate check fail-closed(root cause of spam in #353–#361): credentials present but index fetch fails → leave pending, create nothing
# ACA_GITHUB_API_BASE points to an unused local port → fetch_dedup_index fails immediately → rc 2 → no POST
new_tree subdedupdown
mkdir -p "$FAKEHOME/.aca/outbox/corrections"
printf -- '---\ntype: correction\nts: 2026-01-03T00:00:00Z\n---\n\n# Correction: Duplicate check unavailable test\n' \
  > "$FAKEHOME/.aca/outbox/corrections/dedup.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" \
  GITHUB_TOKEN='fake-token-for-offline-test' ACA_GITHUB_API_BASE='http://127.0.0.1:1' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB'"
check "submit: duplicate check unavailable leaves pending(fail-closed)" 0 "Duplicate check unavailable" "pending=1"
[ -f "$FAKEHOME/.aca/outbox/corrections/dedup.md" ] \
  && { echo "ok - submit: file retained when duplicate check unavailable"; PASS=$((PASS+1)); } \
  || { echo "FAIL - submit: file retained when duplicate check unavailable(deleted by mistake)"; FAIL=$((FAIL+1)); }
rm -f "$FAKEHOME/.aca/outbox/corrections/dedup.md"

# Selective submission: file arguments limit processing to specified files; unselected files do not count toward found and remain unchanged
new_tree subpick
printf -- '---\ntype: correction\nts: 2026-01-04T00:00:00Z\n---\n\n# Correction: Selected\n' \
  > "$FAKEHOME/.aca/outbox/corrections/picked.md"
printf -- '---\ntype: correction\nts: 2026-01-05T00:00:00Z\n---\n\n# Correction: Unselected\n' \
  > "$FAKEHOME/.aca/outbox/corrections/unpicked.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" GITHUB_TOKEN='<placeholder>' GH_TOKEN='' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB' '$FAKEHOME/.aca/outbox/corrections/picked.md'"
check "submit: selective submission processes only specified files" 0 "found=1" "pending=1"
[ -f "$FAKEHOME/.aca/outbox/corrections/unpicked.md" ] \
  && { echo "ok - submit: unselected file retained"; PASS=$((PASS+1)); } \
  || { echo "FAIL - submit: unselected file retained(deleted by mistake)"; FAIL=$((FAIL+1)); }
# Reject paths outside the outbox(prevent accidental uploads of arbitrary files as feedback)
printf -- '# Outside the outbox\n' > "$WORK/outside.md"
run env HOME="$FAKEHOME" ACA_STATE_DIR="$FAKEHOME/.aca" GITHUB_TOKEN='<placeholder>' GH_TOKEN='' GIT_TERMINAL_PROMPT=0 \
  bash -c "cd '$D' && bash '$SUB' '$WORK/outside.md'"
check "submit: path outside outbox rejected" 0 "Outside outbox"
rm -rf "$FAKEHOME/.aca/outbox/corrections"

# ════════════════ aca-update-check and install(npm release and installation state checks)════════════════

run bash "$ROOT/tests/update-tests.sh"
check "update: isolated update behavior regression" 0 "fail=0"

# ════════════════ npm package and npx entry point ════════════════

run node "$ROOT/tests/pack-check.js"
check "package: version matches VERSION, installer and both languages packed, tests excluded" 0 "RESULT OK"
run node "$ROOT/cli/index.js" --version
check "cli: --version prints VERSION" 0 "$(tr -d '[:space:]' < "$ROOT/VERSION")"
run node "$ROOT/cli/index.js" install --lang fr
check "cli: invalid language rejected" 1 "--lang must be en or zh"
CLI_HOME="$WORK/cli-home"; mkdir -p "$CLI_HOME"
run env HOME="$CLI_HOME" USERPROFILE="$CLI_HOME" ACA_STATE_DIR="$CLI_HOME/.aca" node "$ROOT/cli/index.js" install --host codex --lang zh
check "cli: npx entry installs and verifies a host" 0 "installed for codex"
run bash -c "grep -qx 'lang: zh' '$CLI_HOME/.aca/config.yaml' && test -s '$CLI_HOME/.codex/skills/aca/MANIFEST' && grep -q '只改代码与测试' '$CLI_HOME/.codex/skills/aca-implement/SKILL.md'"
check "cli: installed Chinese skills, manifest, and remembered language" 0

run bash "$ROOT/tests/i18n-parity.sh"
check "i18n: every zh-CN source has an English counterpart with matching headings and links" 0 "RESULT OK"
run bash "$ROOT/tests/setup-tests.sh"
check "setup: real installed artifacts for six targets in both languages" 0 "SETUP_HOSTS=12 RESULT OK"

# ════════════════ aca-release version block sync integration ════════════════

if grep -qF 'bash ~/.claude/skills/aca/bin/aca-readme-version-sync README.md "<TARGET_VERSION>"' "$ZH/skills/aca-release/SKILL.md.tmpl"; then
  echo "ok - version block: aca-release integrates automated sync of both versions"; PASS=$((PASS+1))
else
  echo "FAIL - version block: aca-release lacks automated sync of both versions"; FAIL=$((FAIL+1))
fi

if grep -qF 'README.md "$(tr -d '\''[:space:]'\'' < VERSION)" "$(tr -d '\''[:space:]'\'' < VERSION)"' "$ZH/skills/aca-release/SKILL.md.tmpl"; then
  echo "ok - version block: Anyone Can Architect aligns both versions with VERSION when releasing itself"; PASS=$((PASS+1))
else
  echo "FAIL - version block: Anyone Can Architect may retain an old version when releasing itself"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-prose-check(automated half of writing axioms)════════════════

PROSE="$ROOT/bin/aca-prose-check"
new_tree prose_bad
printf '%s
' '---' 'x: 1' '---' '## 1. 标题' '' '这一句有句号。' '第一句。第二句' '- 范围：只做当前版本' '  - 已在分支：直接使用' '' '| 列 | 值 |' '|---|---|' '| a | 片段一；片段二 |' '| b | 一句话。 |' '<div style="x">HTML 行里的句号。不查</div>' '```' '代码里的句号。不算' '```' '行内 `代码。` 不算' > "$D/bad.md"
run bash "$PROSE" "$D/bad.md"
check "prose: periods / multiple sentences / dotted chapter numbers / top-level labels / cells detected; indented branches, HTML and code exempt" 1 "HEADING_DOT line 4" "PROSE_PERIOD line 6" "PROSE_MULTI line 7" "LIST_LABEL line 8" "!line 9" "CELL_SEMICOLON line 13" "CELL_PERIOD line 14" "!line 15" "!line 17" "!line 19" "RESULT FAIL"
new_tree prose_ok
printf '%s
' '## 1 标题' '' '一行一句不落句号' '- 列表项也一样' > "$D/ok.md"
run bash "$PROSE" "$D/ok.md"
check "prose: compliant file OK" 0 "SUMMARY" "RESULT OK"
new_tree prose_en
printf '%s\n' '# Title' '' 'This line is fine' 'This line ends badly.' 'One sentence. Two sentences' 'Use tools, e.g. git and gh' 'Wait...' '' '| a | b |' '| --- | --- |' '| Cell ok | Cell bad. |' '| x; y | ok |' '' '- `run.sh.` code is fine' > "$D/en.md"
run bash "$PROSE" "$D/en.md"
check "prose: English trailing period / multi-sentence / cell punctuation hit; abbreviations, ellipsis and code exempt" 1 "PROSE_PERIOD line 4" "PROSE_MULTI line 5" "!line 6" "!line 7" "CELL_PERIOD line 11" "CELL_SEMICOLON line 12" "!line 14" "RESULT FAIL"
new_tree prose_utf8
printf '%s\n' 'Atlas Service 是权限账本的 API，不直接操作 GitHub、NAS、AI Platform 等基础设施。' > "$D/utf8.md"
run bash "$PROSE" "$D/utf8.md"
check "prose: Chinese spanning byte 40 still outputs the full offending line and result (#500)" 1 "PROSE_PERIOD line 1: Atlas Service 是权限账本的 API，不直接操作 GitHub、NAS、AI Platform 等基础设施。" "SUMMARY PROSE_PERIOD=1" "RESULT FAIL" "!multibyte conversion failure"
run bash "$PROSE" "$D/nope.md"
check "prose: missing target exit 2" 2 "NO_TARGET"
run bash "$PROSE" "$ZH/axioms" "$ZH/doc-design/patterns"
check "prose: axioms and patterns pass their own checks" 0 "RESULT OK"

# ════════════════ aca-readme-version-sync (two-line README version block)════════════════

new_tree versionsync
printf '# Demo Repo\n\n---\n\n> 📦 **Demo Repo v1.2.3**\n> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n' > "$D/README.md"
chmod 640 "$D/README.md"
VERSION_MODE_BEFORE=$(ls -ld "$D/README.md" | awk '{print $1}')
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: Release syncs repo and Anyone Can Architect versions" 0 "UPDATED 1.2.3 2.0.0 4.10.0 4.11.1"
grep -qF '**Demo Repo v2.0.0**' "$D/README.md" \
  && { echo "ok - version block: preserves repo name and updates only versions"; PASS=$((PASS+1)); } \
  || { echo "FAIL - version block: repo name or version drift"; FAIL=$((FAIL+1)); }
tail -n 2 "$D/README.md" | head -n 1 | grep -qF '**Demo Repo v2.0.0**' \
  && tail -n 1 "$D/README.md" | grep -qF 'Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.11.1 · Repo-Type: `automation`' \
  && { echo "ok - version block: repo version comes first and Anyone Can Architect footer comes last"; PASS=$((PASS+1)); } \
  || { echo "FAIL - version block: incorrect line order or footer not on last line"; FAIL=$((FAIL+1)); }
VERSION_MODE_AFTER=$(ls -ld "$D/README.md" | awk '{print $1}')
[ "$VERSION_MODE_BEFORE" = "$VERSION_MODE_AFTER" ] \
  && { echo "ok - version block: write preserves README permissions"; PASS=$((PASS+1)); } \
  || { echo "FAIL - version block: README permission drift $VERSION_MODE_BEFORE → $VERSION_MODE_AFTER"; FAIL=$((FAIL+1)); }

new_tree versionmissing
printf '# Demo\n\n> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n' > "$D/README.md"
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: missing repo version line fails closed" 2 "MISSING_REPO_VERSION" "aca-init"

new_tree versionnotlast
printf '# Demo\n\n> 📦 **Demo v1.0.0**\n> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n\nExtra trailing content\n' > "$D/README.md"
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: footer not on last line fails closed" 2 "FOOTER_NOT_LAST" "aca-init"

new_tree versiontrailingblank
printf '# Demo\n\n> 📦 **Demo v1.0.0**\n> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n\n' > "$D/README.md"
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: blank lines after footer also rejected" 2 "FOOTER_NOT_LAST" "aca-init"

new_tree versionbadmarker
printf '# Demo\n\n> ❌ **Demo v1.0.0**\n> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n' > "$D/README.md"
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: incorrect repo marker prevents write" 2 "INVALID_REPO_VERSION_LINE"

printf '# Demo\n\n> 📦 **Demo v1.0.0**\n> ❌ Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.10.0 · Repo-Type: `automation`\n' > "$D/README.md"
run bash "$VERSION_SYNC" "$D/README.md" 2.0.0 4.11.1
check "version block: incorrect footer marker prevents write" 2 "INVALID_FOOTER"

run bash "$VERSION_SYNC" "$D/README.md" not-a-version 4.11.1
check "version block: invalid repo version prevents write" 2 "INVALID_REPO_VERSION"

if grep -qF '**<REPO_NAME> v<REPO_VERSION>**' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && grep -qF '`REPO_NAME` 优先取 `origin` 的仓库名' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && grep -qF '根据当前分支的版本记录确定 `REPO_VERSION`' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && grep -qF '版本区块格式固定：' "$ZH/meta-skills/aca-init/SKILL.md.tmpl"; then
  echo "ok - version block: aca-init establishes two-line structure and defines name and version sources"; PASS=$((PASS+1))
else
  echo "FAIL - version block: aca-init two-line structure or evidence priority incomplete"; FAIL=$((FAIL+1))
fi

# ════════════════ repo-type pending placeholder (avoid repeated detection when no type fits)════════════════

TYPE_CHECK="$ROOT/bin/aca-repo-type-check"
printf '# Demo

---

> 📦 **Demo v0.1.0**
> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.26.0 · Repo-Type: `pending`
' > "$D/README.md"
run bash "$TYPE_CHECK" "$D"
check "pending: placeholder footer → PENDING exit 1" 1 "PENDING"
printf '# Demo

---

> 📦 **Demo v0.1.0**
> 🤝 Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v4.26.0 · Repo-Type: `automation`
' > "$D/README.md"
run bash "$TYPE_CHECK" "$D"
check "pending: valid type still output unchanged" 0 "automation"
if grep -qF '| `PENDING` | `1` | 告知类型尚未支持，按第八章汇报未完成 |' "$ZH/meta-skills/aca-init/SKILL.md.tmpl"   && grep -qF '将 `REPO_TYPE` 设为 `pending`' "$ZH/meta-skills/aca-init/SKILL.md.tmpl"   && ! grep -qF '| `pending` |' "$ZH/meta-skills/aca-init/SKILL.md.tmpl"; then
  echo "ok - pending: aca-init writes and recognizes placeholder without adding it to the type table"; PASS=$((PASS+1))
else
  echo "FAIL - pending: aca-init placeholder rules missing or placeholder included in enum table"; FAIL=$((FAIL+1))
fi

if grep -qF '只改代码与测试，不改设计文档' "$ZH/skills/aca-implement/SKILL.md.tmpl"; then
  echo "ok - version block: aca-implement does not handle version sync"; PASS=$((PASS+1))
else
  echo "FAIL - version block: aca-implement does not exclude version sync responsibilities"; FAIL=$((FAIL+1))
fi

ROOT_VERSION=$(tr -d '[:space:]' < "$ROOT/VERSION")
if tail -n 2 "$ROOT/README.md" | head -n 1 | grep -qF "**Anyone Can Architect v${ROOT_VERSION}**" \
  && tail -n 1 "$ROOT/README.md" | grep -qF 'Powered by [Anyone Can Architect](https://github.com/ruozi/anyone-can-architect) v'"${ROOT_VERSION}"' · Repo-Type: `guideline`'; then
  echo "ok - version block: Anyone Can Architect root README uses two-line template"; PASS=$((PASS+1))
else
  echo "FAIL - version block: Anyone Can Architect root README does not use two-line template"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-context-check(CONTEXT structure validator,#249)════════════════

CTX="$ROOT/bin/aca-context-check"

new_tree ctxok
printf '# Foo — Domain Context\n\n## Language\n\nThis repo has no project-specific terms\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: minimal valid structure OK" 0 "RESULT OK"

new_tree ctxbad
printf '# Foo\n\nA tuning tool, currently v1.4.2\n\n## Language\n\n**A**: x\n\n## Current State\n\nSee https://example.com/x\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: preamble prose, version, link and unknown section all detected" 1 "CONTEXT_PREAMBLE_PROSE" "CONTEXT_BAD_SECTION Current State" "CONTEXT_VERSION_REF" "CONTEXT_LINK_REF" "Migration mapping" "RESULT FAIL"

new_tree ctxnolang
printf '# Foo\n\n## Relationships\n\n- A has many B\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: missing Language FAIL" 1 "CONTEXT_NO_LANGUAGE" "RESULT FAIL"

new_tree ctxfence
printf '# Foo\n\n## Language\n\n### a\n\nExample syntax is `v1.2 format`\n\n```text\nv9.9 http://in-fence.example\n```\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: fenced/inline code exempt" 0 "RESULT OK"

new_tree ctxfull
printf '# Foo\n\n## Language\n\n### a\n\nx\n\n## Relationships\n\n- A has many B\n\n## Example dialogue\n\n> Dialogue\n\n## Flagged ambiguities\n\n- None\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: all four sections OK" 0 "RESULT OK"

run bash "$CTX" "$WORK/nonexistent/CONTEXT.md"
check "ctx: missing file exit 2" 2 "NO_CONTEXT"

# ── Term anchor format(#456 / #476 / #492):nonempty H3 headings, unique ignoring case; preserve English code names, allow Chinese ──
new_tree ctxterms
printf "# Foo

## Language

### repo-type

Repo type

### 素材库

A collection of assets

### Linac

An in-house tool; preserve the official spelling of its name

### OpenAI-SDK

A third-party SDK

## Relationships

- [repo-type](#repo-type) has many [素材库](#素材库)
" > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: H3 terms (lowercase English / capitalized proper names / Chinese) OK" 0 "RESULT OK"

new_tree ctx-code-names
printf '# Foo\n\n## Language\n\n### Task Owner\n\nPerson responsible for the task\n\n### CardMock\n\nCard mockup\n\n### task_no\n\nTask number\n\n### __init__\n\nInitialization method\n\n### repo-type\n\nRepo type\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: Title Case / PascalCase / snake_case / kebab-case preserve code names" 0 "RESULT OK"

printf '\n### task owner\n\nDuplicate task owner\n\n### TASK_NO\n\nDuplicate task number\n' >> "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: case-insensitive duplicate detection for terms with spaces and underscores" 1 "CONTEXT_TERM_DUP line 25" "CONTEXT_TERM_DUP line 29" "RESULT FAIL"

new_tree ctx-standard-names
printf '# Foo\n\n## Language\n\n### app-ads.txt\n\nApp advertising authorization file\n\n### ads.txt\n\nAdvertising authorization file\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: external standards with dots retain their original names" 0 "RESULT OK"

printf '\n### APP-ADS.TXT\n\nDuplicate authorization file\n' >> "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: terms with dots still use case-insensitive duplicate detection" 1 "CONTEXT_TERM_DUP line 13" "RESULT FAIL"

new_tree ctx-empty-name
printf '# Foo\n\n## Language\n\n### \n\nDefinition\n\n###    \n\nDefinition\n' > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: reject empty and whitespace-only headings" 1 "CONTEXT_TERM_FORMAT line 5" "CONTEXT_TERM_FORMAT line 9" "RESULT FAIL"

new_tree ctxtermbad
printf "# Foo

## Language

### Repo_Type

x

### repo-type

y

### repo-type

z

#### deep

**Legacy term**: Definition

## Relationships

### Not-Checked
" > "$D/CONTEXT.md"
run bash "$CTX" "$D/CONTEXT.md"
check "ctx: allow underscores, reject duplicates / H4 / legacy bold terms, skip H3 outside Language" 1 "!CONTEXT_TERM_FORMAT line 5" "CONTEXT_TERM_DUP line 13" "CONTEXT_TERM_FORMAT line 17" "CONTEXT_TERM_FORMAT line 19" "!Not-Checked" "RESULT FAIL"

if grep -qF "### example-term-1" "$ZH/templates/CONTEXT.md.example" \
  && ! grep -qE "^**示例术语" "$ZH/templates/CONTEXT.md.example" \
  && grep -qF '从 `~/.claude/skills/aca/templates/<文件名>.example` 创建并填写' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && grep -qF '[context 文档设计](~/.claude/skills/aca/doc-design/documents/context.md)' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && ! grep -qE "^\*\*[^*]+\*\*:" "$ZH/CONTEXT.md"; then
  echo "ok - ctx: template uses H3 terms, aca-init references template and doc design(#456)"; PASS=$((PASS+1))
else
  echo "FAIL - ctx: term formats differ across template / aca-init / this repo's CONTEXT #456"; FAIL=$((FAIL+1))
fi

# ════════════════ Link every use of a project term to its CONTEXT entry (#455)════════════════

if grep -qF '`CONTEXT.md` 已收录的术语使用对应名称与定义' "$ZH/skills/aca-design/SKILL.md.tmpl" \
  && grep -qF '正文与契约表中的已收录术语链接到对应词条' "$ZH/skills/aca-design/SKILL.md.tmpl" \
  && grep -qF '新增或修订定义交由输入提供方确认，按 [context 文档设计](~/.claude/skills/aca/doc-design/documents/context.md)的收录范围处理' "$ZH/skills/aca-design/SKILL.md.tmpl" \
  && grep -qF '标题、代码块、Mermaid 标签与产品文案保留纯文本' "$ZH/skills/aca-design/SKILL.md.tmpl"; then
  echo "ok - logic: Design maintains terminology links and source ownership"; PASS=$((PASS+1))
else
  echo "FAIL - logic: Design terminology contract missing"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-tag-notify-check(release summary format,#459)════════════════

TNC="$ROOT/bin/aca-tag-notify-check"

new_tree tnok
printf "v1.2.3：Topic（#1）

---NOTIFY-BEGIN---
🧭 Change one
📝 Change two
✅ Tests 75/75 passed
---NOTIFY-END---
" > "$D/note.md"
run bash "$TNC" "$D/note.md" v1.2.3
check "tnc: standard format OK(version argument with v)" 0 "RESULT OK"

new_tree tnbad
printf "v1.2.4 Topic

---NOTIFY-BEGIN---
- Change one
Change two
---NOTIFY-END---
" > "$D/note.md"
run bash "$TNC" "$D/note.md" 1.2.3
check "tnc: detect version mismatch / list prefix / missing ✅" 1 "TAG_NOTE_VERSION" "TAG_NOTE_LINE_FORMAT Item 1" "TAG_NOTE_NO_VERIFY" "RESULT FAIL"

new_tree tnnoblock
printf "v1.2.3：Title only
" > "$D/note.md"
run bash "$TNC" "$D/note.md" 1.2.3
check "tnc: missing NOTIFY block FAIL(v4.22.0 regression)" 1 "TAG_NOTE_NO_BLOCK" "RESULT FAIL"

new_tree tnempty
printf "v1.2.3：x

---NOTIFY-BEGIN---

---NOTIFY-END---
" > "$D/note.md"
run bash "$TNC" "$D/note.md" 1.2.3
check "tnc: empty block FAIL" 1 "TAG_NOTE_EMPTY" "RESULT FAIL"

run bash "$TNC" "$WORK/nonexistent/note.md" 1.2.3
check "tnc: missing file exit 2" 2 "NO_NOTE"

if grep -qF "### 6.1 发布摘要" "$ZH/skills/aca-release/SKILL.md.tmpl"   && grep -qF "aca-tag-notify-check ~/.aca/release-note-<TAG>.md <TAG>" "$ZH/skills/aca-release/SKILL.md.tmpl"   && grep -qF "不使用一行标题或空注解" "$ZH/skills/aca-release/SKILL.md.tmpl"   && grep -qF "aca-tag-notify-check" "$ZH/doc-design/documents/release.md"   && ! grep -qF "当前版本的通知内容已存在且版本号一致" "$ZH/skills/aca-release/SKILL.md.tmpl"; then
  echo "ok - release: release summary required and checked automatically before tagging(#459)"; PASS=$((PASS+1))
else
  echo "FAIL - release: release summary rules or validation steps drifted(#459)"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-release-notify-check / aca-tag-notify-extract(announcement integration,#462)════════════════

RNC="$ROOT/bin/aca-release-notify-check"
TNE="$ROOT/bin/aca-tag-notify-extract"

new_tree rncnone
run bash "$RNC" "$D"
check "rnc: no pipeline → NOTIFY_NONE" 0 "NOTIFY_NONE" "RESULT OK"

new_tree rnccnb
mkdir -p "$D/.ci"
printf 'v*:\n  tag_push:\n    - name: notify\n      stages:\n        - script: sh .ci/notify.sh\n' > "$D/.cnb.yml"
printf '#!/bin/sh\nS=$(bash bin/aca-tag-notify-extract "$TAG")\ncurl $FEISHU_WEBHOOK_URL\n' > "$D/.ci/notify.sh"
run bash "$RNC" "$D"
check "rnc: CNB tag_push + script uses extractor → WIRED" 0 "NOTIFY_WIRED" ".cnb.yml" "RESULT OK"

new_tree rncgh
mkdir -p "$D/.github/workflows"
printf "on:\n  push:\n    tags:\n      - 'v*'\njobs:\n  n:\n    steps:\n      - run: curl \$SLACK_WEBHOOK -d released\n" > "$D/.github/workflows/release.yml"
run bash "$RNC" "$D"
check "rnc: GitHub tags + slack does not use summary → UNWIRED FAIL" 1 "NOTIFY_UNWIRED" "release.yml" "RESULT FAIL"

new_tree rncbuild
printf 'job:\n  rules:\n    - if: $CI_COMMIT_TAG\n  script: make build\n' > "$D/.gitlab-ci.yml"
run bash "$RNC" "$D"
check "rnc: GitLab tag pipeline has no announcement actions → NONE" 0 "NOTIFY_NONE" "have no announcement actions" "RESULT OK"

new_tree tne
( cd "$D" && git init -q && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init \
  && printf 'v0.1.0：x（#1）\n\n---NOTIFY-BEGIN---\n- Change\n✅ Passed\n---NOTIFY-END---\n' > note.md \
  && git -c user.name=t -c user.email=t@t tag -a v0.1.0 -F note.md && git tag v0.2.0 )
run bash -c "cd '$D' && bash '$TNE' v0.1.0 --bullet"
check "tne: extract NOTIFY block and convert bullets to •" 0 "• Change" "✅ Passed" "!NOTIFY-BEGIN"
run bash -c "cd '$D' && bash '$TNE' v0.2.0"
check "tne: tag without annotation → exit 1" 1 "NO_NOTIFY"
run bash -c "cd '$D' && bash '$TNE' v9.9.9"
check "tne: missing tag → exit 2" 2 "NO_TAG"

if grep -qF "aca-release-notify-check ." "$ZH/skills/aca-release/SKILL.md.tmpl" \
  && grep -qF "| 📣 通告 |" "$ZH/skills/aca-release/SKILL.md.tmpl" \
  && grep -qF "aca-tag-notify-extract" "$ZH/doc-design/documents/release.md"; then
  echo "ok - release: platform-independent announcement integration, this repo's announcements use extractor(#462)"; PASS=$((PASS+1))
else
  echo "FAIL - release: announcement integration rules or this repo's notify.sh drifted(#462)"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-feedback submits by default after validation passes (#461)════════════════

if grep -qF '### 6.2 确认授权与提交准备' "$ZH/skills/aca-feedback/SKILL.md.tmpl"   && grep -qF '已有授权直接沿用，无需重复确认' "$ZH/skills/aca-feedback/SKILL.md.tmpl"   && grep -qF '未获提交授权' "$ZH/skills/aca-feedback/SKILL.md.tmpl"   && grep -qF '要求先看草案' "$ZH/skills/aca-feedback/SKILL.md.tmpl"   && ! grep -qF '让开发者选择提交、调整或忽略' "$ZH/skills/aca-feedback/SKILL.md.tmpl"; then
  echo "ok - feedback: submit by default after validation passes, explicit intent is the sole authorization(#461)"; PASS=$((PASS+1))
else
  echo "FAIL - feedback: default submission rule or explicit intent boundary drifted(#461)"; FAIL=$((FAIL+1))
fi

# ════════════════ Interface fields on separate lines + §1 shared contract type numbering (#460 / #463)════════════════

IFP="$ZH/doc-design/documents/interface.md"
if grep -qF '只有 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section) 两层' "$IFP" && grep -qF '或有两个以上的 [section](../../CONTEXT.md#section)' "$IFP" \
  && grep -qF '理解并列出全部内容，先不动笔' "$IFP" && grep -qF '## 3 行文步骤' "$IFP" \
  && grep -qF '公共契约 [chapter](../../CONTEXT.md#chapter)：被不同业务的接口共用的契约' "$IFP" && grep -qF '结构示意：' "$IFP" \
  && grep -qF '不列举调用方' "$IFP" \
  && ! grep -qF 'public-api' "$IFP"; then
  echo "ok - interface: two-level structure, understand before writing, shared contracts as needed, no public-api duplicate(#460/#463)"; PASS=$((PASS+1))
else
  echo "FAIL - interface: key doc design rules have drifted(#460/#463)"; FAIL=$((FAIL+1))
fi

# ════════════════ aca-walkthrough design walkthrough (#458)════════════════

WT="$ZH/skills/aca-walkthrough/SKILL.md.tmpl"
WT_OK=1
[ -f "$WT" ] || WT_OK=0
grep -qF '每次讨论一个单元' "$WT" || WT_OK=0
grep -qF '导读不判定审查是否通过' "$WT" || WT_OK=0
grep -qF '先治理被依赖的模块' "$ZH/doc-design/repo-types/desktop-app.md" || WT_OK=0
grep -qF '每个模块内部按 [module](../document-sets/module.md) 文档组规定的顺序治理' "$ZH/doc-design/repo-types/desktop-app.md" || WT_OK=0
grep -qF '/aca-walkthrough' "$ZH/meta-skills/aca/SKILL.md.tmpl" || WT_OK=0
for t in web-app mobile-app desktop-app client-sdk backend-service automation; do
  grep -qE '^## [0-9]+ 治理顺序$' "$ZH/doc-design/repo-types/$t.md" || WT_OK=0
done
! grep -qE '^## ([0-9]+ )?(治理顺序|导读顺序)$' "$ZH/doc-design/repo-types/guideline.md" || WT_OK=0
grep -qF '未规定顺序时，按文档引用依赖安排' "$WT" || WT_OK=0
if [ "$WT_OK" -eq 1 ]; then
  echo "ok - walkthrough: optional walkthrough phase, unit-by-unit confirmation, walkthrough order for each repo type(#458)"; PASS=$((PASS+1))
else
  echo "FAIL - walkthrough: skill / routing / walkthrough order missing or drifted(#458)"; FAIL=$((FAIL+1))
fi

# ════════════════ Pattern fallback: select by applicability when the doc design specifies none ════════════════

if grep -qF '文档设计未指定表达方式时' "$ZH/skills/aca-design/SKILL.md.tmpl" \
  && grep -qF '没有适用 pattern 时，按行文公理选择表达方式' "$ZH/skills/aca-design/SKILL.md.tmpl" \
  && grep -qF '按各 pattern 的适用场景选用 pattern' "$ZH/doc-design/README.md" \
  && ! grep -qF '图优先' "$ZH/doc-design/README.md"; then
  echo "ok - pattern-first: Design owns document expression selection"; PASS=$((PASS+1))
else
  echo "FAIL - pattern-first: Design expression contract missing"; FAIL=$((FAIL+1))
fi

# ════════════════ readme doc design: one design for all three README levels, replacing the docs-readme reference ════════════════

README_OK=1
[ -f "$ZH/doc-design/documents/readme.md" ] || README_OK=0
[ ! -e "$ZH/skills/references/docs-readme.md" ] || README_OK=0
grep -qF '用表格链接直接下一层的文档或目录 README' "$ZH/doc-design/documents/readme.md" || README_OK=0
grep -qF '根 README 可以只链接文档入口，其余文档由文档入口导航' "$ZH/doc-design/documents/readme.md" || README_OK=0
grep -qF '根 README 只链接文档入口时，其余文档都能从文档入口到达' "$ZH/doc-design/documents/readme.md" || README_OK=0
for t in backend-service client-sdk web-app mobile-app desktop-app automation; do
  grep -qF '| [readme](../documents/readme.md) |' "$ZH/doc-design/repo-types/$t.md" || README_OK=0
done
grep -qF '按 [readme 文档设计]' "$ZH/skills/aca-design/SKILL.md.tmpl" || README_OK=0
grep -qF '更新涉及的各级文档入口' "$ZH/skills/aca-design/SKILL.md.tmpl" || README_OK=0
! grep -rqF 'docs-readme' "$ZH/skills" "$ZH/meta-skills" --include='*.tmpl' || README_OK=0
if [ "$README_OK" -eq 1 ]; then
  echo "ok - readme: all repo types reference shared entry rules, root README may link only to the documentation entry, specify and brownfield references are correct"; PASS=$((PASS+1))
else
  echo "FAIL - readme: doc design, repo-type selection or skill references have drifted"; FAIL=$((FAIL+1))
fi

# ════════════════ Module folder conventions (#464)════════════════

MODULE_OK=1
for t in backend-service client-sdk web-app mobile-app desktop-app automation; do
  grep -qF '[module](../document-sets/module.md)' "$ZH/doc-design/repo-types/$t.md" || MODULE_OK=0
done
grep -qF 'docs/design/module-{X}/' "$ZH/doc-design/document-sets/module.md" || MODULE_OK=0
for module_file in interface.md class-design.md testcase.md README.md; do
  grep -qF "| $module_file |" "$ZH/doc-design/document-sets/module.md" || MODULE_OK=0
done
[ ! -e "$ZH/doc-design/documents/module.md" ] || MODULE_OK=0
if [ "$MODULE_OK" -eq 1 ]; then
  echo "ok - module: repo types reference a shared document set that defines the module directory and four files(#464)"; PASS=$((PASS+1))
else
  echo "FAIL - module: module folder conventions have drifted(#464)"; FAIL=$((FAIL+1))
fi

# ════════════════ Recursive submodule nesting and parent–child responsibilities (#511)════════════════

NEST_OK=1
MODULE_SET="$ZH/doc-design/document-sets/module.md"
grep -qF '### 2.2 子模块' "$MODULE_SET" || NEST_OK=0
grep -qF '子模块目录位于直接父级模块目录内' "$MODULE_SET" || NEST_OK=0
grep -qF '└─ module-pricing/' "$MODULE_SET" || NEST_OK=0
grep -qF '### 2.3 父子职责' "$MODULE_SET" || NEST_OK=0
grep -qF '子级 interface 不自动成为父级的对外契约' "$MODULE_SET" || NEST_OK=0
grep -qF '同一测试用例只归属一个层级' "$MODULE_SET" || NEST_OK=0
grep -qF '子模块目录位于直接父级模块目录内，与父级 class-design 的内部组成一致' "$MODULE_SET" || NEST_OK=0
grep -qF '「内部机制」的第一个 [chapter](../../CONTEXT.md#chapter) 为「内部组成」' "$ZH/doc-design/documents/class-design.md" || NEST_OK=0
grep -qF '本文只定义顶层模块，子模块的划分与协作归父模块的 class-design' "$ZH/doc-design/documents/architecture.md" || NEST_OK=0
grep -qF '子模块取自直接父级 class-design 的内部组成' "$ZH/skills/aca-implement/SKILL.md.tmpl" || NEST_OK=0
grep -qF '父级任务依赖其全部子模块任务' "$ZH/skills/aca-implement/SKILL.md.tmpl" || NEST_OK=0
if [ "$NEST_OK" -eq 1 ]; then
  echo "ok - module: submodules can nest recursively; parent–child responsibilities, split criteria and checklist are defined(#511)"; PASS=$((PASS+1))
else
  echo "FAIL - module: recursive submodule nesting rules missing(#511)"; FAIL=$((FAIL+1))
fi

# ════════════════ repo-type enumeration consistency(prevent missed updates when adding types)════════════════
# The repo-type index matches the spec directory (aca-repo-type-check reads valid types there), and aca-init references the index

ENUM_CHECK=$(for f in "$ZH"/doc-design/repo-types/*.md; do basename "$f" .md; done | sort)
ENUM_TABLE=$(sed -nE 's/^\| `([a-z-]+)` \|.*$/\1/p' "$ZH/doc-design/README.md" | sort)

if [ -n "$ENUM_CHECK" ] && [ "$ENUM_CHECK" = "$ENUM_TABLE" ]; then
  echo "ok - enum: repo-type spec directory matches the index($(echo "$ENUM_CHECK" | wc -l | tr -d ' ') types)"; PASS=$((PASS+1))
else
  echo "FAIL - enum: repo-type lists differ"
  echo "  Repo-type spec directory:       $(echo $ENUM_CHECK)"
  echo "  Repo-type index:       $(echo $ENUM_TABLE)"
  FAIL=$((FAIL+1))
fi

# ════════════════ App type detection: web, mobile and desktop ════════════════

APP_TYPE_DIR="$WORK/app-type"
mkdir -p "$APP_TYPE_DIR"
APP_TYPES_OK=1
for app_type in web-app mobile-app desktop-app; do
  printf '> 🤝 Powered by [Anyone Can Architect](https://example.com) v5.0.0 · Repo-Type: `%s`\n' "$app_type" > "$APP_TYPE_DIR/README.md"
  app_type_result=$(LC_ALL=C bash "$ROOT/bin/aca-repo-type-check" "$APP_TYPE_DIR")
  app_type_status=$?
  [ "$app_type_status" -eq 0 ] && [ "$app_type_result" = "$app_type" ] || APP_TYPES_OK=0
  [ -f "$ZH/doc-design/repo-types/$app_type.md" ] || APP_TYPES_OK=0
done
printf '> 🤝 Powered by [Anyone Can Architect](https://example.com) v5.0.0 · Repo-Type: `productivity-client`\n' > "$APP_TYPE_DIR/README.md"
app_type_result=$(LC_ALL=C bash "$ROOT/bin/aca-repo-type-check" "$APP_TYPE_DIR")
app_type_status=$?
[ "$app_type_status" -eq 1 ] && [ "$app_type_result" = 'INVALID_TYPE productivity-client' ] || APP_TYPES_OK=0
if [ "$APP_TYPES_OK" -eq 1 ]; then
  echo "ok - app types: all three app types are recognized and have specs; the legacy productivity client type requires reclassification"; PASS=$((PASS+1))
else
  echo "FAIL - app types: type detection or spec entry has drifted"; FAIL=$((FAIL+1))
fi

# ════════════════ Overview flowchart uses business-process granularity (#425)════════════════

if grep -qF '按阶段性的业务目的划分并命名节点，不按具体操作拆分' "$ZH/doc-design/patterns/flowchart.md" \
  && grep -qF '单个叶子命令的处理设计' "$ZH/doc-design/documents/command.md" \
  && grep -qF '引用命令注册表' "$ZH/doc-design/documents/command-router.md"; then
  echo "ok - flowchart: overview follows business processes only"; PASS=$((PASS+1))
else
  echo "FAIL - flowchart: overview granularity rules or command outline have drifted"
  FAIL=$((FAIL+1))
fi

# ════════════════ Flowchart explanations resolve ambiguity as needed (#453)════════════════

FLOWCHART_PATTERN="$ZH/doc-design/patterns/flowchart.md"
if grep -qF '需要展开的节点引用对应子章节' "$FLOWCHART_PATTERN" \
  && grep -qF '子章节按执行顺序列明具体步骤，明确判断条件，不复述图中路径' "$FLOWCHART_PATTERN" \
  && ! grep -qF '闭合三类' "$FLOWCHART_PATTERN"; then
  echo "ok - flowchart: notes after the diagram resolve implementation ambiguity only as needed"; PASS=$((PASS+1))
else
  echo "FAIL - flowchart: notes after the diagram require detailed explanations of every step or fixed categories"
  FAIL=$((FAIL+1))
fi

# ════════════════ Entry points and navigation use reader-friendly language (#427)════════════════

# ════════════════ architecture module divisions use reader-friendly language (#446–#448)════════════════

ARCH_DOC="$ZH/doc-design/documents/architecture.md"
if grep -qF '模块表：模块、能力、责任边界' "$ARCH_DOC" \
  && grep -qF '关系表：发起方、承接方、协作职责、触发条件、结果处理' "$ARCH_DOC" \
  && grep -qF '[分层视图](../patterns/layered-view.md)' "$ARCH_DOC" \
  && grep -qF '[时序图](../patterns/sequence-diagram.md)' "$ARCH_DOC" \
  && grep -qF '业务工况用于验证模块划分能否支撑业务' "$ARCH_DOC" \
  && grep -qF '模块内部实现与接口契约归对应模块文档' "$ARCH_DOC"; then
  echo "ok - architecture: structure, responsibilities, collaboration and business scenarios"; PASS=$((PASS+1))
else
  echo "FAIL - architecture: governed architecture contract missing"; FAIL=$((FAIL+1))
fi

# ════════════════ guideline does not use ROADMAP (#428)════════════════


if grep -qF 'guideline 不创建、保留或读取 `ROADMAP.md`' "$ZH/doc-design/repo-types/guideline.md" \
  && grep -qF '按必要条件筛选需要初始化的根目录文件' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && ! grep -qF 'FORBIDDEN' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" && ! grep -qF '= guideline ]' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && grep -qF '未规定治理顺序时，说明本类型不适用 Specify' "$ZH/skills/aca-specify/SKILL.md.tmpl" \
  && ! grep -qF 'guideline' "$ZH/skills/aca-release/SKILL.md.tmpl" \
  && ! grep -qF 'guideline' "$ZH/skills/aca-implement/SKILL.md.tmpl" \
  && grep -qF 'aca-repo-type-check' "$ZH/skills/aca-repo-audit/SKILL.md.tmpl" && grep -qF 'Repo-Type 只从根 README footer 读取' "$ZH/partials/precheck.md" \
  && [ ! -e "$ROOT/ROADMAP.md" ] \
  && ! grep -qF 'ROADMAP.md' "$ROOT/README.md"; then
  echo "ok - guideline: records selected by project structure, no fixed design order, no ROADMAP created"; PASS=$((PASS+1))
else
  echo "FAIL - guideline lifecycle: still creates, reads or retains ROADMAP"
  FAIL=$((FAIL+1))
fi

# ════════════════ guideline does not maintain a root CHANGELOG (#429 / #430)════════════════

if grep -qF 'guideline 根目录不创建、保留或读取 `CHANGELOG.md`' "$ZH/doc-design/repo-types/guideline.md" \
  && grep -qF '非文档对象存在独立交付方与消费者' "$ZH/doc-design/repo-types/guideline.md" \
  && ! grep -qF '!= guideline ]' "$ZH/meta-skills/aca-init/SKILL.md.tmpl" \
  && [ "$(grep -lE '^## [0-9]+ 项目结构$' "$ZH"/doc-design/repo-types/*.md | wc -l)" -eq 7 ] \
  && grep -qF '未选用 release 文档时，按类型规则确定记录范围' "$ZH/skills/aca-release/SKILL.md.tmpl" \
  && ! grep -qF 'guideline' "$ZH/skills/aca-specify/SKILL.md.tmpl" \
  && grep -qF "for-each-ref \"refs/tags/\${TAG}\"" "$ROOT/bin/aca-tag-notify-extract" \
  && [ ! -e "$ROOT/CHANGELOG.md" ] \
  && ! grep -qF '[CHANGELOG.md](CHANGELOG.md)' "$ROOT/README.md"; then
  echo "ok - guideline changelog: forbidden at root, maintained alongside non-document deliverables"
  PASS=$((PASS+1))
else
  echo "FAIL - guideline changelog: root directory or release workflow still depends on CHANGELOG"
  FAIL=$((FAIL+1))
fi

# ════════════════ lark-card-mockup description lists (#436)════════════════

LARK_CARD_MOCKUP="$ZH/doc-design/patterns/lark-card-mockup.md"
if grep -qF '描述列表（description list）' "$LARK_CARD_MOCKUP" \
  && grep -qF '将标签与取值分为两列' "$LARK_CARD_MOCKUP" \
  && grep -qF '标签列固定宽度为 64px' "$LARK_CARD_MOCKUP" \
  && grep -qF '不使用空格补齐' "$LARK_CARD_MOCKUP"; then
  echo "ok - lark-card-mockup: multiline properties use a true two-column description list without space padding"
  PASS=$((PASS+1))
else
  echo "FAIL - lark-card-mockup: rules for description lists, two-column alignment or banning space padding are incomplete"
  FAIL=$((FAIL+1))
fi

LARK_CARD_IMPL="$ZH/skills/references/lark-card-mapping.md"
CARD_SECTIONS_OK=1
for chapter in 3 4 5 6 7 8 9 10 11; do
  grep -qE "^## $chapter " "$LARK_CARD_MOCKUP" || CARD_SECTIONS_OK=0
  grep -qE "^## $chapter " "$LARK_CARD_IMPL" || CARD_SECTIONS_OK=0
done
if [ "$CARD_SECTIONS_OK" -eq 1 ] && [ -f "$LARK_CARD_IMPL" ] \
  && [ ! -e "$ZH/skills/references/lark-card-implementation.md" ] \
  && grep -qF '覆盖所有用户能看到的场景与状态，每种状态都展示完整的[卡片示意](../../CONTEXT.md#card-mockup)' "$LARK_CARD_MOCKUP" \
  && grep -qF '尽可能用卡片示意充分表达信息，凡是能用卡片示意表达的信息，不再用解释性文字描述' "$LARK_CARD_MOCKUP" \
  && ! grep -qF '> 场景案例初稿' "$LARK_CARD_MOCKUP" \
  && ! grep -qF 'repo-types/automation.md' "$LARK_CARD_MOCKUP" \
  && grep -qF '使用 HTML 模拟真实场景展示卡片示意，以指导卡片 JSON 的实现' "$LARK_CARD_MOCKUP" \
  && ! grep -qF '映射规范' "$LARK_CARD_MOCKUP" \
  && ! grep -qF 'data-card=' "$LARK_CARD_MOCKUP" \
  && grep -qF '[飞书卡片示意](../../doc-design/patterns/lark-card-mockup.md)里的每个 HTML 样式与特征' "$LARK_CARD_IMPL" \
  && grep -qF '设计包含飞书卡片示意时，按[飞书卡片映射](~/.claude/skills/aca/skills/references/lark-card-mapping.md)实现' "$ZH/skills/aca-implement/SKILL.md.tmpl" \
  && grep -qxF '## 2 整体表达原则' "$LARK_CARD_MOCKUP" \
  && grep -qxF '## 2 通用实现' "$LARK_CARD_IMPL" \
  && grep -qF 'component-json-v2-overview' "$LARK_CARD_IMPL" \
  && grep -qF '[飞书卡片示意](../patterns/lark-card-mockup.md)' "$ZH/doc-design/documents/command.md" \
  && grep -qF '[飞书卡片示意](../patterns/lark-card-mockup.md)' "$ZH/doc-design/documents/event.md"; then
  echo "ok - lark-card: mockup and mapping pair chapter by chapter"
  PASS=$((PASS+1))
else
  echo "FAIL - lark-card: mockup and mapping are not paired chapter by chapter"
  FAIL=$((FAIL+1))
fi

# ════════════════ Parent–child boundary recheck & single-level composition diagram (#513)════════════════

SUBMOD_BOUNDARY_OK=1
grep -qF '组成图将每个直接子模块作为一个整体节点' "$ZH/doc-design/documents/class-design.md" || SUBMOD_BOUNDARY_OK=0
grep -qF '不绘制子模块内部的类、状态、算法与更深层子模块' "$ZH/doc-design/documents/class-design.md" || SUBMOD_BOUNDARY_OK=0
grep -qF '只展开本层与直接子模块，与直接子模块目录一致' "$ZH/doc-design/documents/class-design.md" || SUBMOD_BOUNDARY_OK=0
grep -qF '回查父级 class-design，核对父子边界' "$ZH/doc-design/document-sets/module.md" || SUBMOD_BOUNDARY_OK=0
grep -qF '父级不直接操作子级内部字段，不调用子级 interface 未声明的方法' "$ZH/doc-design/document-sets/module.md" || SUBMOD_BOUNDARY_OK=0
grep -qF '父级 class-design 没有保留已归属子级的数据结构、状态机、算法与子级内部测试' "$ZH/doc-design/document-sets/module.md" || SUBMOD_BOUNDARY_OK=0
if [ "$SUBMOD_BOUNDARY_OK" -eq 1 ]; then
  echo "ok - module: parent class-design single-level composition and parent–child boundary recheck (#513)"; PASS=$((PASS+1))
else
  echo "FAIL - module: parent class-design single-level composition or parent–child boundary recheck missing (#513)"; FAIL=$((FAIL+1))
fi

# ════════════════ Code-first integration-guide (#514)════════════════

IG_OK=1
IG_DOC="$ZH/doc-design/documents/integration-guide.md"
grep -qF '可用代码表达的接入场景：以可复制运行的代码为主体' "$IG_DOC" || IG_OK=0
grep -qF '参数用途、调用条件与语句自身无法表达的约束就近写入代码注释' "$IG_DOC" || IG_OK=0
grep -qF '正文只写代码之外必需的操作与完成结果' "$IG_DOC" || IG_OK=0
grep -qF '正文没有复述代码已表达的调用与参数' "$IG_DOC" || IG_OK=0
if [ "$IG_OK" -eq 1 ]; then
  echo "ok - integration-guide: code-first expression and inline comments without prose duplication (#514)"; PASS=$((PASS+1))
else
  echo "FAIL - integration-guide: code-first expression or checklist rules missing (#514)"; FAIL=$((FAIL+1))
fi

# ════════════════ Independent /aca-test skill & blast-radius verification (#515)════════════════

ACA_TEST_OK=1
ACA_TEST_SKILL="$ZH/skills/aca-test/SKILL.md.tmpl"
[ -f "$ACA_TEST_SKILL" ] || ACA_TEST_OK=0
grep -qF 'name: aca-test' "$ACA_TEST_SKILL" || ACA_TEST_OK=0
grep -qF '按变更突破的设计边界选取最小化测试集' "$ACA_TEST_SKILL" || ACA_TEST_OK=0
grep -qF '只运行测试并核实结果，不修改设计文档、生产代码或测试代码' "$ACA_TEST_SKILL" || ACA_TEST_OK=0
grep -qF '在低并发隔离条件下单独重跑失败项核实' "$ACA_TEST_SKILL" || ACA_TEST_OK=0
grep -qF 'implement / test / release / feedback 是纯执行，不注入' "$ZH/axioms/README.md" || ACA_TEST_OK=0
grep -qF '/aca-test' "$ZH/meta-skills/aca/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '不运行测试' "$ZH/skills/aca-implement/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '测试运行统一交给 `/aca-test`' "$ZH/skills/aca-implement/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '不运行受审代码与测试' "$ZH/skills/aca-review/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '运行验证在审查通过后由 `/aca-test` 执行' "$ZH/skills/aca-review/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '按 `/aca-test` 的边界规则与仓库 `release` 文档，确定本次范围所需的测试与构建命令' "$ZH/skills/aca-repo-audit/SKILL.md.tmpl" || ACA_TEST_OK=0
grep -qF '可统一执行全量验证，或按改动突破的设计边界与依赖范围分级定义' "$ZH/doc-design/documents/release.md" || ACA_TEST_OK=0
grep -qF '包含子项时每步以加粗短语开头表达目的' "$ZH/axioms/writing.md" || ACA_TEST_OK=0
if [ "$ACA_TEST_OK" -eq 1 ]; then
  echo "ok - aca-test: independent test skill, blast-radius scoping, implement/review separation and bold step headers (#515)"; PASS=$((PASS+1))
else
  echo "FAIL - aca-test: skill, routing, implement/review separation or release tiered verification missing (#515)"; FAIL=$((FAIL+1))
fi

# ════════════════ Summary ════════════════

echo "───────────────────────────"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
