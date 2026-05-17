# Tasks: Backend Standard Health Checks

**Input**: `specs/003-custom-health-checks/`  
**Branch**: `003-custom-health-checks`

## Phase 1: Setup

- [x] T001 Add health check NuGet packages to `backend/src/FelloWay.Api/FelloWay.Api.csproj`
- [x] T002 Create `backend/src/FelloWay.Api/Extensions/HealthCheckExtensions.cs`

## Phase 2: US1 — Liveness (P1)

- [x] T003 [US1] Wire `AddFelloWayHealthChecks` and `MapFelloWayHealthChecks` in `backend/src/FelloWay.Api/Program.cs`
- [x] T004 [US1] Delete `backend/src/FelloWay.Api/Controllers/HealthController.cs`

## Phase 3: US2 — Readiness (P1)

- [x] T005 [US2] Extend `backend/tests/FelloWay.Api.Tests/HealthEndpointTests.cs` (JSON shape + healthy readiness)
- [x] T006 [US2] Add `UnavailableDatabaseWebApplicationFactory` and readiness 503 test

## Phase 4: Polish

- [x] T007 Update health section in `specs/002-backend-api/quickstart.md`
- [x] T008 Run `dotnet test` on `backend/FelloWay.slnx`
