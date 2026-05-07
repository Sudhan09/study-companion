#!/usr/bin/env bash
# Run the 3 granted-folder validators.
# Used by the auto-merge workflow pre-merge (against branch tree) and
# post-merge (against merged main tree). On failure prints validator output
# and exits 1; the caller captures stdout/stderr for the Slack message.
#
# Plugin validators (validate-skills.js, validate-agents.js) are intentionally
# NOT run here — they live in Sudhan09/study-companion-plugin and are not
# present in this checkout.

set -uo pipefail

# Resolve repo root from script location so this works regardless of cwd.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

VALIDATORS=(
  "validate-imports.js"
  "validate-state-schemas.js"
  "validate-wins-schemas.js"
  "validate-vacation-consistency.js"
)

failed=()
for v in "${VALIDATORS[@]}"; do
  echo ">>> ${v}"
  if node "scripts/${v}"; then
    echo "<<< ${v}: OK"
  else
    echo "<<< ${v}: FAILED"
    failed+=("${v}")
  fi
  echo ""
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "VALIDATORS FAILED: ${failed[*]}"
  exit 1
fi
echo "ALL VALIDATORS PASSED"
exit 0
