# Projects API

Project and category management for organizing tasks.

## Base Path

`/api/project`

## Actions

The `myn_projects` tool supports these actions: `list`, `get`, `create`, `move_task`.

## Endpoints

### List Projects

```
GET /api/project/defaults
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeArchived` | boolean | Include archived projects (default: false) |
| `includeStats` | boolean | Include task statistics (default: true) |

**Response:**

```json
{
  "projects": [
    {
      "id": "uuid",
      "name": "Q1 Planning",
      "description": "First quarter objectives",
      "color": "#3B82F6",
      "icon": "target",
      "parentId": null,
      "createdAt": "2026-01-01T00:00:00Z",
      "stats": {
        "totalTasks": 12,
        "completedTasks": 8,
        "criticalTasks": 2
      }
    }
  ]
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/project/defaults?includeStats=true"
```

### Get Project

```
GET /api/project/{projectId}
```

**Response:**

```json
{
  "id": "uuid",
  "name": "Q1 Planning",
  "description": "First quarter objectives",
  "color": "#3B82F6",
  "icon": "target",
  "parentId": null,
  "createdAt": "2026-01-01T00:00:00Z",
  "tasks": [
    {
      "id": "uuid",
      "title": "Prepare budget",
      "priority": "CRITICAL",
      "status": "PENDING",
      "startDate": "2026-03-01"
    }
  ],
  "subProjects": [
    { "id": "uuid", "name": "Budget", "taskCount": 3 }
  ]
}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/project/PROJECT_ID"
```

### Create Project

```
POST /api/project/create
```

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Project name (1-100 chars) |
| `description` | string | No | Description (max 500 chars) |
| `color` | string | No | Hex color (`#3B82F6`) |
| `icon` | string | No | Icon identifier |
| `parentId` | UUID | No | Parent project for nesting |

**Response:** `{ id, name, created }`

```bash
curl -X POST "$MYN_API_URL/api/project/create" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "Home Renovation", "color": "#10B981", "icon": "home"}'
```

### Move Task to Project

```
PUT /api/project/{targetProjectId}/moveTaskToProject/{taskId}
```

Moves a task to a different project. No request body needed.

**Response:** `{ taskId, previousProjectId?, newProjectId, moved }`

```bash
curl -X PUT "$MYN_API_URL/api/project/TARGET_PROJECT_ID/moveTaskToProject/TASK_ID" \
  -H "X-API-KEY: $MYN_API_KEY"
```
