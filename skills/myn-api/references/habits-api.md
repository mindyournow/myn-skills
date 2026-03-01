# Habits API

Habit streaks, habit chains, scheduling, and reminders.

## Base Path

- Streaks and chains: `/api/v1/habit-chains`
- Reminders: `/api/habits/reminders`

## Endpoints

### List All Habit Streaks

```
GET /api/v1/habit-chains/streaks
```

Returns streak data for all habits.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `habits` | object[] | Array of habit streak objects |
| `habits[].habitId` | UUID | Habit identifier |
| `habits[].title` | string | Habit title |
| `habits[].currentStreak` | number | Current consecutive completions |
| `habits[].longestStreak` | number | All-time longest streak |
| `habits[].totalCompletions` | number | Total times completed |
| `habits[].lastCompletedAt` | datetime | Last completion timestamp |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/streaks"
```

### Get Specific Habit Streak

```
GET /api/v1/habit-chains/{habitId}/streaks
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeHistory` | boolean | Include day-by-day streak history |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `habitId` | UUID | Habit identifier |
| `currentStreak` | number | Current consecutive completions |
| `longestStreak` | number | All-time longest streak |
| `totalCompletions` | number | Total times completed |
| `lastCompletedAt` | datetime | Last completion timestamp |
| `streakHistory` | object[] | Day-by-day history (only if `includeHistory=true`) |
| `streakHistory[].date` | date | Calendar date |
| `streakHistory[].completed` | boolean | Whether the habit was completed that day |

```bash
# Basic streak info
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/660e8400-e29b-41d4-a716-446655440001/streaks"

# With full history
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/660e8400-e29b-41d4-a716-446655440001/streaks?includeHistory=true"
```

### Skip Habit (Preserve Streak)

```
POST /api/v1/habit-chains/{habitId}/skip
```

Marks a habit as skipped for a day without breaking the streak.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `skipDate` | date | Date to skip (default: today, YYYY-MM-DD) |
| `reason` | string | Optional reason for skipping |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `habitId` | UUID | Habit identifier |
| `skippedDate` | date | The date that was skipped |
| `streakPreserved` | boolean | Whether the streak was preserved |
| `newStreakCount` | number | Updated streak count |

```bash
curl -X POST "$MYN_API_URL/api/v1/habit-chains/660e8400-e29b-41d4-a716-446655440001/skip" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "skipDate": "2026-03-01",
    "reason": "Sick day"
  }'
```

### List All Chains

```
GET /api/v1/habit-chains
```

Returns all habit chains (grouped sequences of habits).

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `chains` | object[] | Array of chain objects |
| `chains[].chainId` | UUID | Chain identifier |
| `chains[].name` | string | Chain name |
| `chains[].habitCount` | number | Number of habits in the chain |
| `chains[].totalCompletions` | number | Total completions across all habits |
| `chains[].lastCompletedAt` | datetime | Last completion in this chain |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains"
```

### Get Specific Chain

```
GET /api/v1/habit-chains/{chainId}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `chainId` | UUID | Chain identifier |
| `name` | string | Chain name |
| `habits` | object[] | Ordered list of habits in the chain |
| `habits[].habitId` | UUID | Habit identifier |
| `habits[].title` | string | Habit title |
| `habits[].order` | number | Position in the chain |
| `trigger` | string | What triggers the chain (nullable) |
| `location` | string | Where the chain is performed (nullable) |
| `totalCompletions` | number | Total completions across all habits |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/770e8400-e29b-41d4-a716-446655440002"
```

### Get Habit Schedule

```
GET /api/v1/habit-chains/schedule
```

Returns the habit schedule for the upcoming days.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `days` | number | Number of days to look ahead (default: 7) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `schedule` | object[] | Array of daily schedules |
| `schedule[].date` | date | Calendar date |
| `schedule[].dayOfWeek` | string | Day name (e.g., `Monday`) |
| `schedule[].habits` | object[] | Habits due on that day |
| `schedule[].habits[].habitId` | UUID | Habit identifier |
| `schedule[].habits[].title` | string | Habit title |
| `schedule[].habits[].duration` | string | Expected duration (nullable) |
| `schedule[].habits[].completed` | boolean | Whether already completed |
| `schedule[].habits[].chainName` | string | Parent chain name (nullable) |
| `habitsDue` | number | Total habits due across the period |

```bash
# Default 7-day schedule
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/schedule"

# 14-day schedule
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/habit-chains/schedule?days=14"
```

### List All Reminders

```
GET /api/habits/reminders
```

Returns reminder settings for all habits.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `reminders` | object[] | Array of reminder objects |
| `reminders[].habitId` | UUID | Habit identifier |
| `reminders[].title` | string | Habit title |
| `reminders[].enabled` | boolean | Whether the reminder is active |
| `reminders[].reminderTime` | time | Time of day for the reminder (nullable, HH:mm) |
| `reminders[].reminderDays` | string[] | Days the reminder fires (e.g., `["MON", "WED", "FRI"]`) |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/habits/reminders"
```

### Get Specific Reminder

```
GET /api/habits/reminders/{habitId}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/habits/reminders/660e8400-e29b-41d4-a716-446655440001"
```

### Update Reminder

```
PUT /api/habits/reminders/{habitId}
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | boolean | Enable or disable the reminder |
| `time` | time | Time of day for the reminder (HH:mm) |

```bash
# Enable a reminder at 7:30 AM
curl -X PUT "$MYN_API_URL/api/habits/reminders/660e8400-e29b-41d4-a716-446655440001" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "time": "07:30"
  }'

# Disable a reminder
curl -X PUT "$MYN_API_URL/api/habits/reminders/660e8400-e29b-41d4-a716-446655440001" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```
