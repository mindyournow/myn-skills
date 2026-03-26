# Timers API

Countdown timers, alarms, and Pomodoro sessions.

## Base Path

`/api/v2/timers`

## Actions

The `myn_timers` tool supports these actions: `create_countdown`, `create_alarm`, `list`, `cancel`, `snooze`, `pomodoro`.

## Endpoints

### List Active Timers

```
GET /api/v2/timers
```

Returns all active timers for the current user.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `timers` | object[] | Array of timer objects |
| `timers[].timerId` | UUID | Timer identifier |
| `timers[].type` | string | `COUNTDOWN`, `ALARM`, or `POMODORO` |
| `timers[].label` | string | User-defined label (nullable) |
| `timers[].status` | string | Current status |
| `timers[].duration` | number | Total duration in seconds (COUNTDOWN/POMODORO) |
| `timers[].remaining` | number | Seconds remaining (COUNTDOWN/POMODORO) |
| `timers[].endTime` | datetime | When the timer will fire (COUNTDOWN) |
| `timers[].alarmTime` | datetime | Scheduled alarm time (ALARM) |
| `timers[].recurrence` | string | RRULE for recurring alarms (ALARM, nullable) |
| `timers[].currentSession` | number | Current Pomodoro session number (POMODORO) |
| `timers[].totalSessions` | number | Total Pomodoro sessions configured (POMODORO) |
| `timers[].isWorkPhase` | boolean | Whether in work or break phase (POMODORO) |
| `activeCount` | number | Total number of active timers |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/timers"
```

### Create Countdown Timer

```
POST /api/v2/timers/countdown
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** `"COUNTDOWN"` |
| `duration` | number | **Required.** Duration in seconds |
| `label` | string | Optional label |

**Tool Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `duration` | number | Duration in seconds |
| `durationMinutes` | number | Duration in minutes (converted to seconds automatically) |
| `label` | string | Timer label/description |

One of `duration` or `durationMinutes` is required.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `timerId` | UUID | Timer identifier |
| `type` | string | `"COUNTDOWN"` |
| `duration` | number | Duration in seconds |
| `endTime` | datetime | When the timer will fire |
| `label` | string | Timer label (nullable) |
| `status` | string | `ACTIVE`, `PAUSED`, or `COMPLETED` |

```bash
# 25-minute countdown
curl -X POST "$MYN_API_URL/api/v2/timers/countdown" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "COUNTDOWN",
    "duration": 1500,
    "label": "Focus time"
  }'
```

### Create Alarm

```
POST /api/v2/timers/alarm
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Alarm name (defaults to "Alarm" from label) |
| `alarmTime` | datetime | **Required.** When the alarm should fire (ISO 8601) |
| `recurrence` | string | Optional recurrence pattern (e.g., "daily", "weekdays") |
| `completionSound` | string | Optional alarm sound name |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `timerId` | UUID | Timer identifier |
| `type` | string | `"ALARM"` |
| `alarmTime` | datetime | When the alarm will fire |
| `label` | string | Alarm label (nullable) |
| `recurrence` | string | Recurrence pattern (nullable) |
| `status` | string | `ACTIVE`, `TRIGGERED`, or `SNOOZED` |

```bash
# One-time alarm
curl -X POST "$MYN_API_URL/api/v2/timers/alarm" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Morning wake-up",
    "alarmTime": "2026-03-02T07:00:00Z"
  }'

# Recurring weekday alarm
curl -X POST "$MYN_API_URL/api/v2/timers/alarm" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Standup reminder",
    "alarmTime": "2026-03-02T08:30:00Z",
    "recurrence": "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  }'
```

### Cancel Timer

```
POST /api/v2/timers/{timerId}/cancel
```

**Uses read-before-write guard** -- reads timer state hash before cancelling.

**Response:** `{ timerId, status }`

```bash
curl -X POST "$MYN_API_URL/api/v2/timers/TIMER_ID/cancel" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123"
```

### Snooze Timer

```
POST /api/v2/timers/{timerId}/snooze
```

Snoozes a ringing alarm or timer.

**Uses read-before-write guard** -- reads timer state hash before snoozing.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `snoozeMinutes` | number | Minutes to snooze (default: 5) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `timerId` | UUID | Timer identifier |
| `snoozedUntil` | datetime | When the timer will ring again |
| `status` | string | `"SNOOZED"` |

```bash
curl -X POST "$MYN_API_URL/api/v2/timers/TIMER_ID/snooze" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123" \
  -H "Content-Type: application/json" \
  -d '{"snoozeMinutes": 10}'
```

### Create Pomodoro Timer

```
POST /api/v2/timers/countdown
```

Creates a Pomodoro timer (uses the countdown endpoint with `type: "POMODORO"`).

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** `"POMODORO"` |
| `workDuration` | number | Work phase in seconds (tool accepts minutes, auto-converts) |
| `breakDuration` | number | Short break in seconds (tool accepts minutes, auto-converts) |
| `longBreakDuration` | number | Long break in seconds (tool accepts minutes, auto-converts) |
| `sessions` | number | Number of work sessions (default: 4) |
| `autoStart` | boolean | Auto-start next phase (default: false) |
| `label` | string | Optional label |

**Tool Parameters (in minutes):**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `workDuration` | number | 25 | Work duration in minutes |
| `breakDuration` | number | 5 | Break duration in minutes |
| `longBreakDuration` | number | 15 | Long break duration in minutes |
| `sessions` | number | 4 | Number of pomodoro sessions |
| `autoStart` | boolean | false | Auto-start next phase |

```bash
curl -X POST "$MYN_API_URL/api/v2/timers/countdown" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "POMODORO",
    "workDuration": 1500,
    "breakDuration": 300,
    "longBreakDuration": 900,
    "sessions": 4,
    "autoStart": true,
    "label": "Deep work block"
  }'
```
