# @mindyournow/skills

Universal MYN API skills for AI assistants. Teaches any AI agent how to interact with the [Mind Your Now](https://mindyournow.com) productivity platform via its REST API.

## What's Inside

```
skills/
  myn-api/
    SKILL.md              # Main skill: philosophy, auth, routing table, workflows
    references/
      authentication.md   # API key setup, scopes, rate limits
      tasks-api.md        # Unified tasks: CRUD, complete, archive, search
      briefing-api.md     # Compass: status, generate, corrections, complete
      calendar-api.md     # Events: list, create, delete, meetings
      habits-api.md       # Streaks, skip, chains, schedule, reminders
      lists-api.md        # Grocery: get, add, toggle, bulk_add, convert
      timers-api.md       # Countdown, alarm, pomodoro, snooze
      search-api.md       # Unified search
      memory-api.md       # Remember, recall, forget, search
      profile-api.md      # User info, goals, preferences
      household-api.md    # Members, invites, chores, schedule
      projects-api.md     # List, get, create, move_task
      planning-api.md     # Plan, schedule_all, reschedule
    scripts/
      myn-api.sh          # curl wrapper with auth header injection
```

## Usage

### Claude Code / Panopticon

Copy the skill directory to your skills folder:

```bash
cp -r skills/myn-api ~/.claude/skills/
# or
pan sync  # if using Panopticon
```

### OpenClaw

Install the OpenClaw plugin which bundles these skills automatically:

```bash
openclaw plugins install @mindyournow/openclaw-plugin
```

### Cursor / Other AI Editors

Clone this repo and add the skill directory to your project rules or context.

## Prerequisites

1. A Mind Your Now account at [mindyournow.com](https://mindyournow.com)
2. An API key with `AGENT_FULL` scope (Settings > API Keys)

## Architecture

This package contains **pure structured documentation** — no TypeScript, no build step, no runtime dependencies. Skills use [Panopticon SKILL.md format](https://github.com/eltmon/panopticon-cli) with YAML frontmatter and progressive disclosure:

| Layer | What Loads | When | Token Cost |
|-------|-----------|------|------------|
| **Index** | Skill name + description | Always in context | ~24 tokens |
| **Instructions** | SKILL.md body | When skill triggers | ~800 tokens |
| **References** | Per-domain API docs | On-demand during execution | Loaded as needed |

## Related

- [`@mindyournow/openclaw-plugin`](https://github.com/mindyournow/openclaw-plugin) — OpenClaw plugin that wraps these skills with tool definitions
- [Mind Your Now](https://mindyournow.com) — The productivity platform

## License

MIT
