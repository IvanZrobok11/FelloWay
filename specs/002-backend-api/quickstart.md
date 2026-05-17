# Quickstart: Backend API Development

**Feature**: `002-backend-api`  
**Date**: 2026-05-17

## Prerequisites

- .NET 8 SDK
- Docker Desktop (for local PostgreSQL via Testcontainers or compose)
- Azure CLI (optional, for Blob/Key Vault later)
- GetStream app key + secret (development app)
- LinkedIn / Facebook OAuth app credentials (dev redirect URIs)

## Local setup

```bash
cd backend
dotnet restore FelloWay.slnx
dotnet tool install --global dotnet-ef   # if needed

# User secrets (from backend/src/FelloWay.Api)
dotnet user-secrets set "ConnectionStrings:Default" "Host=localhost;Database=felloway;Username=postgres;Password=postgres" --project src/FelloWay.Api
dotnet user-secrets set "Jwt:SigningKey" "felloway-dev-signing-key-change-in-production-min-32-chars!!" --project src/FelloWay.Api
dotnet user-secrets set "Stream:ApiKey" "<key>" --project src/FelloWay.Api
dotnet user-secrets set "Stream:ApiSecret" "<secret>" --project src/FelloWay.Api
dotnet user-secrets set "OAuth:LinkedIn:ClientId" "<id>" --project src/FelloWay.Api
dotnet user-secrets set "OAuth:LinkedIn:ClientSecret" "<secret>" --project src/FelloWay.Api
# Facebook, Azure Blob — add when implementing US1/US4

dotnet ef database update --project src/FelloWay.Infrastructure --startup-project src/FelloWay.Api
dotnet run --project src/FelloWay.Api
```

**Phase 0 checklist**: Register LinkedIn/Facebook OAuth apps; configure GetStream dev app; Azure Key Vault for staging (replace user-secrets in non-dev).

### Development OAuth (local / Testing)

Until real LinkedIn/Facebook token exchange is wired, use:

- `POST /auth/oauth/linkedin/token` with body `{ "code": "test-code", "redirectUri": "...", "codeVerifier": "..." }`
- Or `code`: `dev-{unique-subject}` for a stable test user

`GET /chat/stream-token` returns a dev token when Stream credentials are not configured.

### Events (US2 smoke)

After `dotnet run` in `backend/src/FelloWay.Api`:

```http
GET /events
GET /events?q=Flutter&city=Kyiv
GET /events/{id}
Authorization: Bearer <token>
POST /events/{id}/attend
DELETE /events/{id}/attend
GET /events/{id}/attendees   # joined subscribers only
```

Seeded dev events: **Flutter & Friends Kyiv**, **Product IT Summit** (see `DataSeeder`).

### Trips (US3 smoke)

Requires event attendance and home city on profile (`PUT /users/me` with `homeCityId`).

```http
GET /events/{eventId}/trips
POST /events/{eventId}/trips
  { "routeLabel": "...", "departureAt": "...", "originCityId": "<uuid>", "transportRole": "driver", "capacity": 4 }
POST /trips/{tripId}/join          # auto-approved when home city matches trip origin
DELETE /trips/{tripId}/join        # cancel pending request
GET /trips/{tripId}/join-requests  # trip owner only
POST /trips/{tripId}/approve/{userId}
```

Leaving an event (`DELETE /events/{id}/attend`) revokes active trip memberships and pending join requests for that event.

### Trust, safety, admin (US4 smoke)

```http
POST /users/{id}/block
GET /users/{id}/reviews
PUT /users/me/push-preferences
POST /events/{eventId}/attendees/{userId}/review   # body: { "rating": 5, "comment": "..." }
```

Admin (OAuth code `dev-admin` → role `admin`):

```http
GET /admin/events/pending
POST /admin/events/{id}/approve
POST /admin/events/{id}/reject
POST /admin/users/{id}/ban
GET /admin/reports
POST /admin/reports/{id}/resolve   # body: { "status": "resolved" }
```

Hangfire dashboard (Development): `/hangfire`. Recurring job `post-event-review-reminder` runs daily (stub push).

Swagger UI (Development): `https://localhost:7xxx/swagger`

## Run against Flutter client

```bash
cd frontend
flutter run --dart-define=API_BASE_URL=https://localhost:7xxx --dart-define=API_MODE=live
```

Use a trusted dev certificate or Android cleartext exception for local HTTP if needed.

## Quality gates

From `backend/`:

```bash
dotnet format --verify-no-changes
dotnet build
dotnet test
```

Integration tests spin up PostgreSQL via Testcontainers — Docker must be running.

## Contract-first workflow

1. Edit OpenAPI under [shared/api-contracts/](../../shared/api-contracts/).
2. Implement controller/DTO in `FelloWay.Api`.
3. Update [frontend mock catalog](../../frontend/lib/shared/mocks/mock_api_catalog.dart) if response shapes change.
4. PR checklist: spec FR-B* coverage + integration test for changed routes.

## CI

GitHub Actions [`.github/workflows/backend-ci.yml`](../../.github/workflows/backend-ci.yml): `dotnet format --verify-no-changes`, `dotnet build`, `dotnet test` on `backend/` changes.

## Staging deploy checklist (Azure)

1. **App Service** — deploy `FelloWay.Api` (Linux, .NET 8), enable HTTPS only.
2. **PostgreSQL Flexible Server** — connection string in App Service configuration / Key Vault reference.
3. **Key Vault** — store `Jwt:SigningKey`, OAuth client secrets, Stream keys, Blob connection; use managed identity for App Service access.
4. **Run migrations** — `dotnet ef database update` in release pipeline or startup job (one-time per release).
5. **Hangfire** — uses same PostgreSQL; ensure dashboard is not public in staging/production.
6. **CORS** — set `Cors:AllowedOrigins` for staging/production web clients; see [007-api-cors-policy/quickstart.md](../007-api-cors-policy/quickstart.md).
7. **Health** — wire App Service liveness to `GET /health` and readiness to `GET /health/ready` (ASP.NET Core built-in health checks; see [003 health contract](../003-custom-health-checks/contracts/health-probes.md)). Expect **200** when healthy, **503** on readiness when the database is unreachable; liveness stays **200** if only the DB is down.

## Load smoke (NFR-B001)

Script: [`backend/scripts/load-smoke.js`](../../backend/scripts/load-smoke.js) (k6).

```bash
# Install k6, then:
k6 run -e BASE_URL=https://<staging-host> -e AUTH_TOKEN=<jwt> backend/scripts/load-smoke.js
```

**Target**: p95 &lt; 300 ms for `GET /health` and `GET /events` under light load (5 VUs, 30s). Adjust thresholds in the script for your environment.

## Manual smoke checklist

- [ ] OAuth login returns JWT + refresh
- [ ] `GET /users/me` after login
- [ ] `PUT /users/me` with interests + city
- [ ] Avatar upload returns URL
- [ ] `GET /chat/stream-token` connects Stream SDK on device
- [ ] `GET /events` paginated; attend / unjoin
- [ ] Create trip → join request → approve
- [ ] Block user prevents DM/trip join (per policy)

## Related docs

- [plan.md](./plan.md)
- [data-model.md](./data-model.md)
- [shared/api-contracts/](../../shared/api-contracts/)
