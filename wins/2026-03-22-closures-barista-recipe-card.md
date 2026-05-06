<!-- Per design §G Revision 3 seed wins. Historical capture from MEMORY.md "barista with recipe card in pocket" reference. -->
<!-- Uses the REVISED /lock-decision schema (user_precondition + concept_gap + test + artifact). user_precondition is best-effort historical. -->
---
date: 2026-03-22
concept: closures
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: abstract environment-capture (LEGB, scope chain) vs concrete carry-something-along
test: |
  Counterfactual: if LEGB-rules-first / definition-first approach had been used instead, would have
  memorized but not internalized — works in toy cases (factorial wrapped in maker), breaks at first
  novel application (state machine, currying real workflow).
artifact: "Closures = barista with recipe card in pocket. The function carries its environment."
---

The barista isn't a generic coffee-maker function. The barista you hand a recipe card to KEEPS that recipe card in their pocket — and uses it every time you ask them to make a drink later. The recipe card is the captured variable. The barista is the closure. Whether you ask them today or tomorrow, the recipe is in their pocket.

This bridge worked because Sudhan was thinking "where does the variable LIVE after the function returns?" — the abstract scope-chain answer doesn't satisfy that question; the recipe-card answer makes the location concrete.

**Calibration target (not script):** mechanism-matched (recipe card explains the *carry-with* mechanism, not just the vibe), one analogy (no stacked metaphors), inline visualization-ready (the barista handing-the-card mental image is a single visual that doesn't fragment).
