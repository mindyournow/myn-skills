# Timers API

Countdown timers, alarms, and Pomodoro sessions.

## Base Path

`/api/v2/timers`

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
| `timers[].status` | string | Current status (e.g., `RUNNING`, `PAUSED`, `SNOOZED`, `RINGING`, `COMPLETED`) |
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

### Create Timer

```
POST /api/v2/timers
```

Creates a new timer. The request body varies by timer type.

#### Countdown Timer

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** `"COUNTDOWN"` |
| `duration` | number | **Required.** Duration in seconds |
| `label` | string | Optional label |

```bash
# 25-minute countdown
curl -X POST "$MYN_API_URL/api/v2/timers" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "COUNTDOWN",
    "duration": 1500,
    "label": "Focus time"
  }'
```

#### Alarm Timer

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** `"ALARM"` |
| `alarmTime` | datetime | **Required.** When the alarm should fire (ISO 8601) |
| `label` | string | Optional label |
| `recurrence` | string | Optional RRULE for repeating alarms |
| `sound` | string | Optional alarm sound name |

```bash
# One-time alarm
curl -X POST "$MYN_API_URL/api/v2/timers" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "ALARM",
    "alarmTime": "2026-03-02T07:00:00Z",
    "label": "Morning wake-up"
  }'

# Recurring weekday alarm
curl -X POST "$MYN_API_URL/api/v2/timers" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "ALARM",
    "alarmTime": "2026-03-02T08:30:00Z",
    "label": "Standup reminder",
    "recurrence": "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  }'
```

#### Pomodoro Timer

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | **Required.** `"POMODORO"` |
| `workDuration` | number | **Required.** Work phase duration in seconds |
| `breakDuration` | number | **Required.** Short break duration in seconds |
| `longBreakDuration` | number | **Required.** Long break duration in seconds (after all sessions) |
| `sessions` | number | Number of work sessions before long break (default: 4) |
| `autoStart` | boolean | Auto-start next phase (default: false) |
| `label` | string | Optional label |

```bash
# Standard Pomodoro: 25min work, 5min break, 15min long break, 4 sessions
curl -X POST "$MYN_API_URL/api/v2/timers" \
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

### Cancel Timer

```
POST /api/v2/timers/{timerId}/cancel
```

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Read the timer first to obtain `stateHash`.

```bash
# 1. Read timer to get stateHash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/timers/550e8400-e29b-41d4-a716-446655440000"
# → { "timerId": "...", "stateHash": "abc123", ... }

# 2. Cancel with state hash
curl -X POST "$MYN_API_URL/api/v2/timers/550e8400-e29b-41d4-a716-446655440000/cancel" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123"
```

### Snooze Timer

```
POST /api/v2/timers/{timerId}/snooze
```

Snoozes a ringing alarm or timer.

**⚠️ Requires `X-MYN-State-Hash` header (agent requests).** Read the timer first to obtain `stateHash`.

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
# 1. Read timer to get stateHash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v2/timers/550e8400-e29b-41d4-a716-446655440000"
# → { "timerId": "...", "stateHash": "abc123", ... }

# 2. Snooze for 10 minutes with state hash
curl -X POST "$MYN_API_URL/api/v2/timers/550e8400-e29b-41d4-a716-446655440000/snooze" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "X-MYN-State-Hash: abc123" \
  -H "Content-Type: application/json" \
  -d '{"snoozeMinutes": 10}'
```

**Note:** The `GET /api/v2/timers` (list) response includes a `stateHash` per timer object for use in subsequent writes.
