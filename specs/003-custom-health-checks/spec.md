# Feature Specification: Backend Standard Health Checks

**Feature Branch**: `003-custom-health-checks`  
**Created**: 2026-05-17  
**Updated**: 2026-05-17  
**Status**: Implemented  
**Input**: User description: "lets update helth check in Backend to using custom library" → **Revised**: remove `HealthController`; use **Microsoft ASP.NET Core built-in health checks** (no custom health library).

## Summary

Replace the hand-written `HealthController` with **ASP.NET Core’s built-in health check pipeline** so liveness and readiness probes are consistent, structured, and easy to extend—without introducing a separate custom FelloWay health package.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Platform liveness probe (Priority: P1)

As a deployment platform operator, I need a lightweight endpoint that confirms the API process is running so traffic is not routed to a crashed instance.

**Why this priority**: Without liveness, orchestrators cannot detect and replace failed instances.

**Independent Test**: Call the liveness endpoint on a running API instance and receive a success response without requiring database connectivity.

**Acceptance Scenarios**:

1. **Given** the API process is running, **When** a liveness probe is requested, **Then** the response indicates the service is alive within 1 second.
2. **Given** the API process is running but the database is unavailable, **When** a liveness probe is requested, **Then** the liveness response still indicates alive (liveness does not depend on the database).

---

### User Story 2 — Readiness with dependency verification (Priority: P1)

As a deployment platform operator, I need a readiness endpoint that verifies the API can serve real requests (including database access) so unhealthy instances are removed from rotation.

**Why this priority**: Readiness prevents user-facing errors during deploys, migrations, or database outages.

**Independent Test**: Stop or block database connectivity and confirm readiness returns a failure status while liveness remains successful.

**Acceptance Scenarios**:

1. **Given** the API and database are healthy, **When** a readiness probe is requested, **Then** the response indicates ready with per-dependency status reported in a structured payload.
2. **Given** the database is unreachable, **When** a readiness probe is requested, **Then** the response indicates not ready and returns a non-success status suitable for load balancers.
3. **Given** readiness fails, **When** the database becomes available again, **Then** readiness returns to ready without requiring a full process restart.

---

### User Story 3 — Extensible dependency checks (Priority: P2)

As a backend maintainer, I need a single, standard way to add dependency checks (database today; Hangfire, blob, chat later) without maintaining a bespoke controller.

**Why this priority**: The built-in health check model supports named checks registered at startup—avoiding duplicate probe logic.

**Independent Test**: Register an additional named check using the framework’s health check registration and see it in readiness output without changing public route paths.

**Acceptance Scenarios**:

1. **Given** health checks are configured at application startup, **When** a new required dependency check is added, **Then** readiness reports its name and pass/fail (or degraded) state in the structured response.
2. **Given** an optional dependency is misconfigured in a non-production environment, **When** readiness is queried, **Then** behavior follows documented policy (fail readiness vs. degraded only).

---

### Edge Cases

- Database connection succeeds but migrations are pending — readiness policy: connection success is sufficient for MVP (migration check is a later iteration).
- Readiness probe timeout shorter than database connection timeout — checks must complete within typical probe windows (fail fast).
- Concurrent readiness requests during deploy — must not exhaust connection pools.
- Health endpoints must not require authentication and must not expose secrets, connection strings, or stack traces.
- High probe frequency must not materially degrade capacity for normal API traffic.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The backend MUST expose **liveness** at `GET /health` confirming the process is running (no database dependency).
- **FR-002**: The backend MUST expose **readiness** at `GET /health/ready` aggregating dependency checks before declaring the service ready.
- **FR-003**: Readiness MUST verify the primary application database is reachable (same behavior as today’s `HealthController`).
- **FR-004**: The hand-written **`HealthController` MUST be removed**; probes MUST be served by the **ASP.NET Core built-in health check middleware/endpoints** (`Microsoft.Extensions.Diagnostics.HealthChecks`).
- **FR-005**: Health responses MUST be **structured and machine-readable** (overall status plus per-check entries with stable names and statuses)—using the framework’s standard health report format (e.g. UI client JSON writer).
- **FR-006**: When any **required** readiness check fails, the API MUST return a non-success HTTP status suitable for load balancers (e.g. 503).
- **FR-007**: Health endpoints MUST remain **unauthenticated** and safe for probes (no tokens or secrets in responses).
- **FR-008**: Additional named checks MUST be registrable at **application startup** via the standard health check registration API—without reintroducing a controller.
- **FR-009**: Existing integration tests for `/health` and `/health/ready` MUST pass or be updated for the structured response contract.
- **FR-010**: Operator documentation MUST describe liveness vs. readiness, HTTP status expectations, and how to read per-check entries.
- **FR-011**: The solution MUST **NOT** introduce a separate custom FelloWay health class library project; use only the Microsoft built-in health check packages already aligned with ASP.NET Core 8.

### Non-Functional Requirements

- **NFR-001**: Liveness responses MUST complete within **500 ms** under normal load on a warm instance.
- **NFR-002**: Readiness responses MUST complete within **3 seconds** when all dependencies are healthy.
- **NFR-003**: Health probe handling MUST not block normal API request processing.
- **NFR-004**: Response field names and check names MUST remain stable across deploys for monitoring compatibility.

### Validation Requirements

- Automated tests MUST cover: liveness OK, readiness OK when DB up, readiness fails when DB down.
- CI MUST run the backend test suite after migration.
- Staging smoke checklist MUST include both endpoints.

### Key Entities

- **Health report**: Overall status and timestamp (framework health report).
- **Health check entry**: Name (e.g. `npgsql`, `database`), status, optional description safe for operators.
- **Registration**: Which checks are tagged for liveness vs. readiness (e.g. check tags / endpoint predicates).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Operators configure liveness on `GET /health` and readiness on `GET /health/ready` with documented pass/fail rules.
- **SC-002**: When the database is unavailable, readiness fails while liveness succeeds in 100% of test runs.
- **SC-003**: 100% of existing health-related automated tests pass after removing `HealthController`.
- **SC-004**: New dependency checks are added only via startup registration—no controller changes.
- **SC-005**: No new custom health library project exists in the solution (verified in review/CI).

## Assumptions

- Scope is **backend API only**; Flutter does not call health endpoints.
- Routes stay **`/health`** and **`/health/ready`** for backward compatibility with tests and Azure probes.
- Use **Microsoft.Extensions.Diagnostics.HealthChecks** plus **EF Core / Npgsql** health check integration where applicable.
- **Liveness** maps to checks tagged or filtered to exclude database; **readiness** includes database (and later optional deps).
- `AddHealthChecks()` already present in `Program.cs` but unused alongside `HealthController`—consolidate to one approach.
- Optional packages such as `AspNetCore.HealthChecks.UI.Client` for JSON responses are acceptable; a bespoke `FelloWay.HealthChecks` project is **out of scope**.

## Out of Scope

- A custom internal “FelloWay health” NuGet/class library project.
- `HealthController` or duplicate manual probe logic.
- Frontend/mobile health reporting.
- Azure Monitor alert configuration.
- Changing URL paths to `/v1/health`.
- OAuth provider health probes.
