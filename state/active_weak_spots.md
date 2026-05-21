---
last_updated: 2026-05-21T21:05:00+05:30
updated_by: user
total_active: 4
---

<!-- Per design §F schema. Seeded from openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md (RTI Day 6 / 2026-04-08 snapshot). -->
<!-- Update protocol: /post-session writes after every session. /lock-weak-spot appends new ones. Drift-audit routine cross-references with drift_log.md. -->
<!-- 2026-05-12 manual sync: /post-session skill spec did not include this file in its 3-output list, so the post-wrap sync was done by user after /day-wrap. -->
<!-- 2026-05-21 manual sync: same skill-spec gap — /post-session (commit 511f5e0) updated room-to-improve/state/current_state.md but not this file; reconciled after-the-fact from that commit. -->

# Active Weak Spots — RTI Pattern-Family Tracker

Priority order: top is dominant.

## F3 — Operator/condition confusion

- **First seen:** 2026-04-08
- **Last seen:** 2026-05-21
- **Pattern:** Originally `len(s) >= 0` in reverse_string base case (2026-04-08). Resurfaced on Loop Week Day 1 (2026-05-12) as operator slips: B.2 Tracker, B.2 Filter, B.3 Drill #1 — 3+ slips in single session. Re-fired on Loop Week Day 4 (2026-05-21) inside comprehension drills: read `*` as `**` in A.3 (twice in one drill, snippets 2 and 8); tested `>` for "first negative" in B.1 P5. All self-corrected after diagnosis hint, but no clean operator-heavy reps earned.
- **Band:** 2 (escalated — 3+× same session 2026-05-12, re-fired 2026-05-21)
- **Reps to graduate:** 2 independent Band 2 reps on operator-heavy drills before downgrading from escalated to watch
- **Reps so far:** 0 since escalation
- **Drill targets (current — Day 4 context):**
  - Day 4 Block D.4 `range(len(...))` anti-pattern refactors — operator/boundary-heavy
  - Day 4 Block D.5 five comp traps cold (filter vs ternary, nesting order, gen exhaustion, dup keys, unhashables)
  - `is_prime(n)` / `factor_pairs(n)` with `range(int(n**0.5)+1)` — boundary discipline (`+1` placement, `<` vs `<=`)
  - Set membership + boolean operators (`in` / `not in`, `&` / `|`, `or` / `and`) — Day 2 Block B.2 Pattern 5 (carryover)

## A1 — Multi-step loop body (one-step transform not automatic)

- **First seen:** 2026-04-08
- **Last seen:** 2026-05-12
- **Pattern:** Originally surfaced in recursion (Day 15 Block 3, P2/P3/P4/P6/P7/P8 — 6× same session — "recursive shell visible, one-step transform not automatic"). Ported to loop context on Loop Week Day 1 (2026-05-12). No A1-targeted drills on Loop Week Day 2/3/4 (2026-05-19/20/21 were teaching sessions, not standalone RTI drill blocks). Review-mode reps on 2026-05-19 (`group_by_length`, `max_product_pair`) explicitly do not count toward graduation per user rule.
- **Band:** 2 (escalated — 6× same bug in same session on 2026-04-08)
- **Reps to graduate:** 3 independent at Band 2, then 1 at Band 3
- **Reps so far:** 1 since escalation (Loop Week Day 1 B.3 Drill #2 Search+Counter, cold first try — 2026-05-12)
- **Drill targets (current — Day 4 context):**
  - `pythagorean_triples(n)` — Day 4 Block E.1 / Block F.C (triple-nested comp, multi-step body)
  - `factor_pairs(n)` — Day 4 Block D.2 / Block E.1 (loop + pair collection)
  - Dict accumulator (count / group-by) — Day 2 Block B.2 carryover
  - Stacked dict + counter on Band 2 multi-step body — Day 2 Mini-Boss A carryover
- **Drill targets (deferred — recursion context, return after loop stabilizes):** sum-of-digits style recursion (one-step reduction named first), list/string recursion pair (current piece + recurse on rest), binary-search-style with no help for first 5 minutes

## F1 — Variable mix-up / naming (escalation candidate)

- **First seen:** 2026-05-21
- **Last seen:** 2026-05-21
- **Pattern:** Two variable-naming slips in one session (Loop Week Day 4 / 2026-05-21): C.2 Drill 3 — loop variables `a, b` shadowed the lists `a, b` (worked, flagged as style); C.4 Drill 3 — used plural list names `ages`/`scores` instead of singular loop variables `age`/`score`, real bug (every inner dict got the whole list). Per RTI "same pattern ≥2× = escalation," flagged — but the two slips differ in severity (one style-only, one real bug) and this was a teaching session, not a drill block.
- **Band:** watch — **escalation candidate**
- **Recommended action:** confirm F1 escalation at next session start (2026-05-22), or override and keep on watch.
- **If escalated:** drill targets would be variable-naming discipline (singular-vs-plural conventions, loop-var-vs-collection-name disambiguation).

## B2 — Bail to AI (improving)

- **First seen:** 2026-04-07
- **Last seen:** 2026-04-08
- **Pattern:** "Logic gets externalized too early on the hardest problems." Improved from Day 14 — help-seeking narrowed (more logic cues, fewer full-answer handoffs). No bail across 2026-05-12 (held under F3 friction), 2026-05-19 (review), 2026-05-20 (teach), 2026-05-21 (teach).
- **Band:** 2 watch (improving)
- **Reps to graduate:** 5 sessions with no bail
- **Reps so far:** 4 clean sessions. 1 more clean session → downgrade from watch.
