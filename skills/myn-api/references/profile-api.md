# Profile API

User information, goals, and preferences.

## Base Path

`/api/v1/customers`

## Actions

The `myn_profile` tool supports these actions: `get_info`, `get_goals`, `update_goals`, `preferences`.

## Endpoints

### Get User Info

```
GET /api/v1/customers
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
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers"
```

### Get Goals

```
GET /api/v1/customers/goals
```

**Response:** `{ goalsAndAmbitions: string | null, stateHash: string }`

Goals are stored as a single markdown text field. The response includes a `stateHash` for use in the read-before-write protocol (MIN-740).

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/goals"
```

### Update Goals

```
PUT /api/v1/customers/goals
```

**Uses read-before-write guard** (MIN-740). Reads goals first to get `stateHash`, retries on 409.

The tool formats structured goal objects into markdown before sending:

**Tool Parameters (goals array):**

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | **Required.** Goal title |
| `description` | string | Goal description |
| `targetDate` | date | Target date (YYYY-MM-DD) |
| `priority` | string | `low`, `medium`, `high` |
| `status` | string | `active`, `completed`, `paused`, `abandoned` |

**Request Body (sent to backend):**

```json
{
  "goalsAndAmbitions": "- **Run a marathon** [active] (high priority)\n  Complete a full marathon by end of year\n  Target: 2026-12-31"
}
```

**Response:** `{ status: "success", message: "Goals and ambitions updated successfully" }`

```bash
HASH=$(curl -s -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/goals" | jq -r .stateHash)

curl -X PUT "$MYN_API_URL/api/v1/customers/goals" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: $HASH" \
  -H "Content-Type: application/json" \
  -d '{"goalsAndAmbitions": "- **Read 24 books this year** [active] (medium priority)"}'
```

### Preferences

Preferences are managed via dedicated endpoints, not a generic preferences store.

**Valid preference keys:**

| Key | Endpoint |
|-----|----------|
| `notification-preferences` | `GET/PUT /api/v1/customers/notification-preferences` |
| `coaching-intensity` | `GET/PUT /api/v1/customers/coaching-intensity` |
| `theme-preference` | `GET/PUT /api/v1/customers/theme-preference` |

**Tool Behavior:**

- With `preferenceKey` + `preferenceValue`: PUTs the value to the corresponding endpoint
- With `preferenceKey` only: GETs from the corresponding endpoint
- Without `preferenceKey`: GETs all preferences by fetching each endpoint

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `preferenceKey` | string | One of: `notification-preferences`, `coaching-intensity`, `theme-preference` |
| `preferenceValue` | any | Value to set (triggers PUT) |

```bash
# Get all preferences
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/notification-preferences"
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/coaching-intensity"
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v1/customers/theme-preference"

# Update theme
curl -X PUT "$MYN_API_URL/api/v1/customers/theme-preference" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"theme": "dark"}'
```
