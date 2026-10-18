#!/usr/bin/env node
// anyone-can-architect — npx entry point
//
// npx anyone-can-architect install [--lang en|zh] [--host <host>]
// npx anyone-can-architect@latest update        (same as install; used by /aca-update)
//
// Runs scripts/install.sh from this package with bash; on Windows it uses Git Bash

'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const VERSION = fs.readFileSync(path.join(ROOT, 'VERSION'), 'utf8').trim();
const HOSTS = ['claude', 'codex', 'cursor', 'grok', 'antigravity', 'antigravity-cli'];

const USAGE = `Anyone Can Architect ${VERSION}

Usage:
  npx anyone-can-architect install [--lang en|zh] [--host <host>]
  npx anyone-can-architect@latest update [--host <host>]

Options:
  --lang en|zh   Language of the skills (default: last used, else English)
  --host <host>  Install for one tool only: ${HOSTS.join(', ')}
                 (default: every tool already set up, else the first one found)
`;

function fail(message) {
  process.stderr.write(`Error: ${message}\n`);
  process.exit(1);
}

function parse(argv) {
  const args = { command: null, lang: null, host: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const value = (name) => {
      const v = argv[++i];
      if (!v || v.startsWith('--')) fail(`${name} needs a value`);
      return v;
    };
    if (a === '-h' || a === '--help' || a === 'help') args.command = 'help';
    else if (a === '-v' || a === '--version') args.command = 'version';
    else if (a === '--lang') args.lang = value('--lang');
    else if (a.startsWith('--lang=')) args.lang = a.slice(7);
    else if (a === '--host') args.host = value('--host');
    else if (a.startsWith('--host=')) args.host = a.slice(7);
    else if (!args.command && (a === 'install' || a === 'update')) args.command = 'install';
    else fail(`unknown argument: ${a}\n\n${USAGE}`);
  }
  if (args.lang && !['en', 'zh'].includes(args.lang)) fail(`--lang must be en or zh, got ${args.lang}`);
  if (args.host && !HOSTS.includes(args.host)) fail(`--host must be one of: ${HOSTS.join(', ')}`);
  return args;
}

// Git Bash on Windows; plain bash elsewhere. Skip System32\bash.exe, which starts WSL instead of Git Bash
function findBash() {
  if (process.platform !== 'win32') return 'bash';
  const candidates = [];
  if (process.env.ACA_BASH) candidates.push(process.env.ACA_BASH);
  for (const base of [process.env.ProgramFiles, process.env['ProgramFiles(x86)'], process.env.LOCALAPPDATA && path.join(process.env.LOCALAPPDATA, 'Programs')]) {
    if (base) candidates.push(path.join(base, 'Git', 'bin', 'bash.exe'));
  }
  const where = spawnSync('where', ['git'], { encoding: 'utf8' });
  if (where.status === 0) {
    for (const git of where.stdout.split(/\r?\n/).filter(Boolean)) {
      candidates.push(path.resolve(path.dirname(git), '..', 'bin', 'bash.exe'));
    }
  }
  const found = candidates.find((c) => fs.existsSync(c));
  if (!found) fail('bash not found. Install Git for Windows (https://git-scm.com/download/win) and run the command again');
  return found;
}

function main() {
  const args = parse(process.argv.slice(2));
  if (args.command === 'version') return void process.stdout.write(`${VERSION}\n`);
  if (args.command !== 'install') return void process.stdout.write(USAGE);

  const script = path.join(ROOT, 'scripts', 'install.sh').split(path.sep).join('/');
  const scriptArgs = [script];
  if (args.lang) scriptArgs.push('--lang', args.lang);
  if (args.host) scriptArgs.push('--host', args.host);

  const result = spawnSync(findBash(), scriptArgs, { stdio: 'inherit' });
  if (result.error) fail(result.error.message);
  process.exit(result.status === null ? 1 : result.status);
}

main();
