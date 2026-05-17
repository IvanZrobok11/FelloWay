# Feature Specification: Cross-Origin Access for Web Clients

**Feature Branch**: `007-api-cors-policy`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User description: "now error by cors — Access to XMLHttpRequest at 'https://localhost:7086/events' from origin 'http://localhost:62178' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource."

## Summary

When the FelloWay client runs in a **browser** (e.g. Flutter web on `http://localhost:62178`) and calls the backend on a **different origin** (e.g. `https://localhost:7086`), the browser blocks the response unless the API explicitly permits that origin. Today this blocks local development and any web-based testing of live API mode. The backend must **allow configured client origins** to call the API from the browser while **rejecting unknown origins** in non-development environments.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Local web client loads live data (Priority: P1)

As a developer running the Flutter web app against a local backend, I need event and profile requests to succeed so I can verify live API integration without switching to mobile-only testing.

**Why this priority**: This is the reported failure (`GET /events` blocked); it blocks all web-based live-mode work.

**Independent Test**: Run backend locally, run Flutter web with live API base URL, open events — data loads or a normal API error appears (not a browser security block).

**Acceptance Scenarios**:

1. **Given** the web app is served from `http://localhost` on any ephemeral port and the API is on `https://localhost` on another port, **When** the app requests `GET /events` with live mode, **Then** the browser does not block the response for missing cross-origin permission.
2. **Given** the same setup, **When** the user is signed in and the app calls an authenticated endpoint, **Then** the request completes or returns an application-level error (401/403/5xx), not a browser CORS failure.
3. **Given** live mode and a reachable backend, **When** the developer opens the events screen, **Then** they see backend data or an in-app error state — not a blank screen caused solely by cross-origin blocking.

---

### User Story 2 — Configurable allowed origins per environment (Priority: P1)

As an operator, I need to declare which web origins may call the API in each environment so staging and production stay locked down while development remains productive.

**Why this priority**: Open-by-default in production is a security risk; hard-coded single origin breaks team workflows.

**Independent Test**: Change allowed-origin configuration for an environment; only listed origins succeed from the browser; others are denied.

**Acceptance Scenarios**:

1. **Given** a non-production environment with localhost origins in configuration, **When** a browser request comes from a listed origin, **Then** the API permits the cross-origin response.
2. **Given** production with only approved staging/production web URLs in configuration, **When** a browser request comes from an unlisted origin, **Then** the API does not grant cross-origin access to that origin.
3. **Given** configuration is updated and the API restarted, **When** a new origin is added to the allow list, **Then** that origin is permitted without code changes.

---

### User Story 3 — Preflight and authenticated browser calls (Priority: P2)

As a user signed in via the web client, I need write operations and requests that send authorization headers to work from the browser, not only simple read-only GETs.

**Why this priority**: Real flows use `Authorization` and non-GET methods, which trigger browser preflight checks.

**Independent Test**: From Flutter web, perform `POST` (e.g. attend event, refresh token path) with auth header; no preflight-related browser block.

**Acceptance Scenarios**:

1. **Given** an authenticated web session, **When** the client sends a `POST` with an authorization header to a permitted origin, **Then** the browser preflight succeeds and the API processes or rejects the call at the application layer.
2. **Given** a permitted origin, **When** the client sends `OPTIONS` for a preflight, **Then** the API responds in a way that allows the actual request to proceed.
3. **Given** credentials/cookies are not required for this API (Bearer tokens in headers), **When** cross-origin access is configured, **Then** behavior matches token-in-header auth without requiring cookie-based cross-origin credentials unless explicitly enabled later.

---

### Edge Cases

- Web app on `http://localhost` vs `https://localhost` (scheme mismatch) — each must be allowlisted or covered by a documented dev pattern.
- API on HTTPS and web on HTTP (mixed content / different ports) — common in local dev; must be supported for configured dev origins.
- Mobile native clients (iOS/Android) — not subject to browser cross-origin rules; must continue to work unchanged.
- Unauthenticated `GET /health` — should remain callable for probes; cross-origin rules must not break standard health checks from monitoring tools unless explicitly restricted.
- Error responses (4xx/5xx) — cross-origin headers must still be present so the client can read error bodies, not only on 200 responses.
- Unknown `Origin` header or missing origin (non-browser clients) — must not break server-to-server or native app traffic.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The API MUST permit cross-origin browser responses for origins listed in environment configuration.
- **FR-002**: The API MUST deny cross-origin browser access for origins not on the allow list in staging and production.
- **FR-003**: For permitted origins, the API MUST include the information browsers need to expose responses to the web client (including on error status codes).
- **FR-004**: The API MUST support browser preflight (`OPTIONS`) for methods and headers used by the FelloWay client (including `Authorization`, `Content-Type`, and correlation/request headers used by the app).
- **FR-005**: Development configuration MUST allow typical local Flutter web origins (`http://localhost` and `https://localhost` with variable ports) without manual code edits per port.
- **FR-006**: Operators MUST be able to configure allowed origins via application settings (not only compile-time constants).
- **FR-007**: Native mobile clients MUST NOT require cross-origin configuration changes to continue using the API.
- **FR-008**: Documentation MUST describe how to run Flutter web against a local backend (base URL, scheme, and any required origin settings) so developers can reproduce the fix.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST verify that a permitted origin receives cross-origin headers on a representative API route and that a disallowed origin does not in production-like configuration.
- **NFR-SEC-001**: Production MUST NOT use a wildcard allow-all-origins policy.
- **NFR-UX-001**: Web users MUST see application error states (network/auth/validation), not opaque browser console-only failures, when the backend is misconfigured vs unreachable.

### Validation Requirements *(mandatory)*

- **Quality gates**: `dotnet build` and `dotnet test` on backend; existing fast test suite remains green.
- **Test evidence**: At least one automated test asserting cross-origin headers for an allowed origin on `GET /events` or `/health`; optional manual checklist in quickstart for Flutter web smoke.
- **Manual verification**: Flutter web with `--dart-define=API_MODE=live` and local API URL loads events without CORS console errors.
- **CI**: Backend CI includes new/updated tests; no Flutter change required unless docs-only in frontend README.

### Key Entities

- **Allowed origin**: A full browser origin (scheme + host + port) permitted to read API responses from JavaScript.
- **Cross-origin policy**: Per-environment set of allowed origins and rules for preflight vs simple requests.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In local dev, 100% of smoke checks from the quickstart (web app → `GET /events`, authenticated `GET /users/me`) complete without browser cross-origin blocking when the backend is healthy.
- **SC-002**: In a production-like configuration test, 0% of requests from an unlisted random origin receive permissive cross-origin headers.
- **SC-003**: Developers can complete the “Flutter web + local API” setup in under 10 minutes using documented steps (no tribal knowledge).
- **SC-004**: Support burden from “CORS blocked” reports for standard local/staging web testing drops to zero for configured environments.

## Assumptions

- Primary reporter is using **Flutter web** in **live API mode** against a **locally running** backend (`https://localhost:7086`).
- **Bearer JWT** in `Authorization` remains the auth model; cookie-based cross-origin credentials are out of scope unless added later.
- **Mobile apps** are in scope only as “must not regress”; no CORS work required on the client for iOS/Android.
- Allowed origins for production will be supplied by deployment configuration (staging URL, future admin web URL).
- The backend already implements REST endpoints from prior API integration work; this feature only enables browser access policy.

## Dependencies

- Live backend API running and reachable (see `005-api-backend-integration`).
- Flutter client `API_BASE_URL` / `API_MODE=live` pointed at the same backend instance used for testing.

## Out of Scope

- Changing OpenAPI contracts or business logic on `/events`.
- Hosting Flutter web in production (only cross-origin permission for when it exists).
- CDN or API gateway CORS (in-scope: FelloWay API application layer unless plan defers to gateway).
