#!/usr/bin/env bash
# Extracts each routine's prompt block (the fenced ``` block under "## Routine prompt") and hashes it.
# User compares each hash against the corresponding /schedule UI prompt body.

set -euo pipefail

cd "$(dirname "$0")/.."

for f in routines/0*.md; do
  name=$(basename "$f" .md)
  # Extract content between the first triple-backtick after "## Routine prompt" and the next triple-backtick.
  block=$(awk '
    /^## Routine prompt/ {found=1; next}
    found && /^```/ && !inblock {inblock=1; next}
    found && /^```/ && inblock {inblock=0; exit}
    found && inblock {print}
  ' "$f")

  if [ -z "$block" ]; then
    echo "  $name: NO PROMPT BLOCK FOUND"
    continue
  fi

  hash=$(printf '%s' "$block" | sha256sum | cut -d' ' -f1 | head -c 16)
  echo "  $name: $hash"
done
