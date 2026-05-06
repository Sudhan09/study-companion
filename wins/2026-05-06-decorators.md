---
date: 2026-05-06
concept: decorators
user_precondition: |
  No verbatim confusion sentence exists in this conversation — user invoked /teach decorators cold (no preceding failed attempt or stated mental-model gap). User's only post-explanation utterance before lock-in was "lock it in" — a commitment-to-drill signal, not a confusion-resolved signal. Treat this win as provisionally calibrated; the precondition field is the weakest part of the record and should be revised if the user later recalls their actual prior mental state.
concept_gap: User's likely mental model treats `@decorator` as a special syntactic feature attached to a function definition; the actual mechanism is name-rebinding (`f = decorator(f)`) where the original function is passed as an argument and replaced by a closure-wrapping return value. Gap = "syntactic ornament" vs "function-substitution at definition time."
test: |
  Counterfactual: if I had led with the abstract definition ("a decorator is a higher-order function that takes a callable and returns a callable"), the user would have memorized the sentence without internalizing the call-flow interception. They would pass a multiple-choice question on what a decorator is, but fail to predict the print order of `START → call → END → result` in the Band 1 drill — because the mental model wouldn't have a place for "wrapper runs before AND after the wrapped function." Memorize-not-internalize failure mode.
artifact: Bouncer-at-the-office-door analogy paired with an ASCII call-flow trace showing the wrapper intercepting calls on both sides of the original function, followed by the `f = decorator(f)` desugaring.
---

The explanation that landed opened with a domain-shift analogy — the bouncer at an office door — chosen specifically because decorators do *active* work on both sides of the wrapped call (logging, timing, auth) rather than passive transformation. Gift-wrapping was rejected as a mechanism mismatch (passive). The bouncer maps cleanly: original function = colleague doing real work; decorator = checkpoint at the door; wrapped function = new front door that routes through the checkpoint first; args/kwargs = visitor's request.

Layer 2 then collapsed the `@decorator` syntax to its desugared form (`f = decorator(f)`) and ran an ASCII trace showing `wrapper("Sudhan")` calling the original `fn("Sudhan")` from inside the closure, with print statements bracketing the call. The closure-captures-fn detail was named explicitly so the user wouldn't later wonder how the wrapper "remembers" which function to call. Layer 3 was the `@timer` real-world example — the cleanest motivating use case because it cannot be done cleanly without decorators (you'd have to mutate every function body).

User confirmation verbatim: **"lock it in"** — committing to the Band 1 drill (`@announce` printing `START`/`END` around `add(a, b)`). No mid-explanation confusion signal was raised; the lock-in came after the full three-layer delivery without a re-angle being needed.
