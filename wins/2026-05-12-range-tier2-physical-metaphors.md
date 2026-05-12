---
date: 2026-05-12
concept: Tier 2 range idioms — `range(len(lst) - 1)` and `range(len(lst) // 2)` (Loop Week Day 1 Block C.2). META-NOTE — this lock captures a TEACHING METHOD move (domain-shift to physical mechanism when math-first framing didn't land), not just a single concept artifact.
user_precondition: |
  Two verbatim confusion signals, escalating.

  First confusion (after the math-first table was delivered):
  "im sorry what these 2:
  range(len(lst) - 1) stop one before last 0 .. len-2 (so i+1 is still valid) range(len(lst) // 2) first half only 0 .. (len/2)-1 (swap-style algos)
  provides?"

  This is a "what's it FOR" signal, not a "what's the math" signal. The user could read the formulas but not see the use case.

  Second confusion (after I responded with code examples that still framed the use cases in algorithm-speak — "check if list is sorted," "reverse a list in place"):
  "explain in other way cuz i cant understand"

  This was an explicit re-angle request — the second framing also didn't land. Three rounds in, math-first and code-example framings had both stalled.

  The win signal:
  "lock this teaching method"

  User chose the deterministic 'lock' trigger after the physical-metaphor framing landed — explicitly directing capture of the method-level move, not just the artifact.
concept_gap: Formulas presented as syntactic templates ("Tier 2 = Tier 1 with len() math") vs formulas understood as solutions to specific iteration constraints (you need fewer than n indices, BECAUSE of how you're using them). Gap = "what does this expression compute" vs "what physical situation does this expression exist to handle."
test: |
  Counterfactual: if I had repeated the math-first framing slower, or expanded the code examples with more algorithm vocabulary ("two-pointer," "in-place reversal"), the user would have either (a) memorized the two idioms as syntactic templates — recognizable in someone else's code but not constructible when facing a fresh "I need to compare neighbors" problem — or (b) disengaged from C.2 entirely. Both are the memorize-not-internalize failure mode. The re-angle had to strip ALL algorithmic vocabulary and ALL code; the metaphors had to be concrete physical actions (toppling, high-fiving) whose CONSTRAINTS mirror the mathematical constraint of the range form.
artifact: Two physical-action metaphors paired one-to-one with the two range forms — dominoes (push each into the next; last domino has no target, so 4 pushes for 5 dominoes) for `range(len(lst) - 1)`, and high-five line (pair from opposite ends; each step touches both, so 5 high-fives for 10 people) for `range(len(lst) // 2)`. One-liner: "Need a neighbor? Stop 1 early. Pairing from opposite ends? Walk halfway."
---

The explanation that landed deliberately stripped all code and all algorithm vocabulary, and led with two concrete physical scenarios — one for each range form. The dominoes scene was chosen for `range(len(lst) - 1)` because the physical impossibility of toppling the last domino into something that doesn't exist directly mirrors the IndexError you'd get from `lst[i+1]` when `i = len(lst) - 1`. The high-five line was chosen for `range(len(lst) // 2)` because each high-five physically involves two people from opposite ends — so the count of high-fives = total people ÷ 2, in a way the user could literally picture without doing modular arithmetic in their head. Both metaphors are CONCRETE PHYSICAL ACTIONS, not passive analogies — the constraints come from the actions themselves, not from the analogy framing.

The teaching-method insight worth keeping: when math-first framing stalls, the re-angle move is to find a domain where the same constraint exists as a physical impossibility or physical pairing rule, NOT to repeat the same math more carefully or expand the code examples. Code examples for use cases ("check if sorted," "reverse in place") tend to require algorithm vocabulary the student doesn't yet have — they add a layer of unfamiliarity on top of the original confusion. Physical metaphors bypass that entire vocabulary stack. The first time I tried code-example framing in this session, the student bounced off it; the physical metaphors landed on first try with no further unpacking needed.

User confirmation came as the explicit deterministic-trigger phrase **"lock this teaching method"** — the user invoked /lock-decision specifically to capture the method, not just the concept. This is also calibration evidence for a feedback-memory pattern I saved earlier this session: the user wants asks stated plainly and metaphors that don't require additional vocabulary to decode. Future application: when a Tier 1/Tier 2 idiom or any other "math expression encoding a constraint" stalls, the move is domain-shift to physical mechanism FIRST, not slower-and-louder math.
