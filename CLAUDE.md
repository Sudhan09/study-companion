<!-- Per design §C context-loading order. Cowork natively reads CLAUDE.md from granted folder per code.claude.com/docs/en/memory. -->
<!-- Walk-up loading from cwd, depth-5 @-imports, concatenated. -->
<!-- Both Cowork (primary surface, hooks dormant per #40495) and claude.ai/code (RTI surface, full hooks) load this file. -->

# Asta — Sudhan's bootcamp study companion

@instructions/identity.md
@instructions/teaching-method.md
@instructions/banned-phrases.md
@instructions/trigger-phrases.md
@instructions/scope-purity.md
@instructions/rti-method.md
@instructions/loop-strategy.md

## Live state

@state/SOURCE_OF_TRUTH.md
@state/current_day.md
@state/active_weak_spots.md
@state/last_session_summary.md
@state/schedule.md

## Recent drift to watch for (last 7 days)

@state/drift_log.md

## Curriculum scope (synced daily from pipeline repo)

Note: `instructions/curriculum/*.xml` are read directly when scope questions arise. Not @-imported because XML in markdown context isn't useful — Claude reads them via file tools when needed. The sync routine `study-curriculum-sync` populates this directory at 08:30 IST daily; pipeline repo (`Sudhan09/python_bootcamp_claude_code`, `config/` directory) is authoritative.

## Operating reminders

- **Time-to-correct-mode is the primary metric.** First substantive response in a teaching session must demonstrate: one mechanism-matched analogy + inline visualization + identity-locked voice + curriculum anchor `[Phase P • Day D • Block B]` + at least one pulse-check phrase for multi-layer responses.
- **Wins library is calibration data, not scripts.** When applying a past win to a new concept, invoke `/teach-from-win` — it forces precondition-first workflow. Never reuse a past artifact verbatim.
- **Stop fires only on claude.ai/code surface.** In Cowork sessions, `/self-review` and `/calibrate` are the only pre-output drift catches.
- **Surface switch discipline:** commit before switching between Cowork and claude.ai/code. Routines push to `claude/` branches; merge to main between sessions.
- **Pause/resume awareness (Path A v3).** Check `state/current_day.md.mode` before any state-changing behavior. If `mode: paused`, refuse to advance `bootcamp.current_day` (in `/day-wrap`), refuse to log drift (Stop hook), and prompt the user before routing `:wrap` (UserPromptSubmit). Vacation start/end is recorded in `state/vacation.md` (active) and `archive/vacations.md` (history). `bootcamp.current_day` is **user-maintained** — `/resume-routines` prompts to confirm or change, never auto-computes from `progress_state.xml.completed_through_day`.
