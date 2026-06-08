---
last_updated: 2026-06-08T13:35:31+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-08
stale_flags: [active_weak_spots.md (~425h old — >72h threshold), room-to-improve/state/current_state.md (~399h old — >72h threshold)]
---

# Spaced rep — 2026-06-08

## Target
- **Weak spot:** F1 — Variable mix-up / naming (default-args context: every parameter — including the default one — must keep its full name throughout the function body; no abbreviation at point of use)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~425h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~399h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~425h old, current_state.md ~399h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: find_first_match. Band 2. Reps 0/2. Write a function with a default argument — every parameter (including `start`) must stay its full name inside the body. No single-char stand-ins anywhere.**

Write this function from scratch:

```python
def find_first_match(items: list, target, start: int = 0) -> int:
    ...
```

Returns the index of the first occurrence of `target` in `items` at or after position `start`. Returns `-1` if not found. Assume `start` is a valid index or `0`.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# items:   input list parameter — stays 'items'; never 'lst', 'data', 'l', 'arr'
# target:  value to search for — stays 'target'; never 't', 'val', 'v', 'x'
# start:   starting index (default 0) — stays 'start'; never 's', 'idx', 'i', 'begin'
# index:   loop counter over range(start, len(items)) — stays 'index'; never 'i', 'idx', 'ix'
# item:    items[index], one element from the list — stays 'item'; never 'x', 'val', 'elem', 'e'
```

**Step 2 — Write the function body.** Use a `for` loop over `range(start, len(items))`.

**The trap this drill tests (default-arg face of F1 escalation):**

The original F1 escalations on 2026-05-22 were define-name ≠ use-name NameErrors: `mat` defined, `m` used (D.3.3); parameter `num`, but `n` used in range calls (E.1.4). The default-arg face is the same failure applied to a parameter that has a default value — the name is shorter, the temptation to abbreviate is higher.

Three risk points, in failure order:

**Risk point 1 — the default parameter inside `range`:**
```python
# ❌ F1 slip — abbreviating 'start' in the range call
for index in range(s, len(items)):   # 'start' defined, 's' used → NameError
```

**Risk point 2 — the loop counter:**
```python
# ❌ F1 slip — single-char loop counter
for i in range(start, len(items)):   # 'i' instead of 'index' — won't crash but breaks the rule
    item = items[i]                  # inconsistent: 'i' used, 'index' never appears
```

**Risk point 3 — the comparison target:**
```python
# ❌ F1 slip — abbreviating 'target' in the comparison
for index in range(start, len(items)):
    item = items[index]
    if item == t:    # 'target' defined, 't' used → NameError
        return index
```

vs

```python
# ✅ correct — every name used under the name it was defined
def find_first_match(items: list, target, start: int = 0) -> int:
    for index in range(start, len(items)):
        item = items[index]
        if item == target:
            return index
    return -1
```

**The four lines examined first on grade (in order):**
1. `for` header — must say `for index in range(start, len(items)):` — `index` and `start` both in full, not abbreviated
2. Extraction line — must say `item = items[index]` — `item` singular, `index` full
3. Comparison line — must say `if item == target:` — `item` and `target` both in full
4. Return in loop — must say `return index` — the same `index` from the header, not an alias

Any abbreviated form of any parameter or variable (`s`, `t`, `i`, `idx`, `x`) = redo. Shortening `target` to `val` or `target_val` is also a redo.

**Expected behaviour:**
```python
find_first_match([10, 20, 30, 20, 40], 20)
# → 1   (first 20 at index 1; start=0 default)

find_first_match([10, 20, 30, 20, 40], 20, start=2)
# → 3   (search from index 2; next 20 is at index 3)

find_first_match([10, 20, 30], 99)
# → -1  (99 not in list)

find_first_match([], 5)
# → -1  (empty list; range(0, 0) is empty)

find_first_match([5, 5, 5], 5, start=1)
# → 1   (start=1, first match from that point is index 1)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. `for` header — `index` (full), `start` (full, not abbreviated), `items` (full) in `range(start, len(items))`
2. Extraction — `item = items[index]`, both full names, singular `item`
3. Comparison — `item == target`, both full names
4. Return — `return index` matches the loop var name exactly

Any abbreviation of any identifier = redo. Output paste required — run all five assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name both sub-steps (extract the element, then test it against target) before touching the keyboard. (A1 rep #3 of 3 toward Band 2 graduation is still open — naming steps aloud is the pattern that closes it.)

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2/2-boundary). Last-3-day window: `count_matching` (2026-06-06, HOF/callable-param face), `first_longer_than` (2026-06-05, while-loop face), `make_profiles` (2026-06-04, zip parallel-list face). None of those covered the **default-args / parameter-aliasing** face — the direct 2026-05-22 escalation trigger (`num`/`n` NameError in `pythagorean_triples` E.1.4 where the param had a natural short abbreviation). `find_first_match` forces the same discipline on two parameters: `target` (tempting to shorten to `t`) and `start` (tempting to shorten to `s` or `i`). Curriculum alignment: Day 5 Block A.6 (default args + naming discipline).
