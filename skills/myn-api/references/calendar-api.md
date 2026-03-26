# Calendar API

Calendar events and meetings management including listing calendars, creating, updating, moving, and deleting events.

## Base Path

`/api/v2/calendar`

## Actions

The `myn_calendar` tool supports these actions: `list_calendars`, `list_events`, `get_event`, `create_event`, `update_event`, `delete_event`, `move_event`, `meetings`.

## Endpoints

### List Calendars

```
GET /api/v1/customers/calendars
```

Returns all connected calendars with metadata.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `calendars` | object[] | Array of calendar objects |
| `calendars[].id` | string | Calendar identifier |
| `calendars[].name` | string | Calendar display name |
| `calendars[].using` | boolean | Whether the calendar is active/in use |
| `calendars[].timeZone` | string | Calendar timezone |
| `calendars[].accessRole` | string | User's access role |
| `calendars[].accountEmail` | string | Associated account email |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/calendars"
```

### List Events

```
GET /api/v2/calendar/events
```

Fetches events from all connected calendars within a date range. Descriptions are automatically truncated to 200 chars and attendee lists are stripped to reduce token bloat.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | datetime | Start of range (ISO 8601). Defaults to today |
| `end` | datetime | End of range (ISO 8601). Defaults to start + 7 days |
| `limit` | number | Max results (default: 50) |

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `startDate` | datetime | Maps to `start` query param |
| `endDate` | datetime | Maps to `end` query param |
| `daysAhead` | number | Alternative to `endDate` — computes end date N days from now |
| `limit` | number | Max results (default: 50) |

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
      "taskId": "550e8400-e29b-41d4-a716-446655440000",
      "status": "confirmed"
    }
  ],
  "total": 1,
  "start": "2026-03-09T00:00:00",
  "end": "2026-03-16T00:00:00"
}
```

**Note:** When a calendar event is linked to a MYN task, the response includes a `taskId` field (UUID string) referencing the linked task.

### Get Event

```
GET /api/v2/calendar/events/{eventId}
```

Returns full details for a single event including description and attendees. Results are cached in-memory (10-minute TTL) with hash-based change detection.

**Required Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `eventId` | string | Calendar event ID |

**Response:** Full event object plus `_cached` (boolean, whether unchanged since last fetch) and `_hash` (content hash).

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events/EVENT_ID"
```

### Create Event

```
POST /api/v2/calendar/standalone-events
```

Creates a new calendar event (not linked to a MYN task).

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Event title (1-200 chars) |
| `startTime` | datetime | Start time (ISO 8601) |
| `endTime` | datetime | End time (ISO 8601, required for non-all-day events) |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `isAllDay` | boolean | All-day event (default: false) |
| `description` | string | Event description (max 2000 chars) |
| `location` | string | Event location |
| `calendarId` | string | Target calendar ID |
| `calendarName` | string | Calendar name to resolve to ID (e.g. "Family", "Work") |
| `attendees` | string[] | Email addresses, household member first names, or "family"/"everyone" to invite all household members |
| `timezone` | string | Timezone (e.g., "America/New_York") |
| `recurrence` | string | RRULE format (e.g., `FREQ=WEEKLY;BYDAY=MO,WE,FR`) |
| `reminders` | object[] | Each with `minutes` (number) and `method` (`popup` or `email`) |

**Calendar Selection Logic:**
1. Explicit `calendarId` takes precedence
2. `calendarName` is resolved by fuzzy match against available calendars
3. If attendees include household members, auto-detects family/shared calendar
4. Falls back to "primary"

```bash
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

### Update Event

```
PATCH /api/v2/calendar/standalone-events/{eventId}?calendarId={calendarId}
```

Updates an existing calendar event. Only provided fields are changed.

**Required Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `eventId` | string | Calendar event ID |

**Update Fields (all optional, at least one required):**

| Field | Type | Description |
|-------|------|-------------|
| `newTitle` | string | New title |
| `newDescription` | string | New description |
| `newLocation` | string | New location |
| `newStartTime` | datetime | New start time (ISO 8601) |
| `newEndTime` | datetime | New end time (ISO 8601) |
| `newAttendees` | string[] | Replace attendee list (email addresses or household member names) |
| `addAttendees` | string[] | Add to existing attendee list |
| `calendarId` | string | Calendar ID (defaults to "primary") |
| `calendarName` | string | Calendar name to resolve |
| `timezone` | string | Timezone for start/end times |

```bash
curl -X PATCH "$MYN_API_URL/api/v2/calendar/standalone-events/EVENT_ID?calendarId=primary" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated meeting title", "location": "Room C"}'
```

### Delete Event

```
DELETE /api/v2/calendar/events/{eventId}
```

**Uses read-before-write guard** (agent reads event state hash before deleting).

```bash
curl -X DELETE "$MYN_API_URL/api/v2/calendar/events/EVENT_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123"
```

### Move Event

```
POST /api/v2/calendar/standalone-events/{eventId}/move?sourceCalendarId={source}&destinationCalendarId={destination}
```

Moves an event from one calendar to another.

**Required Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `eventId` | string | Calendar event ID |
| `destinationCalendarId` | string | Target calendar ID (or use `destinationCalendarName`) |

**Optional Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `destinationCalendarName` | string | Target calendar name (resolved by fuzzy match) |
| `sourceCalendarId` | string | Source calendar ID (defaults to "primary") |

```bash
curl -X POST "$MYN_API_URL/api/v2/calendar/standalone-events/EVENT_ID/move?sourceCalendarId=primary&destinationCalendarId=DEST_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Meetings

```
GET /api/v2/calendar/events (filtered to events with attendees)
```

Returns upcoming meetings (events that have attendees). This action uses the standard events endpoint with date range filtering, then filters to only events with attendees.

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `includePast` | boolean | Include today's past meetings (default: false) |
| `daysAhead` | number | Days to look ahead (default: 7) |
| `limit` | number | Max results |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/calendar/events?start=2026-03-09T00:00:00&end=2026-03-16T00:00:00"
```
