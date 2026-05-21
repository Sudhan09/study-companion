<!-- Per design §G port plan: verbatim port of openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md -->
<!-- Per design §F schema: wrapped in proper YAML frontmatter (---) and last_updated bumped per /post-session. -->
---
last_updated: 2026-05-21T21:05:00+05:30
updated_by: /post-session
phase: 1
rollout_day: 7
latest_session: sessions/2026-05-21.md
independence_score: 3
active_targets: [F3, A1, B2]
escalated_bugs: ["F3 — operator/condition confusion; escalated 2026-05-12, re-fired 2026-05-21 (×2-3, comprehension context); 0 clean operator-heavy reps since escalation", "A1 — 6× same bug Day 15 Block 3 (2026-04-08); 1 clean rep since on Loop Week Day 1 B.3 Drill #2 (2026-05-12); no A1-targeted drills 2026-05-21"]
band_status:
  A1: escalated-band-2 (1/3 reps; no A1-targeted drills 2026-05-21)
  B2: band-2-watch (4/5 clean sessions; no bail 2026-05-21)
  F3: escalated-band-2 (re-fired 2026-05-21 ×2-3; 0/2 clean reps)
  F1: watch (escalation candidate — 2 variable-naming slips 2026-05-21; confirm at next session)
---

# RTI Training State

<!-- Source of truth for #room-to-improve session state. -->
<!-- Updated by /post-session after each post-session analysis. -->
<!-- Read by /rti-preflight at the start of every #room-to-improve session. -->

## Active targets (priority order)

- **F3** — operator / condition confusion. Live concern: re-fired 2026-05-21 (`*` vs `**`, `>` vs `<`). Escalated since 2026-05-12, still 0 clean operator-heavy reps.
- **A1** — multi-step loop body / one-step transform inside loop body not automatic (carryover from Day 15 recursion; ported to loop context Loop Week Day 1). No fresh evidence 2026-05-21.
- **B2** — bail-to-AI under hardest problems (improving — no bail 2026-05-21, 4th clean session).

## Graduated targets

none

## Escalated bugs

- **F3** — operator/condition confusion. Escalated 2026-05-12 (3+ same-session slips). Re-fired 2026-05-21: read `*` as `**` (A.3, twice in one drill) and tested `>` for "first negative" (B.1 P5). All self-corrected after a diagnosis hint, but no clean operator-heavy reps earned. Status: still escalated; need 2 independent Band 2 reps on operator-heavy drills before downgrading. Block D.4/D.5 (anti-patterns + traps) is the target.
- **A1** — 6× same bug Day 15 Block 3 recursion (2026-04-08). Status: 1 clean independent rep on Loop Week Day 1 B.3 Drill #2 (2026-05-12); need 2 more independent reps at Band 2, then 1 at Band 3 to graduate. No A1-targeted drills 2026-05-21.

## Band status

- **A1:** escalated-band-2 (1/3 reps toward graduation; no A1-targeted drills 2026-05-21)
- **A2:** watch (no fresh evidence today)
- **A3:** not-started
- **A4:** not-started
- **B2:** band-2-watch (improving — 4 of 5 clean sessions toward downgrade; no bail 2026-05-21)
- **C1:** watch (no fresh evidence today)
- **D3:** no-new-data
- **E1:** no-new-data
- **F1:** watch — **escalation candidate.** 2 variable-naming slips 2026-05-21 (loop-var shadowing lists in C.2; plural/singular `ages`/`age` mix-up in C.4). Per "same pattern ≥2× = escalation," flagged — but slips differ in severity and this was a teaching session. Confirm or override at next session start.
- **F3:** escalated-band-2 (re-fired 2026-05-21 ×2-3; 0/2 clean reps)

## Re-test queue

- Set membership + boolean operator drills — F3 post-escalation Band 2 target
- Block D.4 `range(len(...))` anti-pattern refactors + D.5 traps — F3 operator/boundary discipline
- `is_prime(n)` / `factor_pairs(n)` with √n bound — Day 4 Block D.2
- Dict accumulator (count / group-by) — A1 replication rep #2
- One sum-of-digits style recursion (carryover from 2026-04-08 queue) — A1 in recursion context, deferred until loop block stabilizes

## Checkpoint pending

false

## Notes

Loop Week Day 4 half-day (2026-05-21) — comprehensions + zip/enumerate, Blocks A-C. Teaching session with drills throughout; independence 3, no `[AI]`-completed drills, no bail (B2 clean — 4th session).

F3 is the standing concern: it surfaced again on operator/condition checks (`*`/`**`, `>`/`<`) inside comprehension drills. It keeps appearing on *tests*, not structure — Block D.4/D.5 (operator-heavy anti-patterns and traps) is the right place to finally earn clean F3 reps. F1 (variable naming) fired twice and is flagged as an escalation candidate pending user confirm.

Comprehension-specific soft-spot observed: twice a comp shipped missing a spec-required clause (the `**2`, the evens filter). Not a tracked family — watch as fluency builds; re-read-the-spec habit recommended.
