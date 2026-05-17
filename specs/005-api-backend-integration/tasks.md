# Tasks: Connect Mobile App to Live Backend API

**Input**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/live-integration.md](./contracts/live-integration.md), [quickstart.md](./quickstart.md)  
**Branch**: `005-api-backend-integration`  
**Prerequisites**: Backend from `002-backend-api` running locally; `004-openapi-dart-codegen` artifacts present (`frontend/lib/generated/felloway_api/`)

**Organization**: Tasks grouped by user story. Foundational auth/network blocks all stories. Constitution requires automated tests per story.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (shared infrastructure)

**Purpose**: Fixtures, docs, and local-dev prerequisites before code changes.

- [x] T001 Align `specs/005-api-backend-integration/quickstart.md` ports with `backend/src/FelloWay.Api/Properties/launchSettings.json` (e.g. `http://localhost:5161`)
- [x] T002 [P] Add backend-shaped JSON fixtures in `frontend/test/fixtures/user_profile_backend.json` and `frontend/test/fixtures/event_list_page_backend.json` from OpenAPI/backend seeder shapes
- [x] T003 [P] Enable Android debug cleartext HTTP if needed in `frontend/android/app/src/debug/AndroidManifest.xml` (only when smoke uses `http://` to local Kestrel)

**Checkpoint**: Quickstart port matches backend; test fixtures exist for mappers.

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Auth API client, network error/refresh foundation, and `AppScope` wiring. **No user story work until this phase completes.**

- [x] T004 Create `frontend/lib/features/auth/domain/token_response.dart` matching contract `TokenResponse` (`accessToken`, `refreshToken`, `expiresIn`, `userId`)
- [x] T005 Create `frontend/lib/features/auth/data/auth_api.dart` with `POST /auth/oauth/linkedin/token` and `POST /auth/refresh` using shared `Dio` (no bearer on auth routes)
- [x] T006 Create `frontend/lib/shared/network/error_response.dart` parser for contract `ErrorResponse` (`message`, `code`, `errors`)
- [x] T007 Extend `frontend/lib/shared/network/api_client.dart` to parse `ErrorResponse` in `mapDioError` and accept optional `AuthApi` for refresh (stub refresh until T025)
- [x] T008 Wire `AuthApi` in `frontend/lib/main.dart` and expose via `frontend/lib/app/app_scope.dart` (`authApi` getter + constructor param)
- [x] T009 [P] Unit test `AppConfig` live mode in `frontend/test/unit/app_config_live_test.dart` — `API_MODE=live` implies `useMockApi == false`
- [x] T010 [P] Unit test `AuthApi` token exchange in `frontend/test/unit/auth_api_test.dart` using `MockAdapter` and fixture JSON (write test first; expect fail until T005)

**Checkpoint**: `AuthApi` callable; `AppScope` provides it; foundational tests exist.

---

## Phase 3: User Story 1 — Live API smoke after login (Priority: P1) 🎯 MVP

**Goal**: Sign in with real backend JWT, load profile and events from HTTP (no mock catalog).

**Independent Test**: `API_MODE=live` + local backend → dev sign-in → profile visible → events list shows seeded items or empty state; stop backend → error UI, not mock data.

### Tests for User Story 1

- [x] T011 [P] [US1] Widget test demo sign-in hidden in live mode in `frontend/test/widget/oauth_sign_in_live_test.dart`
- [x] T012 [P] [US1] Unit test minimal `UserProfile.fromJson` reads `displayName` and `homeCity` from `frontend/test/fixtures/user_profile_backend.json` in `frontend/test/unit/user_profile_mapping_test.dart`

### Implementation for User Story 1

- [x] T013 [US1] Add **Dev backend sign-in** in `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart` calling `AuthApi` with `code: dev-smoke-user` when `!config.useMockApi` and OAuth not configured
- [x] T014 [US1] Hide or disable `_demoSignIn` when `config.useMockApi` is false in `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart`
- [x] T015 [US1] Store `accessToken` and `refreshToken` from `TokenResponse` via `AuthSession.setAuthenticated` after dev exchange in `oauth_sign_in_page.dart`
- [x] T016 [US1] Update `frontend/lib/features/profile/domain/user_profile.dart` `fromJson` for backend fields `homeCity`, `aggregateRating`, `interestIds` (minimal read path for smoke)
- [x] T017 [US1] Verify `frontend/lib/features/events/data/events_repository.dart` `listEvents` maps `items` / `nextCursor` against `frontend/test/fixtures/event_list_page_backend.json`; fix mapping if test fails
- [x] T018 [US1] Run manual smoke checklist steps 1–5 in `specs/005-api-backend-integration/quickstart.md` and record pass/fail in PR description

**Checkpoint**: MVP — login → `/users/me` → `/events` works against `dotnet run` backend.

---

## Phase 4: User Story 2 — Contract-aligned requests and responses (Priority: P1)

**Goal**: Wire shapes match `shared/api-contracts/`; refresh on 401; structured errors surfaced.

**Independent Test**: Unit tests pass with contract fixtures; expired access token refreshes once; validation error shows `ErrorResponse.message`.

### Tests for User Story 2

- [x] T019 [P] [US2] Complete `frontend/test/unit/user_profile_mapping_test.dart` for full contract fields (`homeCityId`, `interestIds`, `aggregateRating`) and `toUpdateBody` / `UserProfileUpdate`
- [x] T020 [P] [US2] Unit test events list/detail mapping in `frontend/test/unit/events_repository_mapping_test.dart` with fixtures
- [x] T021 [P] [US2] Unit test `mapDioError` with `ErrorResponse` JSON in `frontend/test/unit/api_client_error_test.dart`
- [x] T022 [P] [US2] Unit test 401 → refresh → retry in `frontend/test/unit/api_client_refresh_test.dart` using `MockAdapter`

### Implementation for User Story 2

- [x] T023 [US2] Add `homeCityId` to `frontend/lib/features/profile/domain/user_profile.dart` and align `toUpdateBody` with `shared/api-contracts/users/openapi.yaml` `UserProfileUpdate`
- [x] T024 [US2] Update `frontend/lib/features/profile/data/users_repository.dart` `updateMe` to send `homeCityId` and `interestIds` (not legacy-only `homeCity` string body)
- [x] T025 [US2] Implement single-flight refresh in `frontend/lib/shared/network/api_client.dart` on 401 via `AuthApi.refresh` and one retry
- [x] T026 [US2] Update onboarding `PUT /users/me` flow in `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart` for live mode using contract update body (resolve `homeCityId` from seeder/docs or optional define)
- [x] T027 [US2] Align `frontend/lib/features/events/data/events_repository.dart` detail mapping (`_mapDetail`, `_mapSummary`) with contract `Event` schema if drift found in T020

**Checkpoint**: Contract parity for MVP endpoints; refresh and error envelope working.

---

## Phase 5: User Story 3 — Incremental feature wiring (Priority: P2)

**Goal**: Document which features stay mock in live mode; optional codegen adapter without blocking MVP.

**Independent Test**: README/quickstart matrix lists live vs mock per feature; trips/chat behavior explicit when `API_MODE=live`.

### Implementation for User Story 3

- [x] T028 [US3] Expand live vs mock matrix in `specs/005-api-backend-integration/quickstart.md` and `frontend/README.md` (auth/profile/events live; trips/chat mock)
- [x] T029 [P] [US3] Add `// Live mode: mock-only until wired` notes in `frontend/lib/features/trips/data/trips_repository.dart` and `frontend/lib/features/chats/data/stream_chat_service.dart`
- [x] T030 [US3] Optional: add `frontend/lib/features/profile/data/user_profile_contract_mapper.dart` mapping `felloway_api` `UserProfile` → domain `UserProfile` (skip if not adopting codegen in this PR)

**Checkpoint**: Contributors know scope boundaries; optional mapper documented or implemented.

---

## Phase 6: Polish & cross-cutting

**Purpose**: Docs, quality gates, full smoke including failure cases.

- [x] T031 [P] Update root `README.md` with `flutter run` live-mode example (`API_BASE_URL`, `API_MODE=live`, Android `10.0.2.2`)
- [x] T032 [P] Update `specs/005-api-backend-integration/contracts/live-integration.md` if endpoint list changed during implementation
- [x] T033 Run `dart format .` and `flutter analyze` in `frontend/`
- [x] T034 Run `flutter test` in `frontend/`
- [x] T035 Run `dotnet test backend/FelloWay.slnx`
- [x] T036 Execute quickstart smoke steps 6–7 (backend stopped → error UI; restarted → recovery) and update troubleshooting in `specs/005-api-backend-integration/quickstart.md` if needed
- [x] T037 Set `specs/005-api-backend-integration/spec.md` status to **Implemented** when all MVP checkpoints pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **blocks all user stories**
- **Phase 3 (US1)**: Depends on Phase 2 — **MVP**
- **Phase 4 (US2)**: Depends on Phase 2; best after US1 smoke path exists (T018) but tests (T019–T022) can start after T016
- **Phase 5 (US3)**: Depends on US1/US2 behavior being known; docs can parallelize late
- **Phase 6 (Polish)**: After US1 + US2 complete

### User Story Dependencies

| Story | Depends on | Independent test |
|-------|------------|------------------|
| US1 | Foundational (T004–T010) | Dev sign-in + profile + events HTTP |
| US2 | Foundational; benefits from US1 | Mapper + refresh + error unit tests |
| US3 | US1/US2 scope clarity | Docs/matrix only |

### Parallel Opportunities

- **Phase 1**: T002 ∥ T003 (after T001)
- **Phase 2**: T009 ∥ T010 (after T005)
- **US1 tests**: T011 ∥ T012
- **US2 tests**: T019 ∥ T020 ∥ T021 ∥ T022 (after fixtures)
- **US3**: T029 ∥ T030
- **Polish**: T031 ∥ T032

### Parallel Example: User Story 2 tests

```bash
# After foundational + fixtures:
flutter test test/unit/user_profile_mapping_test.dart
flutter test test/unit/events_repository_mapping_test.dart
flutter test test/unit/api_client_error_test.dart
flutter test test/unit/api_client_refresh_test.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1–2 (Setup + Foundational)
2. Complete Phase 3 (US1) through T018
3. **STOP and VALIDATE**: Manual smoke steps 1–5 on local backend
4. Demo live app against `http://localhost:5161` (or documented port)

### Incremental Delivery

1. Foundation → US1 (smoke) → US2 (contract hardening) → US3 (docs/matrix) → Polish
2. Each story adds test coverage without breaking mock mode (`API_MODE=mock`)

### Suggested MVP scope

- **In**: T001–T018 (Phases 1–3)
- **Next**: T019–T027 (US2)
- **Later**: T028–T030 (US3), T031–T037 (Polish)

---

## Notes

- Use `dev-smoke-user` or `dev-{subject}` consistent with `backend/src/FelloWay.Infrastructure/Auth/DevOAuthTokenExchanger.cs`
- Do not commit real OAuth secrets; dev exchange is for local smoke only
- Backend contract bugs discovered in smoke: fix in `backend/` only if required for MVP paths; track otherwise in follow-up issues
- Total tasks: **37** (US1: 8 impl + 2 tests; US2: 5 impl + 4 tests; US3: 3; Setup 3; Foundational 7; Polish 7)
- **T030** skipped (optional `felloway_api` mapper deferred).
- **T018 / T036** manual smoke against running backend — run locally per [quickstart.md](./quickstart.md).
- **T009** covered by existing `frontend/test/unit/app_config_api_mode_test.dart` (no duplicate file).
