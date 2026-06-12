---
last_updated: 2026-06-12T19:06:02+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-12
stale_flags: [active_weak_spots.md (~525h old — >72h threshold), room-to-improve/state/current_state.md (~500h old — >72h threshold)]
---

# Spaced rep — 2026-06-12

## Target
- **Weak spot:** F1 — Variable mix-up / naming (mutable default trap face: default-args parameter naming — never reuse the param name as the loop variable; singular loop var, plural collection)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~525h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~500h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~525h old, current_state.md ~500h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: collect_evens. Band 2. Reps 0/2. Write a function with a mutable default arg — `None` sentinel required; loop variable must be singular form of the input param; never reuse the param name as the loop var.**

Write this function from scratch:

```python
def collect_evens(source_numbers: list[int], even_numbers: list | None = None) -> list:
    ...
```

Returns a list of all even integers from `source_numbers`, appended into `even_numbers`. If `even_numbers` is not provided, starts with an empty list. Preserves order. Does not modify the caller's list.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# source_numbers:  input list parameter — stays 'source_numbers'; never 'nums', 'src', 'numbers', 'lst', 'n'
# even_numbers:    mutable default accumulator — stays 'even_numbers'; never 'evens', 'e', 'result', 'res', 'acc'
# source_number:   ONE element from source_numbers (singular) — stays 'source_number'; never 'source_numbers', 'n', 'num', 'x', 'item'
```

**Step 2 — Write the function body.** Use a plain `for` loop. No list comprehension.

**The trap this drill tests (A.6 / mutable default trap face of F1):**

The F1 escalation bugs on 2026-05-22 were define-name ≠ use-name NameErrors (`mat`/`m`, `num`/`n`). In a default-arg function the same slip gets a new attractor: the natural urge is to abbreviate the long parameter name inside the body, AND to reuse the plural param name as the loop variable (since it's "right there").

**Risk point 1 — mutable default instead of None sentinel:**
```python
# ❌ classic default-args bug — list created once at def time, shared across calls
def collect_evens(source_numbers: list[int], even_numbers: list = []) -> list:
```

**Risk point 2 — reusing the param name as the loop variable:**
```python
# ❌ F1 slip — 'source_numbers' (plural param) reused as the loop variable
for source_numbers in source_numbers:    # shadows the param → NameError on next iteration
    if source_numbers % 2 == 0:
        even_numbers.append(source_numbers)
```

**Risk point 3 — abbreviating the input param inside the body:**
```python
# ❌ F1 slip — 'source_numbers' defined, 'nums' used in the loop header
for source_number in nums:               # 'source_numbers' defined, 'nums' used → NameError
```

**Risk point 4 — abbreviating the accumulator:**
```python
# ❌ F1 slip — 'even_numbers' defined, 'evens' or 'result' used at append time
evens.append(source_number)             # 'even_numbers' defined, 'evens' used → NameError
```

vs

```python
# ✅ correct — None sentinel; singular loop var; every name used under the name it was defined
def collect_evens(source_numbers: list[int], even_numbers: list | None = None) -> list:
    if even_numbers is None:
        even_numbers = []
    for source_number in source_numbers:      # 'source_numbers' (plural, full) iterated; 'source_number' (singular) extracted
        if source_number % 2 == 0:           # 'source_number' in full — not 'n', not 'num', not 'source_numbers'
            even_numbers.append(source_number)  # 'even_numbers' in full — not 'evens', not 'result'
    return even_numbers
```

**The five lines examined first on grade (in order):**
1. Function signature — default must be `None`, not `[]` or any other mutable
2. `if even_numbers is None:` — `even_numbers` in full; sentinel check present
3. `for` header — `for source_number in source_numbers:` — `source_number` (singular, full), `source_numbers` (plural, full); loop var must NOT be `source_numbers`, `n`, `num`, `x`
4. `if` condition — `if source_number % 2 == 0:` — `source_number` in full; operator `==` not `=`
5. `.append()` call — `even_numbers.append(source_number)` — `even_numbers` in full, `source_number` in full

Any of: mutable default, missing None sentinel, plural loop var, param reuse as loop var, abbreviation of `source_numbers`/`even_numbers`/`source_number` = redo.

**Expected behaviour:**
```python
collect_evens([1, 2, 3, 4, 5, 6])
# → [2, 4, 6]

collect_evens([1, 3, 5])
# → []

collect_evens([10, 20, 30], [2])
# → [2, 10, 20, 30]   (appended into the caller-supplied list)

collect_evens([])
# → []   (empty input — loop never runs; returns new empty list)

# Mutable-default isolation check:
a = collect_evens([1, 2])   # → [2]
b = collect_evens([3, 4])   # → [4]  (not [2, 4] — lists are independent)
assert a == [2]
assert b == [4]
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order as listed above. Any mutable default, any abbreviated name, any param-reused-as-loop-var = redo. Output paste required — run all five assertions including the isolation check.

**Bonus (A1 keep-warm):** Before writing the loop body, say in one sentence: "For each `source_number`, I do X first, then Y." Name the two sub-steps (check if even, then append) before typing the body. A1 rep #3 of 3 toward Band 2 graduation is still open — two-step body named in English before coding is the exact pattern that closes it.

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2 boundary reps but graduation blocked by same-session exponent re-fires). Last-3-day window: `apply_pipeline` (2026-06-11, class instance attribute vs loop variable face), `find_first_pair_sum` (2026-06-10, nested-loop shadowing face), `build_frequency_map` (2026-06-09, long-parameter-name abbreviation face). None covered the **mutable default trap / A.6 face** — where the param name is the plural collection being iterated, and the temptation is to (a) reuse that plural param name as the loop var, (b) abbreviate it inside the body, and (c) forget the None sentinel. `collect_evens` forces all four F1 risk points in the default-arg context. Curriculum alignment: Day 5 Block A.6 (default arguments + mutable default trap + F1 primary drill zone per schedule).
