# Habits API

Habit streaks, habit chains, scheduling, and reminders.

## Actions

The `myn_habits` tool supports these actions: `streaks`, `skip`, `chains`, `schedule`, `reminders`.

## Endpoints

### Get Habit Streak

```
GET /api/v2/unified-tasks/{habitId}/streak
```

Returns streak data for a specific habit. Requires `habitId`.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeHistory` | boolean | Include day-by-day streak history (default: false) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `habitId` | UUID | Habit identifier |
| `currentStreak` | number | Current consecutive completions |
| `longestStreak` | number | All-time longest streak |
| `totalCompletions` | number | Total times completed |
| `lastCompletedAt` | datetime | Last completion timestamp (nullable) |
| `streakHistory` | object[] | Day-by-day history (only if `includeHistory=true`) |
| `streakHistory[].date` | date | Calendar date |
| `streakHistory[].completed` | boolean | Whether the habit was completed that day |

```bash
# Basic streak info
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID/streak"

# With full history
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID/streak?includeHistory=true"
```

**Note:** There is no bulk streaks endpoint. Use the `schedule` action to see all habits.

### Skip Habit (Preserve Streak)

```
POST /api/v2/unified-tasks/{habitId}/skip
```

Marks a habit as skipped for a day without breaking the streak.

**Required:** `habitId`

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `skipDate` | date | Date to skip (YYYY-MM-DD, default: today) |
| `reason` | string | Optional reason for skipping |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `habitId` | UUID | Habit identifier |
| `skippedDate` | date | The date that was skipped |
| `streakPreserved` | boolean | Whether the streak was preserved |
| `newStreakCount` | number | Updated streak count |

```bash
curl -X POST "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID/skip" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "skipDate": "2026-03-01",
    "reason": "Sick day"
  }'
```

### List All Chains

```
GET /api/habits/chains
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
| `chains[].lastCompletedAt` | datetime | Last completion in this chain (nullable) |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/habits/chains"
```

### Get Specific Chain

```
GET /api/habits/chains/{chainId}/status
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
  "$MYN_API_URL/api/habits/chains/CHAIN_ID/status"
```

### Get Habit Schedule

```
GET /api/v2/unified-tasks/schedule
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
| `schedule[].dayOfWeek` | number | Day of week number |
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
  "$MYN_API_URL/api/v2/unified-tasks/schedule"

# 14-day schedule
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/schedule?days=14"
```

### List Habit Reminders

Reminder settings live on each habit's unified task entity. List habits through the unified-tasks endpoint, then filter the returned tasks client-side to `taskType == "HABIT"` and `reminderEnabled == true`.

```
GET /api/v2/unified-tasks?type=HABIT
```

**Reminder Fields on Each Task:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Habit identifier |
| `title` | string | Habit title |
| `reminderEnabled` | boolean | Whether the reminder is active |
| `reminderTime` | time | Time of day for the reminder (nullable, HH:mm) |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks?type=HABIT"
```

### Get Specific Reminder Settings

Read the habit's unified task and use its `reminderEnabled` and `reminderTime` fields.

```
GET /api/v2/unified-tasks/{habitId}
```

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID"
```

### Update Reminder Settings

Reminder writes use the unified-task read-before-write protocol. First read the task and capture its `stateHash`, then send that hash in `X-MYN-State-Hash` on the PATCH. If the PATCH returns `409 Conflict` with `currentStateHash`, retry once with the returned hash.

```
PATCH /api/v2/unified-tasks/{habitId}
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `reminderEnabled` | boolean | Enable or disable the reminder |
| `reminderTime` | time | Time of day for the reminder (HH:mm) |

```bash
# 1. Read the task and capture its stateHash.
TASK=$(curl -sS -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID")
STATE_HASH=$(printf '%s' "$TASK" | jq -r '.stateHash')

# 2. Patch the reminder fields using that hash.
curl -X PATCH "$MYN_API_URL/api/v2/unified-tasks/HABIT_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: $STATE_HASH" \
  -H "Content-Type: application/json" \
  -d '{
    "reminderEnabled": true,
    "reminderTime": "07:30"
  }'
```
