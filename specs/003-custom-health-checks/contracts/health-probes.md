# Contract: Health probe endpoints

**Feature**: `003-custom-health-checks`  
**Date**: 2026-05-17  
**Base URL**: API host (e.g. `https://api.felloway.example`)

Operations are **not** part of `shared/api-contracts/openapi.yaml` (infrastructure probes). Documented here for operators and integration tests.

## `GET /health` — Liveness

**Auth**: None  
**Purpose**: Process is running; does not verify database.

### Responses

| Status | Meaning |
|--------|---------|
| 200 | At least one `live`-tagged check is healthy (typically `self`) |
| 503 | Unhealthy (unexpected for MVP `self` check) |

### Example 200 (illustrative UI client shape)

```json
{
  "status": "Healthy",
  "totalDuration": "00:00:00.0123456",
  "entries": {
    "self": {
      "data": {},
      "description": null,
      "duration": "00:00:00.0010000",
      "status": "Healthy",
      "tags": ["live"]
    }
  }
}
```

## `GET /health/ready` — Readiness

**Auth**: None  
**Purpose**: Service can serve traffic; includes database connectivity.

### Responses

| Status | Meaning |
|--------|---------|
| 200 | All `ready`-tagged checks healthy |
| 503 | One or more required checks unhealthy (e.g. database unreachable) |

### Example 200

```json
{
  "status": "Healthy",
  "totalDuration": "00:00:00.0450000",
  "entries": {
    "database": {
      "data": {},
      "description": null,
      "duration": "00:00:00.0400000",
      "status": "Healthy",
      "tags": ["ready"]
    }
  }
}
```

### Example 503

```json
{
  "status": "Unhealthy",
  "totalDuration": "00:00:00.0500000",
  "entries": {
    "database": {
      "data": {},
      "description": "…",
      "duration": "00:00:00.0480000",
      "status": "Unhealthy",
      "tags": ["ready"]
    }
  }
}
```

## Headers

- Responses MAY include `X-Correlation-Id` (existing middleware).
- `Cache-Control`: health endpoints should not be cached (`AllowCachingResponses = false`).

## Compatibility notes

| Aspect | Before (HealthController) | After |
|--------|---------------------------|-------|
| Paths | `/health`, `/health/ready` | Unchanged |
| Liveness body | `{ "status": "healthy" }` | UI health JSON |
| Readiness body | `{ "status": "ready", "database": true }` | UI health JSON with `entries.database` |
| Status codes | 200 / 503 | 200 / 503 |

Clients that only check HTTP status (Azure, k6, current tests) remain compatible.
