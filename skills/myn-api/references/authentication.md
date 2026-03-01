# Authentication

## API Key Setup

MYN uses API key authentication for agent access. Generate a key in the MYN app:

1. Go to **Settings > API Keys**
2. Click **Create API Key**
3. Select the `AGENT_FULL` scope (recommended for AI agents — grants access to all non-admin endpoints)
4. Copy the key (format: `myn_xxxx_...`)

## Making Requests

Include the API key in every request via the `X-API-KEY` header:

```bash
curl -H "X-API-KEY: myn_xxxx_your_key_here" \
  https://api.mindyournow.com/api/v2/unified-tasks
```

Alternative: pass as query parameter `x-api-key` (less secure, avoid in production):

```
https://api.mindyournow.com/api/v2/unified-tasks?x-api-key=myn_xxxx_your_key_here
```

## Environment Variables

Set these for the helper script and examples:

```bash
export MYN_API_URL="https://api.mindyournow.com"
export MYN_API_KEY="myn_xxxx_your_key_here"
```

## Scopes

| Scope | Description |
|-------|------------|
| `AGENT_FULL` | Full access to all non-admin endpoints (recommended) |
| `TASKS_LIST` | List tasks only |
| `TASKS_VIEW` | View individual tasks |
| `TASKS_CREATE` | Create tasks |
| `TASKS_UPDATE` | Update tasks |
| `TASKS_DELETE` | Delete tasks |
| `TASKS_CALENDAR` | Calendar task operations |
| `SCHEDULES_*` | Schedule-related endpoints (5 scopes) |
| `PROJECTS_*` | Project-related endpoints (5 scopes) |
| `USER_READ` | Read user profile |
| `ADMIN_FULL` | Admin access (not for agents) |

For AI agents, always use `AGENT_FULL` — it covers all 17 non-admin scopes in a single selection.

## Rate Limits

| Limit | Default |
|-------|---------|
| Per-minute | 60 requests |
| Per-hour | 1,000 requests |

Rate limits are per API key and configurable by the account owner. When rate-limited, the API returns HTTP 429 with a `Retry-After` header.

## Key Format

- **Pattern**: `myn_<type>_<random>`
- **Storage**: BCrypt-hashed, prefix-indexed for fast lookup
- **Audit**: Every API key usage is logged (endpoint, method, status code, IP, response time)

## Error Responses

| Status | Meaning |
|--------|---------|
| 401 | Missing or invalid API key |
| 403 | Valid key but insufficient scope |
| 429 | Rate limit exceeded |

```json
{
  "error": "Forbidden",
  "message": "API key does not have required scope: TASKS_CREATE",
  "status": 403
}
```
