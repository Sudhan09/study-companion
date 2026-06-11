---
last_updated: 2026-06-11T19:06:35+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-11
stale_flags: [active_weak_spots.md (~502h old — >72h threshold), room-to-improve/state/current_state.md (~477h old — >72h threshold)]
---

# Spaced rep — 2026-06-11

## Target
- **Weak spot:** F1 — Variable mix-up / naming (class instance attribute vs loop variable: `self.steps` is the collection; `step_function` is the loop variable extracted from it — never mixed, never abbreviated)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~502h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~477h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~502h old, current_state.md ~477h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: apply_pipeline. Band 2. Reps 0/2. Write the `run` method of a `Pipeline` class — `self.steps` is the list you iterate over; `step_function` is the loop variable; they must never be confused, abbreviated, or swapped.**

The class stub is given. Write only the `run` method body:

```python
class Pipeline:
    def __init__(self):
        self.steps = []          # list of callables

    def add(self, step_function):
        self.steps.append(step_function)
        return self

    def run(self, initial_value):
        ...                      # write this
```

`run` applies each callable in `self.steps` to a running value, starting from `initial_value`, and returns the final result. If `self.steps` is empty, return `initial_value` unchanged.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# self.steps:     instance attribute (plural list of callables) — iterated OVER; never used as loop var name
# step_function:  loop variable (singular callable) — one function extracted from self.steps each iteration
# initial_value:  input parameter — stays 'initial_value'; never 'val', 'v', 'iv', 'x'
# current_value:  running result accumulator — stays 'current_value'; never 'cur', 'cv', 'result', 'acc', 'v'
```

**Step 2 — Write the `run` method body.**

**The trap this drill tests (class instance attribute vs loop variable face of F1 escalation):**

F1 escalated on 2026-05-22 on define-name ≠ use-name NameErrors (`mat`/`m`, `num`/`n`). In a class method, this slip gets a new attractor: the instance attribute name and the loop variable name look related, and omitting or misapplying `self.` is the exact define/use split.

**Risk point 1 — missing `self.` on the iteration target:**
```python
# ❌ F1 slip — 'steps' not defined; the attribute is 'self.steps'
for step_function in steps:
    current_value = step_function(current_value)
```

**Risk point 2 — plural loop variable shadows the attribute name:**
```python
# ❌ F1 slip — 'steps' as loop var; when you write 'steps(current_value)' you think it's one step but the name says it's the whole list
for steps in self.steps:
    current_value = steps(current_value)
```

**Risk point 3 — `self.step` (singular) instead of `self.steps` (plural):**
```python
# ❌ F1 slip — attribute defined as 'self.steps' (plural); 'self.step' → AttributeError
for step_function in self.step:
    current_value = step_function(current_value)
```

**Risk point 4 — abbreviating `initial_value` or `current_value`:**
```python
# ❌ F1 slip — 'initial_value' defined, 'val' used → NameError
current_value = val
```

vs

```python
# ✅ correct — name map is 1-to-1 throughout
def run(self, initial_value):
    current_value = initial_value
    for step_function in self.steps:          # self.steps (plural attr) iterated; step_function (singular) extracted
        current_value = step_function(current_value)
    return current_value
```

**The four lines examined first on grade (in order):**
1. Initialisation — `current_value = initial_value` — `current_value` in full, `initial_value` in full
2. `for` header — `for step_function in self.steps:` — `step_function` singular, `self.steps` with `self.` and plural `s`
3. Application — `current_value = step_function(current_value)` — `step_function` (not `steps`, not `step`), `current_value` both sides in full
4. Return — `return current_value` — the same name as the accumulator, not aliased

Any of: missing `self.`, plural loop var, `self.step` (no plural `s`), abbreviating `initial_value`/`current_value` = redo.

**Expected behaviour:**
```python
p = Pipeline()
p.add(lambda x: x * 2).add(lambda x: x + 3).add(lambda x: x ** 2)
p.run(4)
# 4 → *2 → 8 → +3 → 11 → **2 → 121
# → 121

q = Pipeline()
q.add(abs).add(lambda x: x - 1)
q.run(-5)
# -5 → abs → 5 → -1 → 4
# → 4

empty_p = Pipeline()
empty_p.run(42)
# → 42   (no steps; loop never runs; returns initial_value)

r = Pipeline()
r.add(str).add(lambda s: s.upper()).add(lambda s: s + "!")
r.run("asta")
# "asta" → str → "asta" → upper → "ASTA" → +"!" → "ASTA!"
# → "ASTA!"
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order as listed above. Any abbreviated name, missing `self.`, or plural loop variable = redo. Output paste required — run all four assertions.

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2 boundary reps but exponent face still open). Last-3-day window: `find_first_pair_sum` (2026-06-10, nested-loop shadowing face), `build_frequency_map` (2026-06-09, long-parameter-name abbreviation face), `find_first_match` (2026-06-08, default-args face). None of those covered the **class instance attribute vs loop variable** face — where `self.steps` (the collection, plural, with `self.`) and `step_function` (the loop variable, singular, no `self.`) must never be confused. `apply_pipeline` forces all four F1 risk points in a class-method context: missing `self.`, plural loop var, `self.step` (missing plural `s`), and accumulator abbreviation. Curriculum alignment: Day 5 Block E.1 (Pipeline class, fluent API, `return self` chaining, functions-as-data).
