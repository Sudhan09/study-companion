<!-- Per design §G Revision 3 seed wins. Historical capture from MEMORY.md "LEGB = searching rooms" reference. -->
<!-- Uses the REVISED /lock-decision schema. user_precondition is best-effort historical. -->
---
date: 2026-03-22
concept: LEGB scope rule
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: name resolution as algorithm vs LEGB as room search
test: |
  Counterfactual: if the LEGB acronym + abstract "name resolution order" had been the explanation,
  would have memorized the four-letter sequence but not internalized why the order matters —
  works on multiple-choice questions, breaks when the user has to predict which `x` Python
  will resolve in a real nested-function bug.
artifact: "LEGB = searching rooms innermost to outermost: Local → Enclosing → Global → Built-in."
---

Imagine a house with four rooms nested inside each other. When Python looks for a variable, it walks through the rooms starting from the innermost: Local first (the room you're in), then Enclosing (the next room out), then Global (the house's main room), then Built-in (the room behind the front door — Python's standard library names). It STOPS at the first room where it finds the name.

This bridge worked because the gap was algorithmic-rule vs spatial-search. The acronym LEGB names four scopes but doesn't explain the *direction* (innermost-out, not outermost-in) or the *stopping rule* (first match wins). The room search makes both physical: you check the room you're standing in first, you stop when you find the thing.

**Calibration target:** mechanism-matched (room-search explains *why* the order is innermost-out — physical proximity), one analogy, supports inline visualization (an actual diagram of nested rooms with arrows). Bridges the same kind of gap as the backpack win (concrete spatial answer to a "where does it live" question).
