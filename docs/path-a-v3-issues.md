<!-- Research input for Path A v3 design — DO NOT use as authoritative spec. -->
<!-- This document captures issues found during a prior 104-scenario simulation. -->
<!-- Generated 2026-05-07 by coordinator session. The executor research session should -->
<!-- treat this as starting input and re-run simulation to fill gaps + verify. -->

# Path A v3 — Issues Inventory

## Provenance

A prior simulation ran 104 scenarios across the proposed pause + carry-forward design. Output:

| Severity | Count | Documented in this file |
|---|---|---|
| 🔴 Critical | 16 | 10 explicitly enumerated below; 6 implied (re-run simulation to surface) |
| 🟡 Medium | 62 | All 62 explicitly enumerated below |
| 🟢 Cosmetic | 26 | Not enumerated (out of scope for Path A v3 research) |

Plus:
- 10 design ambiguities (user must decide)
- 8 design assumptions proven wrong
- 5 highlighted edge cases (worth special handling)
- 6 NEW gaps in Path A surfaced during audit

---

# 🔴 Critical Gaps (10 of 16 explicitly named)

## CRIT-01 — `mode: paused` is not readable by any existing routine or hook

**Scenario:** User sets `mode: paused` in `state/current_day.md` by running `/pause-routines`. The next morning, routine #2 (morning-briefing) runs at 09:00 IST, reads `state/current_day.md`, finds `mode: paused`, and has no defined behavior for this field — the design spec for morning-briefing reads the `bootcamp.*` and `loop_week.*` keys but has zero conditional logic on `mode`. It writes a full briefing as if today is a normal study day.

**Why critical:** The briefing fires Slack (via GitHub Actions auto-merge), Sudhan sees an active schedule on vacation, and the system signals "normal" when it should signal "paused". The pause state is invisible to the infrastructure layer.

**Fix proposed:** Add a mandatory `mode` guard at the top of every routine's Step 2 (after reading `state/current_day.md`). If `mode == paused`, the routine must write a one-line sentinel file (e.g., `state/schedule.md` with `status: paused, no briefing produced`) and exit without writing a full schedule. The auto-merge workflow should distinguish this commit type and suppress the Slack body to a one-liner: "routine skipped — mode=paused".

---

## CRIT-02 — `/pause-routines` skill has no defined writer path — `vacation.md` is never committed

**Scenario:** User invokes `/pause-routines` in a Cowork session. The skill presumably writes `state/vacation.md` (or sets `mode: paused` in `current_day.md`), but Cowork hooks are dormant per #40495. There is no Stop hook or PostCompact hook firing in Cowork to push that state to GitHub. The file exists only in the local Cowork sandbox mount, which is not a Git repo with auto-push.

**Why critical:** The cloud routines run against the GitHub repo, not the Cowork sandbox. If `/pause-routines` never pushes, every routine continues running on vacation. The user believes the system is paused; the system believes nothing has changed.

**Fix proposed:** `/pause-routines` must explicitly commit and push as part of its own skill body — not rely on a hook. The skill must end with: read `state/current_day.md`, set `mode: paused`, write `state/vacation.md` with `start_date`, then run `git add state/current_day.md state/vacation.md && git commit -m "chore(pause): mode=paused from <date>" && git push origin main`. On Cowork, this requires granting git execution within the skill body — the design needs to explicitly authorize this.

---

## CRIT-03 — Carry-forward counter in `missed_routines.md` has no cap — infinite backlog

**Scenario:** Sudhan takes a 3-week vacation (tournament trip). `/pause-routines` runs Day 1. The 8 daily routines fire regardless (CRIT-01 not yet fixed, or pause write failed per CRIT-02). After 21 days: `missed_routines.md` logs 8 × 21 = 168 missed executions. On `/resume-routines`, the carry-forward logic sees 168 entries and either (a) tries to replay all of them, hanging for hours, or (b) applies all missed-days penalties to the RTI bands, incorrectly escalating 3 clean weak spots to Band 4 based on "0 reps in 21 days."

**Why critical:** Data corruption. The RTI band escalation logic (`state/active_weak_spots.md`) would falsely classify weak spots as critically regressed after a legitimate vacation break, affecting the actual study plan on return.

**Fix proposed:** `missed_routines.md` must have a `max_carry_forward_days: 7` field (configurable). On `/resume-routines`, anything beyond 7 days is archived as "skipped (vacation)" not "missed (regression)". RTI bands must NOT auto-escalate during a `mode: paused` window. Add explicit logic: if `state/vacation.md` covers the gap between last session and now, no band escalation occurs.

---

## CRIT-04 — Adding `mode` field is a breaking change for all 8 routines simultaneously

**Scenario:** Developer adds `mode: bootcamp | loop_week | paused` to `current_day.md`. All 8 routines parse `current_day.md` in their Steps. None of them currently handle an unknown key. Routine #1 (curriculum-sync) has no `mode` awareness; it will sync curriculum regardless. Routine #7 (drift-audit) reads `SOURCE_OF_TRUTH.md` first — but `SOURCE_OF_TRUTH.md` doesn't list `mode` as an allowed field. The `validate-state-schemas.js` test will fail on the new key without a schema update.

**Why critical:** A schema migration that doesn't update all 8 routine prompts, the state validator, and `SOURCE_OF_TRUTH.md` atomically will cause validator failures on the very first pause commit — which triggers GitHub Actions `run-validators.sh`, causing the auto-merge to fail, which sends a Slack error, which is visible to the user as an infrastructure failure rather than a feature.

**Fix proposed:** Add `mode` to `SOURCE_OF_TRUTH.md`'s "Allowed extra frontmatter fields" table for `current_day.md`. Update `validate-state-schemas.js` to accept `mode` as an optional string with allowlisted values `[bootcamp, loop_week, paused]`. Update all 8 routine prompts to check `mode` before their Step 3.

---

## CRIT-05 — Auto-merge workflow allowlist excludes `claude/pause-routines-*`

**Scenario:** `/pause-routines` skill pushes to `claude/pause-routines-2026-06-01`. The GitHub Actions trigger is defined with 8 explicit branch patterns. `claude/pause-routines-*` is not in the list. The push happens, Actions does not trigger, the merge to main never happens, `mode: paused` never lands on main, all routines keep running.

**Why critical:** Silent failure. No Slack alert. No error. The user thinks pause is active; GitHub main still has `mode: bootcamp`. Worse outcome than CRIT-02 because there's no observable signal that anything is wrong.

**Fix proposed:** Either add `claude/pause-routines-*` and `claude/resume-routines-*` to the Actions `on: push: branches:` allowlist, OR redesign the pause flow so it pushes directly to `main` (skipping the `claude/*` branch pattern). Given the design's "default-deny on main" rule, the allowlist extension is the right fix.

---

## CRIT-06 — `/resume-routines` has no defined logic for which day to "return to"

**Scenario:** User resumes after a 10-day vacation. `state/current_day.md.bootcamp.current_day` was last set to Day 35 by `/day-wrap` 10 days ago. `loop_week.current_day` was Day 3. On resume, the morning briefing reads these values and briefs for Day 36, Loop Day 4 — as if no time passed.

**Why critical:** Curriculum day is wrong. The briefing will load the wrong `active-chunk.xml`, show the wrong weak-spot drill targets, and set the wrong `[Phase P • Day D]` anchor. The user's first session back starts on the wrong content.

**Fix proposed:** `/resume-routines` must explicitly calculate the correct resume day: read `state/vacation.md.start_date`, compare to today, then check `progress_state.xml`'s `<completed_through_day>` (unchanged since vacation). The resume logic must set `current_day.md.bootcamp.current_day` to `completed_through_day + 1` (not blindly to `current_day + 10`).

---

## CRIT-07 — Routine #6 (monday-distillation) archives vacation-period logs that don't exist

**Scenario:** User on vacation 2 weeks starting Tuesday. Morning-briefing (CRIT-01 unresolved) writes empty header logs daily. Monday post-vacation, distillation archives 12 phantom log files as "completed days" with "Sessions: 0", "Drills: None", "Wins: None" — visually indistinguishable from genuine 12-day-no-output study.

**Why critical:** Data integrity. Weekly-review's "Sessions logged: N" count becomes meaningless. Streak/accountability metrics corrupted by 12 phantom session files.

**Fix proposed:** `state/vacation.md` records `start_date` and `end_date`. Routine #6 (distillation) checks these dates: if `log_date` is within a vacation window, label the archived file as `type: vacation_gap` not `type: study_session`, and exclude it from the session-count in `state/distilled.md`.

---

## CRIT-08 — `state/schedule.md` is written every day including pause — leaves stale plan visible

**Scenario:** User pauses Friday. Saturday and Sunday, morning-briefing skips writing schedule. `state/schedule.md` still contains Friday's plan. Monday user resumes; SessionStart hook injects 3-day-old "Block A: Loop Day 3 drills" as today's schedule.

**Why critical:** Stale schedule injected into AI context as authoritative. Asta references it, creating misleading session opening.

**Fix proposed:** `/pause-routines` writes `state/schedule.md` with `mode: paused` banner and clears the block plan to "No plan — system paused". `/resume-routines` forces a fresh morning-briefing run before first interactive session.

---

## CRIT-09 — `daily-wrap` job has no `mode` awareness — posts normal Slack during vacation

**Scenario:** User on 5-day vacation. Daily-wrap cron job runs every day at 21:00 IST regardless. Reads drift_log.md, posts to Slack. During vacation: posts normal-looking daily summary, making vacation invisible to notification stream.

**Why critical:** Slack untrustworthy as health signal. Normal daily-wrap during declared vacation = notification system loses credibility.

**Fix proposed:** `build-daily-wrap.sh` checks `state/current_day.md.mode`. If `mode: paused`, daily-wrap message says "System paused (vacation) — no routines expected today" with vacation start date.

---

## CRIT-10 — `/pause-routines` race condition: 9.5-hour gap before next routine fire

**Scenario:** User invokes `/pause-routines` at 11:00 PM IST. Skill writes `state/vacation.md` and modifies `state/current_day.md`. Next cloud routine fires at 08:30 IST (9.5 hours later). If Git commit doesn't reach main before 08:30 IST, routine runs on old state.

**Why critical:** Race condition window. Pause push at 11:59 PM IST, Actions completes 00:01 IST, morning-briefing 08:30 IST sees correct paused state — no race. But if push fails (network, auth, Actions failure), 8.5-hour window means morning-briefing runs as normal. Failure invisible until Slack delivers normal briefing.

**Fix proposed:** Explicit check in `/pause-routines`: after pushing, verify the branch appears on GitHub (via `gh api` or equivalent), then explicitly wait for the Actions run to complete (or poll). If Actions doesn't complete within 5 minutes, skill alerts user: "Pause push pending — verify in Slack before closing Cowork."

---

## CRIT-11 through CRIT-16 — Re-run simulation to surface

The first 10 critical gaps are above. The remaining 6 critical scenarios identified by simulation but not explicitly named in the agent's synthesis output. The executor research session should re-run the 104-scenario simulation as Step 2 of their brief to enumerate these.

---

# 🟡 Medium Issues (62 explicitly enumerated)

## Category M1: State File Schema Consistency (8 scenarios)

**M1-1** `current_day.md` mode field missing on repos built before Path A ships — reader routines encounter an unknown schema.

**M1-2** `state/vacation.md` is written but `current_day.md` mode is not updated atomically — window where `mode=bootcamp` but vacation.md exists.

**M1-3** `state/vacation.md` left on disk after `/resume-routines` runs — downstream routines see a stale active record.

**M1-4** `state/missed_routines.md` grows past the 7-day cap — stale entries consume replay incorrectly.

**M1-5** ISO-8601 timestamps without explicit TZ offset stored in vacation.md — IST boundary comparisons fail silently.

**M1-6** `missed_routines.md` `reference_date` field missing from entries written by old version of Step 0 preamble — replay logic cannot determine original fire date.

**M1-7** `loop_week.active` and `loop_week.completed` both set to true simultaneously — undefined state for routines keying off these flags.

**M1-8** `bootcamp.current_day` and `loop_week.current_day` incremented by morning-briefing and `/day-wrap` respectively; Path A adds no write-lock — both can increment during a resume race.

## Category M2: Pause/Resume Lifecycle (10 scenarios)

**M2-1** User triggers `/pause-routines` twice before first pause commits — two concurrent vacation.md writes race.

**M2-2** `/pause-routines` sets `mode=paused` but Git push to GitHub fails (transient network) — local state paused but GitHub sees `mode=bootcamp`.

**M2-3** `/resume-routines` runs but `progress_state.xml.completed_through_day + 1` resolves to a day that doesn't exist in curriculum (e.g., user on last day).

**M2-4** User runs `/resume-routines` after 09:00 IST Monday — monday-distillation already ran with stale state.

**M2-5** `/resume-routines` posts Slack confirmation but `state/last_session_summary.md` rewrite fails mid-way — Slack says resumed but state inconsistent.

**M2-6** 30-day pause limit elapses with no user action — cron continues to fire, but vacation.md still exists, so all 8 routines skip indefinitely.

**M2-7** User edits vacation.md manually (e.g., extends end_date) without going through `/pause-routines` — schema validation passes but mode field in current_day.md not updated.

**M2-8** `/pause-routines` invoked Sunday morning with retrospective routines (#5 weekly-review and #7 drift-audit) not yet run — "run-once-before-pause" exception triggered.

**M2-9** User wants to pause mid-week but pause start_date in vacation.md is in the past (forgot to pause earlier) — carry-forward replay would cover days already partially recorded.

**M2-10** `/pause-routines` run from Claude Code app (not Cowork) — skill spec lists both surfaces but self-commit mechanism relies on routine having write access.

## Category M3: Carry-Forward Replay (9 scenarios)

**M3-1** Catch-up replay for routine #2 (morning-briefing) on resumed Monday — retroactively writes `state/schedule.md` for past dates that already have log entries, creating timestamp inversion.

**M3-2** Catch-up replay for routine #1 (curriculum-sync) on resume day — pipeline repo may have advanced several versions during vacation.

**M3-3** Two routines in `missed_routines.md` with same reference_date — replay ordering within a single day undefined.

**M3-4** Catch-up replay for routine #6 (monday-distillation) — distillation archives logs that may include vacation-window sessions that shouldn't be distilled yet.

**M3-5** `missed_routines.md` accumulates 7 days × 8 routines = up to 56 replay items — replay on resume day could time out, leaving partial-replay state.

**M3-6** Routine #3 (spaced-rep-reminder) catch-up replay fires but `state/active_weak_spots.md` updated since vacation started — replay picks drills targeting weak spots that have since been resolved.

**M3-7** Catch-up replay for routine #5 (weekly-review) fires resume Tuesday — review window extends back into vacation. Should mark vacation days as gaps.

**M3-8** `missed_routines.md` has entry for routine #8 (branch-cleanup) — catch-up replay would try to clean merged branches, possibly including pause/resume branches.

**M3-9** Replay of routine #4 (commit-reminder) for missed days during vacation — repo will have zero commits, every replay fires `[ZERO-COMMIT]`. User returns to find 7 `[ZERO-COMMIT]` tags.

## Category M4: Cron / GitHub Actions Scheduling (7 scenarios)

**M4-1** Routines #3-#8 now on daily cron schedules. Routine #3 (spaced-rep-reminder) was originally Mon-Sat — Sunday spaced-rep fires into a day designated for weekly review.

**M4-2** GitHub Actions workflow allowlist extended to `claude/pause-routines-*` and `claude/resume-routines-*`. A branch named `claude/pause-routines-malicious` could trigger workflow if pushed externally.

**M4-3** Routine #6 (monday-distillation) fires 09:00 IST Monday; `/resume-routines` deadline "before 09:00 IST Monday." If resume completes 08:58 IST, distillation runs 2 minutes later, may see partially-written state.

**M4-4** `build-daily-wrap.sh` reads vacation.md but GitHub Actions runner's file cache might serve stale version if file written seconds ago.

**M4-5** Day 1 of vacation = "🛫 Vacation started" in daily wrap. If pause set 23:55 IST and daily wrap fires 00:00 IST (within 5 minutes), "vacation started" message appears before user's day actually ends.

**M4-6** Routines #5 (weekly-review) and #7 (drift-audit) now daily per Path A. These are explicitly weekly in original design (Sunday-only). Running daily produces 7× output, drift-audit's 7-day window logic assumes once-per-7-days.

**M4-7** `skip:` commit message prefix applied to skip-branches not pushed to GitHub. build-daily-wrap.sh potentially parses commit messages but `skip:` prefix in local-only commit wouldn't appear in Actions context.

## Category M5: RTI Band Staleness (5 scenarios)

**M5-1** RTI bands don't auto-decay during pause (Path A says "staleness annotation only"). After 3-week pause, A1 remains at Band 2 even though user hasn't drilled in 21 days — overconfidence risk.

**M5-2** Staleness annotation added to RTI state file, but `state/active_weak_spots.md` has no corresponding annotation — morning-briefing reads both, gets mixed signals.

**M5-3** Staleness annotation in RTI state written by `/resume-routines`. If user resumes but doesn't read morning briefing, annotation may be overwritten by first post-session run.

**M5-4** After 30-day pause, RTI state says Band 2 for A1, but 30 days no drilling = effectively Band 1. Spaced-rep-reminder will still target Band 2 drills on resume day.

**M5-5** Routine #7 (drift-audit) flags vacation-window logs as "vacation_gap." If user did informal study during vacation (e.g., mobile) and Stop hook didn't fire, drift_log empty — drift-audit reports "no data" which is technically correct but misleading.

## Category M6: Skill Invocation Edge Cases (7 scenarios)

**M6-1** `/pause-routines` invoked during active teaching session in Cowork — self-commit interrupts session context.

**M6-2** `/resume-routines` rewrites `state/last_session_summary.md` with gap notice. Existing last_session_summary.md may have been last real session's data — overwriting it loses that data permanently.

**M6-3** ALLOWED_WRITERS list in Source of Truth includes pause/resume skills. But validator only checks schema compliance, not that writer field matches allowed list — rogue write with `updated_by: some-other-skill` would pass validation.

**M6-4** `/pause-routines` writes vacation.md and self-commits, but morning-briefing routine has already started in same 30-second window — morning-briefing reads vacation.md as absent and proceeds normally, then pause commit lands.

**M6-5** `/resume-routines` posts Slack confirmation. If Slack down, resume complete from state perspective but user gets no notification.

**M6-6** Resume skill reads `progress_state.xml.completed_through_day + 1`. progress_state.xml in `instructions/curriculum/` synced by routine #1. If routine #1 hasn't run since resume, XML has pre-vacation completed_through_day.

**M6-7** User invokes `/pause-routines` when `state/vacation.md` already exists (e.g., from uncommitted previous run) — skill should be idempotent but Path A doesn't specify idempotency contract.

## Category M7: Hook Behavior Under Pause (6 scenarios)

**M7-1** Stop hook runs during paused session (user opens claude.ai/code casually). Drift entries logged even during vacation — RTI state accumulates noise.

**M7-2** SessionStart hook reads `state/vacation.md` but file doesn't exist yet (pre-pause build). Hook needs graceful degrade when vacation.md absent.

**M7-3** SessionStart hook injects context from `state/last_session_summary.md`. After `/resume-routines` rewrites it with gap notice, first session post-resume gets gap notice injected — correct but might dominate context window.

**M7-4** PreCompact hook fires during paused session — snapshots state file paths, but vacation.md doesn't appear in standard state file list. After compact, PostCompact re-loads snapshot. vacation.md state not preserved across compaction.

**M7-5** UserPromptSubmit hook fires on "pause" or "vacation" natural language — could conflict with `/pause-routines` skill invocation.

**M7-6** Stop hook appends to `state/drift_log.md` in append-only pattern. During long pause, drift_log has no entries. After resume, first session's entries appear with timestamp gap of weeks. Drift-audit's 7-day window will always exclude vacation entries.

## Category M8: Cross-Routine Data Dependencies (10 scenarios)

**M8-1** Morning-briefing reads `instructions/curriculum/.last-sync-status` to verify routine #1 ran. During pause, routine #1 doesn't run — `.last-sync-status` grows stale. On resume, morning-briefing sees stale status and emits `[STALE-CURRICULUM]` even though curriculum itself fine.

**M8-2** Routine #7 (drift-audit) reads `state/weekly-review-<this-Sunday>.md` (just written by routine #5). If routine #5 in catch-up replay and fires after routine #7's cron time, routine #7 sees file absent and sets `FRESHNESS_FLAG=stale`.

**M8-3** Routine #6 (monday-distillation) uses `git mv` to archive logs. During catch-up replay, if replay triggers routine #6, `git mv` happens inside routine sandbox — but study-companion repo's main branch doesn't see this until routine's branch merged.

**M8-4** Morning-briefing reads `state/last_session_summary.md`. `/resume-routines` rewrites with gap notice. Gap notice is correct content to brief from. But morning-briefing template extracts specific fields (`Completed`, `Unresolved`, `Tomorrow's first task`) — gap notice may not populate these fields in expected schema.

**M8-5** Routine #3 (spaced-rep-reminder) selection algorithm reads `state/spaced-rep-<previous-3-dates>.md` to avoid re-prompting recent drills. During vacation, these files weren't written. On resume, routine sees no recent files and always picks first drill in sorted list.

**M8-6** Routine #5 (weekly-review) writes `state/weekly-review-<date>.md`. Routine #7 (drift-audit) reads as cross-reference. After pause, first Sunday's weekly-review covers window entirely vacation — review will be sparse. Drift-audit receives sparse review as baseline.

**M8-7** `/resume-routines` reads `progress_state.xml.completed_through_day + 1` but XML in `instructions/curriculum/` written by routine #1. If `/resume-routines` runs before routine #1's next sync, XML is pre-vacation version.

**M8-8** Routine #8 (branch-cleanup) uses `git branch -r --merged origin/main` to identify candidates. Pause/resume branches merged per Path A's "self-commits, self-pushes." Branch-cleanup correctly treats them as candidates after 30 days.

**M8-9** Routine #4 (commit-reminder) checks study-companion commits. During vacation, pause/resume skill commits (vacation.md writes, resume state updates) appear as real commits. Day with only pause-skill commit would NOT get `[ZERO-COMMIT]` even though no study happened.

**M8-10** Monday-distillation archives logs older than 7 days. `vacation_gap` annotation only specified for logs that fall within vacation window. What about partial-vacation logs — log starting last day before vacation where only Block A completed?

---

# 🟠 6 New Gaps Surfaced in Audit (NOT in original 104)

## GAP-01 — Resume ordering contract is undefined

Path A specifies what `/resume-routines` does but not when relative to routine #1's next sync. Curriculum source-of-truth for resume day calculation may be 1–24 hours stale. A sequencing rule ("resume must happen after 08:30 IST on resume day to ensure fresh curriculum XML") would close this.

## GAP-02 — last_session_summary.md destructive overwrite

Path A's `/resume-routines` spec uses "rewrites" without an archive step. Every other state-file mutation in the architecture is either append-only (drift_log), additive (wins), or explicitly version-preserving (archive/completed_days). The resume skill is the only writer that destroys prior content without preservation.

## GAP-03 — vacation.md / current_day.md sync on manual edits

Path A adds schema validators but no cross-file consistency check. A user manually editing either file can create state where vacation.md says "active vacation" but current_day.md says `mode=bootcamp` (or vice versa). Adding a consistency validator (run by SessionStart hook or as pre-push hook) would close this.

## GAP-04 — Ambiguity A1 is structurally ambiguous in Path A's own text

Architecture says "Cron schedules changed to daily for routines #3, #4, #5, #6, #7, #8" — but existing designs for #3 and #4 explicitly exclude Sunday for user-experience reasons (recovery day), and #5 and #7 are inherently weekly by design. It's almost certain the intent is "Step 0 preamble runs daily on all routines" not "all routines fire daily." But as written, ambiguous.

## GAP-05 — No definition of catch-up replay ordering within a single date

7-day cap on missed_routines.md and per-replay atomic removal specified. But if 4 routines missed same day, order they replay in is undefined. Routine ordering matters because routine #3 (spaced-rep) should ideally fire after routine #2 (morning-briefing) has written today's schedule.

## GAP-06 — Branch-cleanup catch-up replay is unspecified

Routine #8 is maintenance routine that deletes merged branches. Whether it participates in catch-up replay is unspecified. If yes, catch-up run on resume day could delete pause/resume branches themselves. If no, must be explicitly excluded from missed_routines carry-forward list.

---

# 🟡 10 Design Ambiguities (User Must Decide)

## A1 — Suppress all routines or only "study-specific" ones?

Routine #1 (curriculum-sync) is infrastructure. #8 (branch-cleanup) is maintenance. #5/#7 (weekly-review, drift-audit) are retrospective.

**Option A:** Suppress all 8. Clean but means no curriculum syncing on vacation.
**Option B:** Suppress study-facing only (#2, #3, #4); keep infrastructure running.
**Recommendation:** Option B. `vacation.md` lists explicit `suppress_routines: [...]`.

## A2 — Who owns `state/current_day.md.bootcamp.current_day` on resume?

**Option A:** `/resume-routines` auto-sets from `progress_state.xml.completed_through_day + 1`.
**Option B:** Asks user to confirm.
**Option C:** Leave stale, rely on morning-briefing to reconcile.
**Recommendation:** Option A with Slack notification showing computed day.

## A3 — Canonical format of `state/vacation.md`?

**Option A:** Simple frontmatter-only file with fixed schema.
**Option B:** Append-log preserving history.
**Recommendation:** Option A for active record + separate `archive/vacations.md` append-log for history.

## A4 — Should carry-forward items in `missed_routines.md` be replayed on resume?

**Option A:** Replay all missed back-dated.
**Option B:** Replay only today's at normal time.
**Option C:** No replay.
**Recommendation:** Option C for most, with partial exception: run curriculum-sync once on resume + write resume-day morning briefing.

## A5 — Does `/resume-routines` re-enable routines immediately or only from next cron?

**Option A:** Immediate re-enable via workflow_dispatch.
**Option B:** Next cron window.
**Recommendation:** Option B with placeholder schedule.md indicating "manual resume briefing pending."

## A6 — What happens when `mode: paused` daily-wrap goes out then vacation ends early?

**Option A:** Accept the confusion.
**Option B:** `/resume-routines` triggers immediate Slack notification.
**Recommendation:** Option B.

## A7 — Does `loop_week.active: true/false` track loop_week pause separately from `mode: paused`?

**Option A:** Collapse — `mode: paused` means everything paused.
**Option B:** Keep both.
**Recommendation:** Option A. Two pause signals = maintenance trap.

## A8 — Who writes `missed_routines.md`?

**Option A:** Each routine when detecting `mode: paused`.
**Option B:** Separate monitoring routine.
**Option C:** `/pause-routines` pre-emptively.
**Recommendation:** Option A.

## A9 — What does `/resume-routines` do with RTI bands that haven't had reps in N days?

**Option A:** Time decay — band resets to "watch" after >7 days.
**Option B:** No time decay.
**Option C:** Time decay informational only.
**Recommendation:** Option C.

## A10 — Should auto-merge daily-wrap be suppressed on paused day or post "paused" confirmation?

**Option A:** Suppress entirely.
**Option B:** Post minimal heartbeat: "System paused. Vacation day N of M."
**Recommendation:** Option B with twist — post only Day 1 of vacation and last day, not every day in between.

---

# 8 Design Assumptions Proven Wrong

## A1-WRONG — "Routines are stateless"

Adding pause makes them stateful. The mode field is persistent state that must be READ and WRITTEN atomically by skills whose hooks are dormant in Cowork.

## A2-WRONG — "`state/current_day.md` is single source of truth"

After vacation, current_day.md contains last pre-vacation state. It's authoritative for mode but stale for day counter. Two sources of truth needed: current_day.md (for mode) and progress_state.xml (for canonical curriculum position). Resume must reconcile.

## A3-WRONG — "Auto-merge allowlist covers all routine branches"

8 routines = 8 branch patterns ≠ complete coverage. Pause/resume flow requires 2 more (`claude/pause-routines-*`, `claude/resume-routines-*`). Allowlist is a contract that must update each time a new state-writing skill is added.

## A4-WRONG — "Cowork skills can modify state without explicit push"

State-critical skill like `/pause-routines` cannot leave push as user responsibility. Infrastructure-critical state changes must be self-committing within skill body.

## A5-WRONG — "RTI band state survives pause intact"

Long pause makes band data stale operationally. "Band 2 escalated, 0/3 reps since escalation" from 3 weeks ago is neither valid evidence of mastery nor safe to ignore. No staleness model in design.

## A6-WRONG — "Morning-briefing writing logs daily is always correct"

During vacation, morning-briefing writes header-only log files identical to legitimate "low-activity study days." Distillation archives as study-day records. Historical record contaminated with phantom session files.

## A7-WRONG — "30-min gap between curriculum-sync and morning-briefing is sufficient"

Actions pipeline adds ~2 min but bottleneck is Actions queue. On shared runners, queue wait can be 5-15 min at peak times. 30-min buffer adequate only when Actions runs immediately. Post-vacation resume day with stale routines catching up could exhaust queue.

## A8-WRONG — "Routine failure observable via Slack within minutes"

`if: always()` step fires but pause/resume branches not in allowlist (CRIT-05). Pushes to those branches never trigger Actions. Failure structurally invisible — no negative signal, no positive signal, just silence.

---

# 5 Highlighted Edge Cases

## EC-01 — Vacation starts Sunday — weekly-review and drift-audit fire before pause lands

Sudhan pauses 09:45 IST Sunday. Weekly-review fires 10:00 IST, drift-audit 10:30. `/pause-routines` push goes out 09:45 IST, takes ~2-3 min Actions to merge — landing main ~09:48 IST. Both retrospective routines fire after pause merged at 09:48 IST and read 10:00, see `mode: paused`, skip — leaving no weekly review for last active study week.

**Fix:** "Last-run-before-pause" semantic for retrospective routines. Run once even if `mode: paused` if scheduled day and not yet run today.

## EC-02 — IST/UTC date boundary

Sudhan sets `mode: paused` at 23:55 IST May 7. `vacation.md.start_date` written as `2026-05-07` (IST date). Commit lands GitHub 23:55:30 IST = 18:25:30 UTC = still May 7 UTC. Routines computing date comparisons in UTC see 1-day discrepancy in vacation window.

**Fix:** All date fields use ISO-8601 with explicit timezone offset (`2026-05-07T23:55:00+05:30`), not bare dates. Routines normalize to IST before comparing.

## EC-03 — First Monday post-vacation: distillation + resume + morning-briefing race

Vacation Wed-Sun (5 days). Monday: monday-distillation 09:00 IST, `/resume-routines` user-triggered some Monday morning, morning-briefing 09:00 IST. Three writes to overlapping state files with no lock = race.

**Fix:** Routine ordering on resume day explicitly sequenced: `/resume-routines` runs first as user-triggered, setting `mode: bootcamp` before any cron routines fire. Resume must complete BEFORE 09:00 IST Monday.

## EC-04 — GitHub Actions 60-day inactivity auto-disable during long vacation

Sudhan takes 10 weeks off (extended travel, health, trading focus). GitHub auto-disables workflows after 60 days inactivity. Auto-merge-and-notify workflow goes offline. When Sudhan returns and `/resume-routines` runs, first routine push triggers Actions — but workflow disabled. Silent break.

**Fix:** Document 30-day pause limit. If vacation exceeds 30 days, user manually re-enables workflow on day 31. Document explicitly in `/pause-routines` skill output when `end_date` >30 days from today.

## EC-05 — `last_session_summary.md` shows pre-vacation content on first resume — Asta opens with "yesterday's recursion drill" but yesterday was 10 days ago

Last session before vacation May 7 (recursion A1). User resumes May 17. SessionStart hook injects last_session_summary.md. File says "Yesterday: recursion A1 — partial. Band 2, 1/3 reps." Asta opens session: "Yesterday left off at recursion A1." The "yesterday" is 10 days ago.

**Fix:** `/resume-routines` updates last_session_summary.md with "returning from vacation" header: `last_session_date: 2026-05-07`, `vacation_gap: 10 days`, note for session to open with brief re-orientation. SessionStart hook checks: if `last_session_date` >1 day ago, prefix injected summary with `[NOTE: last session was N days ago — historical context, not yesterday]`.

---

# Summary Counts

- Total scenarios: 104
- Critical (🔴): 16 (10 enumerated above + 6 to surface via re-simulation)
- Medium (🟡): 62 (all enumerated above as M1-1 through M8-10)
- Cosmetic (🟢): 26 (out of scope)
- Plus: 6 NEW gaps in Path A (GAP-01 through GAP-06)
- Plus: 10 ambiguities (A1-A10), 8 wrong assumptions, 5 highlighted edge cases

# Re-Simulation Required

Executor research session should re-run the 104-scenario simulation as Step 2 of their brief to:
1. Surface the 6 unnamed criticals (CRIT-11 through CRIT-16)
2. Verify M1-M8 enumeration is complete
3. Confirm cosmetic items are truly out-of-scope (don't promote any to medium)

Use this document as starting input + ground truth for the items already enumerated.
