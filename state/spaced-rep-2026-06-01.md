---
last_updated: 2026-06-01T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-01
stale_flags: [active_weak_spots.md (262h old — >72h threshold), room-to-improve/state/current_state.md (237h old — >72h threshold)]
---

# Spaced rep — 2026-06-01

## Target
- **Weak spot:** F1 — Variable mix-up / naming (define-name = use-name; parameter aliasing inside function body)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 262h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 237h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 262h old, current_state.md 237h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: filter_and_scale. Band 2. Reps 0/2. Write a function that filters and scales a list — every parameter name used inside the body must match its definition exactly, no aliases.**

Write this function from scratch:

```python
def filter_and_scale(numbers: list[float], threshold: float, multiplier: float = 2.0) -> list[float]:
    ...
```

Returns a new list containing only the elements of `numbers` that are **strictly greater than** `threshold`, each multiplied by `multiplier`.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# numbers:     input list — stays 'numbers' throughout; never 'nums', 'n', 'lst', 'data'
# threshold:   the cutoff parameter — stays 'threshold'; never 't', 'thresh', 'lim', 'cap'
# multiplier:  the scale factor — stays 'multiplier'; never 'mult', 'm', 'factor', 'scale'
# number:      one element drawn from 'numbers' (singular) — never 'n', 'x', 'val', 'item'
# result:      the output list being built — never 'res', 'r', 'out'
```

**Step 2 — Write the function body.**

**The trap this drill tests (direct escalation trigger — define-name = use-name face):**
The exact bugs that escalated F1 on 2026-05-22:
- D.3.3: defined variable as `mat` in one line, then wrote `m` when using it → NameError
- E.1.4: function parameter was `num`, but the loop range used `n` → NameError

Today's equivalent: writing `threshold` in the def line, then writing `thresh` or `t` the moment it appears in the `if` condition. Or defining `multiplier` then writing `mult` in the return expression. Same bug, same shape.

**The condition line is the highest-risk spot.** Any alias in `if number > threshold` or `number * multiplier` = redo.

**Expected behaviour:**
```python
filter_and_scale([1.0, 5.0, 3.0, 8.0, 2.0], threshold=3.0)
# → [10.0, 16.0]   (5.0 and 8.0 pass; each × 2.0 default)

filter_and_scale([1.0, 5.0, 3.0, 8.0, 2.0], threshold=3.0, multiplier=0.5)
# → [2.5, 4.0]     (same filter, each × 0.5)

filter_and_scale([1.0, 2.0], threshold=10.0)
# → []              (nothing passes)
```

**Pass condition:** Step 1 comments and Step 2 code are 1-to-1 — every name in the body matches the comment map exactly. The `if` line and the multiplication expression are examined first. Any shorthand alias in either = redo. Output paste required — run all three assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Both steps named before touching the keyboard.

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps since escalation — lowest reps among active targets; id "F1" < "A1" < "F3" breaks tie at Band 2). F1 drills in the last 3-day window (2026-05-29 – 2026-05-31): `collect_scores_by_grade` (2026-05-29, collection-vs-loop-var face) and `running_total` (2026-05-30, while-loop parameter-alias face). Neither covered the **define-name = use-name** face (the exact D.3.3 `mat`/`m` + E.1.4 `num`/`n` escalation bugs). `filter_and_scale` targets that face directly with three parameter names to guard.
