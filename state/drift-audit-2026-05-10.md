---
last_updated: 2026-05-10T10:41:39+05:30
updated_by: study-drift-audit
date: 2026-05-10
window_start: 2026-05-04
window_end: 2026-05-10
total_entries: 0
data_source: state/drift_log.md
status: no-data
---

[STALE-WEEKLY-REVIEW] `state/weekly-review-2026-05-10.md` was last updated 38 minutes ago (2026-05-10T10:03:29+05:30), past the 30-minute freshness threshold. Weekly review data may not reflect the latest state — treat with mild caution, though it is the only available input for context.

# Drift audit — week ending 2026-05-10

No claude.ai/code drift entries in the 7-day window.

## What this means
- Drift logging is claude.ai/code-only (Cowork hooks dormant per #40495).
- An empty window indicates either: (a) no claude.ai/code sessions ran this week (all study was in Cowork), OR (b) the Stop hook didn't fire (check `state/.locks/session.lock` timestamps).
- It does NOT mean "no drift happened" — Cowork drift is invisible to this routine.

## Action
- If (a): expected; no audit possible.
- If (b): investigate Stop hook health on claude.ai/code surface.

[No top patterns. No tightening proposals. Wait for next week's data.]

## Caveats
- Drift logged only from claude.ai/code (Cowork sessions don't log drift per #40495). Distinct claude.ai/code sessions in window: 0 (per weekly review).
- **Vacation gap excluded from window:** System has been `mode: paused` since 2026-05-08T01:05:44+05:30 (reason: "short trip"; `end_date: null` as of audit time). Dates 2026-05-08 through 2026-05-10 fall inside the vacation window — absence of drift here reflects no study sessions, not teaching-method health. Pre-vacation dates 2026-05-04 through 2026-05-07 are also empty per the weekly review; these were potentially active days where no claude.ai/code sessions were logged.
- `study-drift-audit` is NOT in `suppress_routines` (retrospective routine — runs through vacations by default).

## Executive summary
0 drift entries in the 7-day window (2026-05-04 to 2026-05-10). No top patterns identified. No tightening proposals generated. Vacation in effect from 2026-05-08; pre-vacation days also show zero logged sessions. Re-run next Sunday after study resumes for meaningful signal.
