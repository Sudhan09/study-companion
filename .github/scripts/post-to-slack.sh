#!/usr/bin/env bash
# Post a message body to Slack via SLACK_WEBHOOK_URL.
# Usage: post-to-slack.sh <text-file>
# Env: SLACK_WEBHOOK_URL must be set (workflow secret)
# Exit: 0 on HTTP 200; 1 on bad inputs, missing secret, or non-200 response.
#
# JSON payload is built via jq (never printf or shell concatenation) so
# embedded quotes, newlines, and backslashes are escaped correctly.
# HTTP response code is asserted post-POST per Mitigation #8.

set -uo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <text-file>" >&2
  exit 1
fi

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "::error::SLACK_WEBHOOK_URL not set in environment" >&2
  exit 1
fi

text_file="$1"
if [ ! -f "${text_file}" ]; then
  echo "::error::text file not found: ${text_file}" >&2
  exit 1
fi

# Slack hard-cap is ~40K. Truncate at 35000 to leave room for envelope.
# Most routine bodies are well under this; monday-distillation could approach it.
MAX_BYTES=35000
size=$(wc -c < "${text_file}")
if [ "${size}" -gt "${MAX_BYTES}" ]; then
  truncated="${text_file}.truncated"
  head -c 32000 "${text_file}" > "${truncated}"
  printf '\n\n... [truncated at 32000 of %s bytes]\n' "${size}" >> "${truncated}"
  text_file="${truncated}"
fi

# Build payload via jq. --rawfile reads the entire file as a single string
# (newlines preserved), which jq encodes correctly into the JSON.
payload=$(jq -n \
  --rawfile text "${text_file}" \
  --arg username "Asta" \
  --arg icon ":dagger_knife:" \
  --arg channel "#study-routines" \
  '{text: $text, username: $username, icon_emoji: $icon, channel: $channel}')

# POST with -w to capture HTTP code, -o /dev/null to discard body, -s for silent.
http_code=$(curl -X POST \
  -H 'Content-Type: application/json' \
  --data "${payload}" \
  -w '%{http_code}' \
  -o /dev/null \
  -sS \
  --max-time 30 \
  "${SLACK_WEBHOOK_URL}")

if [ "${http_code}" != "200" ]; then
  echo "::error::Slack POST failed with HTTP ${http_code}" >&2
  exit 1
fi
echo "Slack POST OK (HTTP 200, ${size} bytes)"
