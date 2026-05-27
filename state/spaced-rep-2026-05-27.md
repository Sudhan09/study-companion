---
last_updated: 2026-05-27T19:08:06+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-27
stale_flags: [active_weak_spots.md (130h old — >72h threshold), room-to-improve/state/current_state.md (116h old — >72h threshold)]
---

# Spaced rep — 2026-05-27

## Target
- **Weak spot:** F3 — Operator/condition confusion (exponent-semantics face: `**2` vs `**0.5` vs `**var`)
- **Band:** 2 escalated (reps so far 0/2 on exponent face; boundary face earned 2 clean reps 2026-05-22 but same-session re-fire blocks downgrade)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 130h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 116h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 130h old, current_state.md 116h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F3: scaled_distance. Band 2. Reps 0/2. Write a function that computes Euclidean distance × scale, forced pre-state of every exponent expression before coding.**

Write this function from scratch:

```python
def scaled_distance(x1: float, y1: float, x2: float, y2: float, scale: float = 1.0) -> float:
    ...
```

Returns the Euclidean distance between `(x1, y1)` and `(x2, y2)`, multiplied by `scale`.

**Step 1 — Exponent pre-state (mandatory, write as comments before any code):**

Before touching the body, write these three lines as comments and fill in the blanks:

```python
# dx**2   evaluates to: ___  (square? root? cube?)
# dy**2   evaluates to: ___
# (dx**2 + dy**2)**0.5   evaluates to: ___  (square? root? power-of-0.5?)
```

This is the drill. If you write the comment wrong, catch it *before* the code runs — not after.

**Step 2 — Write the body.**

Expected assertions (use these to verify):
```python
assert abs(scaled_distance(0, 0, 3, 4) - 5.0) < 1e-9        # 3-4-5 right triangle
assert abs(scaled_distance(0, 0, 3, 4, scale=2) - 10.0) < 1e-9
assert abs(scaled_distance(1, 1, 1, 1)) < 1e-9               # same point → 0
```

**Reminder (the escalation trigger from 2026-05-22):**
- `**2` = raise to the power 2 = **squaring**. `3**2 = 9`. Not square root.
- `**0.5` = raise to the power 0.5 = **square root**. `9**0.5 = 3.0`. Not squaring.
- `**var` where `var` is unknown at write-time — state what `var` holds before using it.

Paste the pre-state comments + full function + run output to confirm.

## Selection rationale

F1 is algorithmically first (Band 2, 0 reps, id asc) but its entire drill category (variable-naming discipline) was covered on both 2026-05-25 and 2026-05-26 — no unused entries within the 3-day window. Fall through to F3. F3 exponent-discipline target (re-test queue entry: `**2` vs `**0.5` vs `**var`) has not been prompted in last 3 days (2026-05-24 absent, 2026-05-25 and 2026-05-26 were both F1). First eligible entry selected.
