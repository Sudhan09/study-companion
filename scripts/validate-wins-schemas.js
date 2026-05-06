#!/usr/bin/env node
// Validates wins/*.md frontmatter against revised /lock-decision schema.
// Per design §G Revision 3: date, concept, user_precondition, concept_gap, test, artifact.
// Legacy `trigger:` field is forbidden.

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const winsDir = path.join(repoRoot, 'wins');

const REQUIRED_FIELDS = ['date', 'concept', 'user_precondition', 'concept_gap', 'test', 'artifact'];
const FORBIDDEN_FIELDS = ['trigger'];

const errors = [];
const filesChecked = [];

if (!fs.existsSync(winsDir)) {
  console.error(`MISSING: ${winsDir}`);
  process.exit(1);
}

for (const entry of fs.readdirSync(winsDir)) {
  if (!entry.endsWith('.md')) continue;
  const full = path.join(winsDir, entry);
  if (!fs.statSync(full).isFile()) continue;
  filesChecked.push(entry);

  const content = fs.readFileSync(full, 'utf8');
  // Tolerate leading HTML comment then frontmatter.
  const fmMatch = content.match(/^(?:<!--[\s\S]*?-->\s*)?---\r?\n([\s\S]+?)\r?\n---\r?\n/);
  if (!fmMatch) {
    errors.push(`${entry}: missing or malformed YAML frontmatter`);
    continue;
  }
  const fm = fmMatch[1];

  for (const field of REQUIRED_FIELDS) {
    if (!new RegExp(`^${field}:\\s`, 'm').test(fm)) {
      errors.push(`${entry}: missing required field '${field}'`);
    }
  }
  for (const field of FORBIDDEN_FIELDS) {
    if (new RegExp(`^${field}:\\s`, 'm').test(fm)) {
      errors.push(`${entry}: forbidden legacy field '${field}' present (replaced by user_precondition+concept_gap+test+artifact in design §G Revision 3)`);
    }
  }
}

if (errors.length) {
  console.error('WINS VALIDATION FAILED:');
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}

console.log(`OK: ${filesChecked.length} wins validated`);
console.log('  Files: ' + filesChecked.join(', '));
