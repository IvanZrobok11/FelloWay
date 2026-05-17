# Research: Hybrid Test Database Strategy

**Feature**: `006-hybrid-test-database`  
**Date**: 2026-05-17

## 1. Suite separation mechanism

**Decision**: Single test project, **xUnit `[Trait("Category", "Integration")]`** with filter `Category!=Integration` as default.

**Rationale**: Already referenced in `IntegrationTestFixture.cs` comments; no second csproj to maintain; works with `dotnet test --filter`.

**Alternatives considered**:
- **Separate test project** — clearer split but duplicate factory boilerplate.
- **Assembly-level categories only** — too coarse for mixed files.

## 2. Default factory data store

**Decision**: `FelloWayWebApplicationFactory` uses **`UseInMemoryDatabase(uniqueName)`** + `Database:SkipInitialization=true` + `Database:DisableHangfire=true`.

**Rationale**: Satisfies FR-001/002; Hangfire.PostgreSql cannot run against InMemory; startup must not call `EnsureCreated` on Npgsql.

**Alternatives considered**:
- **SQLite in-memory** — closer to SQL but extra provider package.
- **Shared PostgreSQL** — violates SC-005 and slows dev loop.

## 3. Integration factory data store

**Decision**: `PostgresWebApplicationFactory` with connection from **`IntegrationTestFixture`** (Testcontainers `postgres:16-alpine`) or override via env `FELLOWAY_TEST_CONNECTION` for local Postgres.

**Rationale**: FR-003/005; container gives CI reproducibility; env override helps developers with existing local PG.

**Alternatives considered**:
- **Only local Postgres** — fails CI without manual service config.
- **Only Testcontainers** — slower on Windows dev without Docker.

## 4. Testing environment vs data store

**Decision**: Both suites use **`ASPNETCORE_ENVIRONMENT=Testing`**; difference is **DI override** (InMemory vs Npgsql), not environment name.

**Rationale**: Keeps auth/OAuth dev paths consistent; spec requires Testing env for integration **with real DB**, not a separate env name.

**Alternatives considered**:
- **`Development` for in-memory** — blurs Swagger/Hangfire dashboard expectations.

## 5. Hangfire in tests

**Decision**: Register Hangfire **only when** `Database:DisableHangfire` is not true.

**Rationale**: In-memory fast tests do not need background jobs; integration tests validate real startup including Hangfire storage.

**Alternatives considered**:
- **In-memory Hangfire storage** — extra package, not required for API contract tests.

## 6. Which tests move to integration

**Decision**: **Minimum** integration set: `GET /health/ready` (healthy DB), one auth token + `GET /users/me` or `GET /events`. All other endpoint tests stay in-memory.

**Rationale**: FR-010; keeps integration job small; most controller logic does not need Npgsql.

**Alternatives considered**:
- **All tests on Postgres** — current pain point this feature removes.

## 7. CI layout

**Decision**: Two steps in `backend-ci.yml`: **fast** (no services) then **integration** (postgres service container on port 5432 or Testcontainers in test process).

**Rationale**: SC-004; GitHub `services: postgres` is simpler than DinD for Testcontainers on some runners.

**Alternatives considered**:
- **Testcontainers only** — works but adds Docker dependency to test process; use as fallback in fixture when `CI` env not set.
