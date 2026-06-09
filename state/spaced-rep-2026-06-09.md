---
last_updated: 2026-06-09T19:05:19+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-09
stale_flags: [active_weak_spots.md (~454h old — >72h threshold), room-to-improve/state/current_state.md (~429h old — >72h threshold)]
---

# Spaced rep — 2026-06-09

## Target
- **Weak spot:** F1 — Variable mix-up / naming (long-parameter-name abbreviation face: the exact 2026-05-22 escalation trigger — parameter defined with a long name, then used under a short alias inside the body)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~454h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~429h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~454h old, current_state.md ~429h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: build_frequency_map. Band 2. Reps 0/2. Write a function that counts word frequencies in a sentence — every parameter and accumulator keeps its full name inside the body; no short aliases.**

Write this function from scratch:

```python
def build_frequency_map(sentence: str) -> dict:
    ...
```

Returns a dict mapping each word (after `sentence.split()`) to its count in the sentence. Case-sensitive. Order matches first occurrence.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# sentence:       input string parameter — stays 'sentence'; never 's', 'sent', 'text', 'string', 'str'
# frequency_map:  accumulator dict — stays 'frequency_map'; never 'freq', 'fm', 'counts', 'd', 'result', 'map'
# word:           ONE element from sentence.split() (singular) — stays 'word'; never 'words', 'w', 'item', 'x', 'token'
```

**Step 2 — Write the function body.** Use a plain `for` loop. No `Counter`, no `defaultdict` — the drill is naming discipline, not shorthand.

**The trap this drill tests (long-parameter-name face of F1 escalation):**

The exact F1 bugs on 2026-05-22 were:
- D.3.3: defined `mat`, then wrote `m` inside the method body → NameError
- E.1.4: parameter was `num`, but loop called `range(int(n**0.5)+1)` using `n` → NameError

This drill replicates that failure mode with two long names that have obvious short forms:

**Risk point 1 — parameter abbreviation:**
```python
# ❌ F1 slip — abbreviating 'sentence' in the split call
for word in s.split():    # 'sentence' defined, 's' used → NameError
```

**Risk point 2 — accumulator abbreviation:**
```python
# ❌ F1 slip — abbreviating 'frequency_map' at access time
if word in freq:          # 'frequency_map' defined, 'freq' used → NameError
    freq[word] += 1
```

**Risk point 3 — plural loop variable:**
```python
# ❌ F1 slip — plural collection name as loop variable
for words in sentence.split():       # shadows nothing but wrong: 'words' is a plural, should be 'word'
    if words in frequency_map:       # 'word' intended, 'words' used
```

vs

```python
# ✅ correct — every name used under the name it was defined
def build_frequency_map(sentence: str) -> dict:
    frequency_map = {}
    for word in sentence.split():         # 'sentence' in full; 'word' singular
        if word in frequency_map:         # 'frequency_map' in full; 'word' in full
            frequency_map[word] += 1      # 'frequency_map' in full; 'word' in full
        else:
            frequency_map[word] = 1       # 'frequency_map' in full; 'word' in full
    return frequency_map                  # 'frequency_map' in full — same name as the variable
```

**The four lines examined first on grade (in order):**
1. `for` header — must say `for word in sentence.split():` — `word` (singular), `sentence` (full name, not abbreviated)
2. `if` condition — must say `if word in frequency_map:` — `word` and `frequency_map` both in full
3. Increment line — must say `frequency_map[word] += 1` — both full names
4. `else` branch — must say `frequency_map[word] = 1` — both full names
5. `return` — must say `return frequency_map` — same name as the dict, not an alias

Any abbreviated form (`s`, `sent`, `freq`, `fm`, `w`, `words`) for any of the three named identifiers = redo.

**Expected behaviour:**
```python
build_frequency_map("the cat sat on the mat")
# → {'the': 2, 'cat': 1, 'sat': 1, 'on': 1, 'mat': 1}

build_frequency_map("asta asta asta")
# → {'asta': 3}

build_frequency_map("one")
# → {'one': 1}

build_frequency_map("")
# → {}   (empty string → sentence.split() → [] → loop never runs)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order as listed above. Any abbreviated alias for any identifier = redo. Output paste required — run all four assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name the two sub-steps (check if word is already in frequency_map, then either increment or initialise) before touching the keyboard. (A1 rep #3 of 3 toward Band 2 graduation is still open — naming steps in English before coding is the exact pattern that closes it.)

## Selection rationale
F1 tops sort: Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets (F1=0, A1=2/3, F3=2/2-boundary). Last-3-day window: `find_first_match` (2026-06-08, default-args/callable-param face), `count_matching` (2026-06-06, HOF callable face). Neither covered the **long-parameter-name abbreviation face** — the direct 2026-05-22 escalation trigger (`mat`/`m` and `num`/`n` NameErrors where the parameter had an obvious short form). `build_frequency_map` replicates that exact failure mode on two identifiers: `sentence` (tempting short form `s`/`sent`) and `frequency_map` (tempting short form `freq`/`fm`). Curriculum alignment: Day 5 Block B.3 / dict-accumulator loop pattern (also hits A1 two-step body keep-warm).
