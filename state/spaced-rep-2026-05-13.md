---
last_updated: 2026-05-13T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-13
stale_flags: []
---

# Spaced rep — 2026-05-13

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30)

## Drill prompt

Spaced rep — F3: two_sum_complement_check. Band 2. Reps 0/2. Write two_sum(nums, target) — check `complement in seen` BEFORE adding current number to seen. Operator choice must be named first.

**Full spec:**

The two-sum hash trick has one critical ordering decision that is an F3 trap: you must check `complement in seen` **before** adding the current number to `seen`. Reversing that order creates a false positive whenever `num + num == target` (you'd match a number against itself).

Before writing a single line of code, write a 2-line comment:

```python
# membership check: complement in seen — using 'in' because we want to find it, not exclude it
# order: check BEFORE add — because we cannot use the same element twice
```

---

### Problem 1 — `two_sum`

```python
def two_sum(nums: list, target: int) -> tuple:
    ...
```

Return the **indices** `(i, j)` where `i < j` and `nums[i] + nums[j] == target`. Return `(-1, -1)` if no such pair exists. Guaranteed at most one valid pair.

Rules:
- One pass. Use a dict `seen = {}` mapping value → index.
- Write the 2-line operator comment first.
- No nested loops, no brute force.

Asserts:
```python
assert two_sum([2, 7, 11, 15], 9)    == (0, 1)
assert two_sum([3, 2, 4], 6)         == (1, 2)
assert two_sum([3, 3], 6)            == (0, 1)   # same value, different indices
assert two_sum([1, 2, 3], 10)        == (-1, -1) # no pair
assert two_sum([0, 4, 3, 0], 0)      == (0, 3)   # zeros
```

---

### Problem 2 — `has_pair_with_sum`

```python
def has_pair_with_sum(nums: list, target: int) -> bool:
    ...
```

Return `True` if any two **distinct** elements in `nums` sum to `target`. Return `False` otherwise.

Rules:
- One pass. Use a set `seen = set()`.
- Same 2-line operator comment ritual before any code.
- The "distinct elements" requirement means you cannot use the same index twice — the check-before-add order enforces this automatically.

Asserts:
```python
assert has_pair_with_sum([1, 4, 45, 6, 10, -8], 16)  == True   # 6 + 10
assert has_pair_with_sum([1, 2, 4, 3, 6], 3)          == True   # 1 + 2
assert has_pair_with_sum([1, 2, 3, 9], 8)             == False
assert has_pair_with_sum([5, 5], 10)                  == True   # two fives
assert has_pair_with_sum([5], 10)                     == False  # single element
assert has_pair_with_sum([], 0)                       == False  # empty
```

---

**Independence target:** both cold, no hints, each under 10 minutes. Post your output paste — "done" without paste isn't a lock. If you slip on the `in` vs `not in` call or reverse the check/add order, name the slip before fixing (F3 protocol: same bug twice = STOP and name it).

## Selection rationale
F3 sorts above A1 this run: both Band 2 escalated, F3 has 0 reps vs A1's 1 — lower reps_so_far takes priority. F3 drill target #1 (set membership + boolean operators) was prompted on 2026-05-12 — within last 3 days, skipped. F3 drill target #2 (two-sum complement check) not prompted in any prior spaced-rep file → selected.
