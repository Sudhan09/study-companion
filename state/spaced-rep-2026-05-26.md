---
last_updated: 2026-05-26T19:07:21+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-26
stale_flags: [active_weak_spots.md (108h old — >72h threshold), room-to-improve/state/current_state.md (82h old — >72h threshold)]
---

# Spaced rep — 2026-05-26

## Target
- **Weak spot:** F1 — Variable mix-up / naming (define-name = use-name; singular loop var vs plural collection)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 108h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 82h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 108h old, current_state.md 82h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: filter_positives_scaled. Band 2. Reps 0/2.**

Write this function from scratch:

```python
def filter_positives_scaled(numbers: list[int], scale: int = 1) -> list[int]:
    ...
```

Returns a list of every positive number in `numbers`, each multiplied by `scale`. Numbers ≤ 0 are excluded.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# numbers: input list, stays 'numbers' throughout — never aliased
# number: one element from the loop (singular of 'numbers')
# scale: the default-arg multiplier, stays 'scale' — never 's' or 'factor'
# results: the accumulator list being built
```

**Step 2 — Then write the function body.**

**Naming rules (what the drill is testing):**
1. `numbers` stays `numbers` start to finish — no `nums`, no `n_list`, no `lst`.
2. Loop variable is `number` (singular). Not `n`, `num`, `x`, or `item`.
3. Accumulator is `results`. Not `res`, `output`, or `r`.
4. `scale` stays `scale`. No one-letter aliases.
5. Comments from Step 1 must match the code names exactly — 1-to-1.

**Expected behaviour:**
```python
filter_positives_scaled([3, -1, 0, 7, -2, 5], scale=2)  # → [6, 14, 10]
filter_positives_scaled([3, -1, 7])                      # → [3, 7]  (scale defaults to 1)
filter_positives_scaled([-1, -2])                        # → []
```

**Pass condition:** Zero naming mismatches between Step 1 comments and Step 2 code. A single `n` for `number`, or `nums` for `numbers`, anywhere in the body = redo.

**Bonus (F3 keep-warm):** State aloud which operator you're using in the filter condition (`>`, `>=`, `< 0`, `!= 0`) and why, before writing the `if`.

## Selection rationale
Highest band among active: F1, F3, A1 all Band 2 escalated. Lowest reps_so_far: F1 and F3 tied at 0/2 — F1 wins on id asc (F1 < F3). F1's first drill (`group_by_length`) was prompted on 2026-05-25 — skipped, within 3-day window. This drill (`filter_positives_scaled`) is the next F1 target: default-args + parameter-naming context (A.6 drill zone per today's schedule), not prompted in last 3 days.
