# Feature Specification: Production LinkedIn OAuth Sign-In

**Feature Branch**: `main`  
**Created**: 2026-05-19  
**Status**: Implemented  
**Input**: User description: "what i need to do to have posibility to authorize via linkedin"

## Summary

Enable **end-to-end LinkedIn sign-in** for the FelloWay mobile app: the user authenticates with LinkedIn on device, the app sends an OAuth **authorization code** to the FelloWay API, the API exchanges the code with LinkedIn and issues **API access + refresh tokens**. The mobile client never stores or uses LinkedIn provider access tokens for API calls.

Builds on existing contracts (`POST /auth/oauth/linkedin/token`), backend `AuthService`, and Flutter `AuthApi` / `flutter_appauth`; replaces the current gap where live OAuth UI stores provider tokens directly instead of API JWTs, and where the backend uses `DevOAuthTokenExchanger` only.

## Clarifications

### Session 2026-05-19

- Q: Which OAuth architecture should we target for LinkedIn sign-in? → A: **Production flow** — mobile obtains authorization code → backend exchanges with LinkedIn → API JWT (client never stores LinkedIn access tokens).
- Q: For local development when LinkedIn credentials are not configured, should the backend still accept `dev-{subject}` codes? → A: **Hybrid** — accept `dev-{subject}` (and existing `test-code`) when LinkedIn client secrets are absent; use real LinkedIn token exchange when `OAuth:LinkedIn:ClientId` and `ClientSecret` are configured.
- Q: Should this feature include Facebook sign-in with the same production flow, or LinkedIn only? → A: **LinkedIn only** — production exchange and mobile code→API JWT flow for LinkedIn; Facebook unchanged in this feature.
- Q: When LinkedIn returns profile claims, is email required to create or sign in a user? → A: **Email optional** — create or link user without email when LinkedIn omits it; persist email when provided.
- Q: What is the minimum environment that must pass real LinkedIn sign-in for this feature to be done? → A: **Local + staging** — real LinkedIn end-to-end on local API (localhost or tunnel) and on staging; production not required for feature completion.

### Session 2026-05-26

- Q: Which web session mode should production use for split API/frontend hosts? → A: **Split hosts** — after `/auth/success?ticket=...`, web redeems ticket via `POST /auth/linkedin/mobile/complete`, stores FelloWay API JWTs, and uses Bearer auth for API calls (no cross-origin cookie session dependency).
- Q: Must LinkedIn BFF URLs stay HTTPS when CloudFront sits in front of the API? → A: **HTTPS-only end state** — LinkedIn `redirect_uri`, API `/auth/linkedin/login`, and `/auth/linkedin/callback` MUST be `https://` in configuration and in redirects seen by the browser. A transient `http://` hop from CloudFront (e.g. missing `X-Forwarded-Proto` or viewer-policy downgrade) is an **infrastructure defect to fix**, not an acceptable permanent OAuth callback URL.
- Q: Must the deployed web frontend origin be listed in API `Cors:AllowedOrigins` for ticket handoff? → A: **Yes** — each environment's exact HTTPS web origin (e.g. `https://d3w0bvsi9wle0t.cloudfront.net`) MUST be in `Cors:AllowedOrigins`; otherwise `POST /auth/linkedin/mobile/complete` from the browser is blocked and sign-in is not complete.
- Q: On split-host Flutter web, should the client call `GET /auth/session` after LinkedIn BFF? → A: **JWT only** — do not rely on `GET /auth/session` when web and API hosts differ; complete ticket handoff, store API JWT, use Bearer for `/users/me` and other protected calls.
- Q: Which deployed environments must pass split-host LinkedIn BFF web sign-in for this fix? → A: **dev + test + prod only** — verify real LinkedIn BFF on all three AWS environments; **staging does not exist** in this project.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Sign in with LinkedIn (Priority: P1)

As an attendee, I want to tap **Continue with LinkedIn** and land in the app with a valid FelloWay session so I can browse events and use my profile.

**Why this priority**: LinkedIn is a primary auth provider per product requirements; without this flow, users depend on dev shortcuts or mocks.

**Independent Test**: With LinkedIn BFF configured, complete sign-in on **Flutter Web** (split-host) or mobile; `GET /users/me` with Bearer JWT succeeds. On split-host web, Network shows `POST /auth/linkedin/mobile/complete` **2xx** after `/auth/success?ticket=...`.

**Acceptance Scenarios**:

1. **Given** LinkedIn BFF is configured, **When** the user completes LinkedIn on **split-host web**, **Then** the app redeems `ticket` via `POST /auth/linkedin/mobile/complete` and stores API `accessToken` and `refreshToken` (no cross-origin cookie session).
2. **Given** a successful sign-in, **When** the user opens profile or events, **Then** protected API calls use the API JWT Bearer header.
3. **Given** the user cancels or denies LinkedIn consent, **When** they return to the app, **Then** they see a clear error and remain signed out (no partial session).

---

### User Story 2 — Operator setup (Priority: P2)

As a developer or operator, I need documented steps to register the LinkedIn app, configure secrets, and verify sign-in in **dev**, **test**, and **prod** environments.

**Why this priority**: LinkedIn app verification lead time (TECH_PLAN Phase 0) blocks production profile/email scopes.

**Independent Test**: Follow quickstart: configure backend secrets + Flutter dart-defines; manual smoke passes without code changes.

**Acceptance Scenarios**:

1. **Given** backend `OAuth:LinkedIn:ClientId` and `ClientSecret` are set, **When** a valid authorization code is posted, **Then** the API returns token pair and creates or links `OAuthIdentity` for provider `linkedin`.
2. **Given** LinkedIn client secrets are **not** configured, **When** the client posts `code` `dev-{subject}` to `POST /auth/oauth/linkedin/token`, **Then** the API returns API tokens and links a stable dev user (same subject → same account).
3. **Given** LinkedIn secrets **are** configured, **When** a `dev-{subject}` code is posted, **Then** the API rejects it and only accepts real LinkedIn authorization codes.

---

### Edge Cases

- LinkedIn token exchange fails (invalid code, expired code, wrong redirect URI) — API returns standard error envelope; app shows sign-in failure, no JWT stored.
- LinkedIn app not verified for email/profile scopes — sign-in still succeeds; display name prefilled when available; email omitted; user completes profile in onboarding/edit.
- LinkedIn returns profile without email — user account created with `OAuthIdentity` subject only; no sign-in failure.
- Concurrent sign-in attempts — only latest successful session tokens persisted client-side.
- Backend reachable but LinkedIn unreachable — exchange fails with actionable error; no silent mock fallback in live mode.
- User already linked via same LinkedIn subject — existing user receives new API tokens (same account).
- LinkedIn secrets added after dev-only usage — same `dev-{subject}` users remain distinct from real LinkedIn identities; no automatic merge unless explicitly designed later.
- Invalid `dev-*` code format when dev fallback is active — **4xx** with standard error envelope.
- Per-environment redirect URI mismatch — LinkedIn rejects authorization; document separate redirect URIs in LinkedIn app settings for **dev**, **test**, and **prod** API callbacks (and mobile custom scheme if applicable).
- API behind CloudFront redirects OAuth callback to `http://` — sign-in MAY appear to succeed at `/auth/success` but session/ticket handoff fails; operator MUST enforce HTTPS viewer policy, forward `X-Forwarded-Proto`/`Host`, and register only `https://` callback URIs in LinkedIn.
- Web origin missing from `Cors:AllowedOrigins` — browser blocks `POST /auth/linkedin/mobile/complete`; user lands on `/auth/success` then is redirected to `/sign-in` with 401 on follow-up API calls.
- Split-host web calls `GET /auth/session` expecting a cookie — returns **401** even when `/auth/success?ticket=` was issued; client MUST use ticket→JWT path instead.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The mobile app MUST obtain a LinkedIn OAuth 2.0 / OIDC **authorization code** (with PKCE) via `flutter_appauth` and MUST NOT use LinkedIn access tokens as the app's API bearer.
- **FR-002**: The app MUST call `POST /auth/oauth/linkedin/token` with `code`, `redirectUri`, and `codeVerifier`, then persist **API** `accessToken` and `refreshToken` only.
- **FR-003**: The backend MUST implement production `IOAuthTokenExchanger` for provider `linkedin` (exchange code with LinkedIn, fetch profile claims, map to `OAuthUserInfo`).
- **FR-004**: The backend MUST continue to issue FelloWay JWT access + refresh tokens and link `OAuthIdentity` per existing `AuthService` behavior.
- **FR-005**: OAuth client secrets MUST live in server configuration / secrets store only (never in the mobile binary except public LinkedIn client id).
- **FR-006**: Redirect URI used on device MUST match LinkedIn app settings and `OAUTH_REDIRECT_URL` (default `com.felloway.app:/oauthredirect`).
- **FR-007**: Documentation MUST cover LinkedIn Developer Portal registration (including redirect URIs for **local** and **staging**), scope request (`openid`, `profile`, `email`), local/tunnel testing notes, and verification lead time per TECH_PLAN.
- **FR-008**: When `OAuth:LinkedIn:ClientId` or `ClientSecret` is missing, the backend MUST accept authorization codes `dev-{subject}` or `test-code` for provider `linkedin` and MUST NOT call LinkedIn APIs.
- **FR-009**: When both LinkedIn client id and secret are configured, the backend MUST exchange only real LinkedIn authorization codes and MUST reject `dev-*` / `test-code` with **4xx**.
- **FR-010**: In live API mode, when mobile OAuth dart-defines are unset, the app MAY expose a documented **local backend sign-in** control that posts `dev-{subject}` (contributor smoke only; not shown when real LinkedIn OAuth UI is active).
- **FR-011**: Scope is limited to provider **`linkedin`**; no changes to Facebook token exchange behavior in this feature.
- **FR-012**: On successful LinkedIn exchange, the backend MUST persist email on the user record when LinkedIn supplies it and MUST NOT require email to issue API tokens.
- **FR-013**: When LinkedIn does not return email, the backend MUST still create or link the user keyed by LinkedIn `providerSubject` and MUST leave email unset until the user provides it elsewhere (if ever).
- **FR-014**: Split-host LinkedIn BFF web sign-in is complete when verified on deployed **dev**, **test**, and **prod** environments (each with its own CloudFront web/API origins and CORS allowlist); there is **no staging** environment in this project.
- **FR-015**: For deployments where web frontend and API are on different hosts, the web client MUST treat LinkedIn BFF completion as **ticket-to-JWT handoff** (`/auth/success?ticket=...` → `POST /auth/linkedin/mobile/complete`) and MUST authenticate subsequent API calls via FelloWay JWT Bearer.
- **FR-016**: Behind reverse proxies (CloudFront/ALB), the API MUST generate LinkedIn OAuth and post-login redirect URLs using the **public HTTPS** scheme/host (forwarded headers or explicit public base URL); `http://` callback URLs MUST NOT be emitted to LinkedIn or the browser in deployed environments.
- **FR-017**: For split-host Flutter web, the API MUST include the deployed web app's HTTPS origin in `Cors:AllowedOrigins` (per environment) so `POST /auth/linkedin/mobile/complete` from `/auth/success` succeeds from the browser.
- **FR-018**: When Flutter web and API are on different hosts, the web client MUST NOT treat `GET /auth/session` as the primary post-login auth check; it MUST complete ticket handoff, persist FelloWay JWTs, and use Bearer credentials for protected API calls.

### Non-Functional Requirements

- **NFR-001**: Sign-in flow (user tap to authenticated home or onboarding) SHOULD complete within **30 seconds** under normal network on deployed **dev** or **test**.
- **NFR-002**: No LinkedIn **client secret** in Flutter artifacts or repo.
- **NFR-003**: Automated tests MUST cover token exchange success and invalid-code failure on the API; client unit test for `AuthApi.exchangeLinkedIn` remains valid.
- **NFR-004**: Deployed smoke tests MUST show no browser-visible `http://` hop on `/auth/linkedin/callback` (only `https://` or internal redirect immediately upgraded to HTTPS).

### Validation Requirements

- Manual smoke: real LinkedIn BFF sign-in on **dev**, **test**, and **prod** split-host web deployments → `GET /users/me` with Bearer returns profile in each environment.
- Split-host web smoke: after LinkedIn BFF, browser shows successful `POST /auth/linkedin/mobile/complete` (2xx) from the web origin, then `GET /users/me` with Bearer returns **200**; **`GET /auth/session` MUST NOT be required** for this path to pass.
- Backend integration test with mocked LinkedIn HTTP or contract test for exchanger.
- `flutter analyze` and backend `dotnet test` pass.

### Key Entities

- **OAuthIdentity**: Links `User` to LinkedIn `provider` + `providerSubject`.
- **Session tokens**: API JWT access + refresh (client); refresh rotation per existing auth rules.
- **LinkedIn app registration**: Client id, redirect URIs, verified scopes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A tester completes real LinkedIn BFF sign-in on **dev**, **test**, and **prod** (each with LinkedIn redirect URIs and CORS origins registered) and reaches the events shell without dev-code buttons.
- **SC-002**: No API request from the mobile app uses a LinkedIn-issued bearer token (only FelloWay JWT).
- **SC-003**: Invalid or replayed authorization codes yield **4xx** from `POST /auth/oauth/linkedin/token` with no user session created.
- **SC-004**: With LinkedIn secrets unset, a developer completes local smoke via `dev-{subject}` without LinkedIn Developer Portal access; with secrets set, the same endpoint succeeds only with a real LinkedIn code.

## Assumptions

- Facebook OAuth is **out of scope** for this feature; existing Facebook UI and `POST /auth/oauth/facebook/token` behavior (including dev codes) remain as-is until a follow-up feature.
- Existing OpenAPI contract for `POST /auth/oauth/linkedin/token` is sufficient; no contract version bump unless request fields change.
- LinkedIn OpenID Connect discovery URL is used for mobile authorization (`OAUTH_DISCOVERY_URL`).
- Product continues to disallow email/password registration.

## Out of Scope (this feature)

- A separate **staging** environment (project uses **dev**, **test**, **prod** only).
- **Facebook** production OAuth exchange and mobile flow changes (button may remain; no new Facebook exchanger work).
- Storing or validating LinkedIn access tokens on the client for API authorization.
- Admin panel or web OAuth clients.
- Email/password or phone verification auth.
