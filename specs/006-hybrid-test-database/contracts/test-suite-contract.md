# Contract: API test suites (fast vs integration)

**Feature**: `006-hybrid-test-database`  
**Date**: 2026-05-17

## Fast suite (default)

| Property | Value |
|----------|--------|
| Filter | `Category!=Integration` (exclude integration) |
| External PostgreSQL | **Not required** |
| Factory | `FelloWayWebApplicationFactory` |
| EF provider | InMemory |
| App DB initialization | Skipped |
| Hangfire | Disabled |

**Entry command**:

```bash
cd backend
dotnet test FelloWay.slnx --filter "Category!=Integration"
```

## Integration suite

| Property | Value |
|----------|--------|
| Filter | `Category=Integration` |
| External PostgreSQL | **Required** (Docker Testcontainers or CI service) |
| Factory | `PostgresWebApplicationFactory` + `IntegrationTestFixture` |
| EF provider | Npgsql |
| Environment | `Testing` |
| App DB initialization | `EnsureCreatedAsync` + non-production seed |
| Hangfire | Enabled |

**Entry command**:

```bash
cd backend
dotnet test FelloWay.slnx --filter "Category=Integration"
```

## Failure messages

When integration suite runs without database:

- Test host MUST fail with message containing **"Integration tests require PostgreSQL"** or connection setup instructions (NFR-002).

## CI contract

| Job | Filter | Postgres service |
|-----|--------|------------------|
| `backend-ci` build+test (PR) | `Category!=Integration` | No |
| `backend-ci-integration` (optional job) | `Category=Integration` | Yes |

## Tests in integration (minimum)

| Area | Assertion |
|------|-----------|
| Health | `GET /health/ready` → 200 when DB up |
| Data | Authenticated `GET /users/me` or `GET /events` → 200 |

Unavailable-database tests remain in **fast** suite only.
