# Quickstart: Live API Integration Smoke

**Feature**: `005-api-backend-integration`  
**Date**: 2026-05-17

> **Note (2026-05-26)**: `API_MODE=mock` removed from the client — see [`015-remove-mock-local`](../015-remove-mock-local/quickstart.md). Live integration smoke below still applies against a running API.

## Prerequisites

- Backend running locally ([002 quickstart](../002-backend-api/quickstart.md)): PostgreSQL, migrations, `dotnet run --project src/FelloWay.Api`
- Flutter SDK; repo root + `frontend/`
- Note API port from `backend/src/FelloWay.Api/Properties/launchSettings.json` (default HTTP profile: `http://localhost:5161`)

## 1. Start backend

```bash
cd backend
dotnet ef database update --project src/FelloWay.Infrastructure --startup-project src/FelloWay.Api
dotnet run --project src/FelloWay.Api
```

Verify: `GET http://localhost:<port>/health` → healthy.

## 2. Run app in live mode

From `frontend/` (replace port and host for your setup):

**iOS Simulator**

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5161 \
  --dart-define=API_MODE=live
```

**Android Emulator**

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:5161 \
  --dart-define=API_MODE=live
```

## 3. Manual smoke checklist

| # | Step | Expected |
|---|------|----------|
| 1 | Sign in via **dev live** sign-in (or configured OAuth) | Session has real JWT; not `demo-access-token` |
| 2 | App calls `GET /users/me` | Profile loads or empty profile for new user; no mock catalog data |
| 3 | Complete onboarding if prompted; `PUT /users/me` | 200; profile fields persist on reload |
| 4 | Open events tab | `GET /events` returns seeded events (e.g. Flutter & Friends Kyiv) or empty list |
| 5 | Open one event detail | `GET /events/{id}` loads |
| 6 | Stop backend; pull to refresh events | Clear error UI; **no** silent switch to mock data |
| 7 | Restart backend; refresh | Data loads again |

**Pass criteria**: All steps succeed (SC-001). Record date + commit SHA in PR description.

## 4. Optional: curl sanity (deployed dev)

Development OAuth codes (`dev-smoke-user`, etc.) are **not** supported on deployed API. Use LinkedIn BFF sign-in from the web app, then:

```bash
curl -s https://dev.api.<domain>/users/me -H "Authorization: Bearer <accessToken>"
curl -s https://dev.api.<domain>/events -H "Authorization: Bearer <accessToken>"
```

See [016 production OAuth policy](../016-remove-dev-oauth-backend/contracts/oauth-token-exchange-policy.md) and [016 quickstart](../016-remove-dev-oauth-backend/quickstart.md).

## 5. Quality gates

```bash
cd frontend
dart format .
flutter analyze
flutter test
```

```bash
cd backend
dotnet test
```

## 6. Live vs mock features (live mode)

| Area | Behavior in live mode |
|------|------------------------|
| Auth, profile, events read | Backend HTTP |
| Trips | Mock stubs (documented follow-up) |
| Stream chat | Mock/dev unless `STREAM_API_KEY` + backend Stream configured |

## Troubleshooting

| Symptom | Check |
|---------|--------|
| 401 on all requests | Token from `/auth/oauth/.../token`, not demo token |
| Connection refused | Base URL host (`10.0.2.2` vs `localhost`) |
| Empty profile fields | Mapper: backend uses `interestIds`, `homeCity` |
| Still see mock events | `API_MODE` not `live`, or URL still `api.example.com` with auto mode |
| Onboarding PUT fails on city | Pass `--dart-define=DEV_HOME_CITY_ID=<uuid>` from seeded `Cities` table (optional) |
