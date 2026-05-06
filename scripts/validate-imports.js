#!/usr/bin/env node
// Per build-plan Task 3.9 step 2. Validates every @path referenced in CLAUDE.md
// resolves to an existing file relative to the repo root.

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const claudeMdPath = path.join(repoRoot, 'CLAUDE.md');

if (!fs.existsSync(claudeMdPath)) {
  console.error(`MISSING: ${claudeMdPath}`);
  process.exit(1);
}

const claudeMd = fs.readFileSync(claudeMdPath, 'utf8');
// Match `@path/to/file.md` at line start (skip comments and inline `@` mentions)
const imports = [...claudeMd.matchAll(/^@(\S+)/gm)].map(m => m[1]);

if (!imports.length) {
  console.error('NO @-IMPORTS FOUND in CLAUDE.md');
  process.exit(1);
}

const missing = imports.filter(p => !fs.existsSync(path.join(repoRoot, p)));

if (missing.length) {
  console.error('MISSING IMPORTS:');
  for (const m of missing) console.error('  - ' + m);
  process.exit(1);
}

console.log(`OK: ${imports.length} imports resolve`);
console.log('  Paths: ' + imports.join(', '));
