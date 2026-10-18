#!/usr/bin/env node
// pack-check — the npm package carries the installer and both languages, and leaves out repo-only files
// Usage: node tests/pack-check.js   (runs `npm pack --dry-run`, offline)

'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, 'package.json'), 'utf8'));
const version = fs.readFileSync(path.join(ROOT, 'VERSION'), 'utf8').trim();
const problems = [];

if (pkg.version !== version) problems.push(`package.json version ${pkg.version} != VERSION ${version}`);

const packed = JSON.parse(execSync('npm pack --dry-run --json', { cwd: ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));
const files = packed[0].files.map((f) => f.path.split('\\').join('/'));

const required = [
  'cli/index.js', 'scripts/install.sh', 'scripts/setup.sh', 'bin/aca-update-check', 'bin/aca-host-skill-root',
  'VERSION', 'CONTEXT.md', 'SSOT.md', 'README.md', 'LICENSE',
  'meta-skills/aca/SKILL.md', 'dist/codex/aca/SKILL.md', 'doc-design/README.md', 'axioms/writing.md', 'templates/CONTEXT.md.example',
  'zh-CN/meta-skills/aca/SKILL.md', 'zh-CN/dist/codex/aca/SKILL.md', 'zh-CN/CONTEXT.md', 'zh-CN/doc-design/README.md',
];
for (const f of required) if (!files.includes(f)) problems.push(`missing ${f}`);
for (const f of files) if (/^(tests|assets|\.github)\//.test(f)) problems.push(`unexpected ${f}`);

if (problems.length) {
  for (const p of problems) console.log(`PACK_PROBLEM ${p}`);
  console.log('RESULT FAIL');
  process.exit(1);
}
console.log(`PACK_FILES ${files.length}`);
console.log('RESULT OK');
