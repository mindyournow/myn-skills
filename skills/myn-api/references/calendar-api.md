# Calendar API

Calendar events and meetings management including creation, listing, and deletion.

## Base Path

`/api/v2/calendar`

## Endpoints

### List Events

```
GET /api/v2/calendar/events
```

Fetches events from all connected Google/Microsoft calendars within a date range.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | datetime | Start of range (ISO 8601). Defaults to today midnight |
| `end` | datetime | End of range (ISO 8601). Defaults to start + 7 days |
| `limit` | number | Max results (default: 100) |

**Response:**

```json
{
  "events": [
    {
      "id": "google-event-id-123",
      "title": "Team Standup",
      "startTime": "2026-03-09T09:00:00",
      "endTime": "2026-03-09T09:30:00",
      "location": "Conference Room B",
      "calendarId": "primary",
      "calendarName": "Edward Becker",
      "provider": "google",
      "allDay": false,
      "attendees": [
        { "email": "alice@example.com", "name": "Alice", "status": "accepted" }
      ],
      "status": "confirmed"
    }
  ],
  "total": 1,
  "start": "2026-03-09T00:00:00",
  "end": "2026-03-16T00:00:00"
}
```

```bash
# List events for today
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?start=2026-03-09T00:00:00&end=2026-03-09T23:59:59"

# List events for this week
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?start=2026-03-09T00:00:00&end=2026-03-15T23:59:59"
```

### Create Event

```
POST /api/v2/calendar/standalone-events
```

Creates a new Google Calendar event (not linked to a MYN task).

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
| `timezone` | string | Timezone (e.g., "America/New_York") |
| `recurrence` | string | Recurrence rule (RRULE format, e.g., `FREQ=WEEKLY;BYDAY=MO,WE,FR`) |
| `reminders` | object[] | Reminders, each with `minutes` (number) and `method` (`popup` or `email`) |

```bash
# Create a one-time meeting
curl -X POST "$MYN_API_URL/api/v2/calendar/standalone-events" \
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
```

### Delete Event

```
DELETE /api/v2/calendar/events/{eventId}
```

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Read the event first to obtain `stateHash`.

```bash
# 1. Read event to get stateHash (from the events list)
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?start=2026-03-09T00:00:00&end=2026-03-09T23:59:59"
# → { "events": [{ "id": "...", "stateHash": "abc123", ... }] }

# 2. Delete with state hash
curl -X DELETE "$MYN_API_URL/api/v2/calendar/events/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123"
```

### Meeting Metadata

```
GET /api/v2/calendar/meetings/{eventId}/metadata
```

Returns comprehensive meeting details including organizer info, attendees, location, and user permissions.

### Decline Meeting

```
POST /api/v2/calendar/meetings/{eventId}/decline
```

### Skip Meeting

```
POST /api/v2/calendar/meetings/{eventId}/skip
```

### Get Skipped Meetings

```
GET /api/v2/calendar/meetings/skipped
```

## Support

For help with the calendar API, contact support@mindyournow.com
