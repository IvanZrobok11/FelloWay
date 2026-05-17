# Quickstart: Hybrid API Test Suites

**Feature**: `006-hybrid-test-database`  
**Date**: 2026-05-17

## Fast suite (no PostgreSQL)

```bash
cd backend
dotnet test FelloWay.slnx --filter "Category!=Integration"
```

Runs in-memory EF, skips Hangfire and startup `EnsureCreated`. Use for daily development and PR CI.

## Integration suite (real PostgreSQL)

### Option A — Docker Testcontainers (recommended)

Requires Docker Desktop running.

```bash
cd backend
dotnet test FelloWay.slnx --filter "Category=Integration"
```

### Option B — Local PostgreSQL

```powershell
$env:FELLOWAY_TEST_CONNECTION = "Host=localhost;Database=felloway_it;Username=postgres;Password=YOUR_PASSWORD"
dotnet test FelloWay.slnx --filter "Category=Integration"
```

Create empty database `felloway_it` or let startup `EnsureCreated` create schema in a unique DB (factory uses per-run name).

## Run all tests

```bash
dotnet test FelloWay.slnx
```

Runs both suites sequentially (integration may fail if Docker/Postgres unavailable).

## Verify behavior

| Check | Fast | Integration |
|-------|------|-------------|
| Works with Postgres stopped | Yes | No (clear error) |
| Touches `felloway` dev DB | No | Uses isolated `felloway_it_*` DB |
| Hangfire tables created | No | Yes |

## CI

See `.github/workflows/backend-ci.yml` after implementation: PR runs fast filter only; integration job uses `services.postgres`.
