# Data Model: Health Probes (logical)

**Feature**: `003-custom-health-checks`  
**Date**: 2026-05-17  
**Purpose**: Describe probe configuration and response shape. No new PostgreSQL tables.

## Overview

Health monitoring is **runtime configuration** in the API process, not persisted entities. The framework aggregates registered `IHealthCheck` instances into a **HealthReport** per HTTP request.

```text
HealthCheckRegistration (startup)
    ├── self          [tag: live]   → always Healthy
    └── database      [tag: ready]  → EF DbContext connectivity

HTTP GET /health      → filter: live tags only
HTTP GET /health/ready → filter: ready tags only
```

## Logical entities

### Health check registration

| Field | Description |
|-------|-------------|
| name | Stable identifier (`self`, `database`) |
| tags | Route filter: `live` or `ready` |
| implementation | Framework built-in or `IHealthCheck` |
| required | If true, failure makes aggregate `Unhealthy` (default for readiness MVP) |

### Health report (response)

| Field | Type | Notes |
|-------|------|-------|
| status | enum string | `Healthy`, `Degraded`, `Unhealthy` (UI client JSON) |
| totalDuration | duration | Probe round-trip |
| entries | map | Key = check name |
| entries[].status | enum string | Per-check status |
| entries[].description | string | Optional; no secrets |
| entries[].duration | duration | Per-check timing |
| entries[].tags | string[] | Echo of registration tags |

### HTTP mapping

| Route | Aggregate healthy | HTTP |
|-------|---------------------|------|
| `GET /health` | Yes | 200 |
| `GET /health` | No (theoretical) | 503 |
| `GET /health/ready` | Yes | 200 |
| `GET /health/ready` | No | 503 |

## State transitions

- **Database down**: `database` check → `Unhealthy` → readiness 503; liveness remains 200 (`self` only).
- **Database restored**: next probe can return 200 without process restart.
- **Future optional check degraded**: policy TBD (fail readiness vs. `Degraded` aggregate); MVP only `database` on readiness.

## Validation rules

- Check names MUST remain stable (`self`, `database`) for monitors (NFR-004).
- Responses MUST NOT include connection strings, JWT material, or stack traces.
- Readiness MUST NOT run on liveness route (tag predicate enforced).

## Relationship to 002 data model

No migration. Readiness uses existing `FelloWayDbContext` connection only.
