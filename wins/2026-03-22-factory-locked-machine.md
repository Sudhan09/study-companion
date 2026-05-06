<!-- Per design §G Revision 3 seed wins. Historical capture from MEMORY.md "factory = locked machine" reference. -->
<!-- Uses the REVISED /lock-decision schema. user_precondition is best-effort historical. -->
---
date: 2026-03-22
concept: factory functions
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: factory-as-pattern (abstract) vs factory-as-thing-with-locked-settings (concrete)
test: |
  Counterfactual: if the abstract "factory pattern" definition had been used instead, would have
  memorized but not internalized — recognizable in textbook examples but not generated when
  the user actually needs to produce N differently-configured workers.
artifact: "Factory = machine with locked settings. Each call produces a configured worker."
---

A factory function isn't a function-that-returns-a-function (which is the abstract textbook definition). It's a machine: you set the dials once, lock them in, and then every product the machine spits out has those dials baked in. `make_multiplier(3)` is the machine with the dial locked at 3. Every multiplier it produces will multiply by 3 — the locked dial.

This bridge worked because the gap was abstract-pattern-recognition vs concrete-machinery. Once Sudhan saw the locked-dial mental image, the question "why would I write a function that returns a function?" answered itself: because I want a specialized worker with one setting baked in.

**Calibration target:** mechanism-matched (locked dial explains *why* you'd ever return a function — not just *that* you can), one concrete artifact (no abstract pattern-name), bridges the same kind of gap as the closures win (concrete-mechanism over abstract-rule).
