---
last_updated: 2026-05-30T19:09:07+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-30
stale_flags: [active_weak_spots.md (213h old — >72h threshold), room-to-improve/state/current_state.md (188h old — >72h threshold)]
---

# Spaced rep — 2026-05-30

## Target
- **Weak spot:** F1 — Variable mix-up / naming (define-name = use-name; while-loop + parameter discipline)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 213h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 188h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 213h old, current_state.md 188h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: running_total. Band 2. Reps 0/2. Write a while-loop function that accumulates amounts up to a limit — parameter names stay full, loop variable is singular, no aliases.**

Write this function from scratch:

```python
def running_total(amounts: list[float], limit: float) -> float:
    ...
```

Returns the sum of elements in `amounts` accumulated one at a time — stop (do not include) the first element that would cause the total to exceed `limit`. Return the total so far.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# amounts:  input list — stays 'amounts', never 'a', 'amt', 'vals', 'lst'
# limit:    the cutoff param — stays 'limit', never 'l', 'lim', 'cap', 'max'
# amount:   one element drawn from 'amounts' (singular) — never 'a', 'val', 'x', 'item'
# total:    the running sum — never 't', 'sum', 'res', 'result'
# i:        the while-loop index — its only job is tracking position; never confused for 'amount'
```

**Step 2 — Write the function body using a `while` loop.**

**The trap this drill tests (while-loop variant of the F1 escalation pattern):**
In a for-loop the collection-vs-element slip is writing `amounts["score"]` instead of `amount["score"]`. In a while-loop the equivalent is:
- Using `amounts[i]` correctly, then accidentally writing `amounts` directly where `amounts[i]` is meant
- Or aliasing `limit` as `l` or `lim` the moment it appears in the condition

The condition line is the highest-risk spot: `while i < len(amounts) and total + amounts[i] <= limit:` — every name here must match Step 1 exactly.

**Expected behaviour:**
```python
running_total([10.0, 20.0, 5.0, 30.0], limit=40.0)   # → 35.0  (10+20+5=35; next 30 would push to 65 > 40)
running_total([5.0, 5.0, 5.0], limit=100.0)           # → 15.0  (all elements included)
running_total([50.0, 10.0], limit=20.0)               # → 0.0   (first element already exceeds limit)
```

**Pass condition:** Zero naming mismatches between Step 1 comments and Step 2 code. The while-condition line is examined first — any alias (`l`, `lim`, `a`, `amt`) in the condition or body = redo. Output paste required — run all three assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration of the while loop, I do X first, then Y." Both steps named before touching the keyboard.

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps since escalation, id "F1" < "F3" < "A1"). F1 drills in the last 3-day window (2026-05-27 – 2026-05-29): `collect_scores_by_grade` (2026-05-29, collection-vs-loop-var face) and `count_above_threshold` (2026-05-28, parameter-alias face) — both skipped. `running_total` is the first F1 drill in a while-loop context, thematically aligned with Day 5 Block C. Not previously used.
