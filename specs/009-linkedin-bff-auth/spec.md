# Feature Specification: LinkedIn Sign-In via Backend-Controlled Flow (BFF)

**Feature Branch**: `009-linkedin-bff-auth`  
**Created**: 2026-05-20  
**Status**: Ready for planning (amended 2026-05-20)  
**Input**: Refactor LinkedIn auth to production BFF flow; **local development MUST use HTTPS only**; **remove obsolete frontend and backend files** from the prior client-driven LinkedIn OAuth implementation.

## Summary

Replace the current client-driven LinkedIn sign-in (authorization code sent from the app to the API) with a **backend-for-frontend (BFF)** flow: the user starts sign-in from the app, completes LinkedIn login entirely on the server, and returns to the app already authenticated. The app only opens a server login link and then checks signed-in state through normal API calls; it never processes LinkedIn authorization codes, PKCE, or LinkedIn access tokens.

**In scope**: LinkedIn sign-in only; refactor of existing LinkedIn production flow on `main`; removal of dead code from the replaced client-OAuth approach.  
**Out of scope**: Facebook or other providers; changes to non-auth product areas; unrelated legacy cleanup outside LinkedIn auth paths.

**Session model by platform**: After BFF LinkedIn login, **Flutter Web** uses **cookie-based** sessions; **iOS and Android** use **API JWT** (access + refresh), not cookies.

## Clarifications

### Session 2026-05-20

- Q: How should native mobile (iOS/Android) hold authenticated state after BFF LinkedIn sign-in when HttpOnly cookies are not used by the app HTTP client? → A: **Platform split** — **Flutter Web**: cookie-based session (HttpOnly, Secure, SameSite). **Android/iOS**: JWT-based API auth (not cookies); app stores only FelloWay API tokens after server completes BFF, never LinkedIn tokens.
- Q: Should local development use HTTP or HTTPS for API and app URLs? → A: **HTTPS only for local** — all local API base URLs, frontend return URLs, LinkedIn redirect URIs, and client `API_BASE_URL` values MUST use `https://` (no `http://localhost` in documented or configured local flows).
- Q: Should legacy client-OAuth code remain in the repo after BFF ships? → A: **Remove unused artifacts** — delete superseded LinkedIn PKCE/web callback modules, hand-rolled server token exchanger, and related tests; keep only what BFF, dev sign-in, and non-LinkedIn paths still need.
- Q: How must the API host integrate LinkedIn OAuth on the server? → A: **`AspNet.Security.OAuth.LinkedIn`** — register the provider with **`AddLinkedIn`** (official ASP.NET Core OAuth handler); use `Challenge` on the LinkedIn scheme for login entry and the package’s **`/auth/linkedin/callback`** pipeline for code exchange and claims; custom code limited to ticket/cookie/JWT wiring after `OnTicketReceived`, not a replacement token HTTP client.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Sign in with LinkedIn from the app (Priority: P1)

As an attendee, I want to tap **Login with LinkedIn**, complete LinkedIn’s consent screen, and return to FelloWay signed in so I can use events and my profile without dealing with technical errors or partial login.

**Why this priority**: LinkedIn is a primary sign-in path; the BFF model reduces client complexity and security risk from mishandled OAuth data.

**Independent Test**: With LinkedIn configured for the environment, tap sign-in, finish LinkedIn login, land on the app success route, and confirm profile/events load as an authenticated user.

**Acceptance Scenarios**:

1. **Given** the user is signed out, **When** they tap **Login with LinkedIn**, **Then** the app opens the server’s LinkedIn login entry URL and does not show or handle LinkedIn authorization parameters itself.
2. **Given** the user approves LinkedIn consent, **When** LinkedIn redirects back to the server, **Then** the server completes provider login, creates or updates the FelloWay account, establishes an authenticated session, and redirects the user to the configured app success URL.
3. **Given** a completed sign-in on **web**, **When** the app requests the current user profile, **Then** the response shows the signed-in user and the session is carried by **cookies** on API requests (no LinkedIn or manual OAuth artifacts in the client).
4. **Given** a completed sign-in on **iOS or Android**, **When** the app requests the current user profile, **Then** the response shows the signed-in user and subsequent API calls use **FelloWay JWT** credentials issued by the server after BFF (not cookies, not LinkedIn tokens).
5. **Given** the user denies or cancels LinkedIn consent, **When** they return to the app, **Then** they see a clear message and remain signed out.

---

### User Story 2 — Stay signed in across app usage (Priority: P2)

As a returning user, I want my session to persist securely after LinkedIn sign-in so I do not have to log in again on every visit until I sign out or the session expires.

**Why this priority**: Session continuity is required for a production auth experience after moving to server-managed login.

**Independent Test**: Sign in once, close and reopen the app (or browser tab on web), verify protected content still loads until explicit sign-out or session expiry.

**Acceptance Scenarios**:

1. **Given** a successful LinkedIn sign-in on **web**, **When** the user navigates the app in the same browser context, **Then** protected API calls succeed via **cookie session** without re-entering LinkedIn credentials.
2. **Given** a successful LinkedIn sign-in on **mobile**, **When** the user navigates the app, **Then** protected API calls succeed via **stored API JWT** (and refresh when applicable) without re-entering LinkedIn credentials.
3. **Given** an expired or invalid session (cookie on web, JWT on mobile), **When** the user opens protected areas, **Then** they are prompted to sign in again via the same LinkedIn entry flow.

---

### User Story 3 — Operator and developer verification (Priority: P3)

As a developer or operator, I need clear environment setup and smoke-test steps so LinkedIn sign-in can be verified on local and staging before production rollout.

**Why this priority**: LinkedIn app registration and redirect URLs must align with the BFF endpoints; documentation prevents false “broken auth” reports.

**Independent Test**: Follow environment setup notes; complete one successful sign-in on local and one on staging without changing application code.

**Acceptance Scenarios**:

1. **Given** LinkedIn application credentials are configured for the API environment, **When** the documented smoke test is run, **Then** end-to-end sign-in succeeds and links the user to an existing account when the same LinkedIn identity signs in again.
2. **Given** LinkedIn is not configured in a non-production environment, **When** operators use the documented development sign-in path, **Then** they can still obtain a test session without using production LinkedIn credentials (separate from the BFF LinkedIn flow).
3. **Given** local environment setup documentation, **When** an operator configures LinkedIn redirect URIs and app/API base URLs, **Then** every local URL uses **HTTPS** (API callback, frontend return origin, and client API base).

---

### Edge Cases

- LinkedIn or server token exchange fails (invalid code, misconfigured redirect, provider outage) — user sees a sign-in failure page or app error state; no authenticated session is created.
- LinkedIn profile omits email — account is created or updated without email; sign-in still succeeds when email is optional per product rules.
- User already linked to the same LinkedIn identity — same FelloWay account receives a new session; no duplicate account for the same provider identity.
- User opens login on one device and completes on another — only the browser session that completes the flow receives the authenticated session unless product defines cross-device completion (not in scope).
- Session cookie blocked on **web** (browser privacy settings, third-party cookie restrictions) — user sees guidance to retry or adjust settings; sign-in does not silently appear successful.
- **Mobile** JWT missing or expired after success redirect mishandling — app shows sign-in again; no fallback to LinkedIn client OAuth.
- Concurrent sign-in attempts — latest successful server session wins; no undefined mixed state in the app UI.
- Stale bookmark to old client OAuth callback routes — user is directed to sign-in again via the new server login entry; no client parsing of legacy OAuth callbacks for LinkedIn.
- **Local HTTP URL configured** (API, app, or LinkedIn redirect mismatch) — sign-in fails with actionable operator guidance to switch to HTTPS; system MUST NOT document plain-HTTP localhost URLs as supported for this feature.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer **Login with LinkedIn** that navigates the user to a **server-hosted LinkedIn login entry** (not to LinkedIn directly from client OAuth logic).
- **FR-002**: The server MUST own the full LinkedIn OAuth interaction: redirect to LinkedIn, receive the authorization callback, exchange the code, fetch profile data, and create or update the FelloWay user and provider identity.
- **FR-003**: The app MUST NOT receive, store, parse, or transmit LinkedIn authorization codes, PKCE verifiers, or LinkedIn access tokens for sign-in purposes.
- **FR-004**: The app MUST NOT implement a client-side OAuth redirect handler for LinkedIn provider authorization codes (mobile may parse only **FelloWay-issued** completion parameters such as a one-time ticket, not LinkedIn `code` or tokens).
- **FR-005**: After successful server login on **Flutter Web**, the server MUST establish an authenticated session using **HttpOnly, Secure cookies** with an appropriate **SameSite** policy; the web client MUST rely on cookies for API authentication (credentials included automatically on same-site or configured cross-site requests).
- **FR-006**: After successful server login on **iOS and Android**, the server MUST issue **FelloWay API JWT** access (and refresh when applicable) to the client; the native app MUST NOT use cookies for API authentication and MUST NOT store LinkedIn provider tokens.
- **FR-007**: After establishing the session (cookie or JWT per platform), the server MUST redirect the user to a configured **app success URL** or documented frontend return URL so the client can confirm signed-in state.
- **FR-008**: The app MUST determine signed-in state and load user information only through **authenticated API requests** to the backend (no local storage of LinkedIn OAuth codes or LinkedIn access tokens).
- **FR-009**: The server MUST register production LinkedIn sign-in with **`AspNet.Security.OAuth.LinkedIn`** via **`AddLinkedIn`** (scheme `LinkedIn`, callback path `/auth/linkedin/callback`, scopes `openid`, `profile`, `email`). Login entry MUST **`Challenge`** that scheme; authorization redirect, callback handling, and provider token exchange MUST run inside the package handler—not a hand-rolled `HttpClient` LinkedIn token exchanger. Application code MAY hook **`OnTicketReceived`** (and failure events) only to map claims to FelloWay users and issue cookies or mobile JWT tickets.
- **FR-010**: LinkedIn provider secrets MUST exist only in server configuration or a secrets store, never in the client application package.
- **FR-011**: The feature MUST replace the previous client-driven LinkedIn code-exchange sign-in; that mechanism MUST NOT remain the primary LinkedIn sign-in path after this feature ships.
- **FR-012**: Sign-in errors MUST surface user-readable messages in the app or on a server-rendered failure redirect; the app MUST NOT leave the user in an ambiguous half-signed-in state.
- **FR-013**: Documentation MUST describe LinkedIn Developer Portal redirect URIs for the **server callback**, platform-specific **success return URLs** (web vs mobile deep links), and smoke-test steps for BFF sign-in on web and native.
- **FR-014**: On **mobile**, JWT delivery after BFF MUST occur without exposing LinkedIn authorization codes to the app (e.g. secure success redirect or dedicated mobile completion step documented in the technical plan).
- **FR-015**: Scope is **LinkedIn only**; other providers and unrelated auth refactors are unchanged unless required for shared session infrastructure.
- **FR-016**: **Local** (non-production) environment documentation and default configuration MUST use **HTTPS only** for API host, frontend return URLs, LinkedIn OAuth redirect URIs, and mobile API base URLs; plain HTTP localhost URLs MUST NOT be listed as valid for BFF sign-in or cookie sessions.
- **FR-017**: The codebase MUST NOT retain **unused** modules from the superseded LinkedIn client-OAuth flow (client PKCE helpers, legacy web callback forwarders, hand-rolled LinkedIn token HTTP client, and tests that only served the old flow); retained code MUST compile and tests MUST pass after removal.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Changes MUST satisfy project linting, formatting, and static analysis with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover the server login/callback happy path, sign-in denial/cancel, and regression that the client no longer depends on LinkedIn OAuth codes for session creation.
- **NFR-UX-001**: Sign-in UI MUST follow the project design system with consistent loading, error, and empty states; **Login with LinkedIn** remains a single primary action.
- **NFR-SEC-001**: **Web** cookie sessions MUST resist common web attacks (HttpOnly, **Secure** on all environments including local, SameSite, CSRF protections where applicable). **Mobile** JWTs MUST be stored in platform-secure storage and transmitted only over HTTPS to the API. **Local** sign-in flows MUST NOT rely on non-secure HTTP URLs.
- **NFR-SEC-002**: OAuth and profile retrieval failures MUST NOT leak provider secrets or raw provider tokens to clients or logs visible to end users.
- **NFR-PERF-001**: Median end-to-end sign-in (tap button through landed success screen) SHOULD complete within **90 seconds** under normal network conditions excluding user typing time on LinkedIn.
- **NFR-MAINT-001**: Prefer **battle-tested libraries and framework authentication** over custom OAuth protocol code; custom code limited to wiring, configuration, user mapping, and redirects.
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and project formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Widget or integration tests MUST verify the app opens the server login URL and reflects API-driven auth state (signed in vs signed out) without mocking LinkedIn directly in the client.
- **NFR-FLUTTER-UX-001**: Auth UI state MUST be driven by a single app-wide session/state approach consistent with the existing client app (one source of truth for signed-in vs signed-out).
- **NFR-FLUTTER-PERF-001**: Opening the login URL MUST not block the UI thread; show loading until success URL or API confirms session.

### Validation Requirements *(mandatory)*

- **Quality gates**: Backend and frontend CI test suites green; no new critical static-analysis issues.
- **Test evidence**: API tests for login redirect, callback success/failure, web session cookie attributes, and mobile JWT issuance path; Flutter tests for sign-in button behavior and post-login profile fetch on web (cookies) and mobile (JWT).
- **UX acceptance**: Cancel/deny and network failure paths show localized, actionable copy per existing l10n patterns.
- **Performance check**: Manual smoke on **local (HTTPS)** and staging records time from tap to success screen for three consecutive successful sign-ins (target: under 90 seconds median excluding user input on LinkedIn).
- **Flutter verification**: `flutter analyze`, targeted unit/widget tests for auth presentation, manual web smoke with cookies enabled.

### Key Entities *(include if feature involves data)*

- **User**: FelloWay account; may include optional email, display name; linked to one or more provider identities.
- **Provider identity (LinkedIn)**: Stable provider subject identifier linking a LinkedIn account to a User; used on repeat sign-in to attach session to the same User.
- **Authenticated session (web)**: HttpOnly cookie session on the API host representing the signed-in user until expiry or sign-out.
- **Authenticated session (mobile)**: FelloWay API JWT access (and optional refresh) representing the signed-in user until expiry, refresh failure, or sign-out.
- **Sign-in attempt**: Ephemeral server-side OAuth state from login entry through callback success or failure (not persisted as a long-lived client artifact).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least **95%** of completed LinkedIn sign-in attempts on staging (excluding user-cancelled flows) result in a user who can access their profile within **60 seconds** after returning to the app success URL.
- **SC-002**: **100%** of security review checklist items for this feature pass: no LinkedIn tokens or authorization codes in client storage, logs, or analytics payloads.
- **SC-003**: **Zero** production incidents in the first 30 days post-release attributed to client-side OAuth callback mishandling for LinkedIn (baseline: prior client-driven flow).
- **SC-004**: Operators can complete documented local and staging smoke tests in under **30 minutes** including LinkedIn portal configuration.
- **SC-005**: User-reported “login failed with no message” tickets for LinkedIn sign-in decrease by at least **50%** within 60 days versus the 60 days before release (qualitative tracking if volume is low).

## Assumptions

- **Architecture intent (from stakeholder input)**: Backend-controlled OAuth (BFF); authentication pipeline owned by the API host via **`AspNet.Security.OAuth.LinkedIn` `AddLinkedIn`**; client opens `GET /auth/linkedin/login` (server `Challenge`), LinkedIn redirects to **`/auth/linkedin/callback`** (middleware), then server redirects to app success. Hand-rolled LinkedIn token HTTP clients are **out of scope** for production sign-in.
- **Platforms (decided)**: **Flutter Web** — cookie-based API session after BFF. **iOS/Android** — JWT-based API auth after BFF; cookies are not used on native clients. Mobile JWT handoff mechanism is defined in the technical plan and must not expose LinkedIn OAuth codes to the app.
- **Email**: Optional on first sign-in when LinkedIn omits email (consistent with existing product decision on `main`).
- **Environments**: Feature complete when real LinkedIn BFF sign-in works on **local (HTTPS only)** and **staging**; production rollout may follow separately.
- **Local HTTPS**: Developers use trusted local TLS for API and Flutter web (e.g. dev certificate on standard local HTTPS ports); exact ports and tooling are defined in the technical plan and quickstart, but **scheme must always be HTTPS**.
- **Legacy removal**: Superseded LinkedIn auth files are deleted in the same delivery as BFF; dev/Facebook token-exchange paths that remain in use are not removed.
- **Dev workflows**: Non-production environments without LinkedIn credentials keep a **separate documented dev sign-in** path; it does not use the production BFF LinkedIn endpoints.
- **Deprecation**: The prior client-driven LinkedIn sign-in API is retired or disabled when BFF is enabled in an environment.
- **Facebook**: Unchanged in this feature.
- **Existing user data**: `OAuthIdentity` and User records from the previous LinkedIn flow remain valid; same LinkedIn subject maps to the same User.
