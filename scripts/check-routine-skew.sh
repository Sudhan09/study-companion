#!/usr/bin/env bash
# Extracts each routine's prompt body (between outer triple-backtick fences under
# "## Routine prompt") and hashes it. User compares each hash against the prompt
# body in claude.ai/code/routines.
#
# Path A v3 followup (2026-05-07): the prior awk implementation stopped at the
# FIRST inner ``` it encountered, which truncated routines whose prompt body
# contains nested fenced code blocks (notably routine 08's `cat <<EOF` example).
# This rewrite uses the next-section-header (## Success criteria) as the outer
# block sentinel, then takes the FIRST and LAST ``` lines between those headers
# as the outer fences. Inner ``` lines are treated as content (printed verbatim).

set -euo pipefail

cd "$(dirname "$0")/.."

for f in routines/0*.md; do
  name=$(basename "$f" .md)

  start=$(grep -n '^## Routine prompt' "$f" | head -1 | cut -d: -f1 || true)
  end=$(grep -n '^## Success criteria' "$f" | head -1 | cut -d: -f1 || true)
  if [ -z "${start:-}" ] || [ -z "${end:-}" ]; then
    echo "  $name: NO PROMPT BLOCK FOUND (missing section headers)"
    continue
  fi

  open_offset=$(sed -n "${start},${end}p" "$f" | grep -n '^```$' | head -1 | cut -d: -f1 || true)
  close_offset=$(sed -n "${start},${end}p" "$f" | grep -n '^```$' | tail -1 | cut -d: -f1 || true)
  if [ -z "${open_offset:-}" ] || [ -z "${close_offset:-}" ] || [ "${open_offset}" = "${close_offset}" ]; then
    echo "  $name: NO PROMPT BLOCK FOUND (missing outer fences)"
    continue
  fi

  open_line=$((start + open_offset - 1))
  close_line=$((start + close_offset - 1))
  block=$(sed -n "$((open_line + 1)),$((close_line - 1))p" "$f")

  hash=$(printf '%s' "$block" | sha256sum | cut -d' ' -f1 | head -c 16)
  echo "  $name: $hash"
done
