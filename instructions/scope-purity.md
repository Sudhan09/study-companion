<!-- Per design §G adapt: spirit of rules.xml v2.5 Rule 1 (scope_purity) from the bootcamp pipeline (Sudhan09/python_bootcamp_claude_code) config/rules.xml -->
<!-- Authoritative XMLs synced daily by study-curriculum-sync routine into instructions/curriculum/. Read those files for the runtime registry. -->
<!-- Per design §C: new file. -->

# Scope Purity (Rule 1, ported)

**If a concept hasn't been covered in completed bootcamp days, it doesn't exist in this session.**

Severity: **absolute**. Fail closed.

---

## Allowed

Concepts from completed bootcamp days, per the live registry at `instructions/curriculum/progress_state.xml`'s `<completed_through_day>` field plus `instructions/curriculum/deviation_log.xml`'s `<scope_additions>` per phase. Plus today's concepts (the active curriculum chunk per `<active_files>`).

## Read-only allowed

A pre-registered concept may be SHOWN as a future preview, but not used in exercises, asserts, or solution hints.

Example:
> "On Day 6 you'll learn functions, which formalize this pattern."

The learner must never WRITE out-of-scope code.

## Forbidden

Using out-of-scope concepts in any:
- Exercise prompt
- Assertion
- Solution hint
- "Just use library X" advice

## Exception (per rules.xml)

ONE approved out-of-scope tool per mini-project IF specified in the trigger prompt or curriculum spec. Must include a scope note:

> SCOPE NOTE: `import random` is formally taught on Day X. Here we use ONLY `random.randint(a, b)` as a black-box tool. Treat it as a built-in that gives a random number.

Without an approved exception + scope note, the use is a hard fail.

---

## Scope test (before any drill, code block, or hint)

> **"Could Sudhan write this using ONLY completed days + today's concepts?"**

If no → remove that part of the drill. Do not ask. **Fail closed.**

---

## Runtime scope source

- **Live registry:** `instructions/curriculum/progress_state.xml` `<completed_through_day>` + active curriculum chunk per `<active_files>` + `instructions/curriculum/deviation_log.xml` `<scope_additions>`.
- **Synced daily** by the `study-curriculum-sync` routine at 08:30 IST (cron `0 3 * * *` UTC).
- **Pipeline repo** (`Sudhan09/python_bootcamp_claude_code`, `config/` directory) is the authoritative source. Study companion does NOT fork these files — it subscribes.

## On scope violation

Stop. Tell user:
> "That uses `[concept]`, which is Phase [P] / Day [D] material — outside today's scope per `progress_state.xml`. Proceed with `[in-scope alternative]` or skip the example."

Never silently include the out-of-scope concept and hope it lands.
