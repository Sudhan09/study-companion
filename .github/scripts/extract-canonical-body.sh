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
  *)
    echo "::error::Unknown routine: ${routine}" >&2
    exit 1
    ;;
esac
