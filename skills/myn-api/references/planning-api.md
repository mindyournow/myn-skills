# Planning API

AI-powered planning, auto-scheduling, and rescheduling.

## Base Path

`/planning`

## Actions

The `myn_planning` tool supports these actions: `plan`, `schedule_all`, `reschedule`.

## Endpoints

### Plan (Trigger AI Planning)

```
GET /planning/plan
```

Triggers the AI planning engine to plan/schedule tasks for the current user. The backend handles this automatically based on the authenticated user's tasks -- no request body is needed.

**Tool Parameters (accepted but not sent to backend):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `goal` | string | What you want to accomplish |
| `constraints` | object | Planning constraints |
| `constraints.availableHours` | number | Available hours |
| `constraints.preferredTimes` | string[] | Preferred time slots |
| `constraints.avoidTimes` | string[] | Times to avoid |
| `constraints.deadline` | datetime | Hard deadline |
| `constraints.priority` | string | `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON` |
| `tasks` | array | Tasks to plan |

**Response:** String result from the planning engine.

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/planning/plan"
```

### Schedule All

```
POST /planning/scheduleAll
```

Auto-schedules all eligible tasks (today or past start date, not completed, not OVER_THE_HORIZON/PARKING_LOT) for the authenticated user, then triggers planning. No request body needed.

**Note (MIN-740):** Changed from GET to POST.

```bash
curl -X POST "$MYN_API_URL/planning/scheduleAll" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Reschedule (Kick the Can)

```
POST /planning/kickTheCan?rebalance={true|false}
```

Reschedules overdue/today tasks into the future based on priority. Optionally redistributes all uncompleted tasks evenly.

**Note (MIN-740):** Changed from GET to POST.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `rebalance` | boolean | If `true`, redistribute all uncompleted tasks evenly (default: false) |

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `spreadOverDays` | number | If > 1, sets `rebalance=true` (default: 1) |

```bash
# Basic reschedule — defer overdue tasks
curl -X POST "$MYN_API_URL/planning/kickTheCan?rebalance=false" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'

# Rebalance — spread all uncompleted tasks evenly
curl -X POST "$MYN_API_URL/planning/kickTheCan?rebalance=true" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```
