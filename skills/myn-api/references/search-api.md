# Search API

Unified search across all MYN entity types with filtering, pagination, and relevance highlighting.

## Base Path

`/api/v2/search`

## Endpoints

### Search

```
POST /api/v2/search
```

Performs a full-text search across tasks, habits, chores, events, projects, notes, and memories.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `query` | string | **Required.** Search query text |
| `types` | string[] | Entity types to search. Options: `task`, `habit`, `chore`, `event`, `project`, `note`, `memory`. Omit to search all types. |
| `filters` | object | Optional filters to narrow results |
| `filters.status` | string | Filter by status (e.g., `PENDING`, `COMPLETED`) |
| `filters.priority` | string | Filter by priority (e.g., `CRITICAL`, `OPPORTUNITY_NOW`) |
| `filters.projectId` | UUID | Filter by project |
| `filters.dateFrom` | date | Results from this date onward (YYYY-MM-DD) |
| `filters.dateTo` | date | Results up to this date (YYYY-MM-DD) |
| `limit` | number | Max results (default: 20, max: 100) |
| `offset` | number | Pagination offset (default: 0) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `results` | object[] | Array of search result objects |
| `results[].id` | UUID | Entity identifier |
| `results[].type` | string | Entity type (`task`, `habit`, `chore`, `event`, `project`, `note`, `memory`) |
| `results[].title` | string | Entity title |
| `results[].description` | string | Entity description (nullable) |
| `results[].relevance` | number | Relevance score (0.0 to 1.0) |
| `results[].highlights` | object[] | Matched text snippets |
| `results[].highlights[].field` | string | Field where the match occurred (e.g., `title`, `description`) |
| `results[].highlights[].snippet` | string | Text snippet with match context |
| `results[].metadata` | object | Type-specific metadata (e.g., `priority`, `status`, `dueDate`) |
| `total` | number | Total matching results |
| `limit` | number | Limit used in this request |
| `offset` | number | Offset used in this request |
| `query` | string | The query that was executed |
| `suggestions` | string[] | Alternative search suggestions (nullable) |

```bash
# Basic search
curl -X POST "$MYN_API_URL/api/v2/search" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "quarterly report"}'

# Search only tasks and notes
curl -X POST "$MYN_API_URL/api/v2/search" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "quarterly report",
    "types": ["task", "note"],
    "limit": 10
  }'

# Search with filters
curl -X POST "$MYN_API_URL/api/v2/search" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "budget",
    "types": ["task", "project"],
    "filters": {
      "status": "PENDING",
      "priority": "CRITICAL",
      "dateFrom": "2026-01-01",
      "dateTo": "2026-03-31"
    },
    "limit": 50,
    "offset": 0
  }'

# Paginated search
curl -X POST "$MYN_API_URL/api/v2/search" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "meeting notes",
    "limit": 20,
    "offset": 20
  }'
```
