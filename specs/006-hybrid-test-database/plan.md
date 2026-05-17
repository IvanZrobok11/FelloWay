# Implementation Plan: Hybrid Database Strategy for API Tests

**Branch**: `006-hybrid-test-database` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: Split API tests into fast in-memory suite (default) vs integration suite (Testing + real PostgreSQL).

## Summary

Restore **EF Core InMemory** for the default `FelloWayWebApplicationFactory` so `dotnet test` runs without PostgreSQL. Introduce **`[Trait("Category", "Integration")]`** tests with `PostgresWebApplicationFactory` + `IntegrationTestFixture` (Testcontainers or local Postgres) that run the real **Testing** startup path (`EnsureCreated` + non-prod seed). Disable Hangfire and DB init for in-memory hosts via configuration flags.

## Technical Context

**Language/Version**: .NET 8, C# 12, xUnit 2.5  
**Primary Dependencies**: `Microsoft.AspNetCore.Mvc.Testing`, `Microsoft.EntityFrameworkCore.InMemory`, `Testcontainers.PostgreSql` 4.3, Npgsql, Hangfire.PostgreSql  
**Storage**: InMemory (fast suite); PostgreSQL (integration suite)  
**Testing**: xUnit traits/filters; `WebApplicationFactory<Program>`; existing `FelloWay.Application.Tests` unchanged  
**Target Platform**: Developer machines + GitHub Actions (`ubuntu-latest`)  
**Project Type**: Monorepo `backend/tests/FelloWay.Api.Tests/`  
**Performance Goals**: Fast suite &lt; 2 min (NFR-001); integration suite acceptable on CI with container startup  
**Constraints**: Fast suite must not touch `localhost:5432`; integration uses isolated DB per run  
**Scale/Scope**: ~21 API test classes → majority in-memory; 2–4 integration classes initially (health + auth/events smoke)

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `dotnet build` + analyzer on test project |
| Test strategy | ✅ Pass | Two-tier pyramid: fast default + integration for SQL fidelity |
| UX consistency | N/A | Backend testing only |
| Performance budgets | ✅ Pass | Fast suite excludes container startup |
| Flutter quality checks | N/A | |
| Evidence plan | ✅ Pass | CI job split documented in quickstart + `backend-ci.yml` |

**Post-design re-check**: No violations.

## Project Structure

### Documentation (this feature)

```text
specs/006-hybrid-test-database/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/test-suite-contract.md
└── tasks.md                    # /speckit.tasks
```

### Source Code (repository root)

```text
backend/tests/FelloWay.Api.Tests/
├── FelloWay.Api.Tests.csproj          # + EF InMemory package
├── Infrastructure/
│   ├── FelloWayWebApplicationFactory.cs       # DEFAULT: in-memory + skip DB init
│   ├── PostgresWebApplicationFactory.cs       # NEW: real PG, unique DB name
│   ├── UnavailableDatabaseWebApplicationFactory.cs  # unchanged pattern
│   ├── IntegrationTestFixture.cs                # Testcontainers, ICollectionFixture
│   └── IntegrationCollection.cs               # NEW: xUnit collection
├── Integration/                               # NEW folder (optional)
│   └── HealthAndDataIntegrationTests.cs       # Trait Category=Integration
└── [existing test classes]                      # default factory, no trait

backend/src/FelloWay.Api/
├── Extensions/DatabaseExtensions.cs     # skip init when InMemory or flag set
└── Program.cs

backend/src/FelloWay.Infrastructure/
└── DependencyInjection.cs               # skip Hangfire when Database:DisableHangfire

.github/workflows/backend-ci.yml         # fast job + integration job (postgres service)
```

**Structure Decision**: Single test project, two factories, xUnit category filter (no second csproj).

## Implementation Phases (for `/speckit.tasks`)

### Phase 1 — Fast in-memory path (P1)

1. Re-add `Microsoft.EntityFrameworkCore.InMemory` to `FelloWay.Api.Tests.csproj`.
2. Rewrite `FelloWayWebApplicationFactory`:
   - `UseEnvironment("Testing")` (keep env name for auth/config paths)
   - `Database:SkipInitialization=true`
   - `Database:DisableHangfire=true` (new config key)
   - Replace `FelloWayDbContext` with `UseInMemoryDatabase(Guid)` per factory instance
3. Update `DependencyInjection` to skip `AddHangfire` when `configuration.GetValue<bool>("Database:DisableHangfire")`.
4. Ensure `ApplyDatabaseAsync` returns early when `SkipInitialization` (already exists).
5. Default `dotnet test` uses filter `Category!=Integration` via `Directory.Build.props` or documented command.

### Phase 2 — Integration real-DB path (P1)

1. Add `PostgresWebApplicationFactory` implementing `IClassFixture<IntegrationTestFixture>` or collection fixture passing connection string from container.
2. Wire `IntegrationTestFixture` as `ICollectionFixture` + `[Collection("Integration")]`.
3. Mark integration tests with `[Trait("Category", "Integration")]`.
4. Integration factory: real connection string, **no** `SkipInitialization`, **no** `DisableHangfire` — full Testing startup.
5. Move or duplicate: `HealthEndpointTests` ready test + one OAuth/events test to integration collection.
6. Keep `UnavailableDatabaseWebApplicationFactory` in fast suite (in-memory unrelated).

### Phase 3 — CI and docs (P2)

1. Update `backend-ci.yml`: Job 1 `dotnet test --filter "Category!=Integration"`; Job 2 postgres service or testcontainers + `--filter Category=Integration`.
2. Update `backend/README` or `specs/002-backend-api/quickstart.md` testing section.
3. Add `specs/006-hybrid-test-database/quickstart.md` commands.

## Complexity Tracking

> No constitution violations requiring justification.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Test suite contract | [contracts/test-suite-contract.md](./contracts/test-suite-contract.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
