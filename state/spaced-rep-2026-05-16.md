---
last_updated: 2026-05-16T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-16
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-16

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30 ⚠️ STALE ~96h) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30 ⚠️ STALE ~96h)

[STALE input — RTI state may be ahead; no session logged 2026-05-13, 2026-05-14, or 2026-05-15 so stale by design, not drift]

## Drill prompt

[STALE input ~96h — no sessions since 2026-05-12; stale by design not drift] Spaced rep — F3: set_membership_boolean_ops. Band 2. Reps 0/2. Three drills on operator decisions — name the operator choice in a 1-line comment before each function body.

**Full spec:**

Every F3 slip on 2026-05-12 was an operator decision made too fast: `>=` vs `>`, wrong `in`/`not in` direction, wrong short-circuit logic. Protocol today: write a 1-line operator comment before any function body. The comment is mandatory — it IS the F3 target.

Operator comment format (required for all three problems):
```
# operator: <which one> — because <1-clause reason>
```

---

### Problem 1 — `filter_non_negative`

```python
def filter_non_negative(nums: list) -> list:
    ...
```

Return a list of all numbers `>= 0`. Zero counts. (This is the exact "positive vs non-negative" distinction that tripped F3 on 2026-05-12.)

Rules: single loop, one operator decision. Write the operator comment first — `>` or `>=`?

```python
assert filter_non_negative([1, -2, 0, 3, -4]) == [1, 0, 3]
assert filter_non_negative([-1, -2, -3])       == []
assert filter_non_negative([0])                == [0]
assert filter_non_negative([])                 == []
```

---

### Problem 2 — `unique_to_first`

```python
def unique_to_first(a: list, b: list) -> list:
    ...
```

Return elements in `a` that are NOT in `b`. Order preserved.

Rules: convert `b` to a set first (O(1) membership), then single loop over `a`. Operator comment: `in` or `not in`?

```python
assert unique_to_first([1, 2, 3, 4], [2, 4])    == [1, 3]
assert unique_to_first([1, 2, 3], [1, 2, 3])    == []
assert unique_to_first([], [1, 2])              == []
assert unique_to_first([1, 2], [])              == [1, 2]
assert unique_to_first([1, 1, 2, 3], [2])       == [1, 1, 3]
```

---

### Problem 3 — `all_seen_before`

```python
def all_seen_before(stream: list, reference: list) -> bool:
    ...
```

Return `True` if **every** element in `stream` appears in `reference`. Return `False` if even one is absent.

Rules: one loop, one operator decision. Operator comment must name: `in` or `not in`, AND the early-return direction — do you return `False` early or `True` early?

```python
assert all_seen_before([1, 2, 3], [1, 2, 3, 4]) == True
assert all_seen_before([1, 2, 5], [1, 2, 3, 4]) == False  # 5 missing
assert all_seen_before([], [1, 2])              == True   # vacuous truth
assert all_seen_before([1], [])                 == False
```

---

**Independence target:** all three cold, no hints, each under 10 minutes. Paste output — "done" without paste is not a lock. Any operator slip: name it before fixing. Same slip twice = STOP, name the pattern, don't continue.

## Selection rationale
F3 sorts above A1: both Band 2 escalated; F3 has 0 reps vs A1's 1 — lower reps_so_far takes priority per algorithm. F3 drill #2 (two_sum_complement) prompted 2026-05-13, drill #3 (upper_triangular) prompted 2026-05-15 — both within last 3 days. Drill #1 (set membership + boolean operators) not prompted in any spaced-rep file in last 3 days → selected.
