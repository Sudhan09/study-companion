#!/usr/bin/env bash
# POSIX atomic-write helper for routines.
# Usage: bash scripts/atomic-write.sh <tmpfile> <dst>
# Pre: <tmpfile> already written with desired content.
# Post: <dst> contains <tmpfile>'s content; <tmpfile> is gone.
# On Linux/POSIX, rename(2) is atomic within a filesystem, so a routine
# killed mid-rename either leaves <dst> at its old content or at the new
# content — never half-written.

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <tmpfile> <dst>" >&2
  exit 2
fi

tmp="$1"
dst="$2"

if [ ! -f "$tmp" ]; then
  echo "atomic-write: tmpfile '$tmp' does not exist" >&2
  exit 1
fi

# Verify same filesystem (rename is only atomic within one).
tmp_dev=$(stat -c '%d' "$tmp")
dst_dir=$(dirname "$dst")
mkdir -p "$dst_dir"
dst_dev=$(stat -c '%d' "$dst_dir")
if [ "$tmp_dev" != "$dst_dev" ]; then
  echo "atomic-write: '$tmp' and '$dst_dir' are on different filesystems; rename is NOT atomic" >&2
  exit 1
fi

mv -f "$tmp" "$dst"
