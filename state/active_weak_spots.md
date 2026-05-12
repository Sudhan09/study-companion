---
last_updated: 2026-05-12T16:30:00+05:30
updated_by: user
total_active: 3
---

<!-- Per design §F schema. Seeded from openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md (RTI Day 6 / 2026-04-08 snapshot). -->
<!-- Update protocol: /post-session writes after every session. /lock-weak-spot appends new ones. Drift-audit routine cross-references with drift_log.md. -->
<!-- 2026-05-12 manual sync: /post-session skill spec did not include this file in its 3-output list, so the post-wrap sync was done by user after /day-wrap. -->

# Active Weak Spots — RTI Pattern-Family Tracker

Priority order: top is dominant.

## A1 — Multi-step loop body (one-step transform not automatic)

- **First seen:** 2026-04-08
- **Last seen:** 2026-05-12
- **Pattern:** Originally surfaced in recursion (Day 15 Block 3, P2/P3/P4/P6/P7/P8 — 6× same session — "recursive shell visible, one-step transform not automatic"). Ported to loop context on Loop Week Day 1 (2026-05-12) as multi-step loop-body assembly. Block B.3 stacking drills exercised the same family.
- **Band:** 2 (escalated — 6× same bug in same session on 2026-04-08)
- **Reps to graduate:** 3 independent at Band 2, then 1 at Band 3
- **Reps so far:** 1 since escalation (Loop Week Day 1 B.3 Drill #2 Search+Counter, cold first try — 2026-05-12)
- **Drill targets (current — loop context):**
  - Dict accumulator pattern (count / group-by) — Loop Week Day 2 Block B.2 Pattern 1 + Block D.1 `word_frequency` / `group_by_length`
  - Stacked dict + counter on Band 2 multi-step body — Day 2 Mini-Boss A `count_pairs_summing_to`
  - Upper-triangular pair iteration — Day 2 Block C.6 anagram pairs / closest pair
- **Drill targets (deferred — recursion context, return after loop stabilizes):** sum-of-digits style recursion (one-step reduction named first), list/string recursion pair (current piece + recurse on rest), binary-search-style with no help for first 5 minutes

## F3 — Operator/condition confusion

- **First seen:** 2026-04-08
- **Last seen:** 2026-05-12
- **Pattern:** Originally `len(s) >= 0` in reverse_string base case (always-true condition, 2026-04-08). Resurfaced on Loop Week Day 1 (2026-05-12) as operator slips in loop context: B.2 Tracker lock attempt, B.2 Filter ("positive" vs "non-negative"), B.3 Drill #1 multiple bug rounds. 3+ slips in single session.
- **Band:** 2 (escalated — 3+× same session 2026-05-12; per RTI protocol "same bug twice = STOP")
- **Reps to graduate:** 2 independent Band 2 reps on operator-heavy drills before downgrading from escalated to watch
- **Reps so far:** 0 since escalation
- **Drill targets (current — loop context):**
  - Set membership + boolean operators (`in` / `not in`, `&` / `|`, `or` / `and`) — Day 2 Block B.2 Pattern 5
  - Two-sum complement check — Day 2 Block B.3 (`complement in seen` before adding)
  - Upper-triangular boundary — Day 2 Block C.6 (`j > i` not `j != i`)
- **User-flagged caveat:** in 2026-05-12 wrap summary user framed F3 as "still on watch" rather than escalated. Logged here as escalated per protocol; user override expected at next session start if intentional downgrade.

## B2 — Bail to AI (improving)

- **First seen:** 2026-04-07
- **Last seen:** 2026-04-08
- **Pattern:** "Logic gets externalized too early on the hardest problems. Improved from Day 14 — help-seeking got narrower (more logic cues, fewer full-answer handoffs) but still surfaced on final hard problem." No bail on 2026-05-12 session — protocol held under F3 friction.
- **Band:** 2 watch (improving)
- **Reps to graduate:** 5 sessions with no bail
- **Reps so far:** 3 clean sessions (added 2026-05-12; if 2 more clean, downgrade from watch)
