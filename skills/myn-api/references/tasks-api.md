# Tasks API

Unified task management covering Tasks, Habits, and Chores.

## Base Path

`/api/v2/unified-tasks`

## Endpoints

### List Tasks

```
GET /api/v2/unified-tasks
```

**Important:** This endpoint returns ALL active tasks for the authenticated user. Filter by priority, date, etc. client-side. This matches the frontend's established pattern — the backend handles complex household deduplication and eager loading that doesn't support server-side filtering.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | string | Filter by task type: `TASK`, `HABIT`, `CHORE` |
| `isCompleted` | boolean | Filter by completion state |
| `householdId` | UUID | Filter by household |
| `ids` | string | Comma-separated task IDs |

```bash
# Fetch all tasks (then filter client-side)
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks"

# Fetch only habits
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?type=HABIT"

# Fetch specific tasks by ID
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?ids=550e8400-...,660e8400-..."
```

### Client-Side Filtering Examples

The response includes `priority`, `startDate`, `isCompleted`, and `isArchived` fields on each task. Filter in your agent/script:

```bash
# Get Critical Now tasks (priority == "CRITICAL", not completed, not archived)
curl -s -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v2/unified-tasks" | \
  jq '[.[] | select(.priority == "CRITICAL" and .isCompleted == false and .isArchived == false)]'

# Get today's tasks by start date
curl -s -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v2/unified-tasks" | \
  jq --arg today "$(date +%Y-%m-%d)" '[.[] | select(.startDate | startswith($today))]'
```

### Get Task

```
GET /api/v2/unified-tasks/{taskId}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/550e8400-e29b-41d4-a716-446655440000"
```

### Create Task

```
POST /api/v2/unified-tasks
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Client-generated UUID |
| `title` | string | Task title (1–200 chars) |
| `taskType` | string | `TASK`, `HABIT`, or `CHORE` |
| `priority` | string | `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON`, `PARKING_LOT` |
| `startDate` | date | Start date (YYYY-MM-DD) |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Description (max 2000 chars) |
| `duration` | string | Duration: `"30m"`, `"1h"`, `"1h30m"` (NOT ISO PT prefix) |
| `projectId` | UUID | Assign to project |
| `recurrenceRule` | string | RRULE for HABIT/CHORE types (**required** for HABIT and CHORE) |

**Type-Specific Rules:**

- `TASK`: Basic task, can be shared
- `HABIT`: MUST have `recurrenceRule`, CANNOT be shared
- `CHORE`: MUST have `recurrenceRule`, always household-scoped

```bash
# Create a regular task
curl -X POST "$MYN_API_URL/api/v2/unified-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Prepare quarterly report",
    "taskType": "TASK",
    "priority": "CRITICAL",
    "startDate": "2026-03-01",
    "duration": "2h",
    "description": "Q1 financials and projections"
  }'

# Create a habit
curl -X POST "$MYN_API_URL/api/v2/unified-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "title": "Morning meditation",
    "taskType": "HABIT",
    "priority": "OPPORTUNITY_NOW",
    "startDate": "2026-03-01",
    "duration": "15m",
    "recurrenceRule": "FREQ=DAILY"
  }'
```

### Update Task

```
PATCH /api/v2/unified-tasks/{taskId}
```

Send only the fields to update:

```bash
curl -X PATCH "$MYN_API_URL/api/v2/unified-tasks/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"priority": "OPPORTUNITY_NOW", "startDate": "2026-03-05"}'
```

### Complete Task

```
POST /api/v2/unified-tasks/{taskId}/complete
```

```bash
curl -X POST "$MYN_API_URL/api/v2/unified-tasks/550e8400-e29b-41d4-a716-446655440000/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Archive Task

```
POST /api/v2/unified-tasks/{taskId}/archive
```

```bash
curl -X POST "$MYN_API_URL/api/v2/unified-tasks/550e8400-e29b-41d4-a716-446655440000/archive" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Search (via unified search)

```
GET /api/v2/search
```

See [search-api.md](search-api.md) for full search documentation.

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=quarterly+report&limit=10"
```

### Get Habit Streak

```
GET /api/v2/unified-tasks/{taskId}/streak
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/660e8400-e29b-41d4-a716-446655440001/streak"
```

### Move Task to Project

```
PUT /api/v2/unified-tasks/{taskId}/project
```

```bash
curl -X PUT "$MYN_API_URL/api/v2/unified-tasks/550e8400-e29b-41d4-a716-446655440000/project" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"projectId": "770e8400-e29b-41d4-a716-446655440002"}'
```
