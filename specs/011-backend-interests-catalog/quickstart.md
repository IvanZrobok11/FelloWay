# Quickstart: Backend Interests Catalog (011)

**Branch**: `011-backend-interests-catalog`

## Prerequisites

- PostgreSQL running (local API)
- .NET 8 SDK, Flutter SDK
- Node 18+ for OpenAPI merge (if regenerating client)

## Backend

Apply migration `ReplaceInterestCatalog` before first run on an existing dev DB. It removes legacy interest rows (`.NET`, `Flutter`, `DevOps`, `Product`) and inserts the ten canonical Ukrainian catalog entries with fixed GUIDs. Existing `user_interests` / `event_interests` rows pointing at removed ids are cleared.

```bash
cd backend/src/FelloWay.Api
dotnet ef database update --project ../FelloWay.Infrastructure
dotnet run
```

Verify catalog:

```bash
curl -s http://localhost:5161/interests | jq '.items | length'
# Expected: 10
```

Verify names (UK):

```bash
curl -s http://localhost:5161/interests | jq '.items[].name'
```

## OpenAPI + Dart client

From repo root:

```bash
./shared/api-contracts/scripts/generate-api-client.sh
```

## Flutter

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=https://localhost:7086 --dart-define=API_MODE=live
```

### Manual checklist

1. **Catalog**: DevTools → Network → `GET .../interests` returns 10 items with Ukrainian names.
2. **Onboarding**: `/onboarding/interests` shows 10 chips (not IT/Marketing/HR/Design only). Select ≥1 → continue.
3. **Persist**: After sign-in + profile save, `GET /users/me` includes `interestIds` and `interests` with names.
4. **Profile**: Profile tab shows interest **names**, not UUIDs.
5. **Edit**: Profile edit uses chips; save updates server selection.
6. **Invalid id**: `PUT /users/me` with random uuid in `interestIds` → 400.

## Tests

```bash
cd backend
dotnet test --filter "Interest"

cd frontend
flutter test test/unit/ test/widget/
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Still see .NET/Flutter interests | Run EF migration `ReplaceInterestCatalog`; restart API |
| Onboarding empty chips | API down or `API_MODE=mock` without mock catalog |
| Profile shows UUIDs | Regenerate client; ensure `UserProfile.interests` mapped in repository |
