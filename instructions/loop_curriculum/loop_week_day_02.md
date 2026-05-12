# 🔁 Loop Week — Day 2: Dicts, Sets & Pattern Stacking in Nested Loops

> **Theme:** Lock loop fluency on hashed structures. Dicts and sets aren't lists — they don't preserve order in the same way, they hash for O(1) lookup, and they unlock pattern combinations that turn O(n²) brute force into O(n) elegance. End the day able to reach for a dict or set the moment you see a frequency, lookup, or "have I seen this?" question.
>
> **Time budget:** 6-7 focused hours
>
> **Phase 3b coverage:** L3 (Pattern stacking inside nested + Range Tier 3 introduction)
>
> **Mini-boss:** Pair counter (upper-triangular) + frequency top-3 + anagram grouper, all cold

---

## 🎯 Day 2 Learning Goals

By end of day, you should be able to **without notes**:

1. Pick the right structure cold — list / tuple / dict / set — given any problem
2. Walk a dict in all 3 forms (keys, values, items) and a set fluently
3. Use every dict method correctly (`.get()`, `.setdefault()`, `.update()`, `.pop()`, `.items()`, etc.)
4. Use set operations (union, intersection, difference, symmetric difference) on real data
5. Apply Counter / defaultdict naturally — know which to reach for and why
6. Build a frequency dict cold in 30 seconds
7. Group items by some key (anagram-style) cold
8. Solve two-sum with hash in O(n) — and know exactly why it's faster than nested loops
9. Spot hashability traps (lists/dicts as keys → TypeError)
10. Stack patterns inside nested loops — Counter / Search / Tracker on 2D
11. Use `range(i+1, n)` for unique unordered pairs (no double-counting)
12. Wrap dict-heavy logic in functions and stateful classes (Inventory pattern)

---

## 🗓 Day 2 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Morning** | 1.5 hr | Dict + Set fundamentals, methods, hashability, decision framework |
| **Block B — Midday** | 1.5 hr | Loop forms × dicts/sets + 5 native patterns (frequency, grouping, lookup, invert, membership) |
| **Block C — Afternoon** | 2 hr | Phase 3b L3 — Pattern stacking inside nested + Range Tier 3 intro |
| **Block D — Wrap Block** | 1.5 hr | Functions + Inventory class wrapping dict state |
| **Block E — Evening Mini-Boss** | 30 min | Pair counter + freq top-3 + anagram grouper, cold |

Total: ~7 hours. Adjust breaks as needed.

---

## 📚 Block A — Dict & Set Fundamentals (1.5 hr)

### A.1 — Dict creation & access (20 min)

**Topics:**
- Literal: `{"a": 1, "b": 2}`
- Empty: `{}` (NOT a set — `set()` is the empty set)
- `dict()` constructor: `dict(a=1, b=2)`, `dict([("a", 1), ("b", 2)])`
- **`dict(zip(keys, values))`** — idiom for parallel lists → dict
- Dict comprehension: `{k: v for ... }` (deep on Day 4)
- Access: `d[key]` (raises `KeyError` if missing) vs `.get(key)` (returns `None`) vs `.get(key, default)` (returns default)
- Adding / updating: `d[key] = value`, `.update(other_dict)`
- Deleting: `del d[key]`, `.pop(key)`, `.pop(key, default)`, `.popitem()` (last inserted)

**Drill problems:**
1. Build a dict from `keys = ["a", "b", "c"]` and `values = [1, 2, 3]` using `dict(zip(...))`.
2. Given `d = {"x": 10, "y": 20}`, demonstrate the difference between `d["z"]`, `d.get("z")`, and `d.get("z", 0)`.
3. Given `d = {"a": 1}`, predict: what does `d.update({"a": 99, "b": 2})` produce? Confirm.

### A.2 — Dict methods deep (20 min)

**Topics:**
- `.keys()` — view of keys
- `.values()` — view of values
- `.items()` — view of `(key, value)` pairs
- **View objects are LIVE** — modify dict, view auto-updates
- `.setdefault(key, default)` — get-or-create idiom
- `.update(other)` — merge another dict in (later wins)
- `.pop(key)` — remove + return
- `.copy()` — shallow copy

**Drill problems:**
1. Show view-object liveness: `keys = d.keys(); d["new"] = 5; print(keys)` — predict before running.
2. Use `.setdefault("counts", []).append(1)` — explain what this does in one line.
3. Given two dicts with overlapping keys, predict which value survives `.update()`.

### A.3 — Set fundamentals (15 min)

**Topics:**
- Creation: `{1, 2, 3}`, `set()` (empty — `{}` is dict!), `set([1, 2, 2, 3])` (auto-dedupes)
- `.add(x)`, `.remove(x)` (raises if missing), `.discard(x)` (silent if missing)
- Set ops: union `|`, intersection `&`, difference `-`, symmetric difference `^`
- Method forms: `.union()`, `.intersection()`, `.difference()`, `.symmetric_difference()`
- **`frozenset`** — immutable set, hashable, can be a dict key or element of another set

**Drill problems:**
1. Create two sets `a = {1, 2, 3, 4}` and `b = {3, 4, 5, 6}`. Compute all 4 ops, predict each.
2. Try `s = set(); s.add([1, 2])` — predict the error, confirm.
3. Try `outer = {frozenset([1, 2]), frozenset([3, 4])}` vs `outer = {{1, 2}, {3, 4}}` — predict which works.

### A.4 — `collections` module (15 min)

**Topics:**
- **`Counter`** — frequency dict on steroids
  - `Counter(iterable)` builds frequency map
  - `.most_common(n)` returns top n as `[(item, count), ...]`
  - Arithmetic: `Counter("aabb") + Counter("ab")` works
  - Counter on empty input → empty Counter (not crash)
- **`defaultdict`** — auto-create missing keys
  - `defaultdict(int)` → missing key auto-becomes `0`
  - `defaultdict(list)` → missing key auto-becomes `[]`
  - `defaultdict(set)` → missing key auto-becomes `set()`
- **When `defaultdict` vs regular dict + `.get()`:**
  - `defaultdict` for "build it up" patterns (grouping, frequency)
  - `dict + .get()` when you don't want missing keys to silently create

**Drill problems:**
1. Build a frequency dict from `"hello world"` two ways: regular dict + `.get()`, then `Counter`.
2. Use `defaultdict(list)` to group `["apple", "ant", "banana", "bear"]` by first letter.
3. `defaultdict(int)` masking bug: write code where auto-creation hides a logic error.

### A.5 — Hashability + decision framework (15 min)

**Topics:**
- **What's hashable:** `int`, `float`, `str`, `tuple` (of hashables), `frozenset`, `None`, `bool`
- **What's NOT hashable:** `list`, `dict`, `set`
- Why: hashable = immutable + has `__hash__()`. Mutables can't be safely keyed.
- Tuples-of-tuples work as dict keys; tuples-containing-lists don't.

**Decision framework — the lock-in:**

| Need | Pick |
|---|---|
| Order matters + duplicates allowed + mutable | **List** |
| Order matters + immutable + fixed record | **Tuple** |
| Key→value lookup, O(1) | **Dict** |
| Uniqueness + fast membership, O(1) | **Set** |
| Frequency counting | **Counter** (or dict) |
| Grouping/bucketing | **defaultdict(list)** |

**Drill problems:**
1. For each: which structure? (a) "track scores by student name" → ?, (b) "list of all unique IPs that visited" → ?, (c) "preserve order of products in a cart, allow duplicates" → ?, (d) "store an immutable (lat, lon) coordinate" → ?
2. Try `d = {[1, 2]: "value"}` — predict the error.
3. Try `d = {(1, 2): "value"}` — predict that this works.

### A.6 — Critical traps (5 min)

**Topics (preview, drilled later):**
- Modifying dict during iteration → `RuntimeError: dictionary changed size during iteration`
- `defaultdict` masking bugs (silent key creation)
- `{}` is empty dict, NOT empty set — `set()` for empty set
- Dict ordering guaranteed (insertion order) since Python 3.7+ — relied upon, but don't assume in older code

---

## 🔄 Block B — Loop Forms × Dicts/Sets + Five Native Patterns (1.5 hr)

### B.1 — Walking dicts and sets (20 min)

**Three ways to walk a dict** — drill all three on the same problem:

```python
d = {"apple": 3, "banana": 5, "cherry": 2}
```

**Form 1 — keys (default):**
```python
for key in d:
    print(key, d[key])
```

**Form 2 — values only:**
```python
for value in d.values():
    print(value)
```

**Form 3 — items (the workhorse):**
```python
for key, value in d.items():
    print(f"{key}: {value}")
```

**Walking a set** (no order guarantee):
```python
s = {3, 1, 4, 1, 5, 9}
for x in s:
    print(x)
```

**Lock-in:** Print "fruit costs $X" for each fruit in `d` using all 3 dict forms. Same output, three roads.

### B.2 — Five native dict/set patterns (50 min)

**Pattern 1 — Frequency Counting (10 min)**

The single most common dict use. Build a count of how often each thing appears.

Three flavors:
```python
# Flavor A — manual with .get()
counts = {}
for char in "hello world":
    counts[char] = counts.get(char, 0) + 1

# Flavor B — defaultdict
from collections import defaultdict
counts = defaultdict(int)
for char in "hello world":
    counts[char] += 1

# Flavor C — Counter (the most Pythonic)
from collections import Counter
counts = Counter("hello world")
```

**Drills:**
1. Count letter frequency in `"banana"`. Predict: which letter most common?
2. Count word frequency in `"the quick brown fox jumps over the lazy dog the"`. Top 3?
3. Same drill three times — once with `.get()`, once with `defaultdict`, once with `Counter`. Verify identical output.

**Pattern 2 — Grouping (10 min)**

Bucket items by some computed key.

```python
from collections import defaultdict

words = ["apple", "ant", "banana", "bear", "cherry"]
by_first_letter = defaultdict(list)
for word in words:
    by_first_letter[word[0]].append(word)
# {"a": ["apple", "ant"], "b": ["banana", "bear"], "c": ["cherry"]}
```

**Drills:**
1. Group `["cat", "dog", "elephant", "ant", "bird"]` by length.
2. Group `[3, 1, 4, 1, 5, 9, 2, 6, 5, 3]` into evens vs odds (parity as key).
3. Group `["apple", "banana", "cherry", "date", "fig", "grape"]` by first letter.

**Pattern 3 — Lookup Table (10 min)**

Dict replacing a long if/elif chain. Cleaner, faster, easier to extend.

```python
# Bad — if/elif chain
def get_day_name(n):
    if n == 0: return "Mon"
    elif n == 1: return "Tue"
    elif n == 2: return "Wed"
    # ...

# Good — lookup table
DAY_NAMES = {0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sat", 6: "Sun"}
def get_day_name(n):
    return DAY_NAMES.get(n, "Unknown")
```

**Drills:**
1. Build a vowel→capital-vowel lookup. Use it inside a loop to capitalize only vowels in a word.
2. Build a Roman-numeral-piece lookup (`I=1, V=5, X=10, ...`). Use it to read a single Roman digit.
3. Build a grade lookup (`'A': 90, 'B': 80, ...`). Convert a list of letter grades to numbers.

**Pattern 4 — Inverting a Dict (10 min)**

Swap keys and values.

```python
d = {"a": 1, "b": 2, "c": 3}
inverted = {v: k for k, v in d.items()}
# {1: "a", 2: "b", 3: "c"}
```

**Critical trap:** If values aren't unique, inversion silently loses data.

**Drills:**
1. Invert `{"red": "#f00", "green": "#0f0", "blue": "#00f"}`.
2. Try inverting `{"a": 1, "b": 1, "c": 2}` — predict what `1` maps to in the result.
3. Build an inverse-safe inverter that returns `defaultdict(list)` so duplicate values don't lose data.

**Pattern 5 — Membership Testing (10 min)**

Sets shine here. O(1) lookup vs O(n) for lists.

```python
# Slow — O(n) per check
def find_duplicates_slow(lst):
    seen = []
    duplicates = []
    for x in lst:
        if x in seen:           # O(n) — searches list
            duplicates.append(x)
        else:
            seen.append(x)
    return duplicates

# Fast — O(1) per check
def find_duplicates_fast(lst):
    seen = set()
    duplicates = []
    for x in lst:
        if x in seen:           # O(1) — hash lookup
            duplicates.append(x)
        else:
            seen.add(x)
    return duplicates
```

**Drills:**
1. Find all duplicates in `[1, 2, 3, 2, 4, 1, 5]`. Use a set.
2. Find all elements in `lst1` that aren't in `lst2`. (Hint: `set(lst1) - set(lst2)`)
3. Two-sum preview: given `nums = [2, 7, 11, 15]` and `target = 9`, find indices using a dict (don't nest loops). Drilled deeper in Block C.

### B.3 — Two-sum hash trick (the mindset shift) (20 min)

This is THE pattern that breaks the O(n²) habit. Lock it.

**Brute force (O(n²)):**
```python
def two_sum_brute(nums, target):
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] + nums[j] == target:
                return (i, j)
    return None
```

**Hash-map (O(n)):**
```python
def two_sum_hash(nums, target):
    seen = {}                          # value → index
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:         # O(1) lookup
            return (seen[complement], i)
        seen[num] = i
    return None
```

**The mental model:** *"As I walk the list, I remember what I've seen. For each new number, I ask: did I see its complement before? If yes, I'm done."*

**Drills:**
1. Run two_sum_hash on `[2, 7, 11, 15]` with target `9`. Trace the dict at each step.
2. Modify to return all pairs (not just first). What changes?
3. Why does this break if you add to `seen` BEFORE checking?

---

## 🪜 Block C — Phase 3b L3: Pattern Stacking Inside Nested + Range Tier 3 (2 hr)

### C.1 — The mental shift (10 min)

You already know: Counter / Search / Tracker / Filter / Accumulator (Day 1 patterns).

Now: those patterns live INSIDE nested loops. The accumulator/counter variable is declared OUTSIDE both loops, updates inside. Scope matters.

```python
# Counter outside, updates inside nested
count = 0
for i in range(n):
    for j in range(m):
        if some_condition(i, j):
            count += 1
print(count)
```

**The trap to flag now:** Where you put the counter declaration changes everything.
- Outside both loops → counts across the whole grid
- Between outer and inner → resets per outer iteration (per-row count)
- Inside inner → resets every iteration (always 0 or 1, useless)

### C.2 — Counter inside nested (15 min)

**Drill problems:**
1. Given a 5×5 grid, count cells where `i + j` is even.
2. Given `nums = [1, 2, 3, 4, 5, 6]`, count pairs `(i, j)` where `i < j` and `nums[i] + nums[j]` is even.
3. Given two lists `a = [1,2,3]` and `b = [3,4,5]`, count pairs `(x, y)` where `x + y > 5`.

### C.3 — Search inside nested (15 min)

Find the FIRST matching pair. Requires `break` to exit inner; flag pattern to exit outer.

```python
found = False
for i in range(n):
    for j in range(m):
        if condition(i, j):
            print(f"Found at ({i}, {j})")
            found = True
            break
    if found:
        break
```

**Drill problems:**
1. Given a 2D matrix, find the first cell containing `target`. Return `(row, col)` or `(-1, -1)`.
2. Given `nums = [3, 1, 4, 1, 5, 9, 2, 6]`, find the first pair `(i, j)` where `i < j` and `nums[i] + nums[j] == 10`.
3. Refactor problem 2 using a function with early `return` — much cleaner than flag-and-break.

### C.4 — Tracker inside nested (15 min)

Track max/min/best across all pairs.

```python
max_sum = float('-inf')
best_pair = (-1, -1)
for i in range(n):
    for j in range(i+1, n):     # upper-triangular!
        s = nums[i] + nums[j]
        if s > max_sum:
            max_sum = s
            best_pair = (i, j)
```

**Drill problems:**
1. Given `nums = [1, 4, 2, 8, 5, 3]`, find the pair with maximum product.
2. Same input, find pair with minimum absolute difference.
3. Given two lists, find the cross-pair with closest sum to a target.

### C.5 — Range Tier 3 introduction (15 min)

The variable-inner-range forms. Drilled deep on Days 3-4, introduced here.

| Form | Use case | Iteration count |
|---|---|---|
| `range(i)` | inner shorter than outer | 0+1+2+...+(n-1) = n(n-1)/2 |
| `range(i+1)` | inner equals outer length so far | 1+2+...+n = n(n+1)/2 |
| `range(i+1, n)` | unique unordered pairs (j > i) | n(n-1)/2 |
| `range(i, n)` | pairs including self | n(n+1)/2 |

**Trace each cold:**
```python
# Trace this on paper, no running:
for i in range(4):
    for j in range(i+1, 4):
        print(i, j)
```
Expected: `(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)` — 6 pairs.

**Drill problems:**
1. Trace `for i in range(3): for j in range(i):` — predict every output line.
2. Trace `for i in range(4): for j in range(i, 4):` — note this includes self-pairs.
3. Difference between `range(i+1, n)` and `range(i, n)` — explain in one sentence.

### C.6 — Upper-triangular pair iteration (deep) (20 min)

This is THE form for "count/find pairs without double-counting."

**The skeleton:**
```python
for i in range(n):
    for j in range(i + 1, n):
        # process pair (lst[i], lst[j])
```

**Why `i+1` not `i`:** Skips self-pairs. Why `j > i` not `j != i`: avoids `(2,5)` and `(5,2)` both counting.

**Drill problems:**
1. Given `nums = [1, 5, 7, -1, 5]` and target `6`, count unique pairs (by index) summing to target.
2. Given a list of points `[(x1,y1), (x2,y2), ...]`, find the closest pair (minimum distance).
3. Given a list of strings, find pairs that are anagrams of each other.

### C.7 — Counter outside vs inside (10 min)

The scope trap. Drill it.

```python
# A — Counter OUTSIDE both: total across grid
count = 0
for i in range(n):
    for j in range(m):
        if cond: count += 1

# B — Counter BETWEEN: per-row, prints n times
for i in range(n):
    count = 0
    for j in range(m):
        if cond: count += 1
    print(f"Row {i}: {count}")

# C — Counter INSIDE inner: resets every iteration, useless
for i in range(n):
    for j in range(m):
        count = 0
        if cond: count += 1   # always 0 or 1, never accumulates
```

**Drill problems:**
1. Predict: 3×3 grid, count cells where `i == j`. Counter outside both — what's the total?
2. Same grid, counter between — what gets printed for each row?
3. Spot the bug: code with counter declared in wrong scope — fix it.

### C.8 — Edge cases (10 min)

**Topics:**
- Empty list: `for i in range(len([]))` → no iterations
- Single-element list: nested with `range(i+1, n)` → 0 inner iterations
- All-equal elements: pair-counting still works, every pair "matches"
- `range(0, 5, -1)` → empty (direction mismatch)
- Modifying dict during iteration → `RuntimeError`

**Drill problems:**
1. Run upper-triangular pair counter on empty list. Should return 0, not crash.
2. Run on single-element list. Same — return 0.
3. Predict: `d = {1: 'a', 2: 'b'}; for k in d: del d[k]` — what happens?

---

## 🎁 Block D — Wrap Block: Functions + Inventory Class (1.5 hr)

### D.1 — Functions wrapping dict/set logic (45 min)

**Convert every Block B pattern to a function. Discipline rules from Day 1 still apply:**
- Take input as parameter
- Return result (don't print inside)
- Don't modify input dict/list
- Clear parameter names

**Drill problems — write each as a function:**

1. **`word_frequency(text)`** — return `dict` of word → count.
2. **`group_by_length(words)`** — return `dict` of length → list of words.
3. **`invert_dict(d)`** — return `dict` with keys/values swapped (assume unique values).
4. **`safe_invert_dict(d)`** — return `defaultdict(list)` handling duplicate values.
5. **`find_intersection(d1, d2)`** — return dict of keys present in both dicts (with values from `d1`).
6. **`top_n_frequent(items, n)`** — return list of n most common items (uses `Counter.most_common`).
7. **`first_non_repeating(text)`** — return first character that appears exactly once, or `None`.
8. **`group_anagrams(words)`** — return list of lists, each inner list is a group of anagrams.
9. **`two_sum(nums, target)`** — return `(i, j)` indices using hash trick (O(n)).
10. **`count_pairs_summing_to(nums, target)`** — count unique pairs (uses upper-triangular nested).

**Function discipline checklist — verify each:**
- ✅ Input as parameter
- ✅ Returns, doesn't print
- ✅ Doesn't modify caller's data
- ✅ Handles empty input gracefully

### D.2 — `Inventory` class (45 min)

**When a class beats a function:** State persists across operations. Inventory keeps growing/shrinking. Methods share the same `self.items`.

**Build this:**

```python
from collections import Counter

class Inventory:
    def __init__(self):
        self.items = []     # list of item names (strings)
    
    def add(self, item):
        # Append an item.
        ...
    
    def remove(self, item):
        # Remove first occurrence. Raise ValueError if not found.
        ...
    
    def count(self, item):
        # Return how many of `item` are present.
        ...
    
    def total(self):
        # Return total number of items.
        ...
    
    def unique_items(self):
        # Return a set of unique item names.
        ...
    
    def most_common(self, n=1):
        # Return list of (item, count) tuples for top n. Uses Counter.
        ...
    
    def has(self, item):
        # Return True if item is present (uses set for O(1)).
        ...
    
    def merge(self, other):
        # Add all items from another Inventory into self.
        ...
```

**Drill: build all 8 methods.** Each method internally uses one of the patterns from Block B (frequency, grouping, membership, etc.).

**Test data:**
```python
inv = Inventory()
inv.add("apple")
inv.add("banana")
inv.add("apple")
inv.add("cherry")
inv.add("apple")

inv.count("apple")          # → 3
inv.total()                 # → 5
inv.unique_items()          # → {"apple", "banana", "cherry"}
inv.most_common(2)          # → [("apple", 3), ("banana", 1)]
inv.has("dragonfruit")      # → False
```

**Class discipline checklist:**
- ✅ Methods operate on `self.items`, not external data
- ✅ `__init__` stores, doesn't process
- ✅ Methods return values; no printing inside
- ✅ Internal use of `Counter` / `set` / dict is implementation detail — caller doesn't need to know

---

## 🏆 Block E — Day 2 Mini-Boss (30 min)

**Cold attempts. No notes from this chat. Each problem stands alone.**

### Mini-Boss A — Pair Counter (Upper-Triangular)

Write `count_pairs_summing_to(nums, target)` that returns the count of unique unordered pairs (by index) where elements sum to target. Use upper-triangular iteration (`range(i+1, n)`).

```python
count_pairs_summing_to([1, 2, 3, 4, 5, 6], 7)        # → 3 — pairs (1,6), (2,5), (3,4)
count_pairs_summing_to([3, 3, 3, 3], 6)              # → 6 — every pair counts
count_pairs_summing_to([1, 2, 3], 100)               # → 0
count_pairs_summing_to([], 5)                        # → 0
count_pairs_summing_to([5], 10)                      # → 0
```

**Tests:** Phase 3b L3 (Counter inside nested, upper-triangular range), function discipline.

### Mini-Boss B — Frequency Top-3

Write `top_3_chars(text)` that returns the top 3 most frequent characters in `text`, ignoring spaces. Return as list of `(char, count)` tuples in descending order. Use `Counter`.

```python
top_3_chars("the quick brown fox jumps over the lazy dog")
# → [("o", 4), ("e", 3), ("h", 2)]   (or similar, tied counts can vary)

top_3_chars("aabbcc")
# → [("a", 2), ("b", 2), ("c", 2)]

top_3_chars("")
# → []
```

**Tests:** Counter pattern, `most_common`, edge case (empty input).

### Mini-Boss C — Anagram Grouper

Write `group_anagrams(words)` that takes a list of words and returns a list of groups, where each group is a list of words that are anagrams of each other. Use a dict with sorted-string-as-key.

```python
group_anagrams(["eat", "tea", "tan", "ate", "nat", "bat"])
# → [["eat", "tea", "ate"], ["tan", "nat"], ["bat"]]
# (group order can vary; word order within groups can vary)

group_anagrams([])
# → []

group_anagrams(["abc"])
# → [["abc"]]
```

**Tests:** Grouping pattern + dict + sorting as key trick. Use of `defaultdict(list)` is the natural form.

---

## 🚦 Day 2 Pass/Fail Rules

**3-strike rule per drill problem (carries from Day 1):**
- 1st miss → diagnosis hint
- 2nd miss → structural hint (skeleton with blanks)
- 3rd miss → I show full solution + you re-attempt fresh

**Mini-boss pass condition:**
- All 3 mini-boss problems correct cold OR with at most 1 self-corrected bug per problem
- If hints needed on more than one → loop back to Block C (pattern stacking) before Day 3

---

## 📋 Day 2 Tracker Recap (paste into progress_tracker.md)

```
Day 2 of Loop Week — Dicts, Sets + Phase 3b L3 (Pattern Stacking)

Locked:
- 3 ways to walk a dict (keys, values, items)
- 5 native dict/set patterns (frequency, grouping, lookup, invert, membership)
- Counter / defaultdict — when to use which
- Hashability + decision framework (list/tuple/dict/set)
- Two-sum hash trick (O(n) vs O(n²))
- Pattern stacking inside nested (Counter, Search, Tracker)
- Upper-triangular iteration (range(i+1, n))
- Range Tier 3 introduction
- Functions wrapping dict logic (10 functions)
- Inventory class with 8 methods using dict/set internally

Mini-boss results:
- count_pairs_summing_to: ✓/✗
- top_3_chars: ✓/✗
- group_anagrams: ✓/✗

Weak spots flagged: [fill in]
Tomorrow's bridge: Strings + Phase 3b L4 + L4.5 (variable-width shapes, pyramids, diamonds)
```

---

## 🧠 Day 2 Memory Hooks

- *"`{}` is empty dict, NOT empty set. Use `set()` for empty set."*
- *"`d.get(key)` returns None on miss; `d[key]` crashes."*
- *"`Counter` for frequency, `defaultdict(list)` for grouping, `set` for membership."*
- *"Hashable = immutable. Lists fail; tuples work; frozensets work."*
- *"Two-sum hash: as you walk the list, remember what you've seen. Ask: did I see the complement?"*
- *"`range(i+1, n)` = upper triangle = unique unordered pairs, no double count."*
- *"View objects are LIVE — modify the dict, the view updates."*
- *"Counter outside both loops = total. Between = per-row. Inside inner = useless."*

---

## 🔮 What unlocks after Day 2

- Day 3 (Strings) — char-level frequency / anagram detection becomes natural with Day 2 patterns
- Day 4 (Comprehensions) — dict and set comprehensions build on dict literacy from today
- Day 6 (Mini-problems) — frequency / grouping / membership problems are now fast
- Phase 3b L4-L4.5 (next day) — variable-width shapes build on the upper-triangular pattern locked today
- Week 4 onward — hash-map problems on LeetCode become routine

---

*End of Day 2 curriculum. Brainstorm complete. Ready to lock or refine.*
