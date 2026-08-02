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

Returns a bounded page of memories. `limit` is required; omitting it returns
HTTP 400. Values are clamped to 1–200.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | number | **Required.** Maximum memories to return, clamped to 1–200 |
| `offset` | number | Number of memories to skip (default: 0) |

**Response envelope:**

```json
{
  "memories": [
    {
      "id": "uuid",
      "type": "PREFERENCE",
      "content": "User prefers morning meetings",
      "confidence": 0.9,
      "sourceConversationId": "conversation-id",
      "sourceGoalId": null,
      "createdAt": "2026-03-01T00:00:00",
      "lastReinforcedAt": "2026-03-05T00:00:00",
      "reinforcementCount": 2,
      "lastUsedAt": "2026-03-09T10:00:00",
      "usageCount": 3,
      "topics": ["meetings"],
      "hasEmbedding": true
    }
  ],
  "totalCount": 1,
  "limit": 50,
  "offset": 0,
  "hasMore": false
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories?limit=50"
```

### Recall One Memory by ID

```
GET /api/v1/customers/memories/{memoryId}
```

Returns one memory owned by the authenticated customer without scanning the
paginated collection. A missing ID or an ID owned by another customer returns
HTTP 404.

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/memories/MEMORY_ID"
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
