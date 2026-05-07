#!/usr/bin/env node
// Path A v3 GAP-03 cross-file consistency validator.
//
// Enforces: state/vacation.md exists ⇔ state/current_day.md.mode == 'paused'.
//
// Failure modes prevented:
//   1. vacation.md exists but mode != 'paused' (orphan vacation record).
//   2. mode == 'paused' but no vacation.md (mode set without active record).
//   3. vacation.md.start_date in the future (data-entry typo).
//   4. vacation.md.end_date < start_date (typo or reversed dates).
//
// Run pre-merge AND post-merge in the auto-merge workflow alongside the other
// validators. Schema-level checks for vacation.md (RFC 3339 offsets, required
// fields) live in scripts/validate-state-schemas.js — this validator is purely
// about cross-file consistency.

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const stateDir = path.join(repoRoot, 'state');
const currentDayPath = path.join(stateDir, 'current_day.md');
const vacationPath = path.join(stateDir, 'vacation.md');

const errors = [];

function readMode() {
  if (!fs.existsSync(currentDayPath)) {
    return null; // bootstrap state — current_day.md not yet present
  }
  const content = fs.readFileSync(currentDayPath, 'utf8');
  const fmMatch = content.match(/^---\r?\n([\s\S]+?)\r?\n---\r?\n/);
  if (!fmMatch) return null;
  const modeMatch = fmMatch[1].match(/^mode:\s*(\S+)\s*$/m);
  if (!modeMatch) return null; // mode field absent → treated as 'bootcamp' (M1-1 default)
  return modeMatch[1].replace(/^["']|["']$/g, '');
}

function readVacationFields() {
  if (!fs.existsSync(vacationPath)) return null;
  const content = fs.readFileSync(vacationPath, 'utf8');
  const fmMatch = content.match(/^---\r?\n([\s\S]+?)\r?\n---\r?\n/);
  if (!fmMatch) return { _malformed: true };
  const fm = fmMatch[1];
  const out = {};
  for (const field of ['start_date', 'end_date', 'set_at', 'set_by']) {
    const m = fm.match(new RegExp(`^${field}:\\s*(.+)$`, 'm'));
    if (m) out[field] = m[1].trim().replace(/^["']|["']$/g, '');
  }
  return out;
}

const mode = readMode();
const vac = readVacationFields();
const vacExists = vac !== null && !vac._malformed;

// Rule 1: vacation.md exists ⇔ mode == 'paused'.
if (vacExists && mode !== 'paused') {
  errors.push(
    `cross-file: state/vacation.md exists but state/current_day.md.mode is '${mode || 'absent'}', expected 'paused'. ` +
    `Either run /resume-routines (which removes vacation.md) or set mode: paused in current_day.md.`
  );
}
if (!vacExists && mode === 'paused') {
  errors.push(
    `cross-file: state/current_day.md.mode is 'paused' but state/vacation.md does not exist. ` +
    `Either run /pause-routines (which writes vacation.md) or set mode back to a non-paused value.`
  );
}

// Rule 2: vacation.md frontmatter must parse if present.
if (vac && vac._malformed) {
  errors.push(`state/vacation.md: missing or malformed YAML frontmatter`);
}

// Rule 3 + 4: date sanity checks (only when vacation.md is present and well-formed).
if (vacExists && vac.start_date) {
  const start = Date.parse(vac.start_date);
  if (isNaN(start)) {
    errors.push(`state/vacation.md: 'start_date: ${vac.start_date}' is unparseable`);
  } else {
    // Compare against IST today's start (00:00 IST = (today UTC -5:30 if needed)).
    // Tolerance: allow up to 1 day in the future in case of timezone-edge typos.
    const tomorrow = Date.now() + 24 * 3600 * 1000;
    if (start > tomorrow) {
      errors.push(
        `state/vacation.md: 'start_date: ${vac.start_date}' is more than 1 day in the future — likely typo`
      );
    }
    if (vac.end_date && vac.end_date !== 'null') {
      const end = Date.parse(vac.end_date);
      if (!isNaN(end) && end < start) {
        errors.push(
          `state/vacation.md: 'end_date: ${vac.end_date}' precedes 'start_date: ${vac.start_date}'`
        );
      }
    }
  }
}

if (errors.length) {
  console.error('VACATION CONSISTENCY FAILED:');
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}

const summary = vacExists
  ? `OK: vacation.md present + mode='paused' (consistent)`
  : `OK: vacation.md absent + mode='${mode || 'bootcamp'}' (consistent)`;
console.log(summary);
