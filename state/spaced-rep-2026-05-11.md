---
last_updated: 2026-05-11T19:06:21+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-11
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-11

## Target
- **Weak spot:** A1 — Multi-step loop body / recursive one-step transform not automatic
- **Band:** 2 escalated (reps so far 0/3 at Band 2, then 1 at Band 3)
- **Source:** active_weak_spots.md (last_updated 2026-05-06T20:00:00+05:30) [STALE — ~115h old] + room-to-improve/state/current_state.md (last_updated 2026-05-06T20:00:00+05:30) [STALE — ~115h old]

[STALE input — RTI state may be ahead]

## Drill prompt

[STALE] Spaced rep — A1: str_recursion_pair. Band 2. Reps 0/3. Two drills — name the one-step reduction before writing any code.

**Full spec:**

Two cold-solve problems. For each one, write a comment naming the reduction BEFORE writing any code line. The comment must name: (a) what is "current piece" you process, and (b) what is the "smaller version" you recurse on.

---

### Problem 1 — `reverse_string`

```python
def reverse_string(s: str) -> str:
    ...
```

- Recursion only. No loops. No `reversed()`, no slicing tricks as the answer — recursion is the answer.
- Write your reduction comment first:
  ```python
  # current piece: ???
  # recurse on: ???
  ```
- Then write the base case. Then the recursive step.

Asserts:
```python
assert reverse_string("")     == ""
assert reverse_string("a")    == "a"
assert reverse_string("abc")  == "cba"
assert reverse_string("racecar") == "racecar"
```

---

### Problem 2 — `sum_list`

```python
def sum_list(lst: list) -> int:
    ...
```

- Recursion only. No loops. No `sum()`.
- Same ritual: reduction comment first, then code.
  ```python
  # current piece: ???
  # recurse on: ???
  ```

Asserts:
```python
assert sum_list([])        == 0
assert sum_list([5])       == 5
assert sum_list([1, 2, 3]) == 6
assert sum_list([10, -3, 7]) == 14
```

---

**Independence target:** both cold, no hints, each under 8 minutes. Post your output paste — "done" without paste isn't a lock.

## Selection rationale
A1 is highest priority (escalated Band 2, 0/3 reps — lowest reps_so_far of all active spots). Drill target 1 (sum-of-digits) was used on 2026-05-08, within last 3 days → skipped. Drill target 2 (list/string recursion pair) not prompted in any prior spaced-rep file → selected.
