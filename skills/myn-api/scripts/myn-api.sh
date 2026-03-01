#!/usr/bin/env bash
#
# myn-api.sh — curl wrapper with MYN API key injection
#
# Usage:
#   ./myn-api.sh GET /api/v2/unified-tasks
#   ./myn-api.sh GET /api/v2/unified-tasks?priority=CRITICAL
#   ./myn-api.sh POST /api/v2/unified-tasks '{"id":"...","title":"...", ...}'
#   ./myn-api.sh PATCH /api/v2/unified-tasks/UUID '{"priority":"OPPORTUNITY_NOW"}'
#   ./myn-api.sh DELETE /api/v2/timers/UUID
#
# Environment:
#   MYN_API_URL  — Base URL (default: https://api.mindyournow.com)
#   MYN_API_KEY  — API key with AGENT_FULL scope (required)

set -euo pipefail

MYN_API_URL="${MYN_API_URL:-https://api.mindyournow.com}"

if [[ -z "${MYN_API_KEY:-}" ]]; then
  echo "Error: MYN_API_KEY environment variable is not set." >&2
  echo "Generate an API key at Settings > API Keys in MYN with AGENT_FULL scope." >&2
  exit 1
fi

METHOD="${1:?Usage: myn-api.sh METHOD PATH [BODY]}"
PATH_PART="${2:?Usage: myn-api.sh METHOD PATH [BODY]}"
BODY="${3:-}"

CURL_ARGS=(
  -s
  -X "$METHOD"
  -H "X-API-KEY: $MYN_API_KEY"
  -H "Accept: application/json"
)

if [[ -n "$BODY" ]]; then
  CURL_ARGS+=(-H "Content-Type: application/json" -d "$BODY")
fi

curl "${CURL_ARGS[@]}" "${MYN_API_URL}${PATH_PART}" | python3 -m json.tool 2>/dev/null || cat
