# 🔁 Loop Week — Day 3: Strings & Variable-Width Shapes

> **Theme:** The deepest day of the week. Strings are the most loop-rich data type in Python — most methods, most edge cases, most interview problems. Immutability forces accumulator fluency. Two-pointer technique gets its first real workout. By end of day, you should be able to walk a string in any direction with any technique, build run-length encoders cold, and draw triangles, pyramids, and diamonds without notes.
>
> **Time budget:** 7-8 focused hours (densest day — budget extra)
>
> **Phase 3b coverage:** L4 (Variable-width shapes) + L4.5 (Pyramid/Diamond)
>
> **Mini-boss:** Diamond cold + clean palindrome + run-length encoder

---

## 🎯 Day 3 Learning Goals

By end of day, you should be able to **without notes**:

1. Walk a string using char loop, index loop, enumerate, while+index, or two-pointer
2. Use every essential string method correctly (split/join, strip, find/index, replace, predicates)
3. Slice strings in any direction with positive/negative indices and steps
4. Spot the immutability-induced O(n²) trap (`+=` in long loops) and fix it with `"".join()`
5. Reverse a string 4 ways: slicing, accumulator, two-pointer, prepend
6. Detect palindromes — basic, then case-insensitive ignoring punctuation
7. Build run-length encoding cold
8. Use `ord` and `chr` for ASCII-based tricks (Caesar cipher, shift problems)
9. Print right triangles (left/right aligned, inverted) of any height
10. Print centered pyramids and diamonds using the two-loop-per-row pattern
11. Cross-pollinate with Day 2 — use frequency dicts and sets inside string problems
12. Wrap string logic in functions and a `StringAnalyzer` class

---

## 🗓 Day 3 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Morning** | 1.5 hr | String fundamentals + slicing + immutability + methods deep |
| **Block B — Midday** | 1.5 hr | Loop forms × strings + 5 native string patterns |
| **Block C — Afternoon Part 1** | 1.5 hr | Phase 3b L4 — Variable-width shapes (triangles) |
| **Block D — Afternoon Part 2** | 1 hr | Phase 3b L4.5 — Pyramid + Diamond |
| **Block E — Wrap Block** | 1.5 hr | Functions + StringAnalyzer class |
| **Block F — Evening Mini-Boss** | 30 min | Diamond + clean palindrome + run-length encoder, cold |

Total: ~7.5 hours. The most demanding day — pace yourself.

---

## 📚 Block A — String Fundamentals (1.5 hr)

### A.1 — Creation & immutability (15 min)

**Topics:**
- Literal: `"hello"`, `'hello'`, `"""multi-line"""`
- Empty string: `""` — falsy, length 0
- From iterable: `"".join(["a", "b", "c"])` → `"abc"`
- Casting: `str(123)` → `"123"`, `str([1,2])` → `"[1, 2]"`
- Repetition: `"ab" * 3` → `"ababab"`
- Concatenation: `"hi" + " " + "there"` → `"hi there"`
- **Immutability — the core property:** `s[0] = "X"` raises `TypeError`. Every "modification" actually builds a new string.

**The performance trap (lock this now):**

```python
# ❌ O(n²) — string rebuilds every iteration
result = ""
for char in long_text:
    result += char       # creates new string each time

# ✅ O(n) — build list, join once
chars = []
for char in long_text:
    chars.append(char)
result = "".join(chars)
```

For short strings (< 100 chars) the difference is invisible. For long strings, it's the difference between instant and frozen.

**Drill problems:**
1. Try `s = "hello"; s[0] = "J"` — predict the error.
2. Build the alphabet two ways: `+=` accumulator vs `"".join(list)`. Time both on 1000 iterations (use `time.time()`).
3. Concatenate `"abc"` 5 times using `*` and using a loop. Verify same result.

### A.2 — Slicing deep (20 min)

**Topics:**
- `s[start:stop:step]` — half-open: includes start, excludes stop
- `s[:]` — full copy (rarely needed since strings are immutable)
- `s[::-1]` — reverse (the iconic Python idiom)
- `s[:n]` — first n chars
- `s[n:]` — from index n to end
- `s[-n:]` — last n chars
- `s[::2]` — every other char
- `s[::-2]` — every other char, reversed
- **Slice never crashes on out-of-range; index does.**

**The off-by-one classic:**
- `s[0:5]` gives indices 0, 1, 2, 3, 4 — NOT 0 through 5
- `s[2:5]` gives `s[2]`, `s[3]`, `s[4]` — three chars

**Drill problems:**
1. Given `s = "Python rocks"`, write slices for: first 3 chars, last 3 chars, middle word, reversed, every other char.
2. Predict before running: `s[100:200]` (out of range slice — what happens?). Confirm.
3. Predict: `s[5:2]` (start > stop with positive step). What does it return?
4. Reverse a string 3 ways: slicing, accumulator, two-pointer (preview).

### A.3 — String methods deep (40 min)

**Case methods (5 min):**
- `.upper()`, `.lower()`, `.title()`, `.swapcase()`, `.capitalize()`
- All return new strings; original unchanged

**Drill:** Take `"hello world"`, apply each method. Predict each output.

**Split/join — the inverse pair (10 min):**
- `.split()` (no arg) — splits on whitespace, collapses multiple spaces
- `.split(sep)` — splits on exact separator
- `.split(sep, maxsplit)` — limit splits
- `"sep".join(iterable)` — joins iterable of strings with separator
- **Critical:** `.join()` requires all iterable elements to be strings; ints crash with TypeError

**Drill problems:**
1. `"  hello   world  ".split()` vs `"  hello   world  ".split(" ")` — predict both.
2. Join `["1", "2", "3"]` with `"-"`. Then try joining `[1, 2, 3]` — predict the error.
3. Reverse the words in `"the quick brown fox"` using split + join.

**Strip methods (5 min):**
- `.strip()` — removes whitespace from both ends
- `.lstrip()` / `.rstrip()` — left/right only
- `.strip(chars)` — removes any of those chars from ends
- **Banned reflex:** Don't use `.strip()` as a fix for spaces inside the string. Strip only touches ends.

**Drill problems:**
1. `"  hello  world  ".strip()` — predict result. Note middle spaces remain.
2. `"###hello###".strip("#")` — predict.
3. Bug spot: code using `.strip()` to remove all spaces from a sentence — explain why broken, fix correctly.

**Find/replace methods (5 min):**
- `.find(sub)` — returns lowest index, or `-1` if not found
- `.index(sub)` — returns lowest index, or raises `ValueError`
- `.replace(old, new)` — returns new string; original unchanged
- `.replace(old, new, count)` — limit replacements
- `.count(sub)` — count non-overlapping occurrences

**Drill problems:**
1. `"hello".find("z")` vs `"hello".index("z")` — predict each.
2. Replace all spaces in `"a b c d"` with `_`. Replace only first 2 with `.replace(" ", "_", 2)`.
3. Count occurrences of `"ab"` in `"ababab"` — predict (overlap?).

**Predicate methods (5 min):**
- `.isdigit()`, `.isalpha()`, `.isalnum()`, `.isspace()`
- `.startswith(prefix)`, `.endswith(suffix)`
- All return bool; work on full string (not single chars)

**Drill problems:**
1. Predict: `"abc123".isalnum()`, `"abc 123".isalnum()`, `"".isalpha()`.
2. `"hello.py".endswith(".py")` — predict.
3. Use `.isdigit()` inside a loop to count digits in `"a1b2c3d4"`.

**Padding/formatting (5 min):**
- `.zfill(n)` — pad left with zeros to total width n
- `.center(n, char=' ')` — center in width n
- `.ljust(n, char)` / `.rjust(n, char)` — left/right justify

**f-string format specs (5 min):**
- `f"{x:>5}"` — right-align in width 5
- `f"{x:<5}"` — left-align
- `f"{x:^5}"` — center
- `f"{x:0>3}"` — pad left with `0` to width 3
- `f"{x:.2f}"` — float with 2 decimal places
- `f"{x:5d}"` — int in width 5

**Drill problems:**
1. `"42".zfill(5)` — predict.
2. Print `f"{i:3d} | {name:<10} | {price:>8.2f}"` for some sample data — formatted table.
3. Right-align numbers 1-10 in width 4 using f-string padding.

### A.4 — ASCII awareness with `ord` and `chr` (10 min)

**Topics:**
- `ord('a')` → 97, `ord('A')` → 65, `ord('0')` → 48
- `chr(97)` → `'a'`, `chr(65)` → `'A'`
- Useful for: shift ciphers, char arithmetic, Roman numerals
- `'a' <= c <= 'z'` works for range checks (uses underlying ord)

**Drill problems:**
1. Print `ord('a')` through `ord('z')`. Note they're sequential.
2. Convert `'A'` to `'a'` using `chr(ord('A') + 32)`.
3. Caesar cipher preview: shift each lowercase letter in `"hello"` by 3. Use `ord` + `chr`.

### A.5 — Critical traps preview (5 min)

- `+=` in long loops → O(n²)
- `.strip()` only touches ends, never inside
- `.find()` returns -1; treat -1 as sentinel, not as "last char"
- Empty string `""` — falsy, length 0, often crashes naive code
- Single char `"a"` — is it a palindrome? Yes (length-1 strings are palindromes by definition)
- Mixed case comparison — `"Hello" == "hello"` is `False`. Use `.lower()` first.
- `.split()` vs `.split(" ")` differ on multiple/leading/trailing spaces

---

## 🔄 Block B — Loop Forms × Strings + 5 Native Patterns (1.5 hr)

### B.1 — Five ways to walk a string (20 min)

Drill all five on the same problem: *"Print each character with its 1-based position."*

```python
text = "hello"
```

**Form 1 — char loop (no position):**
```python
for char in text:
    print(char)
```

**Form 2 — index loop:**
```python
for i in range(len(text)):
    print(f"{i+1}: {text[i]}")
```

**Form 3 — enumerate (the workhorse):**
```python
for i, char in enumerate(text, start=1):
    print(f"{i}: {char}")
```

**Form 4 — while + manual index:**
```python
i = 0
while i < len(text):
    print(f"{i+1}: {text[i]}")
    i += 1
```

**Form 5 — two-pointer (for palindrome-style):**
```python
left, right = 0, len(text) - 1
while left < right:
    print(text[left], text[right])
    left += 1
    right -= 1
```

**Lock-in:** Implement all 5. Verify same output where applicable. Form 5 has different semantics (pairs) but same iteration discipline.

### B.2 — Five native string patterns (50 min)

**Pattern 1 — String accumulator (4 variants) — locked already, drill cold (15 min)**

```python
# 1. Build all
result = ""
for char in text:
    result += char

# 2. Transform (e.g., uppercase)
result = ""
for char in text:
    result += char.upper()

# 3. Filter (e.g., vowels only)
result = ""
for char in text:
    if char in "aeiou":
        result += char

# 4. Prepend (reverses)
result = ""
for char in text:
    result = char + result
```

**Drill problems (test all 4 variants):**
1. Build a copy of `"python"` — variant 1.
2. Uppercase every char in `"hello"` — variant 2 (don't use `.upper()` on the whole string).
3. Keep only consonants in `"banana"` — variant 3.
4. Reverse `"hello"` using prepend — variant 4.

**Pattern 2 — Neighbour access (10 min)**

Accessing `text[i-1]` and `text[i+1]` with boundary guards.

```python
# Find positions where current char equals next char
for i in range(len(text) - 1):     # stop one short to allow text[i+1]
    if text[i] == text[i+1]:
        print(f"Duplicate at {i}")
```

**Drill problems:**
1. Find all positions in `"bookkeeper"` where consecutive chars are the same.
2. Find all positions in `"abcde"` where the char is greater than the previous one.
3. Run-length encoding setup: walk `"aaabb"` and detect every position where current char differs from next.

**Pattern 3 — Two-pointer on strings (10 min)**

Pointers move from opposite ends. Used for palindromes, reverse-in-place (immutable workaround), and pair problems.

```python
def is_palindrome_basic(s):
    left, right = 0, len(s) - 1
    while left < right:
        if s[left] != s[right]:
            return False
        left += 1
        right -= 1
    return True
```

**Drill problems:**
1. Implement `is_palindrome_basic` and test on `"racecar"`, `"hello"`, `"a"`, `""`.
2. Reverse a string using two-pointer logic (build a list, swap, join).
3. Check if two strings are reverses of each other using two pointers (one moving forward, other backward).

**Pattern 4 — Run-length encoding (10 min)**

Count consecutive duplicates. `"aaabbc"` → `"a3b2c1"`.

```python
def compress(s):
    if not s:
        return ""
    result = []
    count = 1
    for i in range(1, len(s)):
        if s[i] == s[i-1]:
            count += 1
        else:
            result.append(s[i-1] + str(count))
            count = 1
    result.append(s[-1] + str(count))     # don't forget last group!
    return "".join(result)
```

**Drill problems:**
1. Implement `compress`. Test on `"aaabbc"`, `"abc"`, `"aaaa"`, `""`, `"a"`.
2. Modify so it returns the original if compressed isn't shorter (`compress("abc")` → `"abc"`).
3. Decompress: `"a3b2c1"` → `"aaabbc"`. (Hint: needs to handle multi-digit counts.)

**Pattern 5 — Substring scanning (sliding window preview) (5 min)**

Walk a string, maintain a "window" of recent chars. Full sliding window is Day 6+ territory.

```python
def has_unique_chars_in_window(text, window_size):
    for i in range(len(text) - window_size + 1):
        window = text[i:i+window_size]
        if len(set(window)) == window_size:    # uses Day 2 set!
            return True
    return False
```

**Drill problem:**
1. Find any 4-char substring in `"abcdefabc"` where all chars are unique. Use the set trick from Day 2.

### B.3 — String × Day 2 cross-pollination (20 min)

Day 2 patterns (frequency, grouping, set membership) shine on strings.

**Drill problems:**
1. **First non-repeating character** — frequency dict, then walk text again to find first with count 1.
   ```python
   def first_non_repeating(text):
       counts = Counter(text)
       for char in text:
           if counts[char] == 1:
               return char
       return None
   ```
2. **Anagram check** — two strings are anagrams iff `sorted(s1) == sorted(s2)` OR `Counter(s1) == Counter(s2)`.
3. **Longest substring without repeating characters** — walk with two pointers, set tracks current window.

---

## 🪜 Block C — Phase 3b L4: Variable-Width Shapes (1.5 hr)

### C.1 — The mental flip (10 min)

Inner range depends on outer. Up to now, both ranges were fixed (`for j in range(5)`). Now the inner range becomes a function of `i`.

**Why this produces a triangle:**

```python
for i in range(5):
    for j in range(i + 1):
        print("*", end="")
    print()
```

When `i=0`, inner runs 1 time (1 star). When `i=1`, 2 times. When `i=4`, 5 times. The "+1" matters — without it, row 0 would print 0 stars.

**Drill problems:**
1. Trace `for i in range(4): for j in range(i+1): print("*", end=""); print()` on paper. Predict the shape.
2. Predict iterations of `for i in range(4): for j in range(i):` (note: `range(i)`, not `range(i+1)`).
3. Predict shape: `range(i)` produces what triangle vs `range(i+1)`?

### C.2 — Right triangle, left-aligned (15 min)

```
*
**
***
****
*****
```

```python
def left_triangle(height):
    for i in range(height):
        for j in range(i + 1):
            print("*", end="")
        print()
```

**Drill problems:**
1. Implement `left_triangle(height)`. Test for heights 3, 5, 1.
2. Variant — use numbers instead of `*`:
   ```
   1
   1 2
   1 2 3
   1 2 3 4
   ```
3. Variant — use the row number:
   ```
   1
   2 2
   3 3 3
   4 4 4 4
   ```

### C.3 — Inverted triangle (15 min)

```
*****
****
***
**
*
```

```python
def inverted_triangle(height):
    for i in range(height):
        for j in range(height - i):
            print("*", end="")
        print()
```

**Drill problems:**
1. Implement `inverted_triangle`. Test heights 3, 5.
2. Trace why `range(height - i)` produces shrinking rows.
3. Variant — reverse number triangle:
   ```
   1 2 3 4 5
   1 2 3 4
   1 2 3
   1 2
   1
   ```

### C.4 — Right-aligned triangle (the two-loop-per-row insight) (25 min)

```
    *
   **
  ***
 ****
*****
```

This is the critical jump. Each row needs TWO inner loops: spaces, THEN stars.

```python
def right_aligned_triangle(height):
    for i in range(height):
        # Loop 1 — leading spaces
        for s in range(height - i - 1):
            print(" ", end="")
        # Loop 2 — stars
        for j in range(i + 1):
            print("*", end="")
        print()
```

**Why `height - i - 1` for spaces:** Row 0 needs `height - 1` spaces. Row `height - 1` needs 0 spaces.

**Drill problems:**
1. Implement `right_aligned_triangle`. Test heights 3, 5.
2. Trace row-by-row what `height - i - 1` evaluates to. Confirm it's the right shape.
3. Variant — make it left-aligned but with leading spaces still computed (waste exercise — proves you understand the decoupling).

### C.5 — Off-by-one diagnosis (15 min)

When triangles look wrong, the bug is almost always in the range expression.

**Bugs to spot and fix:**

```python
# Bug A — missing top row
for i in range(5):
    for j in range(i):       # should be i+1
        print("*", end="")
    print()

# Bug B — missing one row at bottom
for i in range(4):           # should be 5
    for j in range(i + 1):
        print("*", end="")
    print()

# Bug C — extra space (off-by-one in spaces loop)
for i in range(5):
    for s in range(5 - i):   # should be 5 - i - 1 if pyramid, 4 - i if right-tri
        print(" ", end="")
    for j in range(i + 1):
        print("*", end="")
    print()
```

**Drill: For each bug, identify the off-by-one and fix it.**

### C.6 — Number triangles (10 min)

Inner range starts at 1, ends at `i+2`:

```python
for i in range(5):
    for j in range(1, i + 2):
        print(j, end=" ")
    print()
# 1
# 1 2
# 1 2 3
# 1 2 3 4
# 1 2 3 4 5
```

**Drill problems:**
1. Build the above. Verify.
2. Floyd's triangle (sequential numbering):
   ```
   1
   2 3
   4 5 6
   7 8 9 10
   ```
3. Multiplication triangle (row × col):
   ```
   1
   2 4
   3 6 9
   4 8 12 16
   ```

---

## 💎 Block D — Phase 3b L4.5: Pyramid + Diamond (1 hr)

### D.1 — Centered pyramid (20 min)

```
    *
   ***
  *****
 *******
*********
```

**The two-loop-per-row pattern:**
- Spaces per row: `n - i - 1`
- Stars per row: `2*i + 1` (always odd: 1, 3, 5, 7, 9...)

```python
def pyramid(height):
    for i in range(height):
        for s in range(height - i - 1):
            print(" ", end="")
        for j in range(2 * i + 1):
            print("*", end="")
        print()
```

**Drill problems:**
1. Implement `pyramid`. Test heights 3, 5.
2. Trace row-by-row what `2*i + 1` evaluates to. Confirm odd widths.
3. Variant — pyramid with numbers instead of stars (keep odd widths).

### D.2 — Inverted pyramid (15 min)

```
*********
 *******
  *****
   ***
    *
```

- Spaces per row: `i`
- Stars per row: `2*(n-i) - 1`

```python
def inverted_pyramid(height):
    for i in range(height):
        for s in range(i):
            print(" ", end="")
        for j in range(2 * (height - i) - 1):
            print("*", end="")
        print()
```

**Drill problems:**
1. Implement `inverted_pyramid`. Test heights 3, 5.
2. Verify the formulas — what does row 0 look like? Row `n-1`?

### D.3 — Diamond (the boss of L4.5) (20 min)

Diamond = pyramid + inverted pyramid stacked. Watch the middle row — don't print it twice.

**Two approaches:**

**Approach A — Two separate loop blocks:**
```python
def diamond(height):
    # Top half (pyramid)
    for i in range(height):
        for s in range(height - i - 1):
            print(" ", end="")
        for j in range(2 * i + 1):
            print("*", end="")
        print()
    # Bottom half (inverted, but skip the duplicate middle row)
    for i in range(height - 2, -1, -1):     # height-2 down to 0
        for s in range(height - i - 1):
            print(" ", end="")
        for j in range(2 * i + 1):
            print("*", end="")
        print()
```

For `height=5`, total rows = 9: top 5 + bottom 4 (skips the center).

**Approach B — Symmetric reuse:** call `pyramid(height)` then `pyramid_partial(height-1)` reversed.

**Drill problems:**
1. Implement diamond using Approach A. Test heights 3, 5.
2. Count total rows for height 5. Should be 9. For height 3? 5.
3. Variant — hollow diamond: only border `*`, interior is space. (Hint: print `*` only when at first or last position of inner loop.)

### D.4 — Hollow shapes (bonus, 5 min)

Hollow rectangle:
```
*****
*   *
*   *
*   *
*****
```

```python
def hollow_rectangle(rows, cols):
    for i in range(rows):
        for j in range(cols):
            if i == 0 or i == rows - 1 or j == 0 or j == cols - 1:
                print("*", end="")
            else:
                print(" ", end="")
        print()
```

The range stays the same; the **condition inside** decides what to print.

**Drill: Implement and test for 5×5, 3×7.**

---

## 🎁 Block E — Wrap Block: Functions + StringAnalyzer (1.5 hr)

### E.1 — Functions wrapping string logic (45 min)

**Discipline rules carry from Day 1 + Day 2:**
- Take input as parameter
- Return result; don't print inside (except for shape printers)
- Don't modify caller's data (strings are immutable, so this is safe — but still)
- Handle empty string, single char gracefully

**Drill problems — write each as a function:**

1. **`reverse_string(s)`** — return reversed string. Implement using slicing first; bonus: also using accumulator and two-pointer.
2. **`is_palindrome(s)`** — basic version, exact match (case-sensitive, includes punctuation).
3. **`is_palindrome_clean(s)`** — case-insensitive, ignoring all non-alphanumeric. Use two-pointer.
4. **`vowel_count(s)`** — return count of vowels.
5. **`compress(s)`** — run-length encoding. Return original if compressed isn't shorter.
6. **`first_non_repeating(s)`** — return first char with count 1, or `None`.
7. **`longest_word(sentence)`** — split, return the longest word (ties → return first).
8. **`caesar_cipher(s, shift)`** — shift each letter by `shift` positions. Preserve case. Leave non-letters alone. Use `ord`/`chr`.
9. **`title_case_manual(s)`** — uppercase first letter of each word without using `.title()`.
10. **Shape printers (return strings, don't print):** `make_pyramid(height)`, `make_diamond(height)`, `make_left_triangle(height)`. Use `"\n".join(rows)`.

**Function discipline checklist:**
- ✅ Empty string handled (return what's natural — empty result, `None`, `True` for palindrome, etc.)
- ✅ Single-char handled
- ✅ For shape printers — return string, don't print directly (caller can choose to print or save)

### E.2 — `StringAnalyzer` class (45 min)

**When the class beats functions:** you're going to ask many questions about the same text. Don't recompute frequency 5 times — store the text, lazy-compute on demand.

```python
from collections import Counter

class StringAnalyzer:
    def __init__(self, text):
        self.text = text
    
    def length(self):
        # Total characters (including spaces).
        ...
    
    def word_count(self):
        # Number of words (split on whitespace).
        ...
    
    def char_frequency(self):
        # Return Counter of char → count.
        ...
    
    def vowel_count(self):
        # Number of vowels (case-insensitive).
        ...
    
    def is_palindrome(self):
        # Clean palindrome check (case-insensitive, alphanumeric only).
        ...
    
    def reverse(self):
        # Return reversed text.
        ...
    
    def compress(self):
        # Return run-length encoded version (or original if shorter).
        ...
    
    def longest_word(self):
        # Return longest word.
        ...
    
    def most_common_char(self, ignore_spaces=True):
        # Return char appearing most. Ties → return first encountered.
        ...
    
    def is_anagram_of(self, other):
        # Return True if self.text is anagram of other (string).
        ...
```

**Drill: Build all 10 methods.**

**Test data:**
```python
sa = StringAnalyzer("a man a plan a canal panama")
sa.length()                     # → 27
sa.word_count()                 # → 7
sa.is_palindrome()              # → True (clean)
sa.most_common_char()           # → "a" (or " " if ignore_spaces=False)
sa.longest_word()               # → "panama"
sa.is_anagram_of("napa man clan a a planpa")  # check the math
```

**Class discipline checklist:**
- ✅ Methods operate on `self.text`
- ✅ `__init__` stores, doesn't pre-compute (unless the class is documented to)
- ✅ Methods return values; no printing
- ✅ Use `Counter` / `set` / dict internally; caller doesn't see these

---

## 🏆 Block F — Day 3 Mini-Boss (30 min)

**Cold attempts. No notes from this chat. Each problem stands alone.**

### Mini-Boss A — Diamond, Height 5

Print a diamond of `*` characters with height 5 (top pyramid is 5 rows, full diamond is 9 rows total). Use the two-loop-per-row pattern.

Expected output:

```
    *
   ***
  *****
 *******
*********
 *******
  *****
   ***
    *
```

**Tests:** Phase 3b L4.5 boss. Locks pyramid + inverted pyramid + middle-row dedup.

### Mini-Boss B — Clean Palindrome

Write `is_palindrome_clean(s)` that returns `True` if `s` is a palindrome ignoring case and all non-alphanumeric characters. Use two-pointer (no slicing tricks — those are 1-line cheats).

```python
is_palindrome_clean("A man, a plan, a canal: Panama")    # → True
is_palindrome_clean("race a car")                         # → False
is_palindrome_clean("")                                   # → True (vacuously)
is_palindrome_clean(".,!")                                # → True (no real chars)
is_palindrome_clean("Was it a car or a cat I saw?")       # → True
```

**Tests:** Two-pointer pattern, predicate methods (`.isalnum()`), case normalization, edge cases.

### Mini-Boss C — Run-Length Encoder

Write `compress(s)` that returns the run-length encoding of `s`. If the encoded version isn't strictly shorter than the original, return the original.

```python
compress("aaabbc")                  # → "a3b2c1"
compress("abcd")                    # → "abcd" (encoded would be "a1b1c1d1", longer)
compress("aaaaa")                   # → "a5"
compress("")                        # → ""
compress("a")                       # → "a"
compress("aabbccdd")                # → "aabbccdd" (encoded is "a2b2c2d2", same length)
```

**Tests:** Neighbour access (`s[i] vs s[i-1]`), accumulator pattern, edge cases (empty, single char, no repeats), the "don't forget the last group" trap.

---

## 🚦 Day 3 Pass/Fail Rules

**3-strike rule per drill problem:**
- 1st miss → diagnosis hint
- 2nd miss → structural hint (skeleton with blanks)
- 3rd miss → I show full solution + you re-attempt fresh

**Mini-boss pass condition:**
- All 3 mini-boss problems correct cold OR with at most 1 self-corrected bug per problem
- If hints needed on more than one → loop back to Block C (variable-width shapes) before Day 4

---

## 📋 Day 3 Tracker Recap (paste into progress_tracker.md)

```
Day 3 of Loop Week — Strings + Phase 3b L4 + L4.5

Locked:
- 5 ways to walk a string (char loop, index, enumerate, while+index, two-pointer)
- 5 native string patterns (accumulator 4-variant, neighbour access, two-pointer, RLE, substring scan)
- String methods deep — split/join, strip, find/replace, predicates, padding, f-string format specs
- Slicing fluency (positive, negative, step, reverse)
- Immutability + the += O(n²) trap + "".join() fix
- ord/chr for ASCII tricks (Caesar cipher)
- Phase 3b L4 — variable-width shapes (left/right/inverted triangles, number triangles)
- Phase 3b L4.5 — pyramid, inverted pyramid, diamond, hollow shapes
- Two-loop-per-row insight (spaces THEN content)
- Cross-pollination with Day 2 (frequency, set, anagram detection)
- Functions wrapping string logic (10 functions)
- StringAnalyzer class with 10 methods

Mini-boss results:
- Diamond, height 5: ✓/✗
- is_palindrome_clean: ✓/✗
- compress (RLE): ✓/✗

Weak spots flagged: [fill in]
Tomorrow's bridge: Comprehensions + Phase 3b L7 (range mastery + anti-patterns)
```

---

## 🧠 Day 3 Memory Hooks

- *"Strings are Voldemort — you can't change them."* (Building on Day 1's tuple hook.)
- *"`+=` in long loops = O(n²). Build a list, `"".join()` once."*
- *"`.find()` returns -1; `.index()` raises. Pick by what you want on miss."*
- *"`.strip()` only touches the ends. Inside spaces stay."*
- *"`s[start:stop]` excludes stop. `s[0:5]` is 5 chars, indices 0-4."*
- *"Two-pointer palindrome: `left < right`, walk inward, mismatch = false."*
- *"Pyramid widths: `2*i + 1`. Always odd: 1, 3, 5, 7..."*
- *"Pyramid spaces: `n - i - 1`. Row 0 = max spaces. Last row = 0 spaces."*
- *"Diamond = pyramid + inverted pyramid, skip the middle row twice."*

---

## 🔮 What unlocks after Day 3

- Day 4 (Comprehensions) — string comprehensions like `"".join(c.upper() for c in text)` build on string fluency
- Day 5 (Functions DEEP) — `StringAnalyzer` was a preview; deeper class patterns land tomorrow
- Day 6 (Mini-problems) — string problems become routine; longest substring / valid palindrome / anagrams all locked
- Week 4+ — string interview problems on LeetCode become approachable
- Week 6 — formal two-pointer technique drilling builds on the palindrome reps from today

---

*End of Day 3 curriculum. Brainstorm complete. Ready to lock or refine.*
