---
last_updated: 2026-05-06T22:00:00+05:30
updated_by: audit-remediation-2026-05-06
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
| Current bootcamp day/phase    | `state/current_day.md`                     | `/day-wrap`                               | SessionStart hook (claude.ai/code) + CLAUDE.md @-import (Cowork) |
| Active weak spots             | `state/active_weak_spots.md`               | `/post-session`, user                     | SessionStart hook + CLAUDE.md @-import                       |
| Drift events                  | `state/drift_log.md`                       | Stop hook (**claude.ai/code only** — dormant in Cowork per #40495) | SessionStart hook + CLAUDE.md @-import |
| Last session summary          | `state/last_session_summary.md`            | `/post-session`, `/day-wrap`              | SessionStart hook + CLAUDE.md @-import                       |
| Today's schedule              | `state/schedule.md`                        | `study-morning-briefing` routine          | SessionStart hook + CLAUDE.md @-import                       |
| RTI live state                | `room-to-improve/state/current_state.md`   | `/post-session`                           | `/rti-preflight`                                             |
| Tracked git repos             | `state/repos.md`                           | user (manual edits)                       | `study-github-commit-reminder` routine                       |
| Wins (gold-standard)          | `wins/<date>-<slug>.md`                    | `/lock-decision`                          | `/teach-from-win`, `/self-review`, manual review             |

## Allowed extra frontmatter fields

Beyond `last_updated` and `updated_by`, the following extra fields are permitted per file. Validator does not currently enforce this allowlist — it's documentation; future validator versions may.

| File                          | Extra fields allowed                                          |
|-------------------------------|---------------------------------------------------------------|
| `current_day.md`              | `bootcamp` (object), `loop_week` (object)                     |
| `active_weak_spots.md`        | `total_active` (int)                                          |
| `last_session_summary.md`     | `session_id` (string), `session_duration_min` (int)           |
| `room-to-improve/state/current_state.md` | `phase`, `rollout_day`, `latest_session`, `independence_score`, `active_targets`, `escalated_bugs`, `band_status` (object) |

Other state files have only the two required fields.

## Freshness rules

- Every state file must have `last_updated: <ISO timestamp>` and `updated_by: <writer name>` frontmatter.
- SessionStart hook prepends `⚠️ STALE` warning if `last_updated` is >24h ago.
- Files >72h old refuse to inject without explicit user override.

## Curriculum scope (separate registry, synced not authored)

- `instructions/curriculum/*.xml` is synced daily by `study-curriculum-sync` from the pipeline repo at `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\`.
- That pipeline repo is authoritative; this registry is read-only with respect to scope.
