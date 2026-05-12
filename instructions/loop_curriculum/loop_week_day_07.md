# 🔁 Loop Week — Day 7: Project, Week Retrospective & Bridge to Daily Curriculum

> **Theme:** The integration day. Six days of pattern-by-pattern drilling collapse into one real project. Plus a week-level retrospective that names what's locked, what's wobbly, and what carries forward into the daily curriculum starting Monday. By end of day, Loop Week is officially complete and Day 16 awaits.
>
> **Time budget:** 6-7 focused hours (lighter than Days 3-6 — the week was heavy; today consolidates)
>
> **Phase 3b coverage:** None new. Block C is conditional cleanup if Day 6 left residue.
>
> **No mini-boss.** The project running cleanly on real input IS the mini-boss.
>
> **Day 7 is calmer than Days 1-6 by design.** Don't sacrifice the retrospective + bridge to perfect the project.

---

## 🎯 Day 7 Learning Goals

By end of day, you should be able to **without notes**:

1. Decompose a real-world problem into modules, classes, and functions before writing code
2. Build a multi-module Python project with clean import structure
3. Apply patterns from Days 1-5 in combination on a single integrated codebase
4. Handle real-world edge cases (Unicode, contractions, mid-sentence punctuation)
5. Produce a paste-ready week retrospective with honest pattern-by-pattern audit
6. Connect Loop Week skills to upcoming curriculum (NumPy, Pandas, Phase 2)
7. Officially close Phase 3b (or flag remaining residue cleanly)

---

## 🗓 Day 7 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Planning** | 30 min | Project pick + architecture sketch + module + function inventory |
| **Block B — Build** | 3.5 hr | Working multi-module program — Text Analyzer (recommended) |
| **Block C — Phase 3b residue** | 30 min (conditional) | Re-attempt Final Boss problems if Day 6 left them open |
| **Block D — Week retrospective** | 1 hr | Pattern audit + mini-boss reflection + weak spots + wins |
| **Block E — Bridge to curriculum** | 30 min | What carries to Day 17 / 18-19 / Week 4+ + resumption note |

Total: ~6 hours (7 if Block C fires).

---

## 📋 Block A — Project Planning (30 min)

### A.1 — Pick the project (5 min)

**Recommended: Text Analyzer.**

Why: Densest in loop coverage. Uses every data structure (string, list, dict, set, tuple), every loop pattern (counter, tracker, accumulator, filter, search), comprehensions, functions, a class. Reads from a file (preview of Day 9). Real text has real edge cases.

**Alternatives if Text Analyzer doesn't excite:**

- **Inventory Management System** — extends Day 2's `Inventory` class. Add file persistence, CLI menu, transaction history. Less loop-heavy, more class-heavy.
- **Number Game Suite** — 5 mini-games sharing utility functions: number guessing, word scramble, hangman, mastermind, simple calculator.
- **Grade Management System Extended** — extends Day 1's grade exercise. Multiple subjects per student, grade history, ranking, statistics. Heavy on multi-tracker.

**Pick one. Don't spend more than 5 minutes deciding.**

### A.2 — Architecture sketch (15 min)

Before writing code, sketch:

1. **Module structure** — which files exist, what does each own?
2. **Class structure** — which classes exist, what's their state, what's their interface?
3. **Function inventory** — list every function you'll need, name + 1-line purpose
4. **Data flow** — input → parse → analyze → present → output

**Example for Text Analyzer:**

```
text_analyzer/
├── analyzer.py         # TextAnalyzer class — main entry point
├── parsers.py          # tokenize_words, split_sentences, clean_text
├── stats.py            # word_frequency, char_frequency, anagram_groups
├── reporting.py        # format_report (the pretty print)
└── main.py             # if __name__ == "__main__" — load file, run analysis, print report
```

**Function inventory (rough):**

| Module | Function | Purpose |
|---|---|---|
| `parsers.py` | `clean_text(s)` | strip extra whitespace, normalize |
| `parsers.py` | `tokenize_words(s)` | split into list of words |
| `parsers.py` | `split_sentences(s)` | split into list of sentences |
| `stats.py` | `word_frequency(words)` | dict word → count |
| `stats.py` | `char_frequency(s)` | dict char → count, ignoring spaces |
| `stats.py` | `find_palindromes(words)` | list of palindrome words |
| `stats.py` | `find_anagram_groups(words)` | list of lists |
| `stats.py` | `vowel_consonant_ratio(s)` | float |
| `reporting.py` | `format_report(stats_dict)` | pretty-printed string |
| `analyzer.py` | `TextAnalyzer.__init__(text)` | store text, pre-tokenize |
| `analyzer.py` | `TextAnalyzer.report()` | run all stats, format, return string |

### A.3 — Discipline checklist (10 min)

Before coding, lock these:

- ✅ Every function takes input as parameter, returns output (no globals, no `print` inside analytical functions)
- ✅ `print` lives only in `reporting.py` and `main.py`
- ✅ Edge cases planned: empty text, single word, no sentences, all-uppercase, Unicode chars
- ✅ Use `Counter` / `defaultdict` over manual frequency builds
- ✅ Use `enumerate` not `range(len(...))`
- ✅ Use comprehensions where clearer; regular loops where not
- ✅ Type hints on all public functions

---

## 🛠 Block B — Build the Project (3.5 hr)

### B.1 — Text Analyzer Spec (recommended)

**Required features:**

1. **Word count + character count** (with/without spaces)
2. **Word frequency dict** — top 10 most common, in descending order
3. **Character frequency dict** — case-insensitive, ignoring spaces and punctuation
4. **Average word length** (rounded to 2 decimal places)
5. **Longest word + its 1-based position** (ties → first occurrence)
6. **Sentence count** — split on `.`, `!`, `?` (handle multiple consecutive punctuation)
7. **Average words per sentence** (rounded to 2 decimal places)
8. **Palindrome detector** — list of words that are palindromes (case-insensitive, length ≥ 2)
9. **Vowel/consonant ratio** — `vowels / consonants`, ignoring non-letter chars
10. **Anagram groups** — groups of words in the text that are anagrams of each other (only groups of size ≥ 2)
11. **Pretty-printed report** — formatted output using f-string format specs

**Optional advanced (only if time):**
- Repeated phrase detection (2-3 word sequences appearing more than once)
- Longest vs shortest sentence
- Word cloud-style top-N display with bar chart in ASCII

### B.2 — `TextAnalyzer` class skeleton

```python
from collections import Counter, defaultdict


class TextAnalyzer:
    def __init__(self, text: str):
        self.text = text
        self.words = self._tokenize_words()
        self.sentences = self._split_sentences()
    
    # Private helpers
    def _tokenize_words(self) -> list[str]: ...
    def _split_sentences(self) -> list[str]: ...
    
    # Counts
    def word_count(self) -> int: ...
    def char_count(self, include_spaces: bool = True) -> int: ...
    def sentence_count(self) -> int: ...
    
    # Frequencies
    def word_frequency(self, top_n: int = 10) -> list[tuple[str, int]]: ...
    def char_frequency(self) -> dict[str, int]: ...
    
    # Stats
    def avg_word_length(self) -> float: ...
    def avg_words_per_sentence(self) -> float: ...
    def longest_word(self) -> tuple[str, int]: ...
    def vowel_consonant_ratio(self) -> float: ...
    
    # Pattern detection
    def palindromes(self) -> list[str]: ...
    def anagram_groups(self) -> list[list[str]]: ...
    
    # Output
    def report(self) -> str: ...
```

### B.3 — Implementation order (recommended)

1. **`_tokenize_words` and `_split_sentences`** first — everything else depends on these
2. **Simple counts** (`word_count`, `char_count`, `sentence_count`) — quick wins, verify tokenization works
3. **Frequencies** (`word_frequency`, `char_frequency`) — uses `Counter`
4. **Stats** (`avg_word_length`, `longest_word`, etc.) — accumulator + tracker patterns
5. **Pattern detection** (`palindromes`, `anagram_groups`) — Day 2 + Day 3 cross-pollination
6. **`report()`** last — assembles everything into formatted output

### B.4 — Real test data

Use a real piece of text. Suggestions:

- A paragraph from a news article
- The first paragraph of a book chapter
- A LinkedIn post
- A piece of your own writing (your bootcamp goals, perhaps)

**Why real text matters:**
- Apostrophes (`"don't"`, `"it's"`) — does your tokenizer handle them?
- Em-dashes (`—`) — does your character frequency handle them?
- Mixed case (`"ML"`, `"USA"`)
- Multi-sentence with `Mr.` or `etc.` — does your sentence splitter break?

**Test on at least 3 different real texts.** Edge cases surface where you didn't expect them.

### B.5 — Sample expected output shape

```
═══════════════════════════════════════════
        TEXT ANALYSIS REPORT
═══════════════════════════════════════════

📏 BASIC COUNTS
   Words:        247
   Characters:   1432  (with spaces)  /  1185 (without)
   Sentences:    18

📊 AVERAGES
   Avg word length:        4.80 chars
   Avg words/sentence:    13.72

🔤 LONGEST WORD
   "responsibility" at position 84

📈 TOP 10 WORDS
    1. the          18
    2. to           12
    3. of           11
    ...

🪞 PALINDROMES FOUND
   noon, level, kayak

🔀 ANAGRAM GROUPS
   • eat / tea / ate
   • silent / listen

🎵 VOWEL / CONSONANT RATIO
   0.65  (vowels: 462, consonants: 723)

═══════════════════════════════════════════
```

The exact format is yours to design. Just make it readable and use f-string padding to align columns.

### B.6 — Discipline reminders during build

- If a function exceeds 30 lines → refactor into helpers
- If you're tempted to print debug info → use a temporary print, remove before commit
- If a list comprehension is more than 2 clauses → break into a regular loop
- If you see `range(len(lst))` → ask if `enumerate` would be cleaner
- If you reach for nested loops on a frequency or pair-finding problem → reach for hash map first

---

## 🏆 Block C — Phase 3b Residue Cleanup (Conditional, 30 min)

**Skip this block if Day 6 Round 6 passed cleanly.**

If P8 (multiplication table) or P15 (diamond) didn't pass cold yesterday, this is the second chance.

### Re-attempt protocol

1. Cold attempt — no notes from this chat or yesterday
2. 1 strike → I show the answer + extract the concept missed + flag for tracker
3. After this block, Phase 3b is officially closed regardless of outcome
   - Pass = Phase 3b CLOSED ✅
   - Strike = Phase 3b CLOSED with flagged weak spot (re-drill in evening if needed)

### What gets re-attempted

- **P8: Multiplication Table** (10×10, formatted with `f"{x:4d}"`)
- **P15: Diamond Pattern** (height 5, 9 rows total)

If both pass cleanly today → Phase 3b clean exit.

If you genuinely missed yesterday's drilling, do not loop forever — extract the concept, log the gap, move on. Day 7 isn't for re-running Day 6.

---

## 📊 Block D — Week Retrospective (1 hr)

This is structured retrospection. Not free-form journaling. Each section has a specific output.

### D.1 — Pattern audit (15 min)

Rate every major pattern on the locked/wobbling/weak scale.

**Honesty rule:** No "mostly locked." Either it's locked (you'd solve it cold tomorrow without strikes) or it's wobbling (one strike likely) or it's weak (would need help).

| Pattern | Locked / Wobbling / Weak |
|---|---|
| For-each, index, enumerate, while+index, while+pop | ? |
| 5 base patterns (counter, tracker, accumulator, filter, search) | ? |
| List methods + slicing + mutability traps | ? |
| Tuple unpacking + immutability rules | ? |
| Dict frequency / grouping / inverting | ? |
| Set operations + membership | ? |
| `Counter` + `defaultdict` choice | ? |
| Hashability + decision framework (list/tuple/dict/set) | ? |
| Two-sum hash trick (the O(n²) → O(n) shift) | ? |
| String accumulator (4 variants) | ? |
| String methods (split/join, strip, find/replace) | ? |
| Two-pointer technique | ? |
| Run-length encoding pattern | ? |
| `ord` / `chr` for ASCII tricks | ? |
| Comprehensions (list, dict, set, gen) | ? |
| Filter vs if/else position | ? |
| Nested + filter comprehensions | ? |
| `zip` + `enumerate` in comp | ? |
| Range Tier 1-4 | ? |
| Range Tier 5 (multi-variable zip) | ? |
| Range Tier 6 (`int(n**0.5)+1`) | ? |
| Range anti-patterns (`range(len(lst))` overuse) | ? |
| Pure function discipline | ? |
| Multi-return + predicates | ? |
| Higher-order functions (function as arg/return) | ? |
| Lambdas — when to use, when not | ? |
| Closures + function factories | ? |
| `nonlocal` keyword | ? |
| Mutable default argument trap | ? |
| `*args` / `**kwargs` + call-site unpacking | ? |
| Decorators (light) | ? |
| Phase 3b L1 — Mental model + tracing | ? |
| Phase 3b L2 — for × for shapes | ? |
| Phase 3b L3 — Pattern stacking inside nested | ? |
| Phase 3b L4 — Variable-width shapes (triangles) | ? |
| Phase 3b L4.5 — Pyramid + Diamond | ? |
| Phase 3b L5 — While family + hybrid loops | ? |
| Phase 3b L6 — 4 nested-loop traps | ? |
| Phase 3b L7 — Range mastery + anti-patterns | ? |
| Phase 3b L8 — Mixed synthesis (Day 6) | ? |
| Phase 3c — Multi-tracker / parallel iteration | ? |
| Performance refactor (O(n²) → O(n)) | ? |

**Tally:**
- Total Locked: ___
- Total Wobbling: ___
- Total Weak: ___

### D.2 — Mini-boss reflection (15 min)

Day-by-day mini-boss results:

| Day | Mini-Boss | Result | Notes |
|---|---|---|---|
| Day 1 | 5×5 grid + 6×6 even-cell + count_pairs | ? | ? |
| Day 2 | pair counter + freq top-3 + anagram grouper | ? | ? |
| Day 3 | diamond + clean palindrome + run-length encoder | ? | ? |
| Day 4 | translate 5 loops + is_prime + pythagorean triples | ? | ? |
| Day 5 | hybrid halving + 4 trap debugs + higher-order pair | ? | ? |
| Day 6 | Final Boss (P8 + P15) + 11 other problems | ? | ? |

Patterns of strikes — what do they tell you? If most strikes were on visual loops (Phase 3b L4-L4.5), that's a signal. If on functions (Day 5 trap debugs), different signal. Name the cluster.

### D.3 — Weak spots compiled (15 min)

Three categories:

**🔴 Drill again before Day 17 (NumPy)** — patterns that wobbled but matter for vectorization
- Examples: comprehensions, slicing, accumulator pattern

**🟡 Drill when topic comes up** — patterns that didn't fully lock but won't bite immediately
- Examples: closures (will revisit Day 12), decorators (Day 12), multi-tracker (Phase 3c — already absorbed)

**🟢 Re-visit at Week 6** — anything that needs spaced repetition
- Examples: two-pointer (Week 6 formal coverage), nested loop traps (deeper at Week 8 trees)

### D.4 — Wins (5 min)

What surprised you positively. Things that landed faster than expected.

This is **not optional and not fluff.** Naming wins is what builds the "I can do this" feeling that fuels the next 170 days. The bootcamp is long. Wins are fuel.

Examples worth flagging:
- "I wrote a comprehension cold on Day 4 that I would have written as a 6-line loop on Day 1"
- "I caught a shadowing bug instinctively on Day 5 — wouldn't have spotted that on Day 1"
- "Two-sum hash clicked the moment I saw the brute force comparison"
- "I now reach for `Counter` automatically on frequency problems — that's the mindset shift"

### D.5 — Honest accounting (10 min)

What didn't go as planned. Days that took longer than budgeted. Patterns that needed extra reps. Frustrations.

Also not optional. Honesty over comfort.

Examples worth flagging:
- "Day 3 took 9 hours, not 7.5 — strings had more methods than I expected"
- "I dropped a pulse-check on Day 5 around mutable defaults — almost didn't lock it"
- "Day 6 Round 1 had a strike — Day 1's tracker pattern decayed faster than I thought"
- "Comprehensions still feel slightly unnatural — I write them, but I'd default to loops if rushed"

---

## 🌉 Block E — Bridge to Daily Curriculum (30 min)

### E.1 — What carries to Day 17 (NumPy)

NumPy is *vectorization* — the library that replaces loops with array operations. Loop fluency is the prerequisite that makes NumPy click.

| Loop concept (Day 1-7) | NumPy equivalent (Day 17) |
|---|---|
| `for x in lst: result.append(f(x))` | `f(arr)` for built-in ops, `np.vectorize(f)(arr)` for custom |
| `for x in lst: total += x` | `arr.sum()` |
| `[x for x in lst if x > 0]` | `arr[arr > 0]` (boolean indexing) |
| Element-wise add | `arr1 + arr2` |
| Element-wise multiply | `arr1 * arr2` |
| Find max position | `arr.argmax()` |
| Apply to 2D row-by-row | axis parameter: `arr.sum(axis=1)` |

**The mental shift:** Days 1-7 trained you to think in loops. NumPy will train you to think in arrays. You don't unlearn loops — you choose when to drop into a loop vs lift to vectorized form.

**One-line takeaway:** *"NumPy operations are loops, hidden behind nicer syntax and run at C speed."*

### E.2 — What carries to Days 18-19 (Pandas)

Pandas operations mirror dict + list operations at scale.

| Loop concept (Day 1-7) | Pandas equivalent (Day 18-19) |
|---|---|
| Frequency dict | `df["col"].value_counts()` |
| Filter list | `df[df["col"] > 5]` |
| Group + aggregate | `df.groupby("category").mean()` |
| Sort by key | `df.sort_values("col")` |
| Find max with key | `df.loc[df["score"].idxmax()]` |
| Apply function to each row | `df.apply(func, axis=1)` |
| Comprehension | `df["col"].apply(lambda x: ...)` |

**Day 2's hash-map mindset transfers directly to Pandas.** Frequency, grouping, lookup — all Pandas one-liners now.

### E.3 — What carries to Phase 2 (Day 22+)

Week 4 is hash maps + two-pointer + sliding window. All previewed this week:

- **Day 2 (hash maps) → Week 4 deepens** — formal LeetCode-style hash map drilling
- **Day 3 (two-pointer palindrome) → Week 6 deepens** — formal two-pointer technique
- **Day 6 Round 5 (longest unique substring) → Week 4 sliding window** — first taste already absorbed

Day 7's job: name the connections. When Day 22 arrives, you recognize "I've already touched this — just adding more reps now."

### E.4 — Resumption note

**Update progress tracker:**

```
═══════════════════════════════════════════
LOOP WEEK COMPLETE — Days 1-7 of bootcamp catch-up arc
═══════════════════════════════════════════

Phase 3b: CLOSED ✅ (or flagged residue if Block C didn't fully resolve)
Phase 3c: ABSORBED — Day 6 Round 3 (Parallel Grading) was the gate
Phase 3d: REORGANIZED — P8 + P15 absorbed into Day 6 Final Boss
Phase 3.5: REORGANIZED — Tier 3 problems folded into Day 6 mini-problems

Total problems solved cold this week: ___
Total mini-boss passes: ___ / 6 (Days 1-6)
Final project: Text Analyzer (or alt) — pushed to GitHub

Resume bootcamp curriculum: Monday, Day 16 (Backtracking + Divide-and-Conquer)
Then proceed: Day 17 (NumPy), Day 18-19 (Pandas), Day 20 (Nested JSON Flattening — Target Problem #1)

Weak spots flagged for Week 4 review: [list]
Weak spots flagged for daily drilling next week: [list]
Wins documented: [list]
═══════════════════════════════════════════
```

### E.5 — Final discipline check

Before closing the day, confirm:

- ✅ Project pushed to GitHub (or saved locally with clean structure)
- ✅ `progress_tracker.md` updated with the resumption note
- ✅ `glossary_cheatsheet.md` updated with new terms (comprehension forms, closures, decorators preview, etc.)
- ✅ Phase 3b status is documented (CLOSED or flagged residue)
- ✅ Weak spots compiled and prioritized
- ✅ Ready to resume Day 16 Monday

---

## 🚦 Day 7 Pass Conditions

Day 7 doesn't have a strict pass/fail. Instead:

**Project pass condition:**
- Runs without crashing on at least 3 different real text inputs
- Produces sensible output (counts add up, frequencies make sense, palindromes are actual palindromes)
- No `print` statements outside `reporting.py` and `main.py`
- No function exceeds 30 lines

**Retrospective pass condition:**
- Pattern audit completed honestly (no "mostly locked")
- Wins section has at least 3 entries
- Honest accounting section has at least 2 entries
- Weak spots categorized into 3 buckets

**Bridge pass condition:**
- Tracker updated with resumption note
- 5 weak spots prioritized for next week's daily drilling

If any of these slip, the day didn't quite close. Better to extend Day 7 than skip into Day 16 with loose ends.

---

## 📋 Day 7 Tracker Recap (paste into progress_tracker.md)

```
Day 7 of Loop Week — Project + Retrospective + Bridge

PROJECT:
- Built: [Text Analyzer / Inventory / Number Game Suite / Grade System]
- Modules: [list]
- LOC (rough): ___
- Edge cases handled: [list]
- Pushed to GitHub: ✓/✗

PHASE STATUS:
- Phase 3b: CLOSED ✅ / FLAGGED (with note)
- Phase 3c: ABSORBED ✅
- Phase 3d, 3.5: REORGANIZED ✅

RETROSPECTIVE:
- Pattern audit completed: ✓
- Locked patterns: ___
- Wobbling patterns: ___
- Weak patterns: ___
- Mini-boss passes: ___ / 6
- Wins documented: ___ (count)
- Honest gaps documented: ___ (count)

WEAK SPOTS PRIORITIZED:
🔴 Before Day 17: [list 1-3]
🟡 As topic comes up: [list]
🟢 Week 6+ revisit: [list]

NEXT:
- Resume curriculum: Monday, Day 16 (Backtracking + D&C)
- After Day 16: Day 17 (NumPy), Day 18-19 (Pandas), Day 20 (Target Problem #1)

LOOP WEEK COMPLETE.
```

---

## 🧠 Day 7 Memory Hooks

- *"Loop Week complete. Loops are now tools, not topics."*
- *"Day 7 surfaces what cold drills can't — composition decisions."*
- *"The project running on real text is the mini-boss. Real input has real edge cases."*
- *"The retrospective is the bridge back to the daily curriculum. Don't skip it."*
- *"Honesty over comfort. No 'mostly locked' on the audit."*
- *"Wins are fuel. Name them. The bootcamp is long."*

---

## 🔮 What unlocks after Day 7

- **Resume the daily curriculum starting Day 16 (Backtracking + D&C) Monday**
- **Days 17-19 (NumPy/Pandas)** — vectorization makes sense because you've drilled the loops it replaces
- **Day 20** — first target problem (Nested JSON Flattening) — uses recursion + dict skills locked this week
- **Week 4 (Hash maps, two-pointer, sliding window)** — preview drilled this week, formal coverage in 3-4 weeks
- **Phase 3b officially CLOSED** — every nested loop pattern, every range tier, every shape pattern locked
- **Day 7's project goes on GitHub** — first portfolio piece in this style. Future capstones build on this discipline.

---

## ⚠️ The honest flag for Day 7

Day 7 is calmer than Days 1-6 by design. The week was intense. This day consolidates and bridges.

If the project takes longer than 4 hours and you're tired, that's fine — the retrospective and bridge blocks are short and high-value. **Don't sacrifice them to perfect the project.**

If at any point the project feels like padding rather than synthesis, stop. The week was the real work. Day 7 is where you recognize that.

If the retrospective surfaces serious gaps, fold them into next week's daily schedule — not Day 7. Day 7 ends. Tomorrow starts.

---

*End of Day 7 curriculum. End of Loop Week. Day 16 awaits.*
