# Feature Specification: Connect Mobile App to Live Backend API

**Feature Branch**: `005-api-backend-integration`  
**Created**: 2026-05-17  
**Status**: Implemented  
**Input**: User description: "i want to relate api and backend. check it works"

## Summary

Connect the Flutter app to the **real FelloWay backend API** (replacing or complementing mock mode) so authenticated users can load and mutate data through the same contracts defined in `shared/api-contracts/`, and **prove end-to-end** that critical flows work against a running backend instance.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Live API smoke after login (Priority: P1)

As a user who completed onboarding, I need the app to load my profile and event list from the real backend so I know the mobile client talks to the same API the server implements.

**Why this priority**: Without a verified live path, the app remains demo-only despite a deployed backend.

**Independent Test**: Run backend locally or on staging, set app to live mode, sign in, see profile and events load without mock stubs.

**Acceptance Scenarios**:

1. **Given** a running backend and valid credentials, **When** the app uses live API mode, **Then** `GET /users/me` returns the signed-in user’s profile and the UI displays it.
2. **Given** the user is authenticated, **When** they open the events experience, **Then** `GET /events` returns data from the backend (empty list is acceptable if no seeded events).
3. **Given** live mode, **When** the backend is unreachable, **Then** the user sees a clear error state (not silent mock fallback unless explicitly configured).

---

### User Story 2 — Contract-aligned requests and responses (Priority: P1)

As a developer, I need the mobile client’s HTTP calls to match the shared OpenAPI contract (paths, methods, auth header, error shape) so drift is caught early.

**Why this priority**: “Relate API and backend” means contract parity, not ad-hoc URLs.

**Independent Test**: Compare live traffic (or integration tests) against `shared/api-contracts/` for the wired endpoints; failures are documented or fixed.

**Acceptance Scenarios**:

1. **Given** wired endpoints, **When** a successful call completes, **Then** response bodies deserialize into the expected models without manual field mapping hacks for those endpoints.
2. **Given** an unauthorized request, **When** the token is missing or expired, **Then** the app receives the standard error envelope and triggers refresh or re-login per product rules.
3. **Given** a validation error from the backend, **When** the server returns the shared error format, **Then** the app can surface a user-visible message.

---

### User Story 3 — Incremental feature wiring (Priority: P2)

As a maintainer, I need a clear order to move features from mock repositories to live API calls without a single big-bang refactor.

**Why this priority**: Full replacement in one release is high risk; incremental wiring is deliverable.

**Independent Test**: At least one feature repository uses live API; others may remain mock with documented follow-up.

**Acceptance Scenarios**:

1. **Given** the integration plan, **When** MVP is complete, **Then** auth, profile, and events read paths use the live backend.
2. **Given** trips/chat still on mocks, **When** live mode is on, **Then** behavior is documented (mock-only features vs live features).

---

### Edge Cases

- Backend version mismatch vs mobile contract — fail with actionable logs, not cryptic parse errors.
- Partial outage (DB up, Stream down) — profile/events may work; chat token failure handled separately.
- Local dev: HTTP vs HTTPS, emulator localhost (`10.0.2.2` Android) vs machine IP.
- Token refresh race on parallel requests — no duplicate login prompts.
- Empty backend database — UI shows empty states, not errors.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST support **live API mode** targeting a configurable backend base URL (development/staging/production).
- **FR-002**: Live mode MUST send **Bearer JWT** on protected routes consistent with backend auth.
- **FR-003**: MVP live wiring MUST cover **authentication/session**, **current user profile** (`GET/PUT /users/me` as needed for smoke), and **events list** (`GET /events`).
- **FR-004**: Live calls MUST align with **`shared/api-contracts/`** for the wired endpoints (paths, methods, required headers).
- **FR-005**: The team MUST document a **manual smoke checklist** (and optional automated integration tests) proving backend + app work together.
- **FR-006**: When live mode is enabled, the app MUST NOT silently fall back to mocks without explicit configuration (avoid false “it works” during backend outages).
- **FR-007**: Error handling MUST use the shared **error envelope** for live responses where the backend returns it.
- **FR-008**: Configuration MUST be documentable for developers (base URL, API mode, OAuth dev shortcuts per backend quickstart).
- **FR-009**: Wired endpoints SHOULD use the **same data shapes** as the shared API contract to reduce manual mapping errors.
- **FR-010**: Out of MVP live scope unless time permits: trips join flows, avatar upload, Stream chat token — remain mock or follow-up tasks.

### Non-Functional Requirements

- **NFR-001**: Live smoke checklist completable in **under 15 minutes** on a standard dev machine with backend + app running.
- **NFR-002**: Perceived load for profile + events on warm backend: user sees content or empty state within **5 seconds** on typical dev hardware/network.
- **NFR-003**: No secrets (JWT signing keys, client secrets) embedded in the mobile app beyond public OAuth client ids.

### Validation Requirements

- Manual smoke per checklist against local or staging backend.
- Automated checks in the mobile and server codebases pass after wiring changes (no new regressions).
- Contract parity for wired endpoints is verified during smoke (request/response match shared definitions).

### Key Entities

- **Live API configuration**: Base URL, API mode (mock/live/auto).
- **Session**: Access + refresh tokens, user identity.
- **Wired endpoints**: Subset of contract paths used in MVP smoke.
- **Smoke evidence**: Checklist results (pass/fail per step).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer completes the documented smoke checklist with **100% pass** on MVP flows (login → profile → events list) against a running backend.
- **SC-002**: At least **3** contract endpoints are verified live (e.g. auth token, `GET /users/me`, `GET /events`).
- **SC-003**: Zero undetected mock fallbacks during live-mode smoke (misconfiguration excluded).
- **SC-004**: Contract mismatch defects found during integration are **tracked and fixed** or documented with follow-up tasks before release.
- **SC-005**: New contributor can run backend + app in live mode using **README/quickstart only** within one working session.

## Assumptions

- Backend MVP from `002-backend-api` is running (PostgreSQL, migrations, dev OAuth shortcuts documented in backend quickstart).
- OpenAPI codegen (`004-openapi-dart-codegen`) provides `felloway_api` package; wiring may use shared `Dio` / existing `ApiClient`.
- MVP focuses on **read-heavy** paths plus auth; writes beyond profile update are follow-up.
- Staging URL or `http://localhost` for dev; production deploy is out of scope for this feature’s proof.
- Stream chat may still use dev tokens; this feature validates **REST** integration first.

## Out of Scope

- Full removal of all mock code paths across every feature.
- Backend feature development not already in contracts.
- Performance/load testing beyond light smoke.
- Production release pipeline and monitoring dashboards.
- Regenerating OpenAPI client (covered by 004; only consume here).
