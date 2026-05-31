---
last_updated: 2026-05-31T10:36:00+05:30
updated_by: study-drift-audit
date: 2026-05-31
window_start: 2026-05-25
window_end: 2026-05-31
total_entries: 0
data_source: state/drift_log.md
status: no-data
---

[STALE-WEEKLY-REVIEW] Weekly review file (`state/weekly-review-2026-05-31.md`) is 30.7 minutes old — just past the 30-minute freshness threshold. Content is likely accurate but was computed before the drift-audit window closed. Treat weekly-review data as approximate for this audit.

# Drift audit — week ending 2026-05-31

No claude.ai/code drift entries in the 7-day window (2026-05-25 – 2026-05-31).

## What this means

- Drift logging is claude.ai/code-only (Cowork hooks dormant per #40495).
- An empty window indicates either: (a) no claude.ai/code sessions ran this week (all study was in Cowork or no study at all), OR (b) the Stop hook didn't fire (check `state/.locks/session.lock` timestamps).
- It does NOT mean "no drift happened" — Cowork drift is invisible to this routine.
- Cross-check with weekly review: 0 sessions logged this week (2026-05-25 – 2026-05-31). Eight consecutive no-session days confirmed. All routine activity (morning-briefing, spaced-rep, curriculum-sync) without any Stop-hook entries. This is consistent with case (a) — no claude.ai/code study sessions ran this week.

## Action

- If (a): expected; no audit possible. The 8-day study gap (2026-05-23 through 2026-05-30) means no Stop-hook sessions fired to append drift entries.
- If (b): investigate Stop hook health on claude.ai/code surface.

[No top patterns. No tightening proposals. Wait for next week's data.]

## Executive summary

0 drift entries in the 7-day window. No claude.ai/code study sessions occurred (2026-05-25 – 2026-05-31 all no-session per weekly review). No patterns detectable; no tightening proposals generated. Weekly review freshness flag: STALE (30.7 min).
