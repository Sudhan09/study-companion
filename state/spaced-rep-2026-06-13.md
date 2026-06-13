---
last_updated: 2026-06-13T19:05:24+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-13
stale_flags: [active_weak_spots.md (~550h old — >72h threshold), room-to-improve/state/current_state.md (~524h old — >72h threshold)]
---

# Spaced rep — 2026-06-13

## Target
- **Weak spot:** F1 — Variable mix-up / naming (predicate parameter naming face: `is_prime(candidate_number)` — every identifier in the function must use the name it was defined under, never abbreviated to `n`, `num`, `i`, `d`, or `x`)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~550h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~524h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~550h old, current_state.md ~524h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: is_prime_predicate. Band 2. Reps 0/2. Write `is_prime(candidate_number)` — the parameter is `candidate_number`; the loop variable is `divisor`; both must be used in full everywhere inside the body, never as `n`, `num`, `c`, `i`, `d`, or `x`.**

Write this function from scratch:

```python
def is_prime(candidate_number: int) -> bool:
    ...
```

Returns `True` if `candidate_number` is prime (exactly two divisors: 1 and itself), `False` otherwise. Edge cases: any `candidate_number < 2` is not prime.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# candidate_number:  input parameter — stays 'candidate_number'; never 'n', 'num', 'c', 'number', 'x'
# divisor:           loop variable (each trial divisor 2..√candidate_number) — stays 'divisor'; never 'd', 'i', 'j', 'factor', 'x'
```

**Step 2 — Write the function body.** Loop from 2 up to `int(candidate_number ** 0.5) + 1` (exclusive upper bound). Return `False` the moment any `divisor` evenly divides `candidate_number`. If the loop completes without a hit, return `True`.

**The trap this drill tests (predicate parameter naming face of F1 escalation):**

F1 escalated on 2026-05-22 from two define-name ≠ use-name NameErrors (`mat`/`m`, `num`/`n`). Predicates create a compressed version of the same trap: a single meaningful parameter name (e.g., `candidate_number`) sits next to a loop variable (`divisor`) where the natural impulse is to abbreviate. Both names are used 2–4 times in a ~5-line function — every shortened name at the point of use is a NameError waiting to fire.

**Risk point 1 — abbreviating the parameter at the range call:**
```python
# ❌ F1 slip — 'candidate_number' defined at the top; 'n' used at range → NameError
for divisor in range(2, int(n ** 0.5) + 1):
```

**Risk point 2 — single-char loop variable:**
```python
# ❌ F1 slip — 'divisor' becomes 'i' or 'd' — shadowing potential, no meaning
for i in range(2, int(candidate_number ** 0.5) + 1):
    if candidate_number % i == 0:   # 'i' means nothing; reader must infer
```

**Risk point 3 — abbreviating the parameter at the modulo check:**
```python
# ❌ F1 slip — 'candidate_number' defined; 'num' used at modulo check → NameError
if num % divisor == 0:
    return False
```

**Risk point 4 — F3 bonus watchpoint (exponent semantics):**
```python
# ❌ F3 slip — '** 0.5' reads as square root (correct), but 'candidate_number ** 2' would be a square (wrong here)
# The face that blocked F3 graduation on 2026-05-22:
int(candidate_number ** 2)      # ❌ wrong — squares the number, not the root
int(candidate_number ** 0.5)    # ✅ correct — square root (the √n bound)
```

vs

```python
# ✅ correct — both names used under the name they were defined; exponent face clean
def is_prime(candidate_number: int) -> bool:
    if candidate_number < 2:
        return False
    for divisor in range(2, int(candidate_number ** 0.5) + 1):   # 'candidate_number' in full; '** 0.5' = square root
        if candidate_number % divisor == 0:                        # 'candidate_number' in full; 'divisor' in full
            return False
    return True
```

**The five lines examined first on grade (in order):**
1. Edge-case guard — `if candidate_number < 2:` — `candidate_number` in full; operator `<` not `<=`
2. `range` call — `range(2, int(candidate_number ** 0.5) + 1)` — `candidate_number` in full; `** 0.5` (root, not `** 2`); `+ 1` on the outside of `int()`
3. `for` header — `for divisor in range(...)` — `divisor` in full; NOT `i`, `d`, `factor`, `x`
4. Modulo check — `if candidate_number % divisor == 0:` — `candidate_number` in full; `divisor` in full; `==` not `=`
5. Returns — `return False` inside loop; `return True` after loop (not inside it)

Any abbreviated name, any `** 2` instead of `** 0.5`, any `+ 1` placed inside `int()` rather than outside = redo.

**Expected behaviour:**
```python
is_prime(2)    # → True  (smallest prime)
is_prime(3)    # → True
is_prime(4)    # → False (4 = 2 × 2)
is_prime(17)   # → True
is_prime(25)   # → False (25 = 5 × 5)
is_prime(1)    # → False (1 has only one divisor)
is_prime(0)    # → False
is_prime(-7)   # → False
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order as listed above. Any abbreviated name, exponent error (`** 2` for root), or `+ 1` inside `int()` = redo. Output paste required — run all eight assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, say in one sentence: "For each `divisor`, I do X first, then Y." Name the two sub-steps (check if `candidate_number % divisor == 0`, then `return False`) before typing the body. A1 rep #3 of 3 toward Band 2 graduation is still open — naming steps in English before coding is the exact pattern that closes it.

**Bonus (F3 watchpoint):** Before typing `** 0.5`, say aloud: "`** 0.5` gives the square root; `** 2` gives the square — I need the root here." State the distinction once. This is the exact exponent-face re-fire that blocked F3 graduation on 2026-05-22.

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, F3=0 on exponent face, A1=2/3; F1 < F3 by id asc tiebreak). Last-3-day window: `collect_evens` (2026-06-12, mutable-default-trap / A.6 face), `apply_pipeline` (2026-06-11, class-instance-attr vs loop-variable face), `find_first_pair_sum` (2026-06-10, nested-loop-shadowing face). None covered the **predicate parameter naming face** — where a single descriptive parameter name (`candidate_number`) sits next to a single loop variable (`divisor`) and every abbreviation in a 5-line function is a NameError. `is_prime_predicate` targets both F1 risk points (parameter abbreviation + single-char loop var) and carries a built-in F3 exponent watchpoint (`** 0.5` vs `** 2`). Curriculum alignment: Day 5 Block A.3 (predicates, `is_prime` listed explicitly) and Block D.2 (√n bound).
