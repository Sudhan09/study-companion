---
last_updated: 2026-06-03T19:07:53+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-03
stale_flags: [active_weak_spots.md (286h old — >72h threshold), room-to-improve/state/current_state.md (284h old — >72h threshold)]
---

# Spaced rep — 2026-06-03

## Target
- **Weak spot:** F1 — Variable mix-up / naming (class-method context: `self.steps` collection vs `step` loop variable)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~286h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~284h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~286h old, current_state.md ~284h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: Pipeline class. Band 2. Reps 0/2. Write a `Pipeline` class — the loop variable inside `apply` must be `step` (singular), never `steps`, `s`, `fn`, or any alias.**

Write this class from scratch:

```python
class Pipeline:
    def __init__(self):
        ...                          # initialise self.steps

    def add(self, step):             # 'step' parameter — one function to append
        ...                          # append and return self (fluent)

    def apply(self, value):          # run all steps in sequence
        ...                          # return final value
```

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# self.steps:  the stored list of functions — attribute name is 'steps' (plural)
#              never 'fns', 'funcs', 'pipeline', 'transforms'
# step:        ONE function drawn from self.steps in the loop — singular of 'steps'
#              never 'steps' (!!), 's', 'fn', 'func', 'f', 'transform'
# value:       the data being transformed — stays 'value' throughout
#              never 'v', 'val', 'x', 'data', 'result'
```

**Step 2 — Write the class body.**

**The trap this drill tests (class-method face of the F1 escalation pattern):**

The F1 bugs on 2026-05-22 were define-name ≠ use-name: wrote `mat` then later `m`; parameter `num` but used `n` in ranges. In a class method the same slip looks like:

- `for steps in self.steps:` — loop variable named `steps` (plural) collides with the attribute name. Calling `steps(value)` then has no way to mean "one function" — and if it somehow runs, it's passing the whole list through, not one step. **This is the highest-risk line.**
- `self.steps.append(s)` in `add` — aliasing the `step` parameter as `s` the moment it appears in the body.
- `v = step(v)` — aliasing `value` as `v` inside `apply`.

The two lines examined first on grade:
1. Loop header: `for step in self.steps:` — `step` must be singular, `self.steps` must be the collection
2. Loop body: `value = step(value)` — both names must match the comment map exactly

**Expected behaviour:**
```python
p = Pipeline()
p.add(lambda x: x * 2).add(lambda x: x + 10).add(lambda x: x ** 2)
print(p.apply(3))     # → 256   (3*2=6 → 6+10=16 → 16**2=256)

p2 = Pipeline()
print(p2.apply(5))    # → 5     (no steps — value passes through unchanged)

p3 = Pipeline()
p3.add(str.upper)
print(p3.apply("hello"))   # → 'HELLO'
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. Loop header — `for step in self.steps:` (singular loop var, pluralised attribute; no reuse, no alias)
2. Loop body — `value = step(value)` (both full names, not abbreviated)
3. `add` body — `self.steps.append(step)` (parameter `step` spelled in full)

Any alias or reuse in any of the three lines = redo. Output paste required — run all three assertions.

**Bonus (A1 keep-warm):** Before writing the `apply` loop body, state in one sentence: "For each step in self.steps, I do X first, then Y." Both sub-steps named before touching the keyboard. (Day 5 Block C.2 A1 target: rep #3 of 3 toward graduation.)

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps — lowest reps_so_far among active targets F3/F1/A1; id "F1" < "A1" < "F3" breaks the Band-2 tie). Last 3-day window (2026-05-31 no file, 2026-06-01 `filter_and_scale` — define-name=use-name face, 2026-06-02 `collect_unique` — default-args face). Class-method face (`self.steps` vs `step`) not prompted in the 3-day window; directly targets the Day 5 Block E.1 `Pipeline` drill named in schedule.md F1 drill targets.
