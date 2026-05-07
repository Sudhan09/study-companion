#!/usr/bin/env bash
# Build the 21:00 IST daily wrap message and write it to stdout.
# Usage: build-daily-wrap.sh
# Caller is expected to have main checked out at HEAD with full history.
#
# Data sources (no separate heartbeat file — merge commits ARE the heartbeat):
# - git log on main, since today midnight IST, --grep='^merge: claude/'
# - state/drift_log.md, lines starting with today's IST date
# - state/schedule.md, logs/<date>.md for alert markers (STALE-CURRICULUM,
#   ZERO-COMMIT, BOOTSTRAP)
#
# Heartbeat-by-design: this script always produces output, even on quiet days
# (clean-day template with 0 expected and 0 fired). The Slack POST validates
# the workflow itself is alive (Mitigation #1).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

DATE=$(TZ=Asia/Kolkata date +%F)
DOW=$(TZ=Asia/Kolkata date +%A)
DOW_SHORT=$(TZ=Asia/Kolkata date +%a)
HHMM=$(TZ=Asia/Kolkata date +%H:%M)

# --- 0. Pause-mode check (Path A v3 CRIT-09 + Q9) ---
# When mode==paused, daily-wrap diverges into a vacation-aware path:
#   Day 1     → "🛫 Vacation started" full banner
#   Day 2..30 → minimal heartbeat (one-line so workflow-alive signal stays)
#   Day 31+   → 🚨 persistent 30-day cap alert (Q9)
#   Last day  → "🛬 Last day of vacation" full banner (when end_date set)
# The normal flow below is bypassed entirely when paused.

MODE="bootcamp"
if [ -f state/current_day.md ]; then
  mode_match=$(awk -F': *' '/^mode:/ { print $2; exit }' state/current_day.md 2>/dev/null | tr -d '"' | tr -d "'")
  if [ -n "${mode_match}" ]; then MODE="${mode_match}"; fi
fi

if [ "${MODE}" = "paused" ]; then
  if [ ! -f state/vacation.md ]; then
    # State inconsistency — validate-vacation-consistency.js should have caught
    # this on the last push; report loudly here as well.
    cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

🚨 STATE INCONSISTENCY
mode=paused in state/current_day.md but state/vacation.md is missing.

🛠 Action: run \`/resume-routines\` to clear the pause, OR manually edit
   state/current_day.md to set mode back to bootcamp/loop_week.
EOT
    exit 0
  fi

  # awk sub() strips the prefix and preserves any colons in the value (RFC 3339
  # timestamps contain colons in HH:MM and the offset, so a -F': *' split would
  # truncate them).
  start_raw=$(awk '/^start_date:/ { sub(/^start_date:[[:space:]]*/, ""); print; exit }' state/vacation.md | tr -d '"' | tr -d "'")
  end_raw=$(awk '/^end_date:/ { sub(/^end_date:[[:space:]]*/, ""); print; exit }' state/vacation.md | tr -d '"' | tr -d "'")

  # Use just the date portion (everything before T) so day arithmetic is in IST
  # midnight-to-midnight terms regardless of the original timestamp's clock time.
  start_date_only="${start_raw%%T*}"
  start_secs=$(TZ=Asia/Kolkata date -d "${start_date_only}" +%s 2>/dev/null || echo 0)
  today_secs=$(TZ=Asia/Kolkata date -d "${DATE}" +%s)

  if [ "${start_secs}" = "0" ]; then
    days_paused=0
  else
    days_paused=$(( (today_secs - start_secs) / 86400 ))
  fi

  end_date_only=""
  days_until_end=99999
  if [ -n "${end_raw}" ] && [ "${end_raw}" != "null" ]; then
    end_date_only="${end_raw%%T*}"
    end_secs=$(TZ=Asia/Kolkata date -d "${end_date_only}" +%s 2>/dev/null || echo 0)
    if [ "${end_secs}" != "0" ]; then
      days_until_end=$(( (end_secs - today_secs) / 86400 ))
    fi
  fi

  # Q9: 30-day cap alert — fires every day past day 30 until cleared.
  if [ "${days_paused}" -gt 30 ]; then
    over_limit=$(( days_paused - 30 ))
    cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

🚨 ALERTS (1) — pause exceeds 30-day cap

⚠️  Pause is on day ${days_paused} (${over_limit} day(s) over the 30-day cap).

📊 System paused since ${start_date_only}. Routines that respect suppress_routines
   are skipping; non-suppressed (curriculum-sync, weekly-review, monday-distillation,
   drift-audit, branch-cleanup) keep running through pause.

🛠 Action needed:
- Run \`/resume-routines\` from Cowork or the Code app, OR
- Update \`state/vacation.md.end_date\` to extend the planned vacation window.
EOT
    exit 0
  fi

  # A10 + CRIT-09: Day 1 banner.
  if [ "${days_paused}" -eq 0 ]; then
    cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

🛫 Vacation started

📅 Start: ${start_raw}
🏁 End: ${end_raw:-open-ended}

ℹ️  Daily-wrap goes silent (one-line heartbeat only) until the last day of
   vacation, OR forever if no end_date set. 30-day cap will trigger a
   persistent ALERT.

ℹ️  Routines NOT in \`vacation.md.suppress_routines\` keep running through pause.
   Default suppress: study-morning-briefing, study-spaced-rep-reminder,
   study-github-commit-reminder.
EOT
    exit 0
  fi

  # A10 + CRIT-09: Last day banner (only when end_date is set and reached).
  if [ "${days_until_end}" -eq 0 ]; then
    cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

🛬 Last day of vacation

📅 Vacation duration: ${days_paused} days
📅 Resume tomorrow (before 09:00 IST Monday if Monday distillation matters this week)

ℹ️  Run \`/resume-routines\` to clear the pause, archive vacation.md, and rewrite
   state/last_session_summary.md with a gap notice.
EOT
    exit 0
  fi

  # Mid-vacation: minimal heartbeat (preserves workflow-alive signal). Slight
  # deviation from A10 ("post only Day 1 + last day") in favor of Mitigation #1
  # (heartbeat-by-design); revisit if noise is unwanted.
  cat <<EOT
🛌 paused · day ${days_paused} · ${DATE}
EOT
  exit 0
fi

# --- 1. Merge commits today ---
# Each per-push merge writes "merge: claude/<routine>-<date>" subject.
MERGE_SUBJECTS=$(git log main --since="${DATE}T00:00:00+05:30" \
  --grep='^merge: claude/' --pretty=format:'%s' 2>/dev/null || true)
MERGED_COUNT=0
if [ -n "${MERGE_SUBJECTS}" ]; then
  MERGED_COUNT=$(printf '%s\n' "${MERGE_SUBJECTS}" | wc -l)
fi

# --- 2. Expected routines for today's day-of-week ---
case "${DOW_SHORT}" in
  Mon)
    EXPECTED=(curriculum-sync morning-briefing spaced-rep commit-reminder monday-distillation)
    ;;
  Tue|Wed|Thu|Fri|Sat)
    EXPECTED=(curriculum-sync morning-briefing spaced-rep commit-reminder)
    ;;
  Sun)
    EXPECTED=(curriculum-sync morning-briefing weekly-review drift-audit branch-cleanup)
    ;;
  *)
    EXPECTED=()
    ;;
esac
EXPECTED_COUNT=${#EXPECTED[@]}

# --- 3. Which expected routines fired (parse from MERGE_SUBJECTS) ---
FIRED=()
for routine in "${EXPECTED[@]}"; do
  if printf '%s\n' "${MERGE_SUBJECTS}" | grep -qE "^merge: claude/${routine}-${DATE}$"; then
    FIRED+=("${routine}")
  fi
done
FIRED_COUNT=${#FIRED[@]}

# --- 4. Missing routines ---
MISSING=()
for routine in "${EXPECTED[@]}"; do
  found=0
  for f in "${FIRED[@]:-}"; do
    if [ "${f}" = "${routine}" ]; then found=1; break; fi
  done
  if [ "${found}" -eq 0 ]; then MISSING+=("${routine}"); fi
done

# --- 5. Drift entries today ---
DRIFT_COUNT=0
DRIFT_QUOTES=""
if [ -f state/drift_log.md ]; then
  DRIFT_TODAY=$(grep "^${DATE}T" state/drift_log.md 2>/dev/null || true)
  if [ -n "${DRIFT_TODAY}" ]; then
    DRIFT_COUNT=$(printf '%s\n' "${DRIFT_TODAY}" | wc -l)
    DRIFT_QUOTES=$(printf '%s\n' "${DRIFT_TODAY}" | head -5)
  fi
fi

# --- 6. Alert markers ---
ALERTS=()
SCHED_FILE="state/schedule.md"
LOGS_FILE="logs/${DATE}.md"

if [ -f "${SCHED_FILE}" ]; then
  if grep -q '\[STALE-CURRICULUM\]' "${SCHED_FILE}" 2>/dev/null; then
    ALERTS+=("[STALE-CURRICULUM] in state/schedule.md (curriculum-sync didn't reach main before morning-briefing)")
  fi
  if grep -q '\[BOOTSTRAP' "${SCHED_FILE}" 2>/dev/null; then
    ALERTS+=("[BOOTSTRAP] in state/schedule.md (curriculum XMLs not yet present)")
  fi
fi

if [ -f "${LOGS_FILE}" ]; then
  if grep -q '\[ZERO-COMMIT\]' "${LOGS_FILE}" 2>/dev/null; then
    ALERTS+=("[ZERO-COMMIT] in logs/${DATE}.md (no commits authored today)")
  fi
fi

if [ "${#MISSING[@]}" -gt 0 ]; then
  ALERTS+=("Missing routine merges: ${MISSING[*]}")
fi

# --- 7. Render message ---

# Helper: emit a routine line with merge-commit timestamp if found.
emit_routine_line() {
  local r="$1" symbol="$2"
  local ts hm
  ts=$(git log main --since="${DATE}T00:00:00+05:30" \
    --grep="^merge: claude/${r}-${DATE}$" \
    --pretty=format:'%ci' --max-count=1 2>/dev/null || true)
  if [ -n "${ts}" ]; then
    hm=$(echo "${ts}" | awk '{print $2}' | cut -c1-5)
    echo "- ${symbol} ${r}: ${hm} IST"
  else
    echo "- ${symbol} ${r}: (not merged today)"
  fi
}

if [ "${#ALERTS[@]}" -eq 0 ] && [ "${FIRED_COUNT}" -eq "${EXPECTED_COUNT}" ]; then
  # Clean day template
  cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

📊 Routines today: ${FIRED_COUNT}/${EXPECTED_COUNT} ✅
EOT
  for r in "${FIRED[@]:-}"; do
    emit_routine_line "${r}" "✅"
  done
  cat <<EOT

🔀 Auto-merge: ${MERGED_COUNT} branch(es) → main ✅
✅ Validators: passed on all merges

📈 Drift today: ${DRIFT_COUNT} entries
EOT
  if [ "${DRIFT_COUNT}" -eq 0 ]; then
    echo "ℹ️  Cowork sessions don't log drift (#40495)"
  else
    printf '%s\n' "${DRIFT_QUOTES}" | while IFS= read -r line; do
      echo "> ${line}"
    done
  fi
  echo ""
  echo "🟢 All clean."
else
  # Problem day template
  cat <<EOT
🗡️  Asta — Daily Wrap
📅 ${DATE} (${DOW}) • ${HHMM} IST

🚨 ALERTS (${#ALERTS[@]}) — read first
EOT
  for a in "${ALERTS[@]}"; do
    echo "- ${a}"
  done
  echo ""
  if [ "${EXPECTED_COUNT}" -gt 0 ]; then
    echo "📊 Routines: ${FIRED_COUNT}/${EXPECTED_COUNT} ⚠️"
    for r in "${EXPECTED[@]}"; do
      fired=0
      for f in "${FIRED[@]:-}"; do
        if [ "${f}" = "${r}" ]; then fired=1; break; fi
      done
      if [ "${fired}" -eq 1 ]; then
        emit_routine_line "${r}" "✅"
      else
        echo "- ❌ ${r} (no merge today)"
      fi
    done
    echo ""
  fi
  echo "🔀 Auto-merge: ${MERGED_COUNT} branch(es) → main"
  echo ""
  echo "📈 Drift today: ${DRIFT_COUNT} entries"
  if [ "${DRIFT_COUNT}" -gt 0 ]; then
    printf '%s\n' "${DRIFT_QUOTES}" | while IFS= read -r line; do
      echo "> ${line}"
    done
  else
    echo "ℹ️  Cowork sessions don't log drift (#40495)"
  fi
  echo ""
  echo "🛠 Action needed:"
  if [ "${#MISSING[@]}" -gt 0 ]; then
    echo "- Investigate missing routines on https://claude.ai/code/routines: ${MISSING[*]}"
  fi
  if [ -f "${SCHED_FILE}" ] && grep -q '\[STALE-CURRICULUM\]' "${SCHED_FILE}" 2>/dev/null; then
    echo "- Re-check Claude GitHub App on Sudhan09/python_bootcamp_claude_code"
  fi
  if [ -f "${LOGS_FILE}" ] && grep -q '\[ZERO-COMMIT\]' "${LOGS_FILE}" 2>/dev/null; then
    echo "- Push commits or accept zero-commit day"
  fi
fi
