# Quickstart: LinkedIn BFF OAuth (009-linkedin-bff-auth)

**Branch**: `009-linkedin-bff-auth`  
**Requirement**: **HTTPS only** for local BFF sign-in (FR-016). Do not use `http://localhost` for API, app, or LinkedIn redirect URIs in this flow.

## Prerequisites

- .NET 8 SDK, Flutter 3.10+
- PostgreSQL (local)
- LinkedIn Developer app
- Trusted dev HTTPS cert: `dotnet dev-certs https --trust`
- Packages: API — `AspNet.Security.OAuth.LinkedIn`; Flutter mobile — `flutter_web_auth_2`

## 1. LinkedIn Developer Portal

1. Create / open app at [LinkedIn Developers](https://www.linkedin.com/developers/).
2. **Authorized redirect URL** (API callback only — handled by **`AddLinkedIn`** middleware):
   - Local: `https://localhost:7086/auth/linkedin/callback`
   - Staging: `https://{staging-api-host}/auth/linkedin/callback`
3. Scopes: `openid`, `profile`, `email`.
4. Do **not** register `com.felloway.app://` as a LinkedIn redirect (mobile: API callback → app ticket redirect).

## 2. Backend configuration

`appsettings.Development.json` (example — **HTTPS**):

```json
{
  "OAuth": {
    "LinkedIn": {
      "ClientId": "<linkedin-client-id>",
      "ClientSecret": "<linkedin-client-secret>"
    }
  },
  "Frontend": {
    "BaseUrl": "https://localhost:7357"
  },
  "Cors": {
    "AllowedOrigins": [
      "https://localhost:7357"
    ]
  }
}
```

Run API with HTTPS profile:

```bash
cd backend/src/FelloWay.Api
dotnet run --launch-profile https
```

Default HTTPS URL: `https://localhost:7086`.

## 3. Run Flutter web (HTTPS)

```bash
cd frontend
flutter run -d chrome --web-port=7357 --dart-define=API_BASE_URL=https://localhost:7086
```

Or VS Code: **felloway (Chrome, live API https)** in `frontend/.vscode/launch.json`.

Ensure `OAUTH_REDIRECT_URL` / legacy defines are **not** used for BFF LinkedIn (callback is server `/auth/linkedin/callback`).

## 4. Smoke test — Web (cookie)

1. Open sign-in → **Login with LinkedIn**.
2. Browser navigates to `https://localhost:7086/auth/linkedin/login?returnUrl=...`.
3. Complete LinkedIn login (`AddLinkedIn` middleware completes callback).
4. Land on `https://localhost:7357/auth/success`.
5. Profile loads; DevTools → Cookies shows session for API host (`felloway.session`).
6. `GET /users/me` succeeds with credentials (no Bearer header).

## 5. Smoke test — Mobile (JWT + flutter_web_auth_2)

1. `API_BASE_URL=https://10.0.2.2:7086` (Android emulator) or host machine HTTPS URL.
2. Manifest / iOS: `com.felloway.app` → `auth` / `callback`.
3. Tap **Login with LinkedIn** → system browser → API login.
4. Return `com.felloway.app://auth/callback?ticket=...`.
5. App `POST /auth/linkedin/mobile/complete` → stores JWT → `GET /users/me` with Bearer.

## 6. Dev fallback (no LinkedIn secrets)

- **Dev backend sign-in** via `POST /auth/oauth/linkedin/token` with `dev-{subject}` when secrets absent.
- `GET /auth/linkedin/login` returns **503** when secrets missing.

## 7. Verification commands

```bash
dotnet test backend/tests/FelloWay.Api.Tests/FelloWay.Api.Tests.csproj --filter "FullyQualifiedName~Auth"
```

```bash
cd frontend && flutter analyze && flutter test test/unit/ test/widget/
```

## 8. Troubleshooting

| Symptom | Check |
|---------|--------|
| Web still logged out after LinkedIn | CORS `AllowCredentials`; `dio` `withCredentials`; both sides **HTTPS** |
| `redirect_uri_mismatch` | LinkedIn redirect must be exactly `https://localhost:7086/auth/linkedin/callback` |
| Mobile does not return to app | `com.felloway.app` intent-filter; `flutter_web_auth_2` callback scheme |
| Cookie not set locally | API and web both HTTPS; avoid mixed content |
| `dev-*` rejected | Secrets configured — use BFF or clear secrets for dev token path |
| Still using hand-rolled exchanger | Should be removed; verify `AddLinkedIn` in `AuthExtensions.cs` |
