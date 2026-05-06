---
last_updated: 2026-05-06T20:00:00+05:30
updated_by: build-init
total_active: 3
---

<!-- Per design §F schema. Seeded from openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md (RTI Day 6 / 2026-04-08 snapshot). -->
<!-- Update protocol: /post-session writes after every session. /lock-weak-spot appends new ones. Drift-audit routine cross-references with drift_log.md. -->

# Active Weak Spots — RTI Pattern-Family Tracker

Priority order: top is dominant.

## A1 — Multi-step loop body (one-step transform not automatic)

- **First seen:** 2026-04-08
- **Last seen:** 2026-04-08
- **Pattern:** "Recursive shell visible, one-step transform not automatic. Repeated across P2, P3, P4, P6, P7, P8 in Day 15 Block 3 recursion."
- **Band:** 2 (escalated — 6× same bug in same session)
- **Reps to graduate:** 3 independent at Band 2, then 1 at Band 3
- **Reps so far:** 0 since escalation
- **Drill targets:** sum-of-digits style recursion (one-step reduction must be named first), list/string recursion pair (current piece + recurse on rest), binary-search-style with no help for first 5 minutes

## B2 — Bail to AI (improving)

- **First seen:** 2026-04-07
- **Last seen:** 2026-04-08
- **Pattern:** "Logic gets externalized too early on the hardest problems. Improved from Day 14 — help-seeking got narrower (more logic cues, fewer full-answer handoffs) but still surfaced on final hard problem."
- **Band:** 2 watch (improving)
- **Reps to graduate:** 5 sessions with no bail
- **Reps so far:** 2 clean sessions

## F3 — Operator confusion (one-off)

- **First seen:** 2026-04-08
- **Last seen:** 2026-04-08
- **Pattern:** "Base-case condition slips / always-true conditions. Specifically: `len(s) >= 0` in reverse_string."
- **Band:** 2 watch (one-off)
- **Reps to graduate:** 3 sessions clean
- **Drill targets:** any base-case-heavy recursion drill
