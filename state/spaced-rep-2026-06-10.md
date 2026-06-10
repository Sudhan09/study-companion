---
last_updated: 2026-06-10T19:06:52+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-10
stale_flags: [active_weak_spots.md (~478h old — >72h threshold), room-to-improve/state/current_state.md (~453h old — >72h threshold)]
---

# Spaced rep — 2026-06-10

## Target
- **Weak spot:** F1 — Variable mix-up / naming (nested-loop shadowing face: all four loop-level names — outer index, outer value, inner index, inner value — must be distinct, full, and never abbreviated)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~478h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~453h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~478h old, current_state.md ~453h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: find_first_pair_sum. Band 2. Reps 0/2. Write a nested-loop function with four named variables — all four must use their full names; outer and inner indices/values must never share a name or be abbreviated.**

Write this function from scratch:

```python
def find_first_pair_sum(numbers: list[int], target_sum: int) -> tuple[int, int] | None:
    ...
```

Returns the first pair `(left_number, right_number)` where `left_number + right_number == target_sum` and `left_number` appears before `right_number` in `numbers`. Returns `None` if no such pair exists.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# numbers:       input list parameter — stays 'numbers'; never 'nums', 'n', 'lst', 'arr'
# target_sum:    target value — stays 'target_sum'; never 'ts', 't', 'target', 'total', 's'
# left_index:    outer loop counter — stays 'left_index'; never 'i', 'li', 'outer', 'idx'
# left_number:   numbers[left_index], the outer element — stays 'left_number'; never 'ln', 'a', 'num', 'left'
# right_index:   inner loop counter — stays 'right_index'; never 'j', 'ri', 'inner', 'idx'
# right_number:  numbers[right_index], the inner element — stays 'right_number'; never 'rn', 'b', 'num', 'right'
```

**Step 2 — Write the function body.** Use two nested `for` loops over `range(len(numbers))`.

**The trap this drill tests (nested-loop shadowing face of F1 escalation):**

The F1 escalation bugs on 2026-05-22 were define-name ≠ use-name NameErrors (`mat`/`m`, `num`/`n`). In nested loops this class of slip has a sharper edge: two loops at different levels with related names create four abbreviation opportunities — and the outer variable can be silently overwritten by an inner one with the same name.

**Risk point 1 — single-char indices:**
```python
# ❌ F1 slip — both loop counters abbreviated to single chars
for i in range(len(numbers)):
    for j in range(i + 1, len(numbers)):    # 'left_index' → 'i', 'right_index' → 'j'
```

**Risk point 2 — shared name for outer and inner element (shadowing):**
```python
# ❌ F1 slip — same name reused at both loop levels
for left_index in range(len(numbers)):
    num = numbers[left_index]                    # 'left_number' named 'num'
    for right_index in range(left_index + 1, len(numbers)):
        num = numbers[right_index]               # 'right_number' also named 'num' → outer value lost
        if num + num == target_sum:              # both terms are the inner value — wrong
```

**Risk point 3 — parameter abbreviation in the comparison:**
```python
# ❌ F1 slip — 'target_sum' abbreviated at point of use
if left_number + right_number == ts:   # 'target_sum' defined, 'ts' used → NameError
```

vs

```python
# ✅ correct — all six names used under the name they were defined
def find_first_pair_sum(numbers: list[int], target_sum: int) -> tuple[int, int] | None:
    for left_index in range(len(numbers)):
        left_number = numbers[left_index]
        for right_index in range(left_index + 1, len(numbers)):
            right_number = numbers[right_index]
            if left_number + right_number == target_sum:
                return (left_number, right_number)
    return None
```

**The six lines examined first on grade (in order):**
1. Outer `for` header — `for left_index in range(len(numbers)):` — `left_index` in full, `numbers` in full
2. Outer extraction — `left_number = numbers[left_index]` — both full names
3. Inner `for` header — `for right_index in range(left_index + 1, len(numbers)):` — `right_index` and `left_index` both in full
4. Inner extraction — `right_number = numbers[right_index]` — distinct from `left_number`, both full names
5. Comparison — `if left_number + right_number == target_sum:` — all three identifiers in full
6. Return — `return (left_number, right_number)` — both in full, no aliasing

Any single-char counter (`i`, `j`), any abbreviation (`ts`, `nums`, `ln`, `rn`), or reuse of the same name at both loop levels = redo.

**Expected behaviour:**
```python
find_first_pair_sum([1, 4, 2, 3], 5)
# → (1, 4)   (1+4=5; first pair found at indices 0, 1)

find_first_pair_sum([2, 7, 1, 4, 3], 6)
# → (2, 4)   (2+4=6; first pair found at indices 0, 3)

find_first_pair_sum([1, 2, 3], 10)
# → None     (no pair sums to 10)

find_first_pair_sum([], 5)
# → None     (empty list — outer loop never runs)

find_first_pair_sum([5, 5], 10)
# → (5, 5)   (5+5=10)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order as listed above. Any abbreviated name or reused loop-level name = redo. Output paste required — run all five assertions.

**Bonus (A1 keep-warm):** Before writing the inner loop body, state in one sentence: "For each right_index, I do X first, then Y." Name the two sub-steps (extract `right_number`, then check if `left_number + right_number == target_sum`) before typing the inner body. A1 rep #3 of 3 toward Band 2 graduation is still open — naming steps in English before coding is the exact pattern that closes it.

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2/2-boundary blocks graduation). Last 3-day window: `build_frequency_map` (2026-06-09, long-parameter-name abbreviation face), `find_first_match` (2026-06-08, default-args face); no file on 2026-06-07. Neither covered the **nested-loop shadowing face** — where outer and inner loop variables at different nesting levels can alias or overwrite each other. `find_first_pair_sum` requires 4 distinct full-name variables across two loop levels (`left_index`, `left_number`, `right_index`, `right_number`), directly replicating the D.1 variable-shadowing trap that Day 5 Block D covers. Only F1 face not yet in recent rotation.
