---
name: myn-api
description: "Mind Your Now productivity platform REST API. Use when the user asks about
  tasks, habits, calendar, briefings, timers, grocery lists, or productivity planning.
  Provides task management, daily compass briefings, habit tracking, calendar events,
  grocery lists, timers, memory, and AI planning via REST API."
version: "0.1.0"
triggers:
  - "myn"
  - "mind your now"
  - "task"
  - "briefing"
  - "compass"
  - "habit"
  - "grocery"
  - "timer"
  - "pomodoro"
globs: []
---

# Mind Your Now (MYN) — REST API Skill

## Core Philosophy: Control Urgency

> "Control urgency so you can focus on important work with a calmer state of mind."

MYN's key insight: your brain fixates on urgent things. By properly managing what's "urgent now," you free mental space for important work. MYN uses **urgency, not importance** as the primary organizing principle.

## The MYN Priority System

Only ONE criterion: **"Is this absolutely due today?"**

### Critical Now (max 5 items)

**The Going Home Test**: "Would you work until midnight to finish this?"
- YES → Critical Now
- NO → Not Critical Now

Rules: **maximum 5 items**, genuinely due TODAY, "hair on fire" tasks.

### Opportunity Now (max 20 items)

Tasks you'd like to do soon but aren't burning. Start dates in the past or near future. Can be worked on opportunistically.

### Over-the-Horizon (10+ days out)

The secret sauce — set start dates 10+ days in the future to get tasks OFF your mental radar. Your brain stops worrying about them.

### Parking Lot

Low urgency tasks that don't fit elsewhere. Review periodically.

## Authentication

All API calls require an `X-API-KEY` header with an API key that has the `AGENT_FULL` scope.

```bash
export MYN_API_URL="https://api.mindyournow.com"
export MYN_API_KEY="myn_xxxx_your_key_here"

curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v2/unified-tasks"
```

Generate an API key at **Settings > API Keys** in MYN. Select the `AGENT_FULL` scope (recommended for AI agents).

See: [references/authentication.md](references/authentication.md)

## API Routing Table

| Domain | Base Path | Reference Doc | Common Actions |
|--------|-----------|--------------|----------------|
| **Tasks** | `/api/v2/unified-tasks` | [tasks-api.md](references/tasks-api.md) | List (all, filter client-side), create, update, complete, archive |
| **Briefing** | `/api/v2/compass` | [briefing-api.md](references/briefing-api.md) | Status, generate, corrections, complete session |
| **Calendar** | `/api/v2/calendar` | [calendar-api.md](references/calendar-api.md) | List events, create event, delete, meetings |
| **Habits** | `/api/v1/habit-chains` | [habits-api.md](references/habits-api.md) | Streaks, skip, chains, schedule, reminders |
| **Lists** | `/api/v1/households/{id}/grocery-list` | [lists-api.md](references/lists-api.md) | Get, add, toggle, bulk add, convert to tasks |
| **Timers** | `/api/v2/timers` | [timers-api.md](references/timers-api.md) | Countdown, alarm, pomodoro, snooze, cancel |
| **Search** | `/api/v2/search` | [search-api.md](references/search-api.md) | Unified search across all content types |
| **Memory** | `/api/v1/customers/memories` | [memory-api.md](references/memory-api.md) | Remember, recall, forget, search |
| **Profile** | `/api/v1/customers` | [profile-api.md](references/profile-api.md) | User info, goals, preferences |
| **Household** | `/api/v1/households` | [household-api.md](references/household-api.md) | Members, invites, chores, schedule |
| **Projects** | `/api/project` | [projects-api.md](references/projects-api.md) | List, get, create, move task |
| **Planning** | `/api/schedules` | [planning-api.md](references/planning-api.md) | AI plan, auto-schedule, reschedule |

## Task Creation Rules

When creating tasks, you MUST provide:

1. **`id`** — Client-generated UUID (e.g., `uuidgen` or `crypto.randomUUID()`)
2. **`taskType`** — One of: `TASK`, `HABIT`, `CHORE`
3. **`priority`** — One of: `CRITICAL`, `OPPORTUNITY_NOW`, `OVER_THE_HORIZON`, `PARKING_LOT`
4. **`startDate`** — ISO 8601 date (`YYYY-MM-DD`)
5. **`title`** — Task title (1–200 chars)

**Type-specific rules:**

| Type | Requirements |
|------|-------------|
| TASK | Basic task, can be shared |
| HABIT | MUST have `recurrenceRule`, CANNOT be shared |
| CHORE | MUST have `recurrenceRule`, always household-scoped |

**Duration format**: `"30m"`, `"1h"`, `"1h30m"` (NOT ISO `PT` prefix)

```bash
curl -X POST "$MYN_API_URL/api/v2/unified-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Prepare quarterly report",
    "taskType": "TASK",
    "priority": "CRITICAL",
    "startDate": "2026-03-01",
    "duration": "2h"
  }'
```

## Common Workflows

### Morning Routine (Compass Briefing)

```bash
# 1. Check briefing status
curl -H "X-API-KEY: $MYN_API_KEY" "$MYN_API_URL/api/v2/compass/status"

# 2. Generate morning briefing
curl -X POST "$MYN_API_URL/api/v2/compass/generate" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"context": "Morning planning session"}'

# 3. Review Critical Now, Opportunity Now, habits due, upcoming meetings
# 4. Apply corrections if needed
# 5. Complete the session (maintains streak)
curl -X POST "$MYN_API_URL/api/v2/compass/complete" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"summary": "Focused on 3 critical items, deferred 2 to tomorrow"}'
```

### Adding a Task (with capacity check)

```bash
# 1. Check current Critical Now count
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?priority=CRITICAL&status=PENDING"

# 2. If >= 5 items, warn the user and suggest re-prioritization
# 3. Create task with appropriate priority
# 4. For HABIT/CHORE, include recurrenceRule
```

### Dealing with Overload

When a user has too many Critical Now items:

1. Acknowledge the constraint (max 5)
2. Suggest moving items to `OPPORTUNITY_NOW`
3. Update task priorities via `PATCH /api/v2/unified-tasks/{id}`
4. Help reschedule with `POST /api/schedules/reschedule`

## Key Principles

1. **Urgency, not importance** — Focus on what MUST be done today
2. **Start dates, not due dates** — Encourage FRESH prioritization
3. **Respect the limits** — Critical Now max 5, Opportunity Now max 20
4. **Use Over-the-Horizon** — Push future work out of mind (10+ days)
5. **The Going Home Test** — Be honest about what's truly critical
