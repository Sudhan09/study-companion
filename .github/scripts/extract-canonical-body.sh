#!/usr/bin/env bash
# Extract the canonical Slack body for a given routine + date.
# Usage: extract-canonical-body.sh <routine> <date>
# Stdout: the body text (will be wrapped by the workflow with envelope header/footer)
# Exit: 0 on success (including missing-body case which writes a sentinel),
#       1 on bad inputs.
#
# Canonical body sources per routine:
#   curriculum-sync     → human-readable summary built from .last-sync-status JSON
#                         (success / STALE / missing-file branches)
#   morning-briefing    → state/schedule.md (frontmatter stripped)
#   spaced-rep          → state/spaced-rep-<date>.md (frontmatter stripped)
#   commit-reminder     → "## Commit reminder" section of logs/<date>.md
#   weekly-review       → state/weekly-review-<date>.md (frontmatter stripped)
#   monday-distillation → "📦 Archived <N> logs" + state/distilled.md (frontmatter stripped)
#   drift-audit         → state/drift-audit-<date>.md (frontmatter stripped)
#   branch-cleanup      → "## Branch cleanup" section of logs/<date>.md

set -uo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <routine> <date>" >&2
  exit 1
fi

routine="$1"
date="$2"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

# --- helpers ---

strip_frontmatter() {
  awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$1"
}

extract_section() {
  local file="$1" header="$2"
  awk -v hdr="^## ${header}" '
    $0 ~ hdr { capture=1; print; next }
    capture && /^## / && $0 !~ hdr { capture=0 }
    capture { print }
  ' "$file"
}

missing_body_message() {
  local f="$1"
  printf '⚠️  %s ran but canonical body file (%s) not found — inspect branch claude/%s-%s' \
    "${routine}" "${f}" "${routine}" "${date}"
}

emit_curriculum_sync() {
  local f="instructions/curriculum/.last-sync-status"
  if [ ! -f "${f}" ]; then
    cat <<EOT
❌ Curriculum sync did not complete

⚠️  instructions/curriculum/.last-sync-status not found
   Routine likely failed before writing its status report

🛠 Action: inspect branch claude/curriculum-sync-${date} for
   error logs in commit messages
EOT
    return 0
  fi
  local status
  if ! status=$(jq -r '.status // "missing"' "${f}" 2>/dev/null); then
    printf '⚠️  .last-sync-status exists but is not valid JSON. Inspect branch claude/curriculum-sync-%s' "${date}"
    return 0
  fi
  case "${status}" in
    OK)
      local active_chunk pipeline_sha files_count missing_count
      active_chunk=$(jq -r '.active_chunk // "unknown"' "${f}")
      pipeline_sha=$(jq -r '.pipeline_commit // "unknown" | .[0:8]' "${f}")
      files_count=$(jq -r '.files_synced | length' "${f}")
      missing_count=$(jq -r '.missing | length' "${f}")
      cat <<EOT
✅ Bootcamp curriculum synced from upstream

📦 Active chunk: ${active_chunk}
🔖 Pipeline pinned at: ${pipeline_sha}
📂 ${files_count} files synced, ${missing_count} missing
EOT
      ;;
    STALE)
      local missing_count missing_bullets
      missing_count=$(jq -r '.missing | length' "${f}")
      if [ "${missing_count}" -gt 3 ]; then
        local extra=$((missing_count - 3))
        missing_bullets=$(jq -r '.missing[0:3] | map("- " + .) | join("\n")' "${f}")
        missing_bullets="${missing_bullets}
- (${extra} more)"
      else
        missing_bullets=$(jq -r '.missing | map("- " + .) | join("\n")' "${f}")
      fi
      cat <<EOT
❌ Sync failed — fallback to state/current_day.md scope

⚠️  Missing files:
${missing_bullets}

🛠 Likely: pipeline clone failed (auth or network)
🛠 Action: re-check Claude GitHub App on python_bootcamp_claude_code
EOT
      ;;
    *)
      printf '⚠️  Unknown sync status "%s". Inspect branch claude/curriculum-sync-%s' "${status}" "${date}"
      ;;
  esac
}

emit_monday_distillation() {
  local f="state/distilled.md"
  if [ ! -f "${f}" ]; then
    missing_body_message "${f}"
    return 0
  fi
  # Count today's archives by grepping archive/completed_days/*.md frontmatter
  # for `archived_on: <date>`. Each new archive file from today's run has this.
  local archive_count=0
  if [ -d archive/completed_days ]; then
    archive_count=$(grep -l "^archived_on: ${date}$" archive/completed_days/*.md 2>/dev/null | wc -l)
  fi
  printf '📦 Archived %s log(s) today\n\n' "${archive_count}"
  strip_frontmatter "${f}"
}

# --- dispatch ---

emit_pause_routines() {
  # Path A v3 CRIT-11: pause-routines body summarizes the new vacation record.
  # On success, vacation.md is committed in the merged tree. On failure, the
  # workflow short-circuits to the "PAUSE NOT APPLIED" arm (in workflow YAML)
  # and never calls this function.
  local f="state/vacation.md"
  if [ ! -f "${f}" ]; then
    cat <<EOT
🛫 Pause merged but vacation.md was not present in the merged tree.
This is a state-consistency error — investigate via the run link.
EOT
    return 0
  fi
  # awk sub() preserves colons in RFC 3339 timestamps (a -F': *' split would
  # truncate at the first colon in HH:MM:SS).
  local start_date end_date suppress reason
  start_date=$(awk '/^start_date:/ { sub(/^start_date:[[:space:]]*/, ""); print; exit }' "${f}" | tr -d '"' | tr -d "'")
  end_date=$(awk '/^end_date:/ { sub(/^end_date:[[:space:]]*/, ""); print; exit }' "${f}" | tr -d '"' | tr -d "'")
  suppress=$(awk '/^suppress_routines:/ { sub(/^suppress_routines:[[:space:]]*/, ""); print; exit }' "${f}" | tr -d '"')
  reason=$(awk '/^reason:/ { sub(/^reason:[[:space:]]*/, ""); print; exit }' "${f}" | tr -d '"' | tr -d "'")
  cat <<EOT
🛫 Vacation started

📅 Start: ${start_date}
🏁 End: ${end_date:-open-ended}
🔇 Suppressed routines: ${suppress:-(default 3)}
📝 Reason: ${reason:-(none given)}

ℹ️  Daily-wrap will post Day 1 + last day, then go silent for the duration.
ℹ️  Routines NOT in suppress_routines (curriculum-sync, weekly-review,
    monday-distillation, drift-audit, branch-cleanup) keep running through pause.
EOT
}

# Helper: extract a key from a nested YAML block. Walks the file line-by-line,
# tracks whether we're inside the named outer block, returns the value of the
# named inner key. Robust to RFC 3339 timestamps with embedded colons.
yaml_nested_get() {
  local file="$1" outer="$2" inner="$3"
  awk -v outer="${outer}" -v inner="${inner}" '
    BEGIN { in_block = 0 }
    # Top-level key match (no leading whitespace) ends any prior block.
    /^[A-Za-z_][A-Za-z0-9_]*:/ {
      if ($0 ~ "^" outer ":") { in_block = 1; next }
      else { in_block = 0 }
    }
    in_block && $0 ~ "^[[:space:]]+" inner ":[[:space:]]*" {
      sub("^[[:space:]]+" inner ":[[:space:]]*", "")
      gsub(/^["'\'']|["'\'']$/, "")
      print
      exit
    }
  ' "${file}"
}

emit_resume_routines() {
  # Path A v3 Q8: verbose resume format.
  local cd="state/current_day.md"
  local arch_log="archive/vacations.md"
  local bootcamp_day lw_day lw_active lw_completed loop_state vac_days

  if [ -f "${cd}" ]; then
    bootcamp_day=$(yaml_nested_get "${cd}" bootcamp current_day)
    lw_day=$(yaml_nested_get "${cd}" loop_week current_day)
    lw_active=$(yaml_nested_get "${cd}" loop_week active)
    lw_completed=$(yaml_nested_get "${cd}" loop_week completed)
  fi

  if [ "${lw_completed}" = "true" ]; then
    loop_state="completed"
  elif [ "${lw_active}" = "true" ]; then
    loop_state="active Day ${lw_day:-?}"
  else
    loop_state="paused"
  fi

  if [ -f "${arch_log}" ]; then
    # Most recent vacation entry: pull last duration_days value.
    vac_days=$(awk '/duration_days:/ { last=$NF } END { print last }' "${arch_log}")
  fi

  local hhmm
  hhmm=$(TZ=Asia/Kolkata date +%H:%M)
  cat <<EOT
✅ Resumed at ${hhmm} IST
─────────────────
📍 bootcamp Day ${bootcamp_day:-?}
🎯 loop_week: ${loop_state}
📅 First task: today's morning briefing fires at 09:00 IST
🛬 Vacation duration: ${vac_days:-?} days
EOT
}

case "${routine}" in
  curriculum-sync)
    emit_curriculum_sync
    ;;
  morning-briefing)
    f="state/schedule.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else strip_frontmatter "${f}"; fi
    ;;
  spaced-rep)
    f="state/spaced-rep-${date}.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else strip_frontmatter "${f}"; fi
    ;;
  commit-reminder)
    f="logs/${date}.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else extract_section "${f}" "Commit reminder"; fi
    ;;
  weekly-review)
    f="state/weekly-review-${date}.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else strip_frontmatter "${f}"; fi
    ;;
  monday-distillation)
    emit_monday_distillation
    ;;
  drift-audit)
    f="state/drift-audit-${date}.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else strip_frontmatter "${f}"; fi
    ;;
  branch-cleanup)
    f="logs/${date}.md"
    if [ ! -f "${f}" ]; then missing_body_message "${f}"; else extract_section "${f}" "Branch cleanup"; fi
    ;;
  pause-routines)
    emit_pause_routines
    ;;
  resume-routines)
    emit_resume_routines
    ;;
  *)
    echo "::error::Unknown routine: ${routine}" >&2
    exit 1
    ;;
esac
