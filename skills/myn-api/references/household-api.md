# Household API

Household members, invites, and chore management.

## Base Path

`/api/v1/households` and `/api/v2/chores`

## Getting the Household ID

Most endpoints require a `householdId`. The plugin auto-resolves it via:

```
GET /api/v1/households/current
```

Response: `{ "id": "uuid" }`

## Endpoints

### List Members

```
GET /api/v1/households/{householdId}/members
```

**Response:**

```json
{
  "householdId": "uuid",
  "members": [
    {
      "id": "uuid",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "owner",
      "joinedAt": "2026-01-15T00:00:00Z",
      "avatarUrl": "https://..."
    }
  ],
  "pendingInvites": [
    {
      "inviteId": "uuid",
      "email": "jane@example.com",
      "role": "member",
      "invitedAt": "2026-03-01T00:00:00Z",
      "expiresAt": "2026-03-08T00:00:00Z"
    }
  ]
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/members"
```

### Invite Member

```
POST /api/v1/households/{householdId}/invites
```

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | email | Yes | Email to invite |
| `role` | string | No | `member` or `admin` (default: member) |
| `message` | string | No | Custom invite message |

**Response:** `{ inviteId, invited, expiresAt }`

```bash
curl -X POST "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/invites" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email": "jane@example.com", "role": "member"}'
```

### List Chores (Today)

```
GET /api/v2/chores/today?householdId={householdId}
```

Returns today's chores for the household.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `householdId` | UUID | Required |

**Response:**

```json
{
  "householdId": "uuid",
  "chores": [
    {
      "id": "uuid",
      "title": "Take out trash",
      "description": "Both kitchen and recycling",
      "recurrenceRule": "FREQ=WEEKLY;BYDAY=TU,FR",
      "assignedTo": "member-uuid",
      "estimatedMinutes": 10,
      "difficulty": "easy",
      "category": "household"
    }
  ]
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/chores/today?householdId=HOUSEHOLD_ID"
```

### Get Chore Schedule

```
GET /api/v2/chores/schedule/range
```

Returns chore schedule for a date range.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `householdId` | UUID | Required |
| `startDate` | date | Start date (YYYY-MM-DD, defaults to today) |
| `endDate` | date | End date (YYYY-MM-DD, defaults to startDate + 7 days) |

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `date` | date | Specific date (sets both startDate and endDate) |
| `weekStart` | date | Start of week (endDate computed as +7 days) |

**Response:**

```json
{
  "schedule": [
    {
      "date": "2026-03-01",
      "dayOfWeek": 0,
      "chores": [
        {
          "choreId": "uuid",
          "title": "Take out trash",
          "assignedTo": "member-uuid",
          "estimatedMinutes": 10,
          "completed": false,
          "completedAt": null,
          "completedBy": null
        }
      ]
    }
  ],
  "totalChores": 5,
  "completedChores": 2
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/chores/schedule/range?householdId=HOUSEHOLD_ID&startDate=2026-03-01&endDate=2026-03-07"
```

### Complete Chore

```
POST /api/v2/chores/instances/{choreId}/complete
```

**Uses read-before-write guard** — reads chore instance state hash before completing.

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `completedBy` | UUID | No | Member who completed it |
| `note` | string | No | Completion note |

**Response:** `{ choreId, completed, completedAt, nextDueDate? }`

```bash
curl -X POST "$MYN_API_URL/api/v2/chores/instances/CHORE_ID/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123" \
  -H "Content-Type: application/json" \
  -d '{"note": "Both bins taken to curb"}'
```
