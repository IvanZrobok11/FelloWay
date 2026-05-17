# Research: Connect Mobile App to Live Backend API

**Feature**: `005-api-backend-integration`  
**Date**: 2026-05-17

## 1. Current client state (live vs mock)

**Decision**: Keep existing `ApiClient` + repository pattern; repositories already branch on `AppConfig.useMockApi` and call Dio for `/users/me`, `/events`, etc.

**Rationale**: Live HTTP paths exist in `UsersRepository`, `EventsRepository`, `TripsRepository`. Mock is explicit via `API_MODE=mock` or default `example.com` URL. No big-bang rewrite required.

**Gap**: Sign-in still uses `FlutterAppAuth` OIDC tokens or `_demoSignIn()` with fake bearer strings. Backend expects JWTs from `POST /auth/oauth/{provider}/token` (dev: `code: dev-{subject}`).

**Alternatives considered**:
- Replace all repositories with `felloway_api` only — higher churn; defer to incremental adapters.
- New network layer — redundant with `ApiClient`.

## 2. Authentication for local smoke

**Decision**: Add a **live dev sign-in** path when `API_MODE=live` and OAuth is not configured: exchange `dev-{subject}` via `POST /auth/oauth/linkedin/token`, store `accessToken` + `refreshToken` in `TokenStorage`, same as production token storage.

**Rationale**: Matches `002-backend-api` quickstart and existing API tests; unblocks smoke without LinkedIn app credentials.

**Alternatives considered**:
- Require full `FlutterAppAuth` for every live run — blocks contributors without OAuth apps.
- Hard-code JWT in dart-define — insecure and brittle.

## 3. Contract alignment strategy

**Decision**: **Phase A** — fix domain mappers in repositories to match `shared/api-contracts` + backend JSON (`interestIds`, `homeCity`, `aggregateRating`, `EventListPage` shape). **Phase B (optional follow-up)** — introduce thin mappers from `felloway_api` built_value models to domain types for wired endpoints.

**Rationale**: `UserProfile.fromJson` still expects legacy mock fields (`interests`, `hobbies`, `homeCityLabel` only). Backend `UserProfileDto` uses `interestIds`, `homeCity`, `homeCityId`. Events list mapping is closer but should be validated against seeded data.

**Alternatives considered**:
- Immediate full cutover to generated client in all repos — large diff; 005 MVP targets parity + smoke, not 100% codegen adoption.

## 4. Token refresh on 401

**Decision**: Implement refresh in `ApiClient` interceptor: on 401, call `POST /auth/refresh` with stored refresh token once, retry original request; on failure invoke `onUnauthorized` (sign out).

**Rationale**: Spec FR-002/acceptance scenario for expired token; currently marked TBD in `api_client.dart`.

**Alternatives considered**:
- Force re-login only — worse UX during smoke with short-lived tokens.

## 5. Error envelope

**Decision**: Extend `mapDioError` (or shared parser) to read contract `ErrorResponse` (`message`, `code`, `errors[]`) when `response.data` is a JSON map.

**Rationale**: FR-007; backend returns shared shape for validation/auth failures.

## 6. Local networking (emulator)

**Decision**: Document base URLs in quickstart:

| Target | `API_BASE_URL` |
|--------|----------------|
| iOS Simulator | `http://localhost:5xxx` (Kestrel port from launchSettings) |
| Android Emulator | `http://10.0.2.2:5xxx` |
| Physical device | `http://<LAN-IP>:5xxx` |

Use `API_MODE=live` explicitly when testing against localhost (URL does not contain `example.com` but explicit live avoids confusion).

**Rationale**: Common Flutter/Android pitfall; spec edge case.

## 7. Features remaining mock in live mode

**Decision**: Document matrix in quickstart: **live** = auth token exchange, profile read/update (MVP), events list/detail read; **mock or degraded** = trips, Stream chat token (unless Stream secrets configured), attend/write flows if not verified in smoke.

**Rationale**: FR-010 / US3 incremental wiring.

## 8. Verification approach

**Decision**: Primary = **manual smoke checklist** in `quickstart.md`; secondary = optional `integration_test` or repository unit tests with `MockAdapter` replaying recorded backend JSON fixtures.

**Rationale**: NFR-001 (&lt;15 min smoke); constitution allows integration tests for critical journeys.

**Alternatives considered**:
- E2E only via Patrol — heavier setup for MVP.
