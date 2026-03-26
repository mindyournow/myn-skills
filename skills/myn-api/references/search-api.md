# Search API

Unified search across all MYN entity types with filtering, pagination, and relevance highlighting.

## Base Path

`/api/v2/search`

## Endpoints

### Search

```
GET /api/v2/search
```

Performs a full-text search across tasks, habits, chores, events, projects, notes, and memories using query parameters.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | **Required.** Search query text |
| `types` | string | Entity types to search (repeatable). Options: `task`, `habit`, `chore`, `event`, `project`, `note`, `memory`. Omit to search all types. |
| `status` | string | Filter by status (e.g., `PENDING`, `IN_PROGRESS`, `COMPLETED`, `ARCHIVED`) |
| `priority` | string | Filter by priority (e.g., `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON`, `PARKING_LOT`) |
| `projectId` | UUID | Filter by project |
| `dateFrom` | date | Results from this date onward (YYYY-MM-DD) |
| `dateTo` | date | Results up to this date (YYYY-MM-DD) |
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
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=quarterly+report"

# Search only tasks and notes
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=quarterly+report&types=task&types=note&limit=10"

# Search with filters
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=budget&types=task&types=project&status=PENDING&priority=CRITICAL&dateFrom=2026-01-01&dateTo=2026-03-31&limit=50"

# Paginated search
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/search?q=meeting+notes&limit=20&offset=20"
```
