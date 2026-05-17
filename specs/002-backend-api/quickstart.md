# Quickstart: Backend API Development

**Feature**: `002-backend-api`  
**Date**: 2026-05-17

## Prerequisites

- .NET 8 SDK
- Docker Desktop (for local PostgreSQL via Testcontainers or compose)
- Azure CLI (optional, for Blob/Key Vault later)
- GetStream app key + secret (development app)
- LinkedIn / Facebook OAuth app credentials (dev redirect URIs)

## Local setup (once `backend/` scaffold exists)

```bash
cd backend
dotnet restore
dotnet tool install --global dotnet-ef   # if needed

# User secrets (from backend/src/FelloWay.Api)
dotnet user-secrets set "ConnectionStrings:Default" "Host=localhost;Database=felloway;Username=postgres;Password=postgres"
dotnet user-secrets set "Stream:ApiKey" "<key>"
dotnet user-secrets set "Stream:ApiSecret" "<secret>"
dotnet user-secrets set "OAuth:LinkedIn:ClientId" "<id>"
dotnet user-secrets set "OAuth:LinkedIn:ClientSecret" "<secret>"
# ... Facebook, Blob connection string

dotnet ef database update --project src/FelloWay.Infrastructure --startup-project src/FelloWay.Api
dotnet run --project src/FelloWay.Api
```

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

## CI (planned)

GitHub Actions: build + test on PR; deploy to Azure App Service on merge to `main` (see TECH_PLAN Phase 0).

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
