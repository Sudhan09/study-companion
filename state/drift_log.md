---
last_updated: 2026-05-06T20:00:00+05:30
updated_by: build-init
---

<!-- Per design §F schema. APPEND ONLY. -->
<!-- Written by Stop hook (claude.ai/code only per #40495). Read by SessionStart hook + CLAUDE.md @-import + drift-audit routine. -->
<!-- Schema: {ISO timestamp} | session={id} | failure=#{N} | severity={hard|soft} | detail="..." -->
<!-- Severity: hard = regex match on banned phrase / explicit rule violation. soft = heuristic match (may have false positives). -->
<!-- Monday distillation moves entries >30 days old to archive/. -->

# Drift log — APPEND ONLY

No entries yet. First entry will be written by the Stop hook on the first claude.ai/code session that triggers a detection.
