# Memory API

Agent memory for storing and retrieving contextual information about users.

## Endpoints

### Remember (Store Memory)

```
POST /api/v1/agent/memories
```

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | Memory content to store (max 500 chars) |
| `type` | string | No | `PREFERENCE`, `PATTERN`, `STYLE`, `MYN_BEHAVIOR`, `PERSONAL`, `RELATIONSHIP` |

**Note:** The tool accepts `category` as the input parameter name, but sends it as the `type` field in the request body.

**Response:**

```json
{
  "id": "uuid",
  "type": "PREFERENCE",
  "content": "User prefers morning meetings before 10am",
  "confidence": 0.95,
  "duplicate": false,
  "message": "Memory stored successfully"
}
```

```bash
curl -X POST "$MYN_API_URL/api/v1/agent/memories" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "User prefers morning meetings before 10am",
    "type": "PREFERENCE"
  }'
```

### Recall (Get Memories)

```
GET /api/v1/customers/memories?limit=50
```

Returns all memories (up to 50). Optionally filter client-side by `memoryId`.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | number | Max results (default: 50) |

**Response:** Array of memory objects:

```json
[
  {
    "memoryId": "uuid",
    "content": "User prefers morning meetings",
    "category": "PREFERENCE",
    "tags": [],
    "importance": "medium",
    "createdAt": "2026-03-01T00:00:00Z",
    "accessedAt": "2026-03-09T10:00:00Z"
  }
]
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories?limit=50"
```

### Forget (Delete Memory)

```
DELETE /api/v1/customers/memories/{memoryId}
```

```bash
curl -X DELETE "$MYN_API_URL/api/v1/customers/memories/MEMORY_ID" \
  -H "X-API-KEY: $MYN_API_KEY"
```

### Search Memories

```
GET /api/v1/agent/memories/search
```

Semantic search across agent memories.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | string | **Required.** Search query |
| `limit` | number | Max results (default: 10) |

**Response:**

```json
{
  "results": [
    {
      "id": "uuid",
      "type": "PREFERENCE",
      "content": "User prefers morning meetings",
      "confidence": 0.95,
      "createdAt": "2026-03-01T00:00:00Z",
      "topics": ["meetings", "scheduling"]
    }
  ],
  "total": 1
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/agent/memories/search?query=meeting+preference&limit=5"
```
