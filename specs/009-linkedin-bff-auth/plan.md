# Implementation Plan: LinkedIn Sign-In via Backend-Controlled Flow (BFF)

**Branch**: `009-linkedin-bff-auth` | **Date**: 2026-05-20 | **Spec**: [spec.md](./spec.md)  
**Input**: BFF LinkedIn auth; **HTTPS-only local**; **remove legacy client-OAuth**; **`AspNet.Security.OAuth.LinkedIn` `AddLinkedIn`** (FR-009)

## Summary

Replace client-driven LinkedIn OAuth (PKCE, `flutter_appauth`, hand-rolled token HTTP client) with a **server-owned BFF**: Flutter opens `GET /auth/linkedin/login`, **`AddLinkedIn`** middleware handles authorize/callback/token/claims, custom **`OnTicketReceived`** maps users and issues **web cookies** or **mobile one-time tickets** → JWT. Local and documented URLs use **HTTPS only** (FR-016).

## Technical Context

**Language/Version**: C# 12 / .NET 8 (API); Dart 3.10+ / Flutter stable (client)  
**Primary Dependencies**: `AspNet.Security.OAuth.LinkedIn` 8.x, `Microsoft.AspNetCore.Authentication.Cookies`, `Microsoft.AspNetCore.Authentication.JwtBearer`, EF Core 8 + Npgsql; Flutter: `dio`, `flutter_web_auth_2` (mobile only), `go_router`, `flutter_secure_storage`  
**Storage**: PostgreSQL (`users`, `oauth_identities`, `refresh_tokens`); `IMemoryCache` for `MobileAuthTicket` (ephemeral)  
**Testing**: xUnit + `WebApplicationFactory` (API); `flutter test` unit/widget; manual HTTPS smoke per quickstart  
**Target Platform**: Flutter Web, Android, iOS; ASP.NET Core API  
**Project Type**: Monorepo `backend/` + `frontend/`  
**Performance Goals**: Median sign-in tap → success screen &lt; 90s (excl. user typing on LinkedIn); non-blocking login URL open (NFR-PERF-001)  
**Constraints**: No LinkedIn codes/tokens in client; HTTPS-only local BFF; credentialed CORS for web cookies; secrets server-only  
**Scale/Scope**: Auth feature only (LinkedIn); Facebook/dev token path unchanged

## Constitution Check

*GATE: Pass (pre- and post-design).*

| Gate | Plan evidence |
|------|----------------|
| Code quality | `dotnet build`, `flutter analyze`; scoped auth modules only |
| Test strategy | API: login 503, mobile ticket complete, real-code rejection when configured; Flutter: BFF URL + session state widgets |
| UX consistency | Existing `OAuthSignInPage`, l10n errors, loading on login |
| Performance | SC-001 / NFR-PERF-001; manual 3-run smoke in quickstart |
| Flutter checks | `flutter analyze` + `test/unit/`, `test/widget/` in CI |
| Evidence | CI test logs; quickstart checklist; no LinkedIn secrets in client |

**Post-design**: No constitution violations requiring Complexity Tracking exceptions.

## Project Structure

### Documentation (this feature)

```text
specs/009-linkedin-bff-auth/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/linkedin-bff-oauth-flow.md
├── checklists/requirements.md
└── tasks.md          # /speckit.tasks
```

### Source Code (repository root)

```text
backend/src/FelloWay.Api/
├── Extensions/AuthExtensions.cs          # AddLinkedIn, cookies, JWT policy scheme
├── Auth/LinkedInBffAuthHandler.cs        # OnTicketReceived, redirects
├── Controllers/AuthController.cs         # Challenge, mobile/complete, session
└── Program.cs

backend/src/FelloWay.Infrastructure/
├── Auth/CompositeOAuthTokenExchanger.cs  # dev/Facebook; reject real LinkedIn codes when BFF on
├── Auth/MobileAuthTicketStore.cs
└── DependencyInjection.cs

backend/tests/FelloWay.Api.Tests/Auth/
├── LinkedInBffLoginTests.cs
└── OAuthDevCodeRejectionTests.cs

frontend/lib/features/auth/
├── presentation/oauth_sign_in_page.dart
├── mobile/linkedin_bff_auth.dart         # flutter_web_auth_2
├── web/linkedin_bff_web_auth*.dart       # same-window login
├── data/auth_api.dart, dio_credentials.dart
└── (removed) oauth_pkce, linked_in_web_auth, oauth_browser*, oauth_native_support

frontend/android/app/src/main/AndroidManifest.xml  # com.felloway.app auth/callback only
```

**Structure Decision**: Multi-package Flutter + .NET API; BFF wiring in `FelloWay.Api`, domain/token issuance in `Application`/`Infrastructure`.

## Implementation Phases

### Phase A — Backend: `AddLinkedIn` BFF (FR-009)

1. Package: `AspNet.Security.OAuth.LinkedIn` in `FelloWay.Api.csproj`.
2. `AuthExtensions.AddFelloWayAuthentication`:
   - `AddLinkedIn(LinkedInAuthenticationDefaults.AuthenticationScheme, …)` when secrets configured.
   - `CallbackPath = "/auth/linkedin/callback"`; scopes `openid`, `profile`, `email`; `SaveTokens = false`.
   - `OnTicketReceived` → `LinkedInBffAuthHandler.HandleTicketReceived` (user upsert, cookie or ticket).
   - `OnRemoteFailure` → platform-aware error redirect (**HTTPS** fallbacks only).
   - Policy scheme: Bearer → JWT; else → `WebSession` cookie.
3. `AuthController`: `GET /auth/linkedin/login` → `Challenge(LinkedInAuthenticationDefaults.AuthenticationScheme)`; `POST /auth/linkedin/mobile/complete`; optional `GET /auth/session`.
4. CORS: `AllowCredentials()` for configured frontend origins.
5. **Remove**: `LinkedInOAuthTokenExchanger`, `LinkedInOAuthReturnOriginParser`, obsolete callback tests.

**Status**: Implemented in branch; align config/docs to HTTPS (Phase D).

### Phase B — Flutter client

1. **Web**: `linkedin_bff_web_auth` — `window.location` to `{API}/auth/linkedin/login?returnUrl=…`; route `/auth/success`; `dio` `withCredentials`.
2. **Mobile**: `linkedin_bff_auth` — `FlutterWebAuth2.authenticate`; parse `ticket` only; `AuthApi.completeLinkedInMobile`.
3. **Remove**: PKCE, `linked_in_web_auth`, `flutter_appauth` (LinkedIn), AppAuth `RedirectUriReceiverActivity`.
4. `AuthSession` / `ApiClient`: cookie mode on web, JWT on mobile.

**Status**: Implemented; widget tests and README section may need completion.

### Phase C — Tests & deprecation

| Test | Purpose |
|------|---------|
| `LinkedInBffLoginTests` | 503 without secrets; ticket → JWT; single-use ticket |
| `OAuthDevCodeRejectionTests` | Real code → 400 when configured; `dev-*` → 200 |
| Flutter unit/widget | Login URL, no client LinkedIn code path |

`CompositeOAuthTokenExchanger`: when LinkedIn configured, non-`dev-*` codes → domain error directing to BFF.

### Phase D — HTTPS-only local (FR-016) — remaining alignment

| Artifact | Target |
|----------|--------|
| `appsettings.Development.json` | `Frontend:BaseUrl` → `https://localhost:7357`; CORS origins HTTPS |
| API launch | Prefer profile **`https`** (`https://localhost:7086`) as documented default |
| LinkedIn portal | Redirect: `https://localhost:7086/auth/linkedin/callback` only (no HTTP) |
| `frontend/.vscode/launch.json` | Default config: HTTPS API + web port |
| `quickstart.md` | All examples `https://` |
| `AuthExtensions` failure fallback | `https://localhost:7357` not `http://` |

Dev `POST /auth/oauth/linkedin/token` with `dev-{subject}` remains when secrets empty.

## Complexity Tracking

*(empty — no justified violations)*
