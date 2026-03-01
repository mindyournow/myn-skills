# Memory API

Agent memory for storing and retrieving contextual information about users.

## Base Path

`/api/v1/customers/memories`

## Endpoints

### Remember (Store Memory)

```
POST /api/v1/customers/memories
```

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Memory content to store |
| `category` | string | No | `user_preference`, `work_context`, `personal_info`, `decision`, `insight`, `routine` |
| `tags` | string[] | No | Tags for categorization |
| `importance` | string | No | `low`, `medium`, `high`, `critical` |
| `expiresAt` | datetime | No | Optional expiration date (ISO 8601) |

**Response:** `{ memoryId, stored, createdAt }`

```bash
curl -X POST "$MYN_API_URL/api/v1/customers/memories" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "User prefers morning meetings before 10am",
    "category": "user_preference",
    "tags": ["meetings", "preferences"],
    "importance": "medium"
  }'
```

### Recall (Get Memories)

```
GET /api/v1/customers/memories
GET /api/v1/customers/memories/{memoryId}
```

Get recent memories (default limit 10) or a specific memory by ID.

**Response (specific):** `{ memoryId, content, category, tags[], importance, createdAt, accessedAt, accessCount, expiresAt? }`

**Response (list):** `{ memories[{ memoryId, content, category, tags[], importance, createdAt, accessedAt? }] }`

```bash
# Get recent memories
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories?limit=10"

# Get specific memory
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories/aabb0000-0000-0000-0000-000000000001"
```

### Forget (Delete Memory)

```
DELETE /api/v1/customers/memories/{memoryId}
```

```bash
curl -X DELETE "$MYN_API_URL/api/v1/customers/memories/aabb0000-0000-0000-0000-000000000001" \
  -H "X-API-KEY: $MYN_API_KEY"
```

### Search Memories

```
GET /api/v1/customers/memories/search
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query |
| `category` | string | Filter by category |
| `tag` | string | Filter by tag (repeatable for multiple tags) |
| `limit` | number | Max results (default: 10) |

**Response:** `{ results[{ memoryId, content, category, tags[], importance, relevance, createdAt }], total }`

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories/search?q=meeting+preference&category=user_preference&limit=5"
```
