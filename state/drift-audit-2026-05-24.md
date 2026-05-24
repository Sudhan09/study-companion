---
last_updated: 2026-05-24T10:34:11+05:30
updated_by: study-drift-audit
date: 2026-05-24
window_start: 2026-05-17
window_end: 2026-05-24
total_entries: 0
data_source: state/drift_log.md
status: no-data
---

# Drift audit — week ending 2026-05-24

No claude.ai/code drift entries in the 7-day window.

## What this means

- Drift logging is claude.ai/code-only (Cowork hooks dormant per [#40495](https://github.com/anthropics/claude-code/issues/40495)).
- An empty window indicates either: (a) no claude.ai/code sessions ran this week (all study was in Cowork), OR (b) the Stop hook didn't fire (check `state/.locks/session.lock` timestamps).
- It does NOT mean "no drift happened" — Cowork drift is invisible to this routine.

## Action

- If (a): expected; no audit possible.
- If (b): investigate Stop hook health on claude.ai/code surface.

[No top patterns. No tightening proposals. Wait for next week's data.]
