# Tasks: Hybrid Database Strategy for API Tests

**Input**: `specs/006-hybrid-test-database/`  
**Branch**: `006-hybrid-test-database`

## Phase 1: Fast in-memory path (P1)

- [x] T001 Re-add `Microsoft.EntityFrameworkCore.InMemory` to `backend/tests/FelloWay.Api.Tests/FelloWay.Api.Tests.csproj`
- [x] T002 Rewrite `FelloWayWebApplicationFactory` (Testing env, skip init, disable Hangfire, in-memory EF)
- [x] T003 Skip `AddHangfire` when `Database:DisableHangfire` in `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [x] T004 Confirm `ApplyDatabaseAsync` early exit for `Database:SkipInitialization`
- [x] T005 Default fast filter via `VSTestTestCaseFilter=Category!=Integration` in test csproj

## Phase 2: Integration real-DB path (P1)

- [x] T006 Add `PostgresWebApplicationFactory` + `IntegrationTestFixture` + `IntegrationCollection`
- [x] T007 Add `Integration/PostgresApiIntegrationTests.cs` with `[Trait("Category", "Integration")]`
- [x] T008 Keep `UnavailableDatabaseWebApplicationFactory` in fast suite; readiness tests split in-memory vs unreachable PG

## Phase 3: CI and docs (P2)

- [x] T009 Update `.github/workflows/backend-ci.yml` (fast job + integration job)
- [x] T010 Update `backend/README.md` testing section
- [x] T011 Add `specs/006-hybrid-test-database/quickstart.md` commands

## Validation

- [x] T012 `dotnet test FelloWay.slnx --filter "Category!=Integration"` (41 passed: 20 Application + 21 Api)
- [x] T013 `flutter test` in `frontend/` (40 passed)
