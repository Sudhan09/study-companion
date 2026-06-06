---
last_updated: 2026-06-06T19:07:52+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-06
stale_flags: [active_weak_spots.md (~382h old — >72h threshold), room-to-improve/state/current_state.md (~357h old — >72h threshold)]
---

# Spaced rep — 2026-06-06

## Target
- **Weak spot:** F1 — Variable mix-up / naming (higher-order function context: function-arg parameter must stay its full name; plural-collection → singular-loop-var discipline across both the `items` list and the `predicate` callable)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~382h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~357h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~382h old, current_state.md ~357h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: count_matching. Band 2. Reps 0/2. Write a higher-order function that counts items satisfying a predicate — the function-arg parameter must stay `predicate` (never `f`, `fn`, `pred`, `p`, `func`); the loop variable must stay `item` (never `items`, `i`, `x`, `element`).**

Write this function from scratch:

```python
def count_matching(items: list, predicate) -> int:
    ...
```

Returns the count of elements in `items` for which `predicate(element)` returns `True`.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# items:      input list parameter — stays 'items'; never 'item', 'lst', 'data', 'elements', 'l'
# predicate:  function argument — stays 'predicate'; never 'f', 'fn', 'pred', 'p', 'func', 'test'
# item:       ONE element drawn from 'items' (singular) — stays 'item'; never 'items', 'i', 'x', 'val', 'element'
# count:      running total accumulator — stays 'count'; never 'c', 'n', 'total', 'result', 'acc'
```

**Step 2 — Write the function body.** Use a plain `for` loop with an `if` block. No list comprehension, no `filter` — the drill is the naming discipline, not the shorthand.

**The trap this drill tests (higher-order-function face of the F1 escalation):**

The F1 bugs on 2026-05-22 were define-name ≠ use-name NameErrors: `mat` defined, `m` used (D.3.3); parameter `num`, but `n` used inside ranges (E.1.4). In a higher-order function the same class of slip has two distinct risk points:

**Risk point 1 — the callable parameter alias:**
```python
# ❌ F1 slip — aliasing the callable
def count_matching(items, predicate):
    count = 0
    for item in items:
        if f(item):        # 'predicate' defined, 'f' used → NameError
            count += 1
    return count
```

**Risk point 2 — the plural loop variable:**
```python
# ❌ F1 slip — using collection name as loop variable
def count_matching(items, predicate):
    count = 0
    for items in items:    # shadows the parameter — loop breaks on first iteration's use
        if predicate(items):  # 'item' intended, 'items' used — works but wrong name
            count += 1
    return count
```

vs

```python
# ✅ correct — every name used under the name it was defined
def count_matching(items: list, predicate) -> int:
    count = 0
    for item in items:         # singular 'item', plural 'items' — distinct
        if predicate(item):    # 'predicate' spelled in full, 'item' in full
            count += 1
    return count
```

**The four lines examined first on grade (in order):**
1. `for` header — must say `for item in items:` (singular loop var, not abbreviated, not a re-use of `items`)
2. `if` line — must say `if predicate(item):` (`predicate` spelled out in full, `item` not abbreviated)
3. `count += 1` — accumulator must be named `count`, not `c`, `n`, `total`
4. `return count` — same name, no aliasing at return

Any abbreviated alias for `predicate` (even `pred`) = redo. Any non-singular for the loop variable (`items`, `i`, `x`) = redo. Accumulator aliased to anything other than `count` = redo.

**Expected behaviour:**
```python
count_matching([1, 2, 3, 4, 5], lambda x: x % 2 == 0)
# → 2   (2 and 4 are even)

count_matching(["hi", "there", "Asta", "yo"], lambda s: len(s) > 3)
# → 2   ("there" and "Asta" have length > 3)

count_matching([], lambda x: x > 0)
# → 0   (empty list — loop body never runs)

count_matching([10, -3, 0, 7], lambda x: x > 0)
# → 2   (10 and 7 are positive)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. `for` header — `item` (singular) from `items` (plural parameter), both full names
2. `if` line — `predicate(item)`, both spelled in full with no alias
3. Accumulator — `count` throughout, never abbreviated
4. `return count` — matches accumulator name

Any alias for any of the four named identifiers = redo. Output paste required — run all four assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name the two sub-steps (test the item against predicate, then conditionally increment count) before touching the keyboard. (A1 rep #3 of 3 toward Band 2 graduation is still open — naming steps aloud before coding is the pattern that closes it.)

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2/2-boundary). Last 3-day window: `first_longer_than` (2026-06-05, while-loop face), `make_profiles` (2026-06-04, parallel-list plural-to-singular face), `Pipeline` (2026-06-03, class-method/self.attribute face). None of those covered the **higher-order function / callable-parameter** face. `count_matching` targets that face and is the first item in the Day 5 Block B.1 drill list — direct curriculum alignment.
