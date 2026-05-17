# Research: Backend Standard Health Checks (003)

**Date**: 2026-05-17

## 1. Replace controller vs. middleware

**Decision**: Delete `HealthController`; expose probes via `MapHealthChecks` endpoint routing.

**Rationale**: `AddHealthChecks()` is already registered in `Program.cs` but unused; aligns with FR-004/FR-011 and Microsoft guidance for Kubernetes/Azure probes.

**Alternatives considered**:
- Keep controller delegating to `HealthCheckService` — rejected; duplicates framework pipeline.
- Custom `FelloWay.HealthChecks` class library — rejected per user direction.

## 2. Liveness vs. readiness separation

**Decision**: Tag-based predicates on two `MapHealthChecks` routes:
- `/health` → checks tagged `live` only (`self` check always healthy).
- `/health/ready` → checks tagged `ready` only (`database` via EF).

**Rationale**: Matches spec FR-001/002; liveness succeeds when DB is down; readiness fails with 503.

**Alternatives considered**:
- Single `/health` with query `?ready=true` — rejected; breaks existing Azure/test paths.
- Npgsql-specific `AddNpgSql` from AspNetCore.HealthChecks.NpgSql — acceptable but redundant when `FelloWayDbContext` already encapsulates DB; `AddDbContextCheck` is the EF-native approach.

## 3. Database readiness check

**Decision**: `AddDbContextCheck<FelloWayDbContext>(name: "database", tags: ["ready"])`.

**Rationale**: Equivalent to current `CanConnectAsync`; uses pooled context; ships in `Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore`.

**Alternatives considered**:
- Manual `IHealthCheck` injecting `FelloWayDbContext` — more code, same behavior.
- Migration pending check — out of scope for MVP (spec edge case).

## 4. Response format

**Decision**: `AspNetCore.HealthChecks.UI.Client` → `UIResponseWriter.WriteHealthCheckUIResponse` on readiness (and optionally liveness for consistency).

**Rationale**: Structured JSON with `status`, `totalDuration`, `entries` map; industry-standard for operators and monitors.

**Alternatives considered**:
- Plain `WriteAsync` minimal `{ status: "healthy" }` — rejected; spec FR-005 requires per-check entries.
- Custom JSON writer matching old `{ status, database }` — rejected; loses extensibility for US3.

**Backward compatibility**: HTTP status codes unchanged (200 healthy, 503 unhealthy). Body shape changes; tests today only assert status codes.

## 5. Registration location

**Decision**: `FelloWay.Api/Extensions/HealthCheckExtensions.cs` with `AddFelloWayHealthChecks` + `MapFelloWayHealthChecks`.

**Rationale**: Matches existing `AddFelloWaySwagger`, `AddJwtAuthentication`; keeps `Program.cs` thin.

**Alternatives considered**:
- Register in `Infrastructure.DependencyInjection` — valid but mixes HTTP endpoint mapping concern into infrastructure layer.

## 6. Authentication and middleware order

**Decision**: Map health endpoints without `[Authorize]`; place `MapFelloWayHealthChecks` after `UseAuthentication`/`UseAuthorization` but health routes are anonymous by default.

**Rationale**: FR-007; correlation middleware already applies to `/health`.

## 7. Packages (versions)

**Decision**:
- `Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore` 8.0.x (aligned with EF 8.0.11).
- `AspNetCore.HealthChecks.UI.Client` 8.0.x.

**Rationale**: Same major as ASP.NET Core 8; no new solution projects.

**Alternatives considered**:
- Only built-in writer (no UI client package) — requires hand-written `ResponseWriter`; UI client is minimal dependency and well maintained.
