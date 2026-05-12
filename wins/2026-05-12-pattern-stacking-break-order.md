---
date: 2026-05-12
concept: pattern stacking with break-pattern + non-break-pattern — the body-order rule (Loop Week Day 1 Block B.3)
user_precondition: |
  Entry-state (request for teach):
  "first explain me b3"

  No prior failed attempt at B.3 existed — the user asked for /teach before drilling, signaling that pattern stacking ("two patterns in one loop") wasn't a known concept yet. Up to this point the user had drilled four B.2 single-state patterns (Tracker, Search, Filter, Accumulator) and his A1 weak spot (escalated band-2) had been on watch for "knows parts, freezes on assembly."

  Post-drill confirmation (the win signal):
  "sentinel stays None
  count is 3
  cuz none triggers break to satisfy if statement"

  This came after a clean cold-write of the B.3 Search+Counter stack on a fresh input list, with the break-check-first order rule correctly applied on first attempt.
concept_gap: Single-state-loop model (one tracker, body order is order-insensitive) vs parallel-state-loop model (two trackers where `break` in one pattern ends the loop for both — so the position of the break check inside the body determines whether the trigger item is counted by the other pattern). The user's B.2 patterns were all single-state; B.3 introduces an interaction the prior model had no slot for.
test: |
  Counterfactual: if I had skipped the Layer 2 order rule and just given the drill cold, the user would likely have written Version A ("count += 1" before the "if n < 0: break" check) and gotten count=5 for the drill input instead of the expected 4. This is the classic silent-bug failure mode: no crash, no error, output looks plausible, would have required tracing the exact data to surface. Memorize-not-internalize failure — the user would have copied a Counter+Search template by analogy from B.2 without realizing the patterns now interact through break. A1 weak spot would have surfaced as expected ("freezes on assembly" → here, "produces wrong assembly silently"). Layer 2 was the assembly-specific insight that needed to land before the cold attempt.
artifact: Two-clipboards-on-one-desk analogy paired with the body-order rule traced through Version A (count first) vs Version B (check first) on `[4, 8, -1]`, showing how break-skipping changes whether the trigger item is counted. One-liner: "Break check first, non-break update after — so break cleanly excludes the trigger item from the other pattern's state."
---

The explanation that landed opened with the "two clipboards on the same desk" analogy (basketball scoreboard offered as backup framing) — chosen because it captures the parallel-state structure without implying any interaction between the two state variables in the no-break case. Layer 1's mental model deliberately did NOT mention break — that wrinkle was held for Layer 2, because surfacing it too early would have confused the parallel-tracks framing. The Layer 1 visualization showed an item walking past two independent decision tracks, each updating its own clipboard according to its own rule.

Layer 2 introduced the asymmetry: `break` in one pattern ends the loop for both, which means the order of update lines inside the body determines whether the trigger item gets included in the other pattern's count. The teaching move was a side-by-side trace of Version A (counter first, then check) and Version B (check first, then counter) on the input `[4, 8, -1]`, showing that Version A gives `count=3` (counts the trigger) while Version B gives `count=2` (excludes the trigger — which is what "count BEFORE the first negative" actually means). The generalization was named explicitly: any time you stack a break-pattern with a non-break-pattern, break check goes first.

User confirmation came in two forms. First, a clean cold-write of the B.3 Search+Counter stack on the actual drill input `[3, 7, 2, 5, -4, 8, -1, 6]` with the order rule correctly applied on first attempt (output: `first_neg=-4, count=4`). Second, an unprompted-with-mechanism prediction on the no-negative edge case `[1, 2, 3]`:

> *"sentinel stays None / count is 3 / cuz none triggers break to satisfy if statement"*

The mechanism explanation is the strongest part of the artifact — the user didn't just predict the values, he named WHY (no break trigger → loop runs full → count hits all 3). That's the model held forward into the next case, which is the actual proof the assembly principle transferred rather than being template-matched. This is the first cleanly-executed pattern-stacking drill in the recorded RTI history; A1 (escalated band-2) gets one independent rep here, pending replication on Filter+Tracker or another non-break stack to confirm the model generalizes.
