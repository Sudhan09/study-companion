---
last_updated: 2026-05-23T19:07:07+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-23
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-23

> [STALE input — RTI state may be ahead] Both `state/active_weak_spots.md` and
> `room-to-improve/state/current_state.md` were last updated 2026-05-21T21:05:00+05:30
> (~46h ago). `/post-session` did not run after the 2026-05-22 session. F1 was
> escalated watch→active on 2026-05-22 per `state/current_day.md` but is not yet
> reflected in `active_weak_spots.md`. Drill selection below is still valid — F3
> remains top-priority — but reps counts may lag actual session progress.

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30 ⚠️ STALE) + room-to-improve/state/current_state.md (last_updated 2026-05-21T21:05:00+05:30 ⚠️ STALE)

## Drill prompt

[STALE — /post-session not run since 2026-05-21; reps count may be behind] Spaced rep — F3: comp_traps_cold. Band 2. Reps 0/2. Five comprehension snippets below — for each one: (1) predict the output OR name the error, and (2) write ONE comment line naming the exact trap type before your answer.

---

```python
# Snippet 1
nums = [1, -2, 3, -4, 5]
result = [x if x > 0 else 0 for x in nums]
```

```python
# Snippet 2
pairs = [(1, 2), (3, 4)]
result = [x * y for x in pairs for y in pairs]
```

```python
# Snippet 3
gen = (x**2 for x in range(5))
a = list(gen)
b = list(gen)
```

```python
# Snippet 4
keys = ["a", "a", "b"]
result = {k: i for i, k in enumerate(keys)}
```

```python
# Snippet 5
data = [[1, 2], [3, 4]]
result = {row for row in data}
```

For each snippet write:
```
# Trap type: <name>
# Output / error: <your prediction>
```

F3 earn-back conditions: both correct answers on Snippets 1 and 4 (operator-decision traps) with the trap name written first = 1 clean rep toward graduation (need 2 total).

## Selection rationale

Highest band among active (Band 2 escalated), lowest reps_so_far (0/2 for F3 vs 1/3 for A1); D.4 (range_len_refactors) was prompted yesterday (2026-05-22) so skipped to D.5 — first un-prompted F3 target in last 3 days.
