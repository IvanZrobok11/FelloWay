# Research: Production LinkedIn OAuth Sign-In

**Feature**: `main` (Production LinkedIn OAuth)  
**Date**: 2026-05-19

## 1. OAuth architecture (mobile ↔ API ↔ LinkedIn)

**Decision**: **Authorization code + PKCE on mobile**; **token exchange on backend**; mobile stores only FelloWay JWT pair.

**Rationale**: Clarification session (2026-05-19); matches existing `POST /auth/oauth/linkedin/token` contract and `AuthService`; avoids passing LinkedIn access tokens to REST layer.

**Alternatives considered**:
- `authorizeAndExchangeCode` on device (current `oauth_sign_in_page.dart`) — rejected; bypasses API JWT and breaks `SC-002`.
- BFF-only web redirect — rejected; native app uses custom URL scheme.

## 2. LinkedIn endpoints (OpenID Connect)

**Decision**: Use LinkedIn OIDC discovery and standard endpoints:

| Step | URL |
|------|-----|
| Discovery | `https://www.linkedin.com/oauth/.well-known/openid-configuration` |
| Authorize | `https://www.linkedin.com/oauth/v2/authorization` |
| Token | `https://www.linkedin.com/oauth/v2/accessToken` |
| UserInfo | `https://api.linkedin.com/v2/userinfo` |

**Scopes**: `openid`, `profile`, `email` (aligned with Flutter `AuthorizationTokenRequest` scopes).

**Rationale**: LinkedIn documents OpenID Connect; `flutter_appauth` supports `discoveryUrl` for authorize step.

**Alternatives considered**:
- Legacy LinkedIn v2 profile APIs only — rejected; OIDC gives `sub`, name, email in one userinfo call.

## 3. Hybrid dev exchanger (secrets-gated)

**Decision**: Register a **composite** `IOAuthTokenExchanger`:

- **`linkedin` + secrets configured** → `LinkedInOAuthTokenExchanger` (HTTP to LinkedIn); reject `dev-*` / `test-code`.
- **`linkedin` + secrets missing** → `DevOAuthTokenExchanger` behavior (accept `dev-{subject}`, `test-code`).
- **`facebook`** → unchanged `DevOAuthTokenExchanger` (out of feature scope for production).

**Rationale**: Clarification C + FR-008/009; preserves contributor smoke and CI tests without LinkedIn app.

**Alternatives considered**:
- Separate `/auth/dev/token` — rejected in clarification (keep single contract path).
- Dev codes in Production only via environment flag — rejected; use secret presence instead.

## 4. HTTP client and resilience

**Decision**: Typed `HttpClient` (named `LinkedInOAuth`) in Infrastructure; **Polly** retry on transient 5xx/408 for token and userinfo calls (2–3 retries, exponential backoff); no retry on 4xx.

**Rationale**: TECH_PLAN / `002-backend-api` plan mentions Polly for OAuth; LinkedIn outages should not hang requests indefinitely.

**Alternatives considered**:
- Raw `HttpClient` without Polly — acceptable for MVP but weaker ops story.

## 5. Flutter `flutter_appauth` flow

**Decision**: Replace `authorizeAndExchangeCode` with **`authorize`** (authorization code only), then `AuthApi.exchangeLinkedIn(code, redirectUri, codeVerifier)` using the PKCE verifier from the authorize request.

**Rationale**: Backend must hold client secret; spec FR-001/002.

**Configuration**:
- `OAUTH_CLIENT_ID` — LinkedIn app client id (public).
- `OAUTH_DISCOVERY_URL` — LinkedIn OIDC discovery URL.
- `OAUTH_REDIRECT_URL` — `com.felloway.app:/oauthredirect` (default).

**Alternatives considered**:
- Manual browser + deep link without appauth — rejected; appauth already in project.

## 6. Email from LinkedIn

**Decision**: **Email optional** — persist when userinfo returns `email`; do not fail exchange when absent.

**Implementation note**: `OAuthUserInfo.Email` exists; `User` entity currently has **no** `Email` column — add nullable `User.Email` + EF migration, map in `AuthService` on create/update.

**Rationale**: FR-012/013; LinkedIn verification may delay email scope (TECH_PLAN risk).

## 7. Local + staging verification

**Decision**: Definition of done requires real LinkedIn on:

1. **Local** — API on Kestrel; device uses `10.0.2.2` (Android) or localhost (iOS sim); LinkedIn app must whitelist mobile redirect URI (not API host).
2. **Staging** — secrets in AWS Secrets Manager / App Service config per `008-aws-deploy-pipeline`; same mobile build with staging `API_BASE_URL`.

**Rationale**: Clarification D; production not a gate.

**Alternatives considered**:
- Staging-only — rejected; developers need local loop.

## 8. Contract changes

**Decision**: **No OpenAPI path/body change** for MVP; optional `401`/`400` error codes documented in feature contract notes only.

**Rationale**: Spec assumption; request already includes `code`, `redirectUri`, `codeVerifier`.

## 9. Testing strategy

**Decision**:
- Unit tests: `LinkedInOAuthTokenExchanger` with `HttpMessageHandler` mock (token + userinfo JSON).
- API tests: factory without LinkedIn secrets → existing `test-code` tests pass; factory with test handler + secrets → real-code path; with secrets, `dev-*` returns 400.
- Flutter: update/widget test for sign-in calling `AuthApi` after authorize; keep `auth_api_test.dart`.

**Rationale**: NFR-003; avoids live LinkedIn in CI.
