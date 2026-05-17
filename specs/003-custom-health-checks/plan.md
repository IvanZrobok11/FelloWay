# Implementation Plan: Backend Standard Health Checks

**Branch**: `003-custom-health-checks` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: Replace `HealthController` with ASP.NET Core built-in health checks; keep `GET /health` and `GET /health/ready`; no custom FelloWay health library.

## Summary

Remove the hand-written `HealthController` and wire **Microsoft.Extensions.Diagnostics.HealthChecks** via `AddHealthChecks`, `AddDbContextCheck<FelloWayDbContext>`, and `MapHealthChecks` with tag-based predicates for liveness vs. readiness. Use **AspNetCore.HealthChecks.UI.Client** for structured JSON responses. Update integration tests and operator docs in `002-backend-api/quickstart.md` (health section cross-reference).

## Technical Context

**Language/Version**: C# 12 / .NET 8  
**Primary Dependencies**: ASP.NET Core health checks (`Microsoft.Extensions.Diagnostics.HealthChecks`), EF Core health check (`Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore`), optional `AspNetCore.HealthChecks.UI.Client` 8.x for `UIResponseWriter`  
**Storage**: PostgreSQL via existing `FelloWayDbContext` (readiness = `CanConnect` equivalent via `AddDbContextCheck`)  
**Testing**: `FelloWay.Api.Tests` integration tests (`HealthEndpointTests`, `CorrelationIdMiddlewareTests` hitting `/health`)  
**Target Platform**: Azure App Service Linux (.NET 8), local `dotnet run`, CI Testcontainers PostgreSQL  
**Project Type**: Backend API slice within existing `backend/` solution (no new projects)  
**Performance Goals**: Liveness &lt; 500 ms; readiness &lt; 3 s when DB healthy (per spec NFR-001/002)  
**Constraints**: Unauthenticated endpoints; no secrets in response; stable route paths; 503 when readiness fails  
**Scale/Scope**: 2 endpoints, delete 1 controller, ~1 extension class, test + doc updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `dotnet format --verify-no-changes` + build in existing `backend-ci.yml` |
| Test strategy | ✅ Pass | Extend `HealthEndpointTests`: liveness 200, readiness 200/503; keep correlation tests on `/health` |
| UX consistency | N/A | No Flutter/UI surface |
| Performance budgets | ✅ Pass | NFR-001/002 from spec; k6 smoke already hits `/health` |
| Flutter quality checks | N/A | Backend-only; constitution Flutter gates do not apply |
| Evidence plan | ✅ Pass | CI `dotnet test`; manual curl examples in `quickstart.md` |

**Post-design re-check**: No constitution violations; no Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/003-custom-health-checks/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1 (logical probe model)
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1 — health probe HTTP contract
└── tasks.md             # Phase 2 (/speckit.tasks — not created here)
```

### Source Code (repository root)

```text
backend/
├── src/FelloWay.Api/
│   ├── Program.cs                          # MapHealthChecks; remove controller routing for health
│   ├── Extensions/HealthCheckExtensions.cs # AddFelloWayHealthChecks + MapFelloWayHealthChecks
│   └── Controllers/HealthController.cs     # DELETE
├── tests/FelloWay.Api.Tests/
│   ├── HealthEndpointTests.cs              # Assert status codes + optional JSON shape
│   └── Infrastructure/CorrelationIdMiddlewareTests.cs  # unchanged path /health
└── FelloWay.slnx                           # no new projects
```

**Structure Decision**: All changes stay in `FelloWay.Api` and tests; health registration colocated in `Extensions/` following existing `AddFelloWaySwagger` / `AddJwtAuthentication` pattern.

## Implementation Phases (for `/speckit.tasks`)

### Phase 1 — Wire built-in health checks (P1)

1. Add NuGet: `Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore`, `AspNetCore.HealthChecks.UI.Client` (8.x).
2. Create `HealthCheckExtensions.cs`:
   - `AddFelloWayHealthChecks(services)` → `AddHealthChecks().AddCheck("self", …, tags: ["live"]).AddDbContextCheck<FelloWayDbContext>(name: "database", tags: ["ready"])`.
   - `MapFelloWayHealthChecks(endpoints)` → `MapHealthChecks("/health", predicate: live only)` and `MapHealthChecks("/health/ready", predicate: ready only, `UIResponseWriter.WriteHealthCheckUIResponse`, `AllowCachingResponses = false`).
3. Replace `builder.Services.AddHealthChecks()` in `Program.cs` with `AddFelloWayHealthChecks()`; call `MapFelloWayHealthChecks()` **before** or **after** `MapControllers` (health must not require auth).
4. Delete `HealthController.cs`.

### Phase 2 — Tests & docs (P1)

1. Update `HealthEndpointTests`: readiness returns 503 when DB unavailable (optional: use factory with invalid connection string for one test).
2. Optionally assert JSON contains `status` field (UI client format uses `Healthy` / `Unhealthy` enum strings).
3. Update `specs/002-backend-api/quickstart.md` health section with sample JSON and status code table (link to `003` contract).
4. Run `dotnet test` on `FelloWay.slnx`.

### Phase 3 — Future checks (P2, out of MVP tasks)

- Register Hangfire, Blob, Stream checks with tag `ready` only when they become release-blocking.

## Complexity Tracking

> No violations.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Contracts | [contracts/health-probes.md](./contracts/health-probes.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
