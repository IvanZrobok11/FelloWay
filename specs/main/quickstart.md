# Quickstart: Fix split-host LinkedIn BFF auth (dev/test/prod)

This quickstart targets the deployed CloudFront setup where:

- **Web** is served from a CloudFront host (e.g. `https://<web-host>.cloudfront.net`)
- **API** is served from a different CloudFront host (e.g. `https://<api-host>.cloudfront.net`)

## Expected web flow (split-host)

1. Web navigates to `GET https://<api-host>/auth/linkedin/login?platform=web&returnUrl=https%3A%2F%2F<web-host>`
2. LinkedIn redirects back to `https://<api-host>/auth/linkedin/callback?...`
3. API redirects to `https://<web-host>/auth/success?ticket=...`
4. Web calls `POST https://<api-host>/auth/linkedin/mobile/complete` with `{ "ticket": "..." }`
5. Web stores FelloWay JWT tokens and calls `GET https://<api-host>/users/me` with `Authorization: Bearer <accessToken>`

`GET /auth/session` is **not required** for split-host deployments.

## LinkedIn Developer Portal setup

- **Redirect URI** (per env): `https://<api-host>/auth/linkedin/callback`
- Ensure LinkedIn app has the redirect URIs registered for **dev**, **test**, and **prod** API hosts.

## Environment mapping (dev / test / prod)

Terraform wires each environment automatically (`infra/terraform/modules/ecs/main.tf` sets `Cors__AllowedOrigins__0` and `Frontend__BaseUrl` from `local.web_origin_url`):

| Env | Web origin (`web_origin_url`) | API public URL (`api_public_url`) | LinkedIn callback |
|-----|------------------------------|-----------------------------------|-------------------|
| **dev** | `https://{web_cf_domain}` or `https://{dev.web.domain}` | `https://{api_cf_domain}` or `https://{dev.api.domain}` | `https://<api-host>/auth/linkedin/callback` |
| **test** | same pattern | same pattern | same |
| **prod** | same pattern | same pattern | same |

**Observed prod (2026-05-26)** (technical CloudFront URLs):

| Role | Host |
|------|------|
| Web | `https://d3w0bvsi9wle0t.cloudfront.net` |
| API | `https://dwkne2w3ldk1d.cloudfront.net` |

After `terraform apply`, run `terraform output web_url` and `terraform output api_url` per environment and register the API callback in LinkedIn.

## API CORS setup (per env)

In non-Development environments, the API only allows explicitly configured origins.

Set `Cors:AllowedOrigins` to include the deployed web origin:

- `https://<web-host>` for dev
- `https://<web-host>` for test
- `https://<web-host>` for prod

## CloudFront / HTTPS requirements

CloudFront must not expose an `http://` hop for `/auth/linkedin/callback`.

- Enforce **viewer HTTPS-only** (redirect HTTP → HTTPS).
- Forward `X-Forwarded-Proto` and `Host` headers to origin so ASP.NET sees the public URL scheme/host.

## Known prod failure (2026-05-26)

Observed trace when web (`d3w0bvsi9wle0t.cloudfront.net`) and API (`dwkne2w3ldk1d.cloudfront.net`) differ:

1. LinkedIn BFF completes → `/auth/success?ticket=...` (200)
2. Client calls `GET /auth/session` and `GET /users/me` → **401**
3. User redirected to `/sign-in`

**Fix (client)**: split-host web must call `POST /auth/linkedin/mobile/complete`, store JWT, use Bearer (not cookie session).

## Smoke checklist (per env)

- Browser Network shows:
  - `/auth/linkedin/login` → 302
  - `/auth/linkedin/callback` → 302 (HTTPS)
  - `/<web>/auth/success?ticket=...` → 200
  - `POST /auth/linkedin/mobile/complete` → **2xx**
  - `GET /users/me` (Bearer) → **200**

### Smoke results (record in PR after deploy)

| Env | Date | `POST .../mobile/complete` | `GET /users/me` Bearer | Notes |
|-----|------|---------------------------|------------------------|-------|
| dev | | | | |
| test | | | | |
| prod | | | | |

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

## 5. Auth on deployed environments

Configure LinkedIn OAuth secrets on the API (see `009-linkedin-bff-auth`). Sign in via **LinkedIn BFF** from the web client (`GET /auth/linkedin/login`). Development authorization codes are **not** accepted on deployed API — see [016-remove-dev-oauth-backend](../016-remove-dev-oauth-backend/quickstart.md).

## 6. Manual smoke checklist

- [ ] **Deployed dev**: LinkedIn BFF → API JWT → `GET /users/me` 200
- [ ] **Deployed dev**: `POST /auth/oauth/linkedin/token` with `dev-smoke-user` returns **400** (no tokens)
- [ ] **Staging**: same LinkedIn BFF flow against staging base URL
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
