<!-- Per design §G Revision 3 seed wins. Historical capture from MEMORY.md "backpack = closure's captured variables" reference. -->
<!-- Uses the REVISED /lock-decision schema. user_precondition is best-effort historical. -->
---
date: 2026-03-22
concept: closure variable capture
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: "what does a closure carry" vs LEGB rules
test: |
  Counterfactual: if LEGB rules had been given as the answer instead, would have memorized
  the rule sequence (Local, Enclosing, Global, Built-in) but not internalized what's actually
  carried — works in textbook quizzes, breaks the first time the user has to reason about
  "why does this variable still exist after the function returned?"
artifact: "Backpack = closure's captured variables. The function brings its scope along."
---

When a closure leaves the function it was defined in, it doesn't leave its variables behind. It carries them in a backpack. Whatever the closure can SEE at the moment it's defined goes into the backpack — and travels with the closure wherever it goes. When you call the closure later, it unzips the backpack and uses what's inside.

This bridge worked because the gap was "where does the variable live after the function returns?" The LEGB rule names the *order* of lookup but doesn't answer the *physical* question. The backpack answers the physical question: the variable lives WITH the closure, not in a global store, not in a returned-function-namespace, but bundled together.

**Calibration target:** mechanism-matched (backpack explains the carrying mechanism), companion to the closures-barista win (recipe-card and backpack are the SAME mechanism viewed from two different gaps — recipe-card answers "what's the function carrying" via concrete object; backpack answers "where do the captured vars live" via spatial metaphor).
