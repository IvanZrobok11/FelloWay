# FelloWay Backend API

ASP.NET Core 8 REST API for the FelloWay monorepo.

## Quick start

See [specs/002-backend-api/quickstart.md](../specs/002-backend-api/quickstart.md).

```bash
cd backend
dotnet restore FelloWay.slnx
dotnet run --project src/FelloWay.Api
```

Swagger (Development): `https://localhost:7xxx/swagger`

## Solution layout

| Project | Role |
|---------|------|
| `src/FelloWay.Api` | HTTP API, middleware, controllers |
| `src/FelloWay.Application` | Use cases, validators, interfaces |
| `src/FelloWay.Domain` | Entities and domain rules |
| `src/FelloWay.Infrastructure` | EF Core, external services |
| `tests/*` | xUnit + WebApplicationFactory |

## API contracts

OpenAPI drafts: [shared/api-contracts/](../shared/api-contracts/)

## Quality gates

```bash
dotnet format FelloWay.slnx --verify-no-changes
dotnet build FelloWay.slnx
# Fast suite (in-memory, no PostgreSQL required)
dotnet test FelloWay.slnx --filter "Category!=Integration"
# Integration suite (real PostgreSQL — Docker or FELLOWAY_TEST_CONNECTION)
dotnet test FelloWay.slnx --filter "Category=Integration"
```

See [specs/006-hybrid-test-database/quickstart.md](../specs/006-hybrid-test-database/quickstart.md).

PR checklist: [`.github/pull_request_template.md`](../.github/pull_request_template.md)

Load smoke (k6): [`scripts/load-smoke.js`](scripts/load-smoke.js)
