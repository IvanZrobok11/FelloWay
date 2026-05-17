# Data Model: Test Suite Configuration (logical)

**Feature**: `006-hybrid-test-database`  
**Date**: 2026-05-17

## Configuration flags (app host)

| Key | Fast suite | Integration suite | Production |
|-----|------------|-------------------|------------|
| `ConnectionStrings:Default` | Ignored (InMemory override) | Real Npgsql | Real |
| `Database:SkipInitialization` | `true` | `false` / absent | `false` |
| `Database:DisableHangfire` | `true` | `false` / absent | `false` |
| `ASPNETCORE_ENVIRONMENT` | `Testing` | `Testing` | `Production` |

## Factory entities

### FelloWayWebApplicationFactory (default)

| Attribute | Value |
|-----------|--------|
| Data store | EF InMemory, unique name per factory |
| Startup DB init | Skipped |
| Hangfire | Disabled |
| Used by | All tests **without** `Category=Integration` |

### PostgresWebApplicationFactory

| Attribute | Value |
|-----------|--------|
| Data store | PostgreSQL (container or env connection) |
| Database name | Unique per run (`felloway_it_{guid}`) |
| Startup DB init | Full `ApplyDatabaseAsync` |
| Hangfire | Enabled (real storage) |
| Used by | `[Trait("Category", "Integration")]` |

### UnavailableDatabaseWebApplicationFactory

| Attribute | Value |
|-----------|--------|
| Purpose | Readiness when DB unreachable |
| Suite | Fast (in-memory host + bad DbContext override) |
| SkipInitialization | `true` |

## Test run lifecycle (integration)

```text
IntegrationTestFixture.InitializeAsync()
  → start Postgres container (or read env connection)
PostgresWebApplicationFactory
  → ConfigureAppConfiguration(connectionString)
  → Program.ApplyDatabaseAsync() → EnsureCreated + Seed
Test execution
IntegrationTestFixture.DisposeAsync()
  → stop container
```

## Isolation rules

- InMemory database name MUST include `Guid` — no shared state across factory instances.
- Postgres integration MUST use unique database per factory or container database per collection.
- Fast suite MUST NOT read `ConnectionStrings:Default` for EF (override removes Npgsql registration).
