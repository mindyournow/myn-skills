# Projects API

MYN calls its task collections "projects" in the API.

## Collections, not projects

MYN has twelve fixed, server-managed collections such as `PERSONAL`, `WORK`,
`GROCERIES`, `BOOKS`, and `CHORES`. They cannot be created, renamed, or deleted.
Use `move_task` to change which collection a task belongs to. Real user-named
projects are planned as a separate future feature.

## Base Path

`/api/project`

## Actions

The `myn_projects` tool supports these actions: `list`, `get`, `move_task`.

## Endpoints

### List Collections

```
GET /api/project/defaults?limit={limit}
```

`limit` is required. Omitting it returns HTTP 400. The endpoint returns compact,
allowlisted collection summaries rather than project entities and their nested
owner, account, calendar, or task graphs.

**Query parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | number | **Required.** Maximum collections to return, clamped to 1–200 |
| `offset` | number | Number of collections to skip (default: 0) |

**Response envelope:**

```json
{
  "projects": [
    {
      "id": "uuid",
      "type": "PERSONAL",
      "customName": null,
      "customEmoji": null,
      "displayName": "Personal",
      "taskCount": 7
    }
  ],
  "total": 12,
  "limit": 50,
  "offset": 0,
  "hasMore": false
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/project/defaults?limit=50"
```

### Get Collection

```
GET /api/project/{projectId}
```

The stored collection fields are `id`, `type`, `customName`, and `customEmoji`.
`customName` and `customEmoji` apply only to legacy `OTHER` rows; fixed collections
use their enum type as their identity.

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/project/PROJECT_ID"
```

### Create Collection — deprecated

```
POST /api/project/create
```

This endpoint is deprecated. Collection creation is not supported, and real
user-named projects are planned separately. A missing or null `type` returns
HTTP 400 with the valid enum values, an unknown type returns HTTP 400, and an
incomplete legacy `OTHER` body returns HTTP 400 naming `customName` and
`customEmoji`. The `myn_projects` tool does not expose this endpoint.

### Move Task to Collection

```
PUT /api/project/{targetProjectId}/moveTaskToProject/{taskId}
```

Moves a task into an existing collection and returns the updated task. Agent API
keys must read the task first and send its `stateHash` as `X-MYN-State-Hash`; the
`myn_projects` `move_task` action performs this guarded read-before-write flow
automatically.

```bash
curl -X PUT "$MYN_API_URL/api/project/TARGET_PROJECT_ID/moveTaskToProject/TASK_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: TASK_STATE_HASH"
```
