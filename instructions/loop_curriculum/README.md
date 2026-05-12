<!-- User-authored Loop Boot Camp curriculum. Parallel to instructions/curriculum/ (bootcamp pipeline). -->
<!-- This directory is NOT auto-synced. Sudhan owns these files; manual edits via PR only. -->

# instructions/loop_curriculum/

Day-by-day curriculum for the **Loop Foundations Boot Camp** — the 7-day intensive Sudhan runs alongside the daily bootcamp to lock loop fluency before recursion (bootcamp Day 16+).

High-level strategy lives in `instructions/loop-strategy.md` (4-phase plan, root causes, non-negotiable rules). This directory holds the day-by-day operational curriculum: blocks, drill problems, mini-bosses, pass/fail rules.

## Day-to-topic map

| File | Day | Topic | Phase 3b coverage |
|---|---|---|---|
| `loop_week_day_01.md` | Day 1 | Lists, Tuples & Nested Loop Foundations | L1 (Mental model + Range Tier 1-2) + L2 (for × for + Range Tier 4) |
| `loop_week_day_02.md` | Day 2 | Dicts, Sets & Pattern Stacking in Nested Loops | L3 (Pattern stacking + Range Tier 3 intro) |
| `loop_week_day_03.md` | Day 3 | Strings & Variable-Width Shapes | L4 (Variable-width shapes) + L4.5 (Pyramid/Diamond) |
| `loop_week_day_04.md` | Day 4 | Comprehensions, `zip`, Range Mastery | L7 (Range mastery — Tiers 5-6 + anti-patterns) |
| `loop_week_day_05.md` | Day 5 | Functions DEEP + While Family + Nested-Loop Traps | L5 (While family + hybrid loops) + L6 (4 classic traps) |
| `loop_week_day_06.md` | Day 6 | Mini-Problems Day (Phase 3b Final Boss + Synthesis) | L8 (Mixed synthesis) + Final Boss (P8 + P15) |
| `loop_week_day_07.md` | Day 7 | Project, Week Retrospective & Bridge to Daily Curriculum | None new — integration + bridge |

## File structure (consistent across Days 1-5; Days 6-7 deviate intentionally)

Every day file contains:

1. Theme statement + time budget + Phase 3b coverage tag + mini-boss
2. Learning goals (numbered list)
3. Time layout (block table — Block A through E or F)
4. Block content (drill problems, code examples, anti-patterns)
5. Mini-boss (3 cold problems testing the day's locks)
6. Pass/fail rules (3-strike rule per drill, mini-boss pass condition)
7. Tracker recap (paste into progress_tracker.md)
8. Memory hooks (1-line mnemonics)
9. What unlocks after this day

**Day 6 deviates:** uses Rounds 1-7 instead of Blocks (proving day, not new content).
**Day 7 deviates:** project + retrospective shape, not block-by-block.

## How routines/skills should reference this directory

- **Morning briefing routine (`routines/02-morning-briefing.md`):** when `state/current_day.md`'s `loop_week.current_day` is set, read the corresponding `loop_week_day_XX.md` for today's block plan + mini-boss target.
- **`/teach` skill:** when teaching a loop concept, check the relevant day's "Memory hooks" section for pre-locked phrasings before generating a new one.
- **`/drill` skill:** generate drills sourced from the day's drill problems, NOT invented from scratch (preserves consistency with the locked curriculum).

## Authoring discipline

- These files are **user-authored**, not auto-synced. Unlike `instructions/curriculum/*.xml` (synced daily from `Sudhan09/python_bootcamp_claude_code` by `study-curriculum-sync` routine), nothing auto-modifies these.
- Edits land via PR. Each day file should remain self-contained — a fresh session reading any one day must understand it without flipping back to other days.
- Cross-day references (e.g., "Day 2 Block B.2 Pattern 1") must remain accurate. If a Day-N file is restructured, audit cross-references in Days N+1..7.

## When this curriculum is "done"

Per `loop-strategy.md` Part 4 (Phase 4 — Free-form Cold Solve), Loop Boot Camp is officially complete when:
- Day 6's Round 6 (Final Boss — P8 + P15) is cold-clean
- Day 7's project runs cleanly on real input
- The hollow-diamond + data-pipeline benchmark from `loop-strategy.md` Part 4 passes cold

After that, this directory becomes reference material; daily bootcamp curriculum (`instructions/curriculum/curriculum_weeks04-06.xml` etc.) takes over as primary scope.
