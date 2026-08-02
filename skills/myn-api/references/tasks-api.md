# Tasks API

Unified task management covering Tasks, Habits, and Chores.

## Base Path

`/api/v2/unified-tasks`

## Actions

The `myn_tasks` tool supports these actions: `list`, `get`, `create`, `update`, `complete`, `archive`, `search`.

## Endpoints

### List Tasks

```
GET /api/v2/unified-tasks?limit={limit}
```

`limit` is required. Omitting it returns HTTP 400. Values are clamped to 1–200.
The default `detail=compact` response uses an allowlisted summary DTO; pass
`detail=full` when the caller needs the existing full task shape. Successful
responses include a representation-specific `ETag`; send it in `If-None-Match`
with the same filters, detail, limit, and offset to receive HTTP 304 when that
exact page is unchanged. `If-Modified-Since` is legacy-only and does not control
304 responses for this collection.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | number | **Required.** Maximum tasks to return, clamped to 1–200 |
| `offset` | number | Number of tasks to skip (default: 0) |
| `detail` | string | `compact` (default) or `full` |
| `status` | string | `PENDING`, `ACTIVE`, or `COMPLETED` (case-insensitive) |
| `type` | string | `TASK`, `HABIT`, `CHORE`, or `RecurringTask` |
| `date` | date | Filter by date (YYYY-MM-DD) |
| `includeHousehold` | boolean | Include household-shared tasks (default: false) |
| `isCompleted` | boolean | Filter by completion state |
| `householdId` | string | Filter by household ID |
| `ids` | string | Comma-separated task IDs |

**Response envelope:**

```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Prepare quarterly report",
      "taskType": "TASK",
      "isCompleted": false,
      "completedToday": false,
      "priority": "CRITICAL",
      "requiredDate": "2026-08-05T00:00:00Z",
      "scheduledDate": "2026-08-01T00:00:00Z",
      "householdId": null,
      "projectId": "uuid",
      "streak": null,
      "currentAssigneeId": null
    }
  ],
  "total": 1,
  "limit": 20,
  "offset": 0,
  "hasMore": false
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?limit=20"

curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?limit=20&status=PENDING&detail=full"
```

### Get Task

```
GET /api/v2/unified-tasks/{taskId}
```

The response includes a `stateHash` field for use in write operations (MIN-740 read-before-write guard).

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/TASK_ID"
```

### Create Task

```
POST /api/v2/unified-tasks
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Task title (1-200 chars) |
| `taskType` | string | `TASK`, `HABIT`, or `CHORE` |
| `priority` | string | `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON`, `PARKING_LOT` |
| `startDate` | date | Start date (YYYY-MM-DD) |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Optional (auto-generated if omitted). Do NOT fabricate UUIDs. |
| `description` | string | Description (max 2000 chars) |
| `duration` | string | Duration: `"30m"`, `"1h"`, `"1h30m"` |
| `projectId` | UUID | Assign to project |
| `recurrenceRule` | string | RRULE for HABIT/CHORE types (**required** for HABIT and CHORE) |
| `isAutoScheduled` | boolean | Enable auto-scheduling (default: true). Only set false if user explicitly opts out. |
| `calendarId` | string | Calendar ID to link task to (e.g. "primary") |
| `calendarName` | string | Calendar name to resolve (e.g. "Family", "Work"). Used instead of calendarId. |
| `scheduleNames` | string[] | Schedule names to assign (e.g. `["Morning"]`, `["Weekday Evening", "Weekend Morning"]`). Resolved to IDs automatically. |

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
    "title": "Prepare quarterly report",
    "taskType": "TASK",
    "priority": "CRITICAL",
    "startDate": "2026-03-01",
    "duration": "2h",
    "description": "Q1 financials and projections",
    "isAutoScheduled": true,
    "scheduleNames": ["Morning"]
  }'

# Create a habit
curl -X POST "$MYN_API_URL/api/v2/unified-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
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

**Uses read-before-write guard** (MIN-740). Reads task first to get `stateHash`, retries on 409.

Send only the fields to update via the `updates` object. Allowed fields: `title`, `description`, `priority`, `status`, `startDate`, `endDate`, `duration`, `projectId`, `recurrenceRule`, `isAutoScheduled`, `calendarId`, `location`, `notes`, `tags`, `estimatedMinutes`, `actualMinutes`, `completedAt`, `archivedAt`, `taskType`, `assignedTo`, `scheduledAt`, `dueDate`.

```bash
HASH=$(curl -s -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/TASK_ID" | jq -r .stateHash)

curl -X PATCH "$MYN_API_URL/api/v2/unified-tasks/TASK_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: $HASH" \
  -H "Content-Type: application/json" \
  -d '{"priority": "OPPORTUNITY_NOW", "startDate": "2026-03-05"}'
```

### Complete Task

```
POST /api/v2/unified-tasks/{taskId}/complete
```

**Uses read-before-write guard** (MIN-740).

```bash
HASH=$(curl -s -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/TASK_ID" | jq -r .stateHash)

curl -X POST "$MYN_API_URL/api/v2/unified-tasks/TASK_ID/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: $HASH" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Archive Task

```
POST /api/v2/unified-tasks/{taskId}/archive
```

**Uses read-before-write guard** (MIN-740).

```bash
curl -X POST "$MYN_API_URL/api/v2/unified-tasks/TASK_ID/archive" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Search (via unified search)

```
GET /api/v2/search
```

See [search-api.md](search-api.md) for full search documentation.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query |
| `includeArchived` | boolean | Include archived results (default: false) |
| `limit` | number | Max results (default: 20) |
| `offset` | number | Pagination offset (default: 0) |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=quarterly+report&limit=10"
```
