<!-- Per design §G Revision 3 seed wins. Historical capture from MEMORY.md "nonlocal = the OLD house" reference. -->
<!-- Uses the REVISED /lock-decision schema. user_precondition is best-effort historical. -->
---
date: 2026-03-22
concept: nonlocal keyword
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: which scope nonlocal targets (between local and global)
test: |
  Counterfactual: if "nonlocal targets the enclosing scope" had been the definition given,
  would have memorized the rule but conflated it with `global` the first time both are needed —
  works when only one nesting level exists, breaks in deeper nesting where "enclosing"
  becomes ambiguous without the spatial anchor.
artifact: "nonlocal = 'I mean the OLD house' (the enclosing scope, not global, not local)."
---

When you write `nonlocal x` inside a nested function, you're saying "I don't mean the new house I'm currently in (local), and I don't mean the giant outer house (global). I mean the OLD house — the one I just left to come into this room." The OLD house is the enclosing scope: the function that defined this one.

`global` is the giant outer house. `nonlocal` is the OLD house — specifically, the function that wraps me. They are different addresses.

This bridge worked because the gap was three-way disambiguation between local, enclosing, and global. The OLD house gives nonlocal a unique, memorable address that's not local and not global — solving the "wait which one is nonlocal again?" hesitation that abstract definitions don't fix.

**Calibration target:** mechanism-matched (OLD house gives a unique spatial identity that disambiguates from local and global), one analogy, builds on the LEGB room-search win (same spatial vocabulary — rooms / houses), inline-friendly visualization-ready.
