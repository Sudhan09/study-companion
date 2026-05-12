---
last_updated: 2026-05-12T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-12
stale_flags: []
---

# Spaced rep — 2026-05-12

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30)

## Drill prompt

Spaced rep — F3: set_membership_and_conditions. Band 2. Reps 0/2. Two drills — operator choice must be deliberate, not guessed.

**Full spec:**

Two cold-solve problems. F3 escalated on 2026-05-12 for three slip types: `>` vs `>=` boundary confusion, `in` vs `not in` membership, `and` vs `or` combining conditions. Each problem below isolates exactly one of those.

Before writing any code, write a 1-line comment naming the operator you'll use and WHY:
```python
# operator: ??? — because ???
```

---

### Problem 1 — `count_valid`

```python
def count_valid(nums: list, blacklist: set) -> int:
    ...
```

Return the count of integers in `nums` that are **strictly positive** (not zero, not negative) **and** not present in `blacklist`.

Rules:
- One loop, one counter. No list comprehensions, no `filter()`.
- Write your operator comment first.

Asserts:
```python
assert count_valid([1, -2, 3, 0, 5], {3})      == 2   # 1 and 5 qualify
assert count_valid([0, 0, 0], {1})              == 0   # 0 is NOT strictly positive
assert count_valid([1, 2, 3], {1, 2, 3})        == 0   # all blacklisted
assert count_valid([-1, -5, 2], set())          == 1   # only 2
assert count_valid([4, 8, 15, 16, 23, 42], {}) == 6   # all positive, none blacklisted
```

---

### Problem 2 — `common_elements`

```python
def common_elements(a: list, b: list) -> list:
    ...
```

Return a list of elements from `a` that also appear in `b`. Order must match `a`. No duplicates in output (each element appears at most once in the result, even if it appears multiple times in `a`).

Rules:
- Convert `b` to a set first (before the loop). One loop over `a`. Use a `seen` set to track what you've already added.
- Write your operator comment first (two operators in play: one for membership in `b_set`, one for already-added guard).

Asserts:
```python
assert common_elements([1, 2, 3], [2, 3, 4])         == [2, 3]
assert common_elements([1, 1, 2, 2], [1, 2])          == [1, 2]   # no duplicates in output
assert common_elements([5, 6, 7], [8, 9])             == []
assert common_elements([], [1, 2])                    == []
assert common_elements([3, 1, 2], [2, 3])             == [3, 2]   # order from a
```

---

**Independence target:** both cold, no hints, each under 8 minutes. Post your output paste — "done" without paste isn't a lock. If you slip on the operator choice mid-solve, name the slip before fixing it (that's the F3 protocol: same bug twice = STOP and name it).

## Selection rationale
F3 sorts above A1 this run: both Band 2 escalated, but F3 has 0 reps since escalation vs A1's 1 — lower reps_so_far takes priority. All F3 drill targets are fresh (no prior spaced-rep file targeted F3 in last 3 days). First drill target selected: set membership + boolean operators.
