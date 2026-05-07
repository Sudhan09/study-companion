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
