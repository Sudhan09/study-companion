---
last_updated: 2026-05-17T10:36:43+05:30
updated_by: study-drift-audit
date: 2026-05-17
window_start: 2026-05-11
window_end: 2026-05-17
total_entries: 0
data_source: state/drift_log.md
status: no-data
---

# Drift audit — week ending 2026-05-17

No claude.ai/code drift entries in the 7-day window.

## What this means

- Drift logging is claude.ai/code-only (Cowork hooks dormant per #40495).
- An empty window indicates either: (a) no claude.ai/code sessions ran this week (all study was in Cowork), OR (b) the Stop hook didn't fire (check state/.locks/session.lock timestamps).
- It does NOT mean "no drift happened" — Cowork drift is invisible to this routine.

## Context for this window

The 7-day window covers 2026-05-11 → 2026-05-17. Known session history in that range per `state/current_day.md` and `state/schedule.md`:
- 2026-05-11: No study session (routines-only day).
- 2026-05-12: One real study session (Loop Week Day 1 — Lists & Tuples). Surface unknown — if this ran in Cowork, Stop hook was dormant and drift is invisible.
- 2026-05-13 through 2026-05-16: No study sessions (routines-only days).
- 2026-05-17: Today; session not yet complete.

Most likely explanation: the 2026-05-12 session ran on the Cowork surface. Stop hook doesn't fire there (per #40495), so no entries were written regardless of any drift that occurred.

## Action

- If (a): expected; no audit possible this week. Drift from the 2026-05-12 Cowork session is permanently invisible to this routine.
- If (b): investigate Stop hook health on claude.ai/code surface — check `state/.locks/session.lock` timestamps.

[No top patterns. No tightening proposals. Wait for next week's data.]
