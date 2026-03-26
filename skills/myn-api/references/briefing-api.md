# Briefing API (DEPRECATED)

**This API has been deprecated.** The compass/briefing endpoints have been renamed to **debrief**.

See [debrief-api.md](debrief-api.md) for the current API documentation.

All `/api/v2/compass/*` endpoints should be replaced with `/api/v2/debrief/*`:

| Old Endpoint | New Endpoint |
|-------------|--------------|
| `GET /api/v2/compass/status` | `GET /api/v2/debrief/status` |
| `POST /api/v2/compass/generate` | `POST /api/v2/debrief/generate` |
| `GET /api/v2/compass/current` | `GET /api/v2/debrief/current` |
| `POST /api/v2/compass/corrections/apply` | `POST /api/v2/debrief/corrections/apply` |
| `POST /api/v2/compass/complete` | `POST /api/v2/debrief/complete` |
