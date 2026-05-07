#!/usr/bin/env node
// Per build-plan Task 9.7. Validates state/*.md schemas:
//  - frontmatter present with `last_updated` and `updated_by`
//  - `last_updated` is parseable ISO timestamp
//  - `current_day.md` has both `bootcamp:` and `loop_week:` sections

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const stateDir = path.join(repoRoot, 'state');

// Per state/SOURCE_OF_TRUTH.md registry. Each state file has a fixed set of
// allowed `updated_by` values. `build-init` is tolerated as a transient seed
// value. Update this map when you add new state files.
//
// Path A v3 additions (2026-05-07):
//   - current_day.md gains `/pause-routines`, `/resume-routines`, `user` writers
//     (per decisions Q10: bootcamp.current_day is user-maintained, NOT auto-computed)
//   - last_session_summary.md gains `/resume-routines` (gap-notice rewrite)
//   - schedule.md gains `/pause-routines` (paused-banner write)
//   - new files: vacation.md (active record), missed_routines.md (audit log)
const ALL_ROUTINES = [
  'study-curriculum-sync',
  'study-morning-briefing',
  'study-spaced-rep-reminder',
  'study-github-commit-reminder',
  'study-weekly-review',
  'study-monday-distillation',
  'study-drift-audit',
  'study-branch-cleanup',
];
const ALLOWED_WRITERS = {
  'SOURCE_OF_TRUTH.md':      ['build-init', 'audit-remediation-2026-05-06', 'manual-edit', 'path-a-v3-migration'],
  'current_day.md':          ['build-init', '/day-wrap', '/pause-routines', '/resume-routines', 'user'],
  'active_weak_spots.md':    ['build-init', '/post-session', '/lock-weak-spot', 'user'],
  'drift_log.md':            ['build-init', 'stop-hook'],
  'last_session_summary.md': ['build-init', '/post-session', '/day-wrap', '/resume-routines'],
  'schedule.md':             ['build-init', 'study-morning-briefing', '/pause-routines'],
  'repos.md':                ['build-init', 'user'],
  // Path A v3 active vacation record. Manual edits allowed for end-date extension.
  'vacation.md':             ['build-init', '/pause-routines', 'user'],
  // Path A v3 audit log: any routine may append a "skipped" entry when its Step 0
  // preamble detects mode=paused. /resume-routines also writes (carry-forward archival).
  'missed_routines.md':      ['build-init', '/resume-routines', ...ALL_ROUTINES],
};

const ALLOWED_MODES = ['bootcamp', 'loop_week', 'paused'];

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
  // Require frontmatter as the first block: ^---\n ... \n---\n
  // The trailing \n after the closing --- prevents matching mid-body horizontal rules.
  const fmMatch = content.match(/^---\r?\n([\s\S]+?)\r?\n---\r?\n/);
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

  const ubMatch = fmRaw.match(/^updated_by:\s*(\S.*?)\s*$/m);
  if (ubMatch) {
    const writer = ubMatch[1];
    const allowed = ALLOWED_WRITERS[entry];
    if (allowed && !allowed.includes(writer)) {
      errors.push(`${entry}: 'updated_by: ${writer}' is not in allowed writers ${JSON.stringify(allowed)} (per SOURCE_OF_TRUTH.md registry)`);
    }
  }

  if (entry === 'current_day.md') {
    if (!/^bootcamp:/m.test(content)) {
      errors.push(`current_day.md: missing 'bootcamp:' section (per design §J #11 two-dimension schema)`);
    }
    if (!/^loop_week:/m.test(content)) {
      errors.push(`current_day.md: missing 'loop_week:' section (per design §J #11 two-dimension schema)`);
    }
    // Path A v3: optional `mode` field. Absent = treat as bootcamp (default per M1-1).
    // When present, must be one of ALLOWED_MODES.
    const modeMatch = fmRaw.match(/^mode:\s*(\S+)\s*$/m);
    if (modeMatch) {
      const mode = modeMatch[1].replace(/^["']|["']$/g, '');
      if (!ALLOWED_MODES.includes(mode)) {
        errors.push(`current_day.md: 'mode: ${mode}' not in allowed values ${JSON.stringify(ALLOWED_MODES)}`);
      }
    }
  }

  // Path A v3: vacation.md schema check (when present).
  if (entry === 'vacation.md') {
    const required = ['start_date', 'set_at', 'set_by'];
    for (const field of required) {
      if (!new RegExp(`^${field}:\\s+\\S`, 'm').test(fmRaw)) {
        errors.push(`vacation.md: missing required field '${field}'`);
      }
    }
    // start_date must be ISO-8601 with offset (RFC 3339), reject bare YYYY-MM-DD.
    const startMatch = fmRaw.match(/^start_date:\s*(.+)$/m);
    if (startMatch) {
      const v = startMatch[1].trim().replace(/^["']|["']$/g, '');
      // Accept null sentinel (open-ended); otherwise require T<time>+HH:MM or Z.
      if (v !== 'null' && !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2})$/.test(v)) {
        errors.push(`vacation.md: 'start_date: ${v}' must be RFC 3339 with explicit offset (e.g., 2026-05-07T23:55:00+05:30) per Path A v3 EC-02`);
      }
    }
    // end_date may be null (open-ended) or an RFC 3339 timestamp.
    const endMatch = fmRaw.match(/^end_date:\s*(.+)$/m);
    if (endMatch) {
      const v = endMatch[1].trim().replace(/^["']|["']$/g, '');
      if (v !== 'null' && !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2})$/.test(v)) {
        errors.push(`vacation.md: 'end_date: ${v}' must be RFC 3339 with explicit offset, or 'null' for open-ended`);
      }
    }
  }

  if (entry === 'active_weak_spots.md') {
    // Per audit finding #019: file is user-editable AND @-imported into every session.
    // Best-effort regex screening for prompt-injection-shaped content. Not a complete
    // defense — raises cost for casual injection attempts.
    const SUSPICIOUS_RE = /^(IMPORTANT:|System:|Ignore (all )?previous|New instruction:|<\|im_start\|>)/im;
    if (SUSPICIOUS_RE.test(content)) {
      errors.push(`active_weak_spots.md: contains suspicious instruction-shaped tokens (possible prompt injection)`);
    }
    // Header allowlist: every '## X' header must match ^[A-F]\d — .* pattern.
    const headers = [...content.matchAll(/^## (.+)$/gm)].map(m => m[1]);
    const validHeader = /^[A-F]\d — /;
    const badHeaders = headers.filter(h => !validHeader.test(h));
    if (badHeaders.length) {
      errors.push(`active_weak_spots.md: non-allowlisted headers ${JSON.stringify(badHeaders)} (expected pattern: '<family-letter><digit> — <description>')`);
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
