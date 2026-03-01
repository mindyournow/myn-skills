# Calendar API

Calendar events and meetings management including creation, listing, and deletion.

## Base Path

`/api/v2/calendar`

## Endpoints

### List Events

```
GET /api/v2/calendar/events
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | datetime | Filter events starting at or after this time (ISO 8601) |
| `end` | datetime | Filter events ending at or before this time (ISO 8601) |
| `calendarId` | string | Filter by specific calendar |
| `allDay` | boolean | Filter for all-day events only |
| `limit` | number | Max results (default: 50) |

```bash
# List events for this week
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?start=2026-03-01T00:00:00Z&end=2026-03-07T23:59:59Z"

# List only all-day events
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?allDay=true&limit=10"
```

### Create Event

```
POST /api/v2/calendar/events
```

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Event title |
| `startTime` | datetime | Start time (ISO 8601) |
| `endTime` | datetime | End time (ISO 8601, required for non-all-day events) |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `isAllDay` | boolean | Whether this is an all-day event (default: false) |
| `description` | string | Event description |
| `location` | string | Event location |
| `calendarId` | string | Target calendar ID |
| `attendees` | string[] | List of attendee email addresses |
| `recurrence` | string | Recurrence rule (RRULE format, e.g., `FREQ=WEEKLY;BYDAY=MO,WE,FR`) |
| `reminders` | object[] | Reminders, each with `minutes` (number) and `method` (`popup` or `email`) |

```bash
# Create a one-time meeting
curl -X POST "$MYN_API_URL/api/v2/calendar/events" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Team standup",
    "startTime": "2026-03-02T09:00:00Z",
    "endTime": "2026-03-02T09:30:00Z",
    "location": "Conference Room B",
    "attendees": ["alice@example.com", "bob@example.com"],
    "reminders": [{"minutes": 10, "method": "popup"}]
  }'

# Create a recurring all-day event
curl -X POST "$MYN_API_URL/api/v2/calendar/events" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sprint review",
    "startTime": "2026-03-06T00:00:00Z",
    "isAllDay": true,
    "recurrence": "FREQ=WEEKLY;INTERVAL=2;BYDAY=FR",
    "description": "Bi-weekly sprint review"
  }'
```

### Delete Event

```
DELETE /api/v2/calendar/events/{eventId}
```

```bash
curl -X DELETE "$MYN_API_URL/api/v2/calendar/events/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-KEY: $MYN_API_KEY"
```

### List Meetings

```
GET /api/v2/calendar/meetings
```

Returns upcoming meetings with attendee information. This is a convenience view over calendar events filtered to multi-attendee meetings.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `includePast` | boolean | Include past meetings (default: false) |
| `daysAhead` | number | Number of days to look ahead (default: 7) |
| `limit` | number | Max results |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `meetings` | object[] | Array of meeting objects |
| `meetings[].id` | string | Meeting/event ID |
| `meetings[].title` | string | Meeting title |
| `meetings[].startTime` | datetime | Start time |
| `meetings[].endTime` | datetime | End time |
| `meetings[].attendees` | string[] | List of attendee emails |
| `meetings[].location` | string | Meeting location (nullable) |
| `meetings[].isRecurring` | boolean | Whether the meeting recurs |
| `total` | number | Total matching meetings |

```bash
# Get meetings for the next 7 days
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/meetings"

# Get meetings for the next 14 days including past
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/meetings?daysAhead=14&includePast=true&limit=25"
```
