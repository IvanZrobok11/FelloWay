# Research: LinkedIn BFF OAuth (009-linkedin-bff-auth)

**Date**: 2026-05-20 (refreshed with `/speckit.plan`)

## 1. Backend OAuth: `AddLinkedIn` (FR-009)

**Decision**: Production LinkedIn sign-in uses **`AspNet.Security.OAuth.LinkedIn`** registered via **`AddLinkedIn`** in `AuthExtensions`. Login entry uses **`Challenge(LinkedInAuthenticationDefaults.AuthenticationScheme)`**. Callback **`/auth/linkedin/callback`** is handled by the package (authorize redirect, code exchange, claims). Custom code is limited to **`LinkedInBffAuthHandler.OnTicketReceived`** (and failure redirects) for FelloWay user mapping, session cookie (web), and `MobileAuthTicket` (mobile).

**Rationale**: Spec FR-009/NFR-MAINT-001; eliminates hand-rolled `LinkedInOAuthTokenExchanger` and client code forwarding.

**Alternatives considered**:
- Hand-rolled `HttpClient` token exchanger — **removed** (was `main` approach).
- Duende/IdentityServer — rejected (scope).

## 2. Platform session model

**Decision**:

| Platform | Credential | Client storage |
|----------|------------|----------------|
| Flutter Web | HttpOnly auth cookie on API host | Browser cookie jar via `dio` `withCredentials: true` |
| iOS / Android | FelloWay JWT access + refresh | `TokenStorage` / `flutter_secure_storage` |

**Rationale**: Clarification 2026-05-20; cookies unreliable in native `dio` after external browser.

## 3. Mobile browser: `flutter_web_auth_2`

**Decision**: iOS/Android only — `FlutterWebAuth2.authenticate` to open BFF login URL. **Not** used on web.

**Rationale**: Captures `com.felloway.app://auth/callback?ticket=` without client OAuth.

## 4. Mobile JWT handoff

**Decision**: One-time **`ticket`** in custom-scheme redirect → **`POST /auth/linkedin/mobile/complete`** → `TokenResponse`. TTL ≤ 60s, single-use (`IMobileAuthTicketStore` / memory cache).

## 5. Web sign-in

**Decision**: Same-window navigation to `GET /auth/linkedin/login?returnUrl=…`; success at `{returnUrl}/auth/success` with session cookie.

## 6. CORS + cookies

**Decision**: Explicit origins + **`AllowCredentials()`** for Flutter web cross-origin API calls with cookies.

## 7. Authentication scheme forwarding

**Decision**: Policy scheme `Smart`: `Authorization: Bearer` → JWT; otherwise → `WebSession` cookie.

## 8. Deprecation / hybrid dev

**Decision**:
- Primary LinkedIn: BFF only when secrets configured.
- **`POST /auth/oauth/linkedin/token`**: Facebook + **`dev-*`** when secrets absent; real LinkedIn codes **rejected** when BFF configured.
- Removed: PKCE modules, `linked_in_web_auth`, `LinkedInOAuthReturnOriginParser`, `flutter_appauth` for LinkedIn.

## 9. Flutter state

**Decision**: **`AppScope` / `AuthSession`** (no Riverpod in repo today).

## 10. Packages (locked)

| Layer | Package |
|-------|---------|
| API | `AspNet.Security.OAuth.LinkedIn`, `Microsoft.AspNetCore.Authentication.Cookies`, `Microsoft.AspNetCore.Authentication.JwtBearer` |
| Flutter mobile | `flutter_web_auth_2`, `dio`, `flutter_secure_storage` |
| Flutter web | `dio` (withCredentials) |
| Removed (LinkedIn path) | `flutter_appauth`, hand-rolled LinkedIn HTTP exchanger |

## 11. Local HTTPS only (FR-016)

**Decision**: All documented and default local URLs use **`https://`**:
- API: `https://localhost:7086` (Kestrel `https` launch profile).
- Flutter web: `https://localhost:7357` (dev TLS / `flutter run` web HTTPS).
- LinkedIn redirect URI: `https://localhost:7086/auth/linkedin/callback`.
- Client `API_BASE_URL`: `https://localhost:7086`.

**Rationale**: Spec FR-016; `Secure` cookies and BFF redirects must not rely on plain HTTP localhost.

**Alternatives considered**:
- HTTP `5161` for local — **rejected** for BFF documentation; may exist in launch profile for non-auth debugging but not for LinkedIn smoke tests.

**Implementation note**: Trust dev certificate (`dotnet dev-certs https --trust`). Flutter web HTTPS may require `--web-hostname=localhost` and trusted cert setup per Flutter docs.
