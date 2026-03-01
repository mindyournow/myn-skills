# Planning API

AI-powered planning, auto-scheduling, and rescheduling.

## Base Path

`/api/schedules`

## Endpoints

### Create Plan

```
POST /api/schedules/plan
```

Generate an AI plan for a goal or set of tasks.

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `goal` | string | Yes* | What you want to accomplish |
| `tasks` | array | Yes* | Tasks to plan (alternative to goal) |
| `tasks[].title` | string | Yes | Task title |
| `tasks[].estimatedDuration` | number | No | Duration in minutes |
| `tasks[].dependsOn` | string[] | No | Task titles this depends on |
| `tasks[].fixedTime` | datetime | No | Fixed time slot |
| `constraints` | object | No | Planning constraints |
| `constraints.availableHours` | number | No | Available hours |
| `constraints.preferredTimes` | string[] | No | Preferred time slots |
| `constraints.avoidTimes` | string[] | No | Times to avoid |
| `constraints.deadline` | datetime | No | Hard deadline |
| `constraints.priority` | string | No | `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON` |

*At least one of `goal` or `tasks` is required.

**Response:**

```json
{
  "planId": "uuid",
  "goal": "Complete Q1 planning",
  "estimatedDuration": 240,
  "schedule": [
    {
      "step": 1,
      "title": "Review last quarter metrics",
      "description": "Pull Q4 data and analyze trends",
      "estimatedMinutes": 60,
      "suggestedTimeSlot": {
        "start": "2026-03-01T09:00:00Z",
        "end": "2026-03-01T10:00:00Z"
      },
      "dependencies": []
    }
  ],
  "conflicts": [
    {
      "taskTitle": "Team standup",
      "reason": "Overlaps with suggested time slot",
      "suggestion": "Move to 10:30 AM"
    }
  ],
  "suggestions": ["Consider breaking the budget review into two sessions"],
  "createdAt": "2026-03-01T08:00:00Z"
}
```

```bash
curl -X POST "$MYN_API_URL/api/schedules/plan" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "goal": "Complete Q1 planning",
    "constraints": {
      "availableHours": 4,
      "deadline": "2026-03-05T17:00:00Z",
      "priority": "CRITICAL"
    }
  }'
```

### Auto-Schedule Day

```
POST /api/schedules/auto
```

Automatically schedule all unscheduled tasks for a day.

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | date | No | Date to schedule (default: today) |
| `respectExisting` | boolean | No | Keep existing calendar items (default: true) |
| `bufferMinutes` | number | No | Buffer between tasks (default: 15) |

**Response:**

```json
{
  "date": "2026-03-01",
  "scheduled": [
    {
      "taskId": "uuid",
      "title": "Prepare report",
      "scheduledStart": "2026-03-01T09:00:00Z",
      "scheduledEnd": "2026-03-01T11:00:00Z",
      "priority": "CRITICAL"
    }
  ],
  "unscheduled": [
    {
      "taskId": "uuid",
      "title": "Research competitors",
      "reason": "Not enough available time"
    }
  ],
  "conflicts": [
    {
      "type": "overlap",
      "description": "Two critical tasks competing for morning slot",
      "tasksInvolved": ["uuid1", "uuid2"]
    }
  ],
  "stats": {
    "totalScheduled": 5,
    "totalMinutes": 300,
    "byPriority": { "CRITICAL": 2, "OPPORTUNITY_NOW": 3 }
  }
}
```

```bash
curl -X POST "$MYN_API_URL/api/schedules/auto" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"date": "2026-03-01", "bufferMinutes": 15}'
```

### Reschedule Tasks

```
POST /api/schedules/reschedule
```

Move tasks to a different date.

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `taskIds` | UUID[] | Yes | Tasks to reschedule |
| `reason` | string | No | Why rescheduling |
| `targetDate` | date | No | New target date |
| `spreadOverDays` | number | No | Spread across N days (default: 1) |

**Response:**

```json
{
  "rescheduled": [
    {
      "taskId": "uuid",
      "title": "Budget review",
      "oldDate": "2026-03-01",
      "newDate": "2026-03-03"
    }
  ],
  "failed": [
    {
      "taskId": "uuid",
      "reason": "Task is already completed"
    }
  ],
  "suggestions": ["Consider spreading over 2 days to avoid overload"]
}
```

```bash
curl -X POST "$MYN_API_URL/api/schedules/reschedule" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "taskIds": ["uuid1", "uuid2"],
    "targetDate": "2026-03-05",
    "reason": "Meeting overran, no time today"
  }'
```
