# Quickstart: Production LinkedIn OAuth Sign-In

**Feature**: `main`  
**Date**: 2026-05-19

## Prerequisites

- .NET 8 SDK, Docker (for API integration tests / PostgreSQL)
- Flutter stable, Dart 3.10+
- LinkedIn Developer app ([create app](https://www.linkedin.com/developers/))
- Submit LinkedIn **verification** early if you need reliable `email` scope (TECH_PLAN Phase 0)

## 1. LinkedIn Developer Portal

1. Create an app → **Auth** tab.
2. Add **Authorized redirect URLs** (all that you use locally):
   - Web (API callback): `http://localhost:5161/auth/oauth/linkedin/callback` and/or `https://localhost:7086/auth/oauth/linkedin/callback` — must match `API_BASE_URL` / `OAUTH_REDIRECT_URL` exactly (scheme + host + port).
   - Mobile: `com.felloway.app:/oauthredirect`
3. Enable **Sign In with LinkedIn using OpenID Connect**.
4. Note **Client ID** and **Client Secret**.
5. Request scopes: `openid`, `profile`, `email`.

## 2. Backend (local)

```powershell
cd backend

dotnet user-secrets set "OAuth:LinkedIn:ClientId" "<client-id>" --project src/FelloWay.Api
dotnet user-secrets set "OAuth:LinkedIn:ClientSecret" "<client-secret>" --project src/FelloWay.Api

dotnet ef database update --project src/FelloWay.Infrastructure --startup-project src/FelloWay.Api
dotnet run --project src/FelloWay.Api
```

**Without secrets** (contributor smoke): omit user-secrets; use `dev-{subject}` codes (see §5).

`OAUTH_CLIENT_ID` in Flutter must be the **same** Client ID as `OAuth:LinkedIn:ClientId` on the API. The **Client Secret** is API-only (user-secrets / Key Vault), never in dart-define.

### Troubleshooting

| Symptom | Likely cause |
|--------|----------------|
| `invalid_client: Client authentication failed` | Wrong or missing `OAuth:LinkedIn:ClientSecret` in user-secrets, or Client ID mismatch vs Flutter `OAUTH_CLIENT_ID`. |
| Two `POST /auth/oauth/linkedin/token` (200 then 400) | Fixed in client: do not exchange the same `code` twice (reload after pull). Second call reused an already-spent authorization code. |
| `invalid_grant` | `redirect_uri` in token request ≠ value used in LinkedIn authorize step, or code expired/reused. |

## 3. Flutter (real LinkedIn)

**Platform**:
- **Web** (`flutter run -d chrome`): LinkedIn redirects to the **API** (`{API_BASE_URL}/auth/oauth/linkedin/callback`), then Development API forwards to **`{Flutter origin}/sign-in`** — origin is embedded in OAuth `state`, so you do **not** need to edit `Frontend:BaseUrl` when Flutter picks a random port. `Frontend:BaseUrl` in `appsettings.Development.json` is only a **fallback** (missing state, tests). Optionally fix the web port: `--web-port=7357` (see `frontend/.vscode/launch.json`).
- **Android / iOS**: `flutter_appauth` (custom scheme `com.felloway.app:/oauthredirect`).
- **Windows desktop**: use **Sign in (local backend)** or an emulator.

```powershell
cd frontend
flutter pub get

# iOS Simulator → localhost; Android Emulator → 10.0.2.2
# Do NOT use -d windows for LinkedIn OAuth
flutter run `
  --dart-define=API_BASE_URL=http://localhost:5161 `
  --dart-define=API_MODE=live `
  --dart-define=OAUTH_CLIENT_ID=<client-id> `
  --dart-define=OAUTH_DISCOVERY_URL=https://www.linkedin.com/oauth/.well-known/openid-configuration `
  --dart-define=OAUTH_REDIRECT_URL=com.felloway.app:/oauthredirect
```

Tap **Continue with LinkedIn** → complete login → app should reach events/onboarding with API JWT.

## 4. Staging

1. Store `OAuth:LinkedIn:ClientId` and `ClientSecret` in staging secrets (Terraform / App Service / Key Vault per `008-aws-deploy-pipeline`).
2. Build app with staging `API_BASE_URL` and same OAuth dart-defines (client id is public).
3. Repeat manual smoke: LinkedIn sign-in → `GET /users/me`.

## 5. Dev fallback (no LinkedIn app)

Backend: do **not** set LinkedIn secrets.

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:5161 --dart-define=API_MODE=live
```

Use **Sign in (local backend)** → posts `dev-smoke-user`.

Or curl:

```bash
curl -s -X POST http://localhost:5161/auth/oauth/linkedin/token \
  -H "Content-Type: application/json" \
  -d "{\"code\":\"dev-smoke-user\",\"redirectUri\":\"http://localhost\",\"codeVerifier\":\"dev\"}"
```

## 6. Manual smoke checklist

- [ ] **Local + secrets**: LinkedIn button → API JWT → `GET /users/me` 200
- [ ] **Local + secrets**: `dev-test` code returns **400**
- [ ] **Local + no secrets**: `dev-smoke-user` returns 200
- [ ] **Staging**: same LinkedIn button flow against staging base URL
- [ ] Cancel LinkedIn login → error snackbar, still signed out
- [ ] No API call uses LinkedIn bearer (inspect proxy logs)

## 7. Quality gates

```powershell
# Backend
cd backend
dotnet format --verify-no-changes
dotnet build
dotnet test

# Frontend
cd frontend
dart format . --set-exit-if-changed
flutter analyze
flutter test
```

## Related

- [spec.md](./spec.md) · [plan.md](./plan.md) · [contracts/linkedin-oauth-flow.md](./contracts/linkedin-oauth-flow.md)
- [002-backend-api quickstart](../002-backend-api/quickstart.md)
- [005-api-backend-integration quickstart](../005-api-backend-integration/quickstart.md)
