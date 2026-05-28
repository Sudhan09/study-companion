---
last_updated: 2026-05-28T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-28
stale_flags: [active_weak_spots.md (166h old — >72h threshold), room-to-improve/state/current_state.md (141h old — >72h threshold)]
---

# Spaced rep — 2026-05-28

## Target
- **Weak spot:** F1 — Variable mix-up / naming (define-name = use-name; parameter name ≠ loop variable alias)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 166h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 141h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 166h old, current_state.md 141h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: count_above_threshold. Band 2. Reps 0/2. Write a function that counts elements above a threshold — parameter names stay full, loop var is singular, no aliases.**

Write this function from scratch:

```python
def count_above_threshold(values: list[int], threshold: int) -> int:
    ...
```

Returns how many numbers in `values` are strictly greater than `threshold`.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# values:    input list — stays 'values' throughout, never 'v', 'vals', 'nums', 'lst'
# threshold: the cutoff param — stays 'threshold', never 't', 'thresh', 'limit'
# value:     one element from the loop (singular of 'values')
# count:     the running integer total
```

**Step 2 — Then write the function body.**

**Naming rules this drill tests (direct F1 escalation triggers):**
1. `values` stays `values` start to finish — not `v`, `vals`, `lst`, or any one-letter alias.
2. Loop variable is `value` (singular). Not `v`, `val`, `n`, `num`, `x`, `item`.
3. `threshold` stays `threshold` — not `t`, `thresh`, or any other alias. This is the exact trap from E.1.4: parameter `num` aliased as `n` in the loop body → NameError.
4. Counter is `count` — not `c`, `cnt`, `total`, `result`.
5. Comments from Step 1 must match code names exactly, 1-to-1.

**Expected behaviour:**
```python
count_above_threshold([1, 5, 3, 9, 2], threshold=4)   # → 2  (5 and 9)
count_above_threshold([1, 2, 3], threshold=5)          # → 0
count_above_threshold([10, 20, 30], threshold=0)       # → 3
```

**Pass condition:** Zero naming mismatches between Step 1 comments and Step 2 code. Any alias (`v`, `t`, `n`, `c`) anywhere in the body = redo. Output paste required — "done" without a run is not a confirm.

**Bonus (F3 keep-warm):** Before writing the `if`, state aloud: `>` or `>=`? And why does the spec say "strictly greater than" tell you which one?

## Selection rationale

F1 tops the sort (Band 2 escalated, 0/2 reps, id "F1" < "F3"). F1's first two drill entries (`group_by_length` on 2026-05-25, `filter_positives_scaled` on 2026-05-26) both within the 3-day window — skipped. This drill (`count_above_threshold`) is the third F1 target: focuses on the **parameter-reuse / alias anti-pattern** — the exact escalation trigger from 2026-05-22 (E.1.4 `num`/`n` mismatch causing NameError). Not prompted in last 3 days.
