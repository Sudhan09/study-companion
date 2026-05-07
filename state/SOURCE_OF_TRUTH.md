---
last_updated: 2026-05-07T20:00:00+05:30
updated_by: path-a-v3-migration
---

<!-- Per design §A registry table. Audited at SessionStart — hook verifies all listed files exist; if a non-registered state file appears, it's flagged. -->

# Source of Truth Registry

Each fact has exactly ONE writer file. SessionStart hook (claude.ai/code) reads this registry and verifies all listed files exist. CLAUDE.md @-imports (Cowork) provides the same primary load — without the freshness check.

## Surface annotation

- **claude.ai/code = SessionStart hook writer/reader** (active hooks: SessionStart, UserPromptSubmit, Stop, PreCompact). PostCompact handler removed 2026-05-06; SessionStart-on-resume covers post-compaction restoration.
- **Cowork = CLAUDE.md @-import reader** (hooks dormant per [#40495](https://github.com/anthropics/claude-code/issues/40495))
- `state/drift_log.md` is **append-only** and only written by the **Stop hook on claude.ai/code**. Cowork sessions do not append to drift_log; they only read it via @-import.

## Registry

| Fact                          | File                                       | Writer                                    | Reader                                                       |
|-------------------------------|--------------------------------------------|-------------------------------------------|--------------------------------------------------------------|
| Current bootcamp day/phase + pause mode | `state/current_day.md`           | `/day-wrap`, `/pause-routines`, `/resume-routines`, user | SessionStart hook (claude.ai/code) + CLAUDE.md @-import (Cowork) + all 8 routines (Step 0 preamble) |
| Active weak spots             | `state/active_weak_spots.md`               | `/post-session`, user                     | SessionStart hook + CLAUDE.md @-import                       |
| Drift events                  | `state/drift_log.md`                       | Stop hook (**claude.ai/code only** — dormant in Cowork per #40495; pause-skips when `mode: paused`) | SessionStart hook + CLAUDE.md @-import |
| Last session summary          | `state/last_session_summary.md`            | `/post-session`, `/day-wrap`, `/resume-routines` | SessionStart hook + CLAUDE.md @-import                |
| Today's schedule              | `state/schedule.md`                        | `study-morning-briefing` routine, `/pause-routines` (paused-banner) | SessionStart hook + CLAUDE.md @-import         |
| RTI live state                | `room-to-improve/state/current_state.md`   | `/post-session`                           | `/rti-preflight`                                             |
| Tracked git repos             | `state/repos.md`                           | user (manual edits)                       | `study-github-commit-reminder` routine                       |
| Wins (gold-standard)          | `wins/<date>-<slug>.md`                    | `/lock-decision`                          | `/teach-from-win`, `/self-review`, manual review             |
| Active vacation record        | `state/vacation.md`                        | `/pause-routines`, user (manual edits)    | All 8 routines (Step 0 preamble), `build-daily-wrap.sh`, `validate-vacation-consistency.js` |
| Missed-routine audit log      | `state/missed_routines.md`                 | All 8 routines (Step 0 preamble append on skip) | `build-daily-wrap.sh`, `/resume-routines`              |
| Vacation history (append-log) | `archive/vacations.md`                     | `/resume-routines` (append on resume)     | manual review                                                |
| Pre-resume session-summary    | `archive/sessions/<date>-pre-resume.md`    | `/resume-routines` (one-time on resume)   | manual review                                                |

## Allowed extra frontmatter fields

Beyond `last_updated` and `updated_by`, the following extra fields are permitted per file. The `validate-state-schemas.js` validator enforces the writer-allowlist column above; this table documents the data fields each writer may include.

| File                          | Extra fields allowed                                          |
|-------------------------------|---------------------------------------------------------------|
| `current_day.md`              | `bootcamp` (object), `loop_week` (object), `mode` (enum: `bootcamp` \| `loop_week` \| `paused`) |
| `active_weak_spots.md`        | `total_active` (int)                                          |
| `last_session_summary.md`     | `session_id` (string), `session_duration_min` (int), `vacation_gap_days` (int — set by `/resume-routines`) |
| `room-to-improve/state/current_state.md` | `phase`, `rollout_day`, `latest_session`, `independence_score`, `active_targets`, `escalated_bugs`, `band_status` (object) |
| `vacation.md`                 | `start_date` (ISO-8601 with offset), `end_date` (ISO-8601 with offset \| null), `suppress_routines` (list), `reason` (string), `set_at` (ISO-8601), `set_by` (string) |
| `missed_routines.md`          | `max_carry_forward_days: 7` (int — fixed)                     |

Other state files have only the two required fields.

## Freshness rules

- Every state file must have `last_updated: <ISO timestamp>` and `updated_by: <writer name>` frontmatter.
- SessionStart hook prepends `⚠️ STALE` warning if `last_updated` is >24h ago.
- Files >72h old refuse to inject without explicit user override.

## Curriculum scope (separate registry, synced not authored)

- `instructions/curriculum/*.xml` is synced daily by `study-curriculum-sync` from the pipeline repo (`Sudhan09/python_bootcamp_claude_code`, `config/` directory).
- That pipeline repo is authoritative; this registry is read-only with respect to scope.

## Pause/resume contract (Path A v3)

- **`bootcamp.current_day` is user-maintained.** Routines and skills do NOT auto-compute it from `progress_state.xml.completed_through_day`. Per Q10 decision: pipeline tracks intended curriculum, not actual study progress. `/resume-routines` displays the current value and prompts user to confirm or change.
- **Pause flow:** `/pause-routines` writes `state/vacation.md` + sets `current_day.md.mode: paused` + writes `state/schedule.md` paused banner. Skill self-commits and self-pushes (Cowork hooks dormant per #40495).
- **Resume flow:** `/resume-routines` archives current `last_session_summary.md` to `archive/sessions/<pre-resume-date>-pre-resume.md`, prompts user for resume day, rewrites `current_day.md.mode: <prior-mode>`, appends to `archive/vacations.md`, removes `state/vacation.md`.
- **Step 0 preamble:** every routine reads `state/current_day.md` first. If `mode: paused`, the routine appends one entry to `state/missed_routines.md` and exits cleanly. No back-dated replay (per Q1 decision).
- **Hooks pause-aware (V1 scope, per Q5):** `stop.js` skips drift-log append when paused; `/day-wrap` skill refuses to advance day when paused; `user-prompt-submit.js` confirms before routing `:wrap` token when paused.
