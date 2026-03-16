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

**Response:** `{ goalsAndAmbitions: string | null, stateHash: string }`

Goals are stored as a single markdown text field. The response includes a `stateHash` for use in the read-before-write protocol (MIN-740).

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/goals"
# → { "goalsAndAmbitions": "...", "stateHash": "abc123" }
```

### Update Goals

```
PUT /api/v1/customers/goals
```

**Requires `X-MYN-State-Hash` header** (agent requests only — MIN-740 read-before-write guard).
Read goals first (`GET /api/v1/customers/goals`) and use its `stateHash` value.

**Body:**

```json
{
  "goalsAndAmbitions": "- **Run a marathon** [active] (high priority)\n  Complete a full marathon by end of year\n  Target: 2026-12-31\n- **Read 24 books** [active] (medium priority)"
}
```

**Response:** `{ status: "success", message: "Goals and ambitions updated successfully" }`

Goals are stored as markdown text. Format each goal as a markdown list item with title, status, priority, description, and target date. The AI assistant formats structured goal objects into this markdown before sending.

```bash
# 1. Read to get stateHash
HASH=$(curl -s -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/goals" | jq -r .stateHash)

# 2. Write with hash
curl -X PUT "$MYN_API_URL/api/v1/customers/goals" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: $HASH" \
  -H "Content-Type: application/json" \
  -d '{"goalsAndAmbitions": "- **Read 24 books this year** [active] (medium priority)"}'
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

### Update Picture Preference

```
PUT /api/v1/customers/picture-preference
```

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Use the `stateHash` from `GET /api/v1/customers/goals` (covers all customer preferences).

### Update Notification Preferences

```
PUT /api/v1/customers/notification-preferences
```

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Use the `stateHash` from `GET /api/v1/customers/goals`.

### Update Theme Preference

```
PUT /api/v1/customers/theme-preference
```

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Use the `stateHash` from `GET /api/v1/customers/goals`.

**Body:** `{ "theme": "light" | "dark" | "system" }`

**Note:** All three preference PUT endpoints share the same customer state hash. Read `GET /api/v1/customers/goals` to obtain the `stateHash` before any preference write.
