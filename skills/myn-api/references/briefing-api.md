# Briefing API

Compass briefing system for AI-generated daily planning sessions with corrections and completion tracking.

## Base Path

`/api/v2/compass`

## Endpoints

### Get Session Status

```
GET /api/v2/compass/status
```

Returns the current briefing session state.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `hasActiveSession` | boolean | Whether a briefing session is currently active |
| `sessionId` | UUID | Current session ID (null if no active session) |
| `lastBriefingId` | UUID | ID of the most recent briefing |
| `lastBriefingTime` | datetime | Timestamp of the most recent briefing |
| `pendingCorrections` | number | Count of unprocessed corrections |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/compass/status"
```

### Generate Briefing

```
POST /api/v2/compass/generate
```

Generates a new Compass briefing with prioritized task lists and suggestions.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `context` | string | Optional context to guide the briefing (e.g., "busy morning, meetings after 2pm") |
| `focusAreas` | string[] | Optional focus areas to emphasize (e.g., `["health", "work deadlines"]`) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `briefingId` | UUID | Unique briefing identifier |
| `sessionId` | UUID | Session this briefing belongs to |
| `summary` | string | Natural language summary of the day |
| `criticalNow` | object[] | Tasks requiring immediate attention |
| `opportunityNow` | object[] | Tasks worth doing if time allows |
| `overTheHorizon` | object[] | Tasks to keep in mind for later |
| `upcomingMeetings` | object[] | Meetings and calendar events today |
| `habitsDue` | object[] | Habits scheduled for today |
| `suggestions` | string[] | AI-generated actionable suggestions |
| `createdAt` | datetime | Briefing generation timestamp |

```bash
# Generate a basic briefing
curl -X POST "$MYN_API_URL/api/v2/compass/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'

# Generate with context and focus areas
curl -X POST "$MYN_API_URL/api/v2/compass/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "context": "Working from home today, low energy",
    "focusAreas": ["health", "project deadlines"]
  }'
```

### Get Latest Briefing

```
GET /api/v2/compass/latest
```

Returns the most recent briefing without generating a new one.

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/compass/latest"
```

### Get Specific Briefing

```
GET /api/v2/compass/briefings/{briefingId}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/compass/briefings/550e8400-e29b-41d4-a716-446655440000"
```

### Submit Correction (Apply)

```
POST /api/v2/compass/corrections/apply
```

Submits a correction to update the active briefing session when reality diverges from the plan.

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Read the current compass state first.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** One of: `TASK_COMPLETED`, `TASK_MISSED`, `TASK_RESCHEDULED`, `TASK_ADDED`, `PRIORITY_CHANGED`, `OTHER` |
| `data` | object | Optional data relevant to the correction type (e.g., `{"taskId": "..."}`) |
| `reason` | string | Optional human-readable reason for the correction |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `correctionId` | UUID | Unique correction identifier |
| `appliedAt` | datetime | When the correction was applied |
| `briefingUpdated` | boolean | Whether the active briefing was re-ranked |

```bash
# 1. Read current compass state to get stateHash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/compass/current"
# → { "stateHash": "abc123", ... }

# 2. Mark a task as completed mid-session
curl -X POST "$MYN_API_URL/api/v2/compass/corrections/apply" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "TASK_COMPLETED",
    "data": {"taskId": "550e8400-e29b-41d4-a716-446655440000"},
    "reason": "Finished the report early"
  }'
```

### Complete Session

```
POST /api/v2/compass/complete
```

Ends the active briefing session with an optional summary and decisions record.

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Read the current compass state first.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `summary` | string | Optional end-of-session summary |
| `decisions` | string[] | Optional list of key decisions made during the session |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `sessionId` | UUID | The completed session ID |
| `completedAt` | datetime | Session completion timestamp |
| `nextSessionRecommended` | datetime | Suggested time for next briefing (nullable) |
| `followUps` | object[] | Auto-generated follow-up items |

```bash
# 1. Read current compass state to get stateHash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/compass/current"
# → { "stateHash": "abc123", ... }

# 2. Complete the session with a summary
curl -X POST "$MYN_API_URL/api/v2/compass/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123" \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "Productive morning, cleared all Critical Now items",
    "decisions": [
      "Postponed quarterly review to Friday",
      "Delegated invoice follow-up to Sarah"
    ]
  }'
```
