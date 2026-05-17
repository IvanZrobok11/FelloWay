# Quickstart: Backend Health Checks (003)

**Feature**: `003-custom-health-checks`  
**Date**: 2026-05-17

## Prerequisites

- .NET 8 SDK
- Running PostgreSQL (local or Testcontainers via test factory)
- Backend built from `backend/`

## Verify locally

```bash
cd backend
dotnet restore FelloWay.slnx
dotnet run --project src/FelloWay.Api
```

In another terminal:

```bash
# Liveness — should return 200 even if you only care that the process is up
curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health

# Readiness — 200 when DB is reachable
curl -s http://localhost:5000/health/ready | jq .

# Correlation id (optional)
curl -s -D - http://localhost:5000/health -o /dev/null | grep -i correlation
```

Adjust port to your launch profile (`Properties/launchSettings.json`).

## Run tests

```bash
cd backend
dotnet test FelloWay.slnx --filter "FullyQualifiedName~Health"
```

Expected:
- `GetHealth_ReturnsOk`
- `GetReady_ReturnsOk_WhenDatabaseAvailable`
- Correlation middleware tests on `/health` still pass

## Azure App Service

1. **Health check path (liveness)**: `/health`
2. **Readiness** (if using deployment slots or custom probe): `/health/ready`
3. Treat **503** on `/health/ready` as “remove from load balancer” during DB outage or deploy.
4. Do not require authentication headers on probe requests.

See also [002-backend-api quickstart — Staging deploy checklist](../002-backend-api/quickstart.md).

## Operator interpretation

| Endpoint | Pass | Fail |
|----------|------|------|
| `GET /health` | HTTP 200 | HTTP 503 |
| `GET /health/ready` | HTTP 200, `status: Healthy` in JSON | HTTP 503, `status: Unhealthy`, inspect `entries.database` |

## k6 load smoke

Existing script `backend/scripts/load-smoke.js` uses `GET /health`; no change required if only status code is asserted.

## Related docs

- [spec.md](./spec.md)
- [plan.md](./plan.md)
- [contracts/health-probes.md](./contracts/health-probes.md)
