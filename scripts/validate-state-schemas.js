#!/usr/bin/env node
// Per build-plan Task 9.7. Validates state/*.md schemas:
//  - frontmatter present with `last_updated` and `updated_by`
//  - `last_updated` is parseable ISO timestamp
//  - `current_day.md` has both `bootcamp:` and `loop_week:` sections

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const stateDir = path.join(repoRoot, 'state');

const errors = [];
const filesChecked = [];

if (!fs.existsSync(stateDir)) {
  console.error(`MISSING: ${stateDir}`);
  process.exit(1);
}

for (const entry of fs.readdirSync(stateDir)) {
  const full = path.join(stateDir, entry);
  if (!entry.endsWith('.md')) continue;
  const stat = fs.statSync(full);
  if (!stat.isFile()) continue;
  filesChecked.push(entry);

  const content = fs.readFileSync(full, 'utf8');
  const fmMatch = content.match(/^---\r?\n([\s\S]+?)\r?\n---/);
  if (!fmMatch) {
    errors.push(`${entry}: missing YAML frontmatter`);
    continue;
  }
  const fmRaw = fmMatch[1];

  const luMatch = fmRaw.match(/^last_updated:\s*(.+)$/m);
  if (!luMatch) {
    errors.push(`${entry}: missing 'last_updated' frontmatter field`);
  } else {
    const ts = luMatch[1].trim();
    const parsed = Date.parse(ts);
    if (isNaN(parsed)) {
      errors.push(`${entry}: 'last_updated' is not a parseable ISO timestamp: '${ts}'`);
    }
  }

  if (!/^updated_by:\s*\S+/m.test(fmRaw)) {
    errors.push(`${entry}: missing 'updated_by' frontmatter field`);
  }

  if (entry === 'current_day.md') {
    if (!/^bootcamp:/m.test(content)) {
      errors.push(`current_day.md: missing 'bootcamp:' section (per design §J #11 two-dimension schema)`);
    }
    if (!/^loop_week:/m.test(content)) {
      errors.push(`current_day.md: missing 'loop_week:' section (per design §J #11 two-dimension schema)`);
    }
  }
}

if (errors.length) {
  console.error('VALIDATION FAILED:');
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}

console.log(`OK: ${filesChecked.length} state files validated`);
console.log('  Files: ' + filesChecked.join(', '));
