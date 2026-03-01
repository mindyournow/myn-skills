# Profile API

User information, goals, and preferences.

## Base Path

`/api/v1/customers`

## Endpoints

### Get User Info

```
GET /api/v1/customers/me
```

**Response:**

```json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "timezone": "America/New_York",
  "language": "en",
  "createdAt": "2026-01-15T00:00:00Z",
  "households": [
    { "id": "uuid", "name": "Home", "role": "owner" }
  ],
  "subscription": {
    "tier": "pro",
    "expiresAt": "2027-01-15T00:00:00Z"
  },
  "stats": {
    "totalTasksCompleted": 1234,
    "currentStreak": 45,
    "longestStreak": 120
  }
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/me"
```

### Get Goals

```
GET /api/v1/customers/goals
```

**Response:** `{ goals[{ id, title, description?, targetDate?, priority, status, progress, createdAt, updatedAt, relatedTasks?[] }], activeCount, completedCount }`

- `priority`: `low`, `medium`, `high`
- `status`: `active`, `completed`, `paused`, `abandoned`
- `progress`: 0–100

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/goals"
```

### Create Goals

```
POST /api/v1/customers/goals
```

**Body:**

```json
{
  "goals": [
    {
      "title": "Run a marathon",
      "description": "Complete a full marathon by end of year",
      "targetDate": "2026-12-31",
      "priority": "high"
    }
  ]
}
```

**Response:** `{ created[{ goalId, title }] }`

```bash
curl -X POST "$MYN_API_URL/api/v1/customers/goals" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"goals": [{"title": "Read 24 books this year", "priority": "medium"}]}'
```

### Update Goal

```
PUT /api/v1/customers/goals/{goalId}
```

**Body:** `{ title?, description?, targetDate?, priority?, status? }`

**Response:** `{ goalId, updated }`

```bash
curl -X PUT "$MYN_API_URL/api/v1/customers/goals/aabb0000-0000-0000-0000-000000000001" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
```

### Get Preferences

```
GET /api/v1/customers/preferences
GET /api/v1/customers/preferences/{key}
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Filter: `notifications`, `display`, `ai`, `privacy`, `integrations` |

**Response (all):** `{ preferences: { key: value, ... }, categories[] }`
**Response (specific):** `{ key, value, category, updatedAt }`

```bash
# Get all preferences
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/preferences"

# Get AI preferences only
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/preferences?category=ai"
```

### Set Preference

```
PUT /api/v1/customers/preferences
```

**Body:** `{ key, value, category? }`

**Response:** `{ key, updated }`

```bash
curl -X PUT "$MYN_API_URL/api/v1/customers/preferences" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key": "ai.tone", "value": "friendly", "category": "ai"}'
```
