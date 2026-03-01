# Household API

Household members, invites, and chore management.

## Base Path

`/api/v1/households` and `/api/v2/chores`

## Getting the Household ID

Most endpoints require a `householdId`. Get it from the user profile:

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/me"
# → { "households": [{ "id": "uuid", "name": "Home" }] }
```

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

### List Chores

```
GET /api/v2/chores?householdId={householdId}
```

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
  "$MYN_API_URL/api/v2/chores?householdId=HOUSEHOLD_ID"
```

### Get Chore Schedule

```
GET /api/v2/chores/schedule
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `householdId` | UUID | Required |
| `date` | date | Specific date (YYYY-MM-DD) |
| `weekStart` | date | Start of week to view |

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
          "completed": false
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
  "$MYN_API_URL/api/v2/chores/schedule?householdId=HOUSEHOLD_ID&date=2026-03-01"
```

### Complete Chore

```
POST /api/v2/chores/{choreId}/complete
```

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `completedBy` | UUID | No | Member who completed it |
| `note` | string | No | Completion note |

**Response:** `{ choreId, completed, completedAt, nextDueDate? }`

```bash
curl -X POST "$MYN_API_URL/api/v2/chores/CHORE_ID/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"note": "Both bins taken to curb"}'
```
