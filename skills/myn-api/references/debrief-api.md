# Daily Debrief API

Daily Debrief system for AI-generated daily planning sessions with corrections and completion tracking.

## Base Path

`/api/v2/debrief`

## Actions

The `myn_debrief` tool supports these actions: `status`, `generate`, `get`, `apply_correction`, `complete_session`.

## Endpoints

### Get Session Status

```
GET /api/v2/debrief/status
```

Returns the current debrief session state.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `hasActiveSession` | boolean | Whether a debrief session is currently active |
| `sessionId` | UUID | Current session ID (nullable) |
| `lastDebriefId` | UUID | ID of the most recent debrief (nullable) |
| `lastDebriefTime` | datetime | Timestamp of the most recent debrief (nullable) |
| `pendingCorrections` | number | Count of unprocessed corrections |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/debrief/status"
```

### Generate Debrief

```
POST /api/v2/debrief/generate
```

Generates a new Daily Debrief with prioritized task lists and suggestions.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Debrief type: `DAILY`, `EVENING`, `WEEKLY`, `WEEKLY_AND_DAILY`, `ON_DEMAND` (default: `DAILY`) |
| `context` | string | Optional context to guide the debrief (e.g., "busy morning, meetings after 2pm") |
| `focusAreas` | string[] | Optional focus areas to emphasize (e.g., `["health", "work deadlines"]`) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `debriefId` | UUID | Unique debrief identifier |
| `sessionId` | UUID | Session this debrief belongs to |
| `summary` | string | Natural language summary of the day |
| `criticalNow` | object[] | Tasks requiring immediate attention |
| `opportunityNow` | object[] | Tasks worth doing if time allows |
| `overTheHorizon` | object[] | Tasks to keep in mind for later |
| `upcomingMeetings` | object[] | Meetings and calendar events today |
| `habitsDue` | object[] | Habits scheduled for today |
| `suggestions` | string[] | AI-generated actionable suggestions |
| `createdAt` | datetime | Debrief generation timestamp |

```bash
# Generate a basic daily debrief
curl -X POST "$MYN_API_URL/api/v2/debrief/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"type": "DAILY"}'

# Generate with context and focus areas
curl -X POST "$MYN_API_URL/api/v2/debrief/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "DAILY",
    "context": "Working from home today, low energy",
    "focusAreas": ["health", "project deadlines"]
  }'

# Evening debrief
curl -X POST "$MYN_API_URL/api/v2/debrief/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"type": "EVENING"}'
```

### Get Current Debrief

```
GET /api/v2/debrief/current
```

Returns the most recent debrief without generating a new one. Used both for the `get` action (with or without `debriefId`).

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/debrief/current"
```

### Submit Correction

```
POST /api/v2/debrief/corrections/apply
```

Submits a correction to update the active debrief session when reality diverges from the plan.

**Uses read-before-write guard** -- reads current debrief state hash before applying.

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
| `debriefUpdated` | boolean | Whether the active debrief was re-ranked |

```bash
curl -X POST "$MYN_API_URL/api/v2/debrief/corrections/apply" \
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
POST /api/v2/debrief/complete
```

Ends the active debrief session with an optional summary and decisions record.

**Uses read-before-write guard** -- reads current debrief state hash before completing.

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
| `nextSessionRecommended` | datetime | Suggested time for next debrief (nullable) |
| `followUps` | object[] | Auto-generated follow-up items |

```bash
curl -X POST "$MYN_API_URL/api/v2/debrief/complete" \
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
