<!-- Per design §G port plan: verbatim port of openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md -->
<!-- Per design §F schema: wrapped in proper YAML frontmatter (---) and last_updated bumped per /post-session. -->
---
last_updated: 2026-05-22T22:24:29+05:30
updated_by: /post-session
phase: 1
rollout_day: 8
latest_session: sessions/2026-05-22.md
independence_score: 3
active_targets: [F3, F1, A1]
escalated_bugs: ["F3 — operator/condition confusion; escalated 2026-05-12, re-fired 2026-05-22 (×2, exponent semantics `**2`/`**0.5`, `a**a`); 2 clean boundary-discipline reps earned 2026-05-22 (is_prime cold ×2) but same-session re-fire blocks downgrade", "F1 — variable naming; escalated 2026-05-22 (2 define/use name mismatches in drill blocks: mat/m D.3.3, num/n E.1.4); 0 clean reps", "A1 — 6× same bug Day 15 Block 3 (2026-04-08); 2 clean reps since (Loop Week Day 1 B.3 Drill #2 2026-05-12, factor_pairs D.2.2 2026-05-22); 1 more Band 2 rep + 1 Band 3 to graduate"]
band_status:
  A1: escalated-band-2 (2/3 reps; factor_pairs D.2.2 cold-clean 2026-05-22)
  B2: graduated (5 clean no-bail sessions; bail attempt resisted 2026-05-22)
  F3: escalated-band-2 (re-fired 2026-05-22 ×2 on exponents; 2 clean boundary reps earned, downgrade blocked by same-session re-fire)
  F1: escalated-band-2 (escalated 2026-05-22; 2 define/use mismatches in drill blocks; 0/2 clean reps)
---

# RTI Training State

<!-- Source of truth for #room-to-improve session state. -->
<!-- Updated by /post-session after each post-session analysis. -->
<!-- Read by /rti-preflight at the start of every #room-to-improve session. -->

## Active targets (priority order)

- **F3** — operator / condition confusion. Escalated since 2026-05-12. Re-fired 2026-05-22 ×2 on **exponent semantics** (`**2` read as square root; `a**a` written for `a**2`). Earned 2 clean boundary-discipline reps same session (`is_prime` cold ×2). The boundary/√n face is improving; the exponent-meaning face is now the live edge.
- **F1** — variable mix-up / naming. Escalated 2026-05-22 after two define/use name mismatches in drill blocks (`mat`/`m` in D.3.3, `num`/`n` in E.1.4). Was an escalation candidate from 2026-05-21; confirmed and escalated.
- **A1** — multi-step loop body / one-step transform inside loop body not automatic (carryover from Day 15 recursion; ported to loop context Loop Week Day 1). 2/3 reps toward graduation — `factor_pairs` cold-clean 2026-05-22.

## Graduated targets

- **B2** — bail-to-AI under hardest problems. Graduated 2026-05-22 after 5 clean no-bail sessions (2026-05-12, 05-19, 05-20, 05-21, 05-22). Note: the bail impulse still surfaced under the hardest problem on 2026-05-22 (`element_wise` — "can you write?") but was self-corrected with no handoff. Informal light watch only; no longer a tracked target.

## Escalated bugs

- **F3** — operator/condition confusion. Escalated 2026-05-12 (3+ same-session slips). Re-fired 2026-05-22 ×2 on exponent semantics: read `** 2` as square root (D.3 Form 2), wrote `a**a` for `a**2` (`pythagorean_triples` E.1.4). Earned 2 clean operator-heavy reps same session (`is_prime` D.2.1 cold + Mini-Boss B cold — √n, `**0.5`, `+1` all correct) — but the same-session re-fire blocks a downgrade. Status: still escalated; the boundary/condition face is now reliable, the **exponent-meaning** face (`**2` square vs `**0.5` root vs `**var`) is the remaining target.
- **F1** — variable mix-up / naming. Escalated 2026-05-22. Two define/use name mismatches in drill blocks: defined `mat` then used `m` (D.3.3 — NameError); parameter `num` but ranges used `n` (`pythagorean_triples` E.1.4 attempt 2 — NameError). Plus looser slips (non-descriptive `mat`, `i` for an item). Status: escalated-band-2; need 2 independent Band 2 reps on naming-sensitive drills before downgrading. Drill target: define-name = use-name discipline; singular loop variable vs plural collection name.
- **A1** — 6× same bug Day 15 Block 3 recursion (2026-04-08). Status: 2 clean independent reps since escalation (Loop Week Day 1 B.3 Drill #2 2026-05-12; `factor_pairs` D.2.2 2026-05-22). Need 1 more independent rep at Band 2, then 1 at Band 3 to graduate.

## Band status

- **A1:** escalated-band-2 (2/3 reps toward graduation; `factor_pairs` D.2.2 cold-clean 2026-05-22)
- **A2:** watch (no fresh evidence today)
- **A3:** not-started
- **A4:** not-started
- **B2:** graduated 2026-05-22 (5 clean no-bail sessions; bail attempt resisted on `element_wise`)
- **C1:** watch (no fresh evidence today)
- **D3:** no-new-data
- **E1:** no-new-data
- **F1:** escalated-band-2 (escalated 2026-05-22; 2 define/use mismatches in drill blocks; 0/2 clean reps)
- **F3:** escalated-band-2 (re-fired 2026-05-22 ×2 on exponents; 2 clean boundary reps earned, downgrade blocked)

## Re-test queue

- `diamond` / `is_palindrome_clean` / `compress` — Day 3 Block F gate, outstanding since 2026-05-20
- Exponent-discipline drills — `**2` (square) vs `**0.5` (root) vs `**var`, F3 post-escalation target (exponent face)
- Variable-naming discipline drills — define-name = use-name, singular-vs-plural — F1 post-escalation Band 2 target
- Loop→comprehension translation reps — `sum(generator)` structure + Form 6 vs Form 8 — translation-reflex soft spot from Mini-Boss A
- One more multi-step-body rep (A1 rep #3 toward graduation) — Day 5 higher-order drills are a natural fit
- One sum-of-digits style recursion (carryover from 2026-04-08 queue) — A1 in recursion context, deferred until loop block stabilizes

## Checkpoint pending

false

## Notes

Loop Week Day 4 second half (2026-05-22) — Blocks D, E, F; Day 4 complete. Teaching session with drills throughout; independence 3 (self-rated; companion read a 2–3 split — clean on Block D + E.1 drills, heavily scaffolded on E.2 `MatrixOps` + `pythagorean_triples`). No `[AI]`-completed drills.

F3 split this session: the boundary/√n/condition face earned 2 clean operator-heavy reps (`is_prime` cold ×2), but it re-fired ×2 on **exponent semantics** — the user read `**2` as square root and wrote `a**a` for `a**2`. The exponent-meaning face is now the explicit F3 target; the boundary face is close to a downgrade once a clean session without re-fire lands.

F1 escalated: the 2026-05-21 escalation-candidate flag is confirmed — two define/use name mismatches in drill blocks (`mat`/`m`, `num`/`n`) this session, both NameErrors. F1 is now a tracked escalated target.

B2 graduated: 5 clean no-bail sessions. The bail impulse still surfaces under the single hardest problem of a session — flagged informally, not tracked.

Object/class foundation gap: E.2 `MatrixOps` exposed that "what is an object" was never solidly taught (Day 3's `StringAnalyzer` class block was skipped). ~6 re-angles needed before the wrap-in-`MatrixOps` concept landed. Recommend an object-fundamentals teach before future class work.

Curriculum bug: Day 4 `pythagorean_triples(20)` answer key omits the valid triple `(12,16,20)` — needs a fix in the pipeline `config/` source.
