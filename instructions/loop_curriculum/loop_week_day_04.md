# 🔁 Loop Week — Day 4: Comprehensions, `zip`, & Range Mastery

> **Theme:** The day where loops get *compressed*. Everything from Days 1-3 gets rewritten in comprehension form. By the end, you read `[x*2 for x in lst if x > 0]` as fluently as `for x in lst:`. Plus: deep range mastery (Tiers 5-6), `zip`, `enumerate` in comp context, and the anti-patterns that distinguish "writes Python" from "writes Pythonic."
>
> **Time budget:** 6-7 focused hours
>
> **Phase 3b coverage:** L7 (Range mastery — Tiers 5-6 + anti-patterns)
>
> **Mini-boss:** Translate 5 loops to comprehensions + `is_prime` (√n bound) + Pythagorean triples
>
> **Honest note:** Day 4 is the for-only exception. Comprehensions are defined as for-based syntax — no "while comprehension" exists. The for/while equal-footing rule gets a pass today. We balance hard on Days 5-7.

---

## 🎯 Day 4 Learning Goals

By end of day, you should be able to **without notes**:

1. Translate any loop from Days 1-3 into a comprehension where appropriate
2. Distinguish filter (`if` after for) from if/else (ternary before for) cold
3. Build list / dict / set / generator comprehensions fluently
4. Use nested comprehensions for matrix transpose and flatten
5. Use `zip()` to pair iterables (and know when to use `enumerate` instead)
6. Spot and fix 5 common anti-patterns (`range(0, n, 1)`, `range(len(lst))` overuse, etc.)
7. Use `range(int(n**0.5) + 1)` legitimately in prime/factor problems — and explain why √n bound works
8. Recognize Tier 6 exotic range forms — and know which to avoid
9. Choose between comprehension and regular loop based on readability, not vanity
10. Use generator expressions for memory-lazy iteration
11. Wrap comprehension-heavy logic in functions and `MatrixOps` class

---

## 🗓 Day 4 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Morning** | 1.5 hr | Comprehension fundamentals + 8 forms ladder |
| **Block B — Midday** | 1.5 hr | Translation drills (Day 1-3 loops → comprehensions) + dict/set/gen comprehensions |
| **Block C — Afternoon Part 1** | 1 hr | `zip`, `enumerate` in comp context + parallel iteration |
| **Block D — Afternoon Part 2** | 1.5 hr | Phase 3b L7 — Range Tier 5-6 + anti-patterns |
| **Block E — Wrap Block** | 1.5 hr | Functions + MatrixOps class |
| **Block F — Evening Mini-Boss** | 30 min | Translate 5 loops + `is_prime` + Pythagorean triples, cold |

Total: ~7 hours.

---

## 📚 Block A — Comprehension Fundamentals (1.5 hr)

### A.1 — The mental model (10 min)

**Comprehensions are NOT new logic.** They're *loop syntax compression*.

Every comprehension answers 3 questions:

| Question | Where it lives in syntax |
|---|---|
| **What to keep / produce?** | Leftmost expression |
| **Where to get it from?** | The `for x in iter` clause |
| **Which to filter?** | The `if cond` clause (optional) |

**Reading order:**
```python
[x * 2 for x in nums if x > 0]
#  ^^^^^                          → expression: produce x*2
#         ^^^^^^^^^^^             → source: iterate nums
#                       ^^^^^^^^^ → filter: only positive
```

**Why Pythonic:**
- Clearer intent (filter + transform in one statement, not 4 lines)
- Often faster (C-level iteration in CPython)
- Reduces accidental scope leaks (loop variable doesn't escape)

**Why NOT always:**
- Past 2 clauses, readability tanks
- Complex side effects don't belong in comps
- Debug points harder (single expression vs multi-line loop)

### A.2 — The 8 forms ladder (40 min)

Drill each form. **Don't skip a level.** Each builds on the prior.

**Form 1 — Basic copy (2 min)**
```python
copy = [x for x in nums]
# Equivalent: list(nums) or nums.copy()
```
Rarely useful by itself — but it's the skeleton everything else extends.

**Form 2 — Transform (5 min)**
```python
squared = [x**2 for x in nums]
upper = [c.upper() for c in text]
```
**Drill:** Square every number in `[1,2,3,4,5]`. Uppercase every char in `"hello"`.

**Form 3 — Filter (5 min)**
```python
positives = [x for x in nums if x > 0]
vowels = [c for c in text if c in "aeiou"]
```
**Drill:** Keep evens from `[1,2,3,4,5,6]`. Keep words longer than 4 chars from a list.

**Form 4 — Filter + Transform (5 min)**
```python
even_squares = [x**2 for x in nums if x % 2 == 0]
```
**Drill:** Square only the evens in `[1,2,3,4,5,6]`. Result should be `[4, 16, 36]`.

**Form 5 — if/else expression (the trap) (5 min)**

This is NOT filter. It's a ternary inside the expression. Position matters.

```python
# Filter — drops elements (length can shrink)
[x for x in nums if x > 0]              # only positives, length ≤ original

# if/else — transforms every element (length unchanged)
[x if x > 0 else 0 for x in nums]       # negatives → 0, every element kept
```

**Drill — predict each, verify:**
```python
nums = [-2, -1, 0, 1, 2]

[x for x in nums if x > 0]          # → ?
[x if x > 0 else 0 for x in nums]   # → ?
[abs(x) for x in nums]              # → ?
[x if x % 2 == 0 else "odd" for x in nums]   # → ?
```

**Memory hook:** *"`if` AFTER for = filter. `if/else` BEFORE for = ternary."*

**Form 6 — Nested loops (10 min)**
```python
pairs = [(i, j) for i in range(3) for j in range(3)]
# 9 pairs total — outer loop is leftmost
```

**Reading rule:** Outer loop = leftmost `for`. Inner loop = rightmost `for`. Same as nested loop top-down reading.

**Drill problems:**
1. Build all `(i, j)` pairs for `i, j` in `range(4)`. Predict count: should be 16.
2. Build all `f"{letter}{digit}"` strings from `"abc"` and `"123"`. Predict count.
3. Cartesian product of two lists using nested comp.

**Form 7 — Nested loop + filter (10 min)**

Filter applies to the combination, not just the outer.

```python
# Upper-triangular pairs (Phase 3b L3 in comp form!)
unique_pairs = [(i, j) for i in range(n) for j in range(i+1, n)]
```

**Drill problems:**
1. Build unique pairs from `range(5)` using nested + filter form.
2. Pythagorean-style: pairs `(a, b)` from `range(1, 11)` where `a + b == 10`.
3. Self-skip: `[(i, j) for i in range(4) for j in range(4) if i != j]`. Count: should be 12.

**Form 8 — Nested comprehension (true nesting) (3 min)**

This is different from Form 6. Form 6 is one comp with two `for` clauses. Form 8 is a comp **inside** a comp.

```python
# Matrix transpose
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
transposed = [[row[i] for row in matrix] for i in range(len(matrix[0]))]
# → [[1,4,7], [2,5,8], [3,6,9]]
```

**Drill problem:**
1. Build a 3×3 grid of `(i, j)` pairs as a 2D list. Use Form 8 (comp inside comp).

### A.3 — Critical reading practice (15 min)

**Predict each output cold.** Don't run yet — write your guess, then verify.

```python
# 1
[x for x in range(5)]

# 2
[x*x for x in range(5)]

# 3
[x for x in range(10) if x % 3 == 0]

# 4
[(i, j) for i in range(3) for j in range(2)]

# 5
[(i, j) for i in range(3) for j in range(i+1, 3)]

# 6
[x if x > 0 else -x for x in [-2, -1, 0, 1, 2]]

# 7
[c.upper() if c in "aeiou" else c for c in "hello"]

# 8
[[i*j for j in range(4)] for i in range(4)]
```

After predicting, run all 8. Note any mismatches — they're your weak spots.

### A.4 — When NOT to use a comprehension (10 min)

The Pythonic move is sometimes a regular loop.

**Use a regular loop when:**
- Logic spans more than 2 conditions
- Side effects (printing, file writes, mutating external state)
- Debugging — comp is one expression, harder to add print mid-flow
- Readability suffers — if a colleague pauses, the comp lost

**Anti-example (don't do this):**
```python
# Cramming everything into a comp
result = [x*2 if x > 0 else (x*-1 if x < -10 else 0) for x in nums if isinstance(x, int) and x != 5]

# Cleaner as a loop
result = []
for x in nums:
    if not isinstance(x, int) or x == 5:
        continue
    if x > 0:
        result.append(x * 2)
    elif x < -10:
        result.append(x * -1)
    else:
        result.append(0)
```

**Rule of thumb:** *If it doesn't fit in 80 chars without scrolling, it's probably too complex for a comp.*

### A.5 — Empty/edge cases (5 min)

**Topics:**
- Empty input → empty output (no crash): `[x for x in []]` → `[]`
- All filtered out → empty list: `[x for x in [1,2,3] if x > 100]` → `[]`
- Single element → single-element list

**Drill:** Predict each, verify.
```python
[x for x in []]
[x for x in [5]]
[x for x in [1,2,3] if x > 100]
[x for x in [1,2,3] if True]
```

---

## 🔄 Block B — Translation Drills + Dict/Set/Gen Comprehensions (1.5 hr)

### B.1 — Translation drills: Day 1 loops → comprehensions (25 min)

Take every Block B pattern from Day 1, rewrite as comp.

**Counter pattern:**
```python
# Loop form
count = 0
for x in nums:
    if x % 2 == 0:
        count += 1

# Comp form (use sum + bool trick — True is 1)
count = sum(1 for x in nums if x % 2 == 0)
# Or even tighter:
count = sum(x % 2 == 0 for x in nums)
```

**Filter pattern:**
```python
# Loop form
result = []
for x in nums:
    if x > 0:
        result.append(x)

# Comp form
result = [x for x in nums if x > 0]
```

**Accumulator (sum):**
```python
# Loop form
total = 0
for x in nums:
    total += x

# Comp form (use sum)
total = sum(nums)
# With transformation: sum of squares
total = sum(x**2 for x in nums)     # generator inside sum — no list built
```

**Search pattern:**
```python
# Loop form
pos = -1
for i, x in enumerate(nums):
    if x == target:
        pos = i
        break

# Comp form (use next + generator)
pos = next((i for i, x in enumerate(nums) if x == target), -1)
```

**Tracker pattern (longest):**
```python
# Loop form
longest = ""
for word in words:
    if len(word) > len(longest):
        longest = word

# Comp form (use max with key)
longest = max(words, key=len, default="")
```

**Drill — translate each Day 1 pattern problem:**
1. Count evens in `[1,4,7,8,10,13,16]` → comprehension
2. Keep positives from `[-3,-1,2,5,-7,8]` → comp
3. Sum of squares of `[1,2,3,4]` → comp + sum
4. Longest string in `["hi","hello","world"]` → max with key
5. First negative in `[3,5,-2,7,-1]` → next + gen expression
6. Build `["A:1","B:2",...]` from `["A","B"]` and `[1,2]` → comp + zip (preview)

### B.2 — Day 2 patterns: which translate, which don't (15 min)

**Frequency counting** — use `Counter` directly, comp is overkill:
```python
# Don't bother:
freq = {c: text.count(c) for c in set(text)}    # O(n²) — text.count is O(n)!

# Just use Counter:
from collections import Counter
freq = Counter(text)                              # O(n)
```

**Grouping** — defaultdict pattern doesn't compress well to comp. Stay with the loop.

**Inverting a dict** — clean comp:
```python
inverted = {v: k for k, v in d.items()}
```

**Membership filtering** — clean comp:
```python
common = [x for x in lst1 if x in set2]    # use set for O(1) lookup
```

**Two-sum hash trick** — does NOT translate to comp. Logic depends on order of insertion. Stays a loop.

**Drill problems:**
1. Invert `{"a":1, "b":2, "c":3}` via dict comp.
2. Filter `[1,2,3,4,5,6,7]` to keep only items in `{2, 4, 6, 8}`. Use comp + set.
3. Try writing two-sum as a comp — explain why it fails.

### B.3 — Day 3 string patterns in comp form (10 min)

**Accumulator transform:**
```python
# Day 3 form
result = ""
for c in text:
    result += c.upper()

# Comp form
result = "".join(c.upper() for c in text)
# Or directly: text.upper() — but the comp form generalizes
```

**Filter:**
```python
vowels_only = "".join(c for c in text if c in "aeiou")
```

**Caesar cipher (Day 3):**
```python
# Comp form
shifted = "".join(
    chr((ord(c) - ord('a') + shift) % 26 + ord('a')) if c.islower() else c
    for c in text
)
# Boundary case — at this complexity, regular loop is more readable
```

**Drill problems:**
1. Build "vowels only" from `"hello world"` via comp + join.
2. Build "every other char" from `"python"` via comp.
3. Caesar cipher on lowercase only — try as comp, then as loop, decide which is more readable.

### B.4 — Dict comprehension (15 min)

**Forms:**
```python
# 1. Basic
{k: v for k, v in items}

# 2. From iterable
{x: x**2 for x in range(5)}            # → {0:0, 1:1, 2:4, 3:9, 4:16}

# 3. Filter
{k: v for k, v in d.items() if v > 0}

# 4. Transform values
{k: v*2 for k, v in d.items()}

# 5. Invert
{v: k for k, v in d.items()}

# 6. From two parallel lists
{k: v for k, v in zip(keys, values)}
```

**Critical trap — duplicate keys silently overwrite:**
```python
{x % 3: x for x in range(10)}
# → {0: 9, 1: 7, 2: 8}    NOT all 10 entries!
# Last write wins for each key.
```

**Drill problems:**
1. Build `{x: x**3 for x in range(1, 6)}`. Predict.
2. Filter `{"a":1, "b":2, "c":3, "d":4}` to keep only entries with even values.
3. Spot the duplicate-key trap: `{len(s): s for s in ["a", "ab", "cd", "xyz"]}` — predict.

### B.5 — Set comprehension (5 min)

**Forms:**
```python
{x for x in iter}                           # auto-dedupe
{x for x in iter if cond}                   # filter + dedupe
{f(x) for x in iter}                        # transform + dedupe
```

**Trap:** Unhashable elements crash.

**Drill problems:**
1. Get unique squares of numbers in `[1, 2, 3, 1, 2]` via set comp.
2. Try set comp with lists as elements: `{[1,2] for _ in range(3)}` — predict the error.
3. Build set of all letters used in `"the quick brown fox"`.

### B.6 — Generator expression (10 min)

**The lazy comprehension.** Parentheses instead of brackets.

```python
gen = (x**2 for x in range(1000000))    # builds nothing yet
# Each value computed on demand
for val in gen:
    if val > 100:
        break    # rest never computed — saved memory + time
```

**Where they shine:**
- Inside `sum`, `max`, `min`, `any`, `all` — no list built
- Iterating once over huge data
- Pipelining: feed one gen into another

```python
# No intermediate list — generator chain
total = sum(x**2 for x in range(1000000) if x % 3 == 0)
```

**Trap — exhaustion:**
```python
gen = (x for x in range(5))
list(gen)        # → [0, 1, 2, 3, 4]
list(gen)        # → []  (already exhausted!)
```

**Drill problems:**
1. Compute sum of squares of evens in `range(100)` using generator inside `sum`.
2. Find first prime above 50 using `next` + generator.
3. Demonstrate exhaustion: build a gen, iterate fully, iterate again, observe empty.

---

## 🔗 Block C — `zip`, `enumerate`, Parallel Iteration (1 hr)

### C.1 — `zip` fundamentals (15 min)

`zip(iter1, iter2, ...)` pairs items from multiple iterables, stops at shortest.

```python
list(zip([1, 2, 3], ["a", "b", "c"]))
# → [(1, 'a'), (2, 'b'), (3, 'c')]

list(zip([1, 2, 3, 4], ["a", "b"]))
# → [(1, 'a'), (2, 'b')]    # stops at shortest
```

**Use cases:**
- Iterate two lists together: `for x, y in zip(a, b):`
- Build dict from parallel lists: `dict(zip(keys, values))`
- Transpose: `list(zip(*matrix))` — the unpack-zip trick

**Drill problems:**
1. Pair `["Alice", "Bob", "Charlie"]` with `[85, 92, 78]`. Print "Name: score" for each.
2. Build a dict from `keys = ["a", "b", "c"]` and `values = [1, 2, 3]` using `zip`.
3. Transpose `[[1,2,3], [4,5,6]]` using `zip(*matrix)`.

### C.2 — `zip` inside comprehensions (15 min)

This is where `zip` earns its keep — pairs cleanly inside comps.

```python
# Element-wise sum of two lists
sums = [a + b for a, b in zip(list1, list2)]

# Pair into tuples (basically what list(zip(...)) does)
pairs = [(a, b) for a, b in zip(list1, list2)]

# Filter pairs
positive_pairs = [(a, b) for a, b in zip(list1, list2) if a > 0 and b > 0]

# Build dict with comprehension + zip
combined = {k: v*2 for k, v in zip(keys, values)}
```

**Drill problems:**
1. Given `prices = [10, 20, 30]` and `quantities = [2, 3, 1]`, compute total revenue with comp + zip.
2. Given names + scores, build dict of `{name: score}` only for scores ≥ 80.
3. Element-wise multiply two equal-length lists.

### C.3 — `enumerate` in comp context (10 min)

When you need the index alongside the value, `enumerate` beats `range(len(...))`.

```python
# Anti-pattern
indexed = [(i, lst[i]) for i in range(len(lst))]

# Pythonic
indexed = [(i, x) for i, x in enumerate(lst)]
```

**With `start`:**
```python
positioned = [(i, x) for i, x in enumerate(lst, start=1)]
```

**Drill problems:**
1. Given `["a", "b", "c"]`, build `["1: a", "2: b", "3: c"]` using `enumerate(start=1)` + comp.
2. Find indices of all positives in a list. (Hint: `[i for i, x in enumerate(lst) if x > 0]`)
3. Build dict `{index: value}` from a list using `enumerate` + dict comp.

### C.4 — Parallel iteration patterns (20 min)

**Pattern: lockstep walk** — `zip` is the answer.
**Pattern: opposite directions** — Range Tier 5: `zip(range(n), range(n-1, -1, -1))`.
**Pattern: index + value** — `enumerate`.
**Pattern: 3+ parallel iterables** — `zip(a, b, c)`.

**Drill problems:**
1. Given two equal-length lists, find all indices where they differ.
2. Walk a list from both ends simultaneously, print pairs (Tier 5 preview):
   ```python
   for i, j in zip(range(n), range(n-1, -1, -1)):
       if i >= j: break
       print(lst[i], lst[j])
   ```
3. Given 3 parallel lists (names, ages, scores), build dict-of-dicts using `zip` of all three.

---

## 🪜 Block D — Phase 3b L7: Range Mastery (1.5 hr)

### D.1 — Range Tier 5: multi-variable iteration (20 min)

```python
# Two indices moving in opposite directions
for i, j in zip(range(n), range(n-1, -1, -1)):
    # i: 0 → n-1
    # j: n-1 → 0
    ...
```

**Why this matters:** Two-pointer technique preview. Walking from both ends.

**Drill problems:**
1. Print pairs `(i, j)` for `n=5` using opposite-direction zip. Trace.
2. Use this pattern to check if a list is symmetric (mirror).
3. Compare with two-pointer while-loop form (Day 3 palindrome). Which is more readable?

### D.2 — Range Tier 6: legitimate exotic — `int(n**0.5) + 1` (25 min)

**The √n bound — why it works for primes/factors.**

For any composite number `n`, at least one factor `f` satisfies `f ≤ √n`. Proof: if both factors of `n = a*b` were greater than √n, then `a*b > n` — contradiction. So testing factors only up to √n is sufficient.

**Prime check:**
```python
def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True
```

**Why `+ 1`:** `range` is exclusive of stop. For `n = 49`, `√49 = 7`. We need to check 7. So `range(2, 7+1) = range(2, 8)` includes 7.

**Factor pairs:**
```python
def factor_pairs(n):
    pairs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            pairs.append((i, n // i))
    return pairs
```

**Performance:** O(n) → O(√n). For n = 1,000,000, that's 1000 iterations vs 1,000,000.

**Drill problems:**
1. Implement `is_prime(n)` using √n bound. Test on 2, 3, 4, 7, 49, 97, 100.
2. Implement `factor_pairs(n)`. Test on 12, 36, 100.
3. Trace why testing only up to √n suffices for `n = 36` (√36 = 6). What pairs would we miss if we stopped at 5?

### D.3 — Range Tier 6: the genuinely exotic (recognize, don't use) (10 min)

| Form | What it does | Honest take |
|---|---|---|
| `range(n % k)` | Loops 0 to (n mod k) - 1 | Rare, usually clever-for-clever's-sake |
| `range(n ** 2)` | Loops 0 to n²-1 | Legal, but if you want n² iterations, nested loops are clearer |
| `range(*some_list)` | Unpacks list as range args | Almost never seen, possible in metaprogramming |

**The vibe:** If you have to think for >5 seconds about what a `range` expression means, it's probably hurting more than helping.

**Drill problems:**
1. Predict: `for i in range(7 % 3): print(i)` — what runs?
2. Try `range(*[2, 10, 2])` — what's it equivalent to?
3. Refactor an obscure range usage into a named variable + plain range.

### D.4 — Anti-patterns deep (35 min)

| Bad | Good | Why |
|---|---|---|
| `range(0, n, 1)` | `range(n)` | `0` and `1` are defaults |
| `for i in range(len(lst)): item = lst[i]` | `for item in lst:` | If you don't need index, don't track it |
| `for i in range(len(lst)): print(i, lst[i])` | `for i, item in enumerate(lst):` | `enumerate` exists for this |
| `for i in range(len(a)): print(a[i], b[i])` | `for x, y in zip(a, b):` | `zip` exists for this |
| `[x for x in lst]` | `list(lst)` or `lst.copy()` | Comprehension is overkill for plain copy |
| `range(len(d))` for a dict | `d.keys()` / `d.items()` | Range over a hash isn't the right primitive |

**The mental shift:** *Reach for `range(len(...))` only when you genuinely need the integer index for something other than `lst[i]` access.*

**When you DO need `range(len(lst))`:**
1. **Modifying list in place by index:** `lst[i] = lst[i] * 2`
2. **Comparing adjacent items:** `if lst[i] > lst[i+1]:`
3. **Skipping ahead by index dynamically:** `i += custom_step`
4. **Two-pointer style:** independent left and right indices

**Drill — refactor each (cold):**
1. `for i in range(0, len(lst), 1): print(lst[i])` — refactor.
2. `for i in range(len(words)): print(f"{i}: {words[i]}")` — refactor.
3. `for i in range(len(a)): result.append(a[i] + b[i])` — refactor.
4. `for i in range(len(d)): key = list(d.keys())[i]; print(key, d[key])` — refactor (this is especially bad).
5. `[x for x in lst]` — refactor.

### D.5 — Critical traps (drill cold) (10 min)

**Trap 1 — Filter vs if/else position:**
```python
# Filter (drops some)
[x for x in nums if x > 0]

# Ternary (transforms all)
[x if x > 0 else 0 for x in nums]
```

**Trap 2 — Nested comp reading order:**
Outer `for` is leftmost. So this:
```python
[(i, j) for i in range(3) for j in range(2)]
```
Is equivalent to:
```python
result = []
for i in range(3):
    for j in range(2):
        result.append((i, j))
```

**Trap 3 — Generator exhaustion:**
```python
g = (x for x in range(5))
sum(g)    # → 10
sum(g)    # → 0   (exhausted!)
```

**Trap 4 — Dict comp duplicate keys:**
```python
{x % 3: x for x in range(10)}   # last write wins per key
```

**Trap 5 — Set comp on unhashables:**
```python
{[1,2] for _ in range(3)}    # TypeError
```

**Drill — predict each, verify.**

---

## 🎁 Block E — Wrap Block: Functions + MatrixOps Class (1.5 hr)

### E.1 — Comprehension-native functions (45 min)

**Drill — write each as a function. Use comp where appropriate, regular loop where not.**

1. **`squares_of_evens(lst)`** — `[x**2 for x in lst if x % 2 == 0]`
2. **`flatten(matrix)`** — nested comp: `[item for row in matrix for item in row]`
3. **`transpose(matrix)`** — using `zip(*matrix)` and converting to list-of-lists
4. **`pythagorean_triples(n)`** — return all `(a, b, c)` with `a < b < c <= n` and `a² + b² == c²`. Triple-nested comp.
5. **`dict_from_pairs(keys, values)`** — `dict(zip(keys, values))`
6. **`invert_safely(d)`** — handles duplicate values, returns `defaultdict(list)`
7. **`is_prime(n)`** — uses `range(int(n**0.5) + 1)`
8. **`factor_pairs(n)`** — `(a, b)` where `a*b == n`, using √n loop
9. **`element_wise_sum(a, b)`** — `[x + y for x, y in zip(a, b)]`
10. **`indices_where(lst, predicate)`** — `[i for i, x in enumerate(lst) if predicate(x)]` (higher-order!)

**Function discipline checklist:**
- ✅ Empty input handled
- ✅ Returns, doesn't print
- ✅ Comp used where it's clearer; regular loop where it's not (judgment call drilled)
- ✅ Higher-order function (#10) uses a callable parameter — preview of Day 5

### E.2 — `MatrixOps` class (45 min)

**When the class makes sense:** matrix operations chained on the same data. Storing the matrix once, applying many transformations.

```python
class MatrixOps:
    def __init__(self, data):
        # data is a list of equal-length lists.
        self.data = data
        self.rows = len(data)
        self.cols = len(data[0]) if data else 0
    
    def transpose(self):
        # Return new MatrixOps with transposed data. Use zip + comp.
        ...
    
    def flatten(self):
        # Return 1D list of all elements (row-major).
        ...
    
    def row_sums(self):
        # List of sums per row. Use comp.
        ...
    
    def col_sums(self):
        # List of sums per col. Use comp + zip.
        ...
    
    def element_wise(self, func):
        # Apply func to every cell, return new MatrixOps. Nested comp.
        ...
    
    def add(self, other):
        # Element-wise add another MatrixOps of same shape. Use zip + nested comp.
        ...
    
    def scalar_multiply(self, k):
        # Multiply every element by k. Use element_wise internally.
        ...
    
    def diagonal(self):
        # Return main diagonal as a list. Comp with enumerate.
        ...
    
    def is_square(self):
        # True if rows == cols.
        ...
```

**Drill: Build all 9 methods.**

**Test data:**
```python
m = MatrixOps([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
m.transpose().data       # → [[1,4,7], [2,5,8], [3,6,9]]
m.flatten()              # → [1,2,3,4,5,6,7,8,9]
m.row_sums()             # → [6, 15, 24]
m.col_sums()             # → [12, 15, 18]
m.element_wise(lambda x: x**2).data   # → [[1,4,9], [16,25,36], [49,64,81]]
m.diagonal()             # → [1, 5, 9]
m.is_square()            # → True
```

**Class discipline:**
- ✅ Methods that return matrices return new `MatrixOps` instances (immutability discipline)
- ✅ Methods that return lists/scalars return plain values
- ✅ `lambda` in `element_wise` previews Day 5 higher-order patterns

---

## 🏆 Block F — Day 4 Mini-Boss (30 min)

**Cold attempts. No notes from this chat. Each problem stands alone.**

### Mini-Boss A — Translate 5 Loops to Comprehensions

For each loop below, write the equivalent comprehension (or comp + builtin like `sum`/`max`).

**Loop 1:**
```python
result = []
for x in range(20):
    if x % 3 == 0:
        result.append(x ** 2)
```

**Loop 2:**
```python
total = 0
for x in nums:
    if x > 0:
        total += x
```

**Loop 3:**
```python
pairs = []
for i in range(5):
    for j in range(5):
        if i != j:
            pairs.append((i, j))
```

**Loop 4:**
```python
upper_vowels = ""
for c in text:
    if c in "aeiouAEIOU":
        upper_vowels += c.upper()
```

**Loop 5:**
```python
freq = {}
for word in words:
    if word not in freq:
        freq[word] = 0
    freq[word] += 1
# (Note: comp can't fully replace this; use Counter. Discuss why.)
```

**Tests:** Comprehension fluency, `sum`/`max` builtins, dict comp limits.

### Mini-Boss B — `is_prime(n)`

Write `is_prime(n)` using `range(int(n**0.5) + 1)`. Handle edge cases.

```python
is_prime(1)        # → False
is_prime(2)        # → True
is_prime(3)        # → True
is_prime(4)        # → False
is_prime(17)       # → True
is_prime(49)       # → False  (49 = 7*7 — must catch)
is_prime(97)       # → True
is_prime(0)        # → False
is_prime(-5)       # → False
```

**Tests:** Range Tier 6 legitimate use, √n bound reasoning, edge cases (n < 2).

### Mini-Boss C — `pythagorean_triples(n)`

Write `pythagorean_triples(n)` returning all triples `(a, b, c)` where `a < b < c <= n` and `a² + b² == c²`. Use a triple-nested comprehension.

```python
pythagorean_triples(20)
# → [(3, 4, 5), (5, 12, 13), (6, 8, 10), (8, 15, 17), (9, 12, 15)]
# (order can vary by definition of nested comp)

pythagorean_triples(5)
# → [(3, 4, 5)]

pythagorean_triples(2)
# → []
```

**Tests:** Triple-nested comp (Form 6 + 7), filter on combination, edge cases.

---

## 🚦 Day 4 Pass/Fail Rules

**3-strike rule per drill problem:**
- 1st miss → diagnosis hint
- 2nd miss → structural hint (skeleton with blanks)
- 3rd miss → I show full solution + you re-attempt fresh

**Mini-boss pass condition:**
- All 3 mini-boss problems correct cold OR with at most 1 self-corrected bug per problem
- If hints needed on more than one → loop back to Block B (translation drills) before Day 5

---

## 📋 Day 4 Tracker Recap (paste into progress_tracker.md)

```
Day 4 of Loop Week — Comprehensions + Phase 3b L7 (Range Mastery)

Locked:
- 8-form comprehension ladder (basic → nested loops with filter)
- Filter vs if/else distinction (the position trap)
- Dict / set / generator comprehensions
- Translation drills: Day 1-3 loops compressed to comp
- zip() fundamentals + zip inside comp
- enumerate inside comp
- Parallel iteration (lockstep, opposite-direction, 3+ way)
- Range Tier 5 — multi-variable (zip + range)
- Range Tier 6 legitimate — √n bound (is_prime, factor_pairs)
- Range Tier 6 exotic — recognize, don't use
- 5 anti-patterns + when range(len(lst)) is justified
- 5 comp traps (filter/ternary, nesting order, gen exhaustion, dup keys, unhashables)
- 10 functions wrapping comp logic
- MatrixOps class with 9 methods using comp/zip internally

Mini-boss results:
- Translate 5 loops: ✓/✗
- is_prime: ✓/✗
- pythagorean_triples: ✓/✗

Weak spots flagged: [fill in]
Tomorrow's bridge: Functions DEEP + Phase 3b L5 + L6 (while family + traps)
```

---

## 🧠 Day 4 Memory Hooks

- *"`if` AFTER for = filter (drops). `if/else` BEFORE for = ternary (transforms)."*
- *"Outer loop = leftmost for. Same as nested loop top-down reading."*
- *"Past 2 clauses → break into a regular loop. Pythonic ≠ one-line."*
- *"`range(len(lst))` — only when you genuinely need the integer index for something other than `lst[i]`."*
- *"`enumerate` if you need index. `zip` if you need parallel. Both if you need both."*
- *"√n bound: if `n = a*b`, at least one of `a,b` is ≤ √n. So range stops at `int(n**0.5) + 1`."*
- *"Dict comp duplicate keys silently overwrite. Set comp crashes on unhashables. Gen exhausts after one pass."*
- *"`{}` is empty dict, `set()` is empty set, `()` is empty tuple, `[]` is empty list. Lock the syntax."*

---

## 🔮 What unlocks after Day 4

- Day 5 (Functions DEEP) — higher-order patterns (map/filter/reduce, function-returns-function) build on comp fluency
- Day 6 (Mini-problems) — many problems compress to 1-3 lines with comprehensions
- Week 4+ — `pandas` / `numpy` use vectorized operations that mirror comprehension thinking
- Week 5 — full Sieve of Eratosthenes builds on today's prime-check skills
- Throughout the bootcamp — Pythonic style is mostly comprehensions used judiciously

---

*End of Day 4 curriculum. Brainstorm complete. Ready to lock or refine.*
