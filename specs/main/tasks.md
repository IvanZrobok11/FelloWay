# Tasks: LinkedIn BFF auth fix + auth refactor

**Input**: Design documents from `specs/main/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Included per constitution and spec NFR-003 (regression for production defect).

**Organization**: Tasks grouped by user story. MVP = User Story 1 (split-host web sign-in works on dev).

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm baseline and environment mapping before code changes.

- [x] T001 Verify feature branch and capture current prod trace (login → `/auth/success?ticket=` → 401) in `specs/main/quickstart.md` notes section if needed
- [x] T002 [P] Record dev/test/prod web + API CloudFront hostnames and map to `infra/terraform/environments/{dev,test,prod}/main.tf` `web_origin_url` / ECS env vars
- [x] T003 [P] Run baseline `dotnet test` in `backend/tests/FelloWay.Api.Tests/` and `flutter test` in `frontend/test/`; note failing/passing auth tests

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Single, explicit auth completion model before story work. **Blocks all user stories.**

**⚠️ CRITICAL**: No user story implementation until this phase is complete.

- [x] T004 Add `WebAuthMode` enum (`splitHostJwt`, `sameOriginCookie`) in `frontend/lib/features/auth/domain/web_auth_mode.dart` derived from `isCrossOriginApi(config.apiBaseUrl)` in `frontend/lib/features/auth/web/bff_ticket_from_browser.dart`
- [x] T005 Implement `AuthCompletionService` in `frontend/lib/features/auth/application/auth_completion_service.dart` with methods: `completeFromTicket(ticket)`, `probeCookieSession()` (same-origin only), `shouldProbeCookieSession`
- [x] T006 Wire `AuthCompletionService` into `frontend/lib/app/app_scope.dart` (or equivalent DI) and expose via `AppScope`
- [x] T007 [P] Add unit tests for `WebAuthMode` + `AuthCompletionService` routing in `frontend/test/unit/auth_completion_service_test.dart` (split-host MUST NOT call cookie probe)
- [x] T008 [P] Add failing regression test: split-host + ticket present → `completeFromTicket` called, `getSession` not called in `frontend/test/unit/auth_completion_service_test.dart`

**Checkpoint**: Auth completion rules centralized; tests define expected behavior.

---

## Phase 3: User Story 1 — Sign in with LinkedIn (split-host web) (Priority: P1) 🎯 MVP

**Goal**: User completes LinkedIn BFF on split-host Flutter web and reaches events/profile authenticated (no redirect loop to `/sign-in`).

**Independent Test**: On dev web host, complete LinkedIn login → Network shows `POST /auth/linkedin/mobile/complete` **2xx** → `GET /users/me` **200** with Bearer; no required `GET /auth/session`.

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T009 [P] [US1] Extend `frontend/test/unit/bff_ticket_from_browser_test.dart` for cross-origin detection with prod-like hostnames
- [x] T010 [P] [US1] Widget/unit test: `OAuthBffSuccessPage` calls ticket completion when `WebAuthMode.splitHostJwt` in `frontend/test/unit/oauth_bff_success_page_test.dart`
- [x] T011 [US1] Backend: add/extend test invalid ticket returns 400 in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs` (if not already covered)

### Implementation for User Story 1

- [x] T012 [US1] Refactor `frontend/lib/main.dart` to use `AuthCompletionService` for ticket bootstrap; remove silent catch that hides ticket redeem failures
- [x] T013 [US1] Refactor `frontend/lib/app/router/app_router.dart` redirect: skip `syncWebCookieSession` when `WebAuthMode.splitHostJwt`; allow `/auth/success` with ticket
- [x] T014 [US1] Refactor `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart` (`OAuthBffSuccessPage`): single path via `AuthCompletionService.completeFromTicket`; remove split-host `getMe()` cookie fallback (lines ~374–393)
- [x] T015 [US1] Fix `frontend/lib/main.dart` + `frontend/lib/app/app.dart`: when `WebAuthMode.splitHostJwt`, disable cookie-based API auth (`useCookieAuthOnWeb: false`) so `ApiClient` uses Bearer from `TokenStorage` after ticket redeem
- [x] T016 [P] [US1] Ensure `frontend/lib/shared/network/api_client.dart` always attaches Bearer when token present (verify no regression for split-host)
- [x] T017 [US1] Remove duplicate ticket redeem from `frontend/lib/features/profile/presentation/profile_page.dart` if it calls `syncWebCookieSession` inappropriately for split-host
- [x] T018 [US1] Verify `frontend/lib/features/auth/data/auth_api.dart` `completeLinkedInMobile` works without credentialed cookies (CORS simple POST); add clear error mapping for 400 ticket errors
- [x] T019 [P] [US1] Backend: confirm `backend/src/FelloWay.Api/Program.cs` `UseForwardedHeaders` runs before auth and OAuth redirect generation; add integration test asserting callback redirect Location uses `https://` when `X-Forwarded-Proto: https` in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T020 [US1] Backend: review `backend/src/FelloWay.Api/Auth/LinkedInBffAuthHandler.cs` web branch always issues ticket (not cookie-only) for split-host; align comments with spec FR-015

**Checkpoint**: Dev split-host web LinkedIn sign-in passes independent test.

---

## Phase 4: User Story 2 — Operator setup (dev / test / prod) (Priority: P2)

**Goal**: Operators can configure and verify LinkedIn BFF on **dev**, **test**, and **prod** (no staging).

**Independent Test**: Follow `specs/main/quickstart.md` smoke checklist on each env; all three pass.

### Tests for User Story 2

- [x] T021 [P] [US2] Add CORS regression test: configured web origin receives `Access-Control-Allow-Origin` on OPTIONS/POST to `/auth/linkedin/mobile/complete` in `backend/tests/FelloWay.Api.Tests/Cors/CorsPolicyTests.cs`

### Implementation for User Story 2

- [x] T022 [P] [US2] Verify `infra/terraform/modules/ecs/main.tf` sets `Cors__AllowedOrigins__0` and `Frontend__BaseUrl` from `var.web_origin_url` for dev/test/prod
- [x] T023 [P] [US2] Verify `infra/terraform/modules/api_cdn/main.tf` CloudFront: `viewer_protocol_policy = redirect-to-https` and `X-Forwarded-Proto` custom header; document in `specs/main/quickstart.md`
- [x] T024 [US2] Update `specs/main/quickstart.md` with concrete env hostnames (dev/test/prod web + API CloudFront URLs) and LinkedIn redirect URI list
- [x] T025 [US2] Update `backend/README.md` CORS + LinkedIn BFF section referencing `specs/main/quickstart.md`
- [x] T026 [US2] Update `frontend/README.md` web BFF flow (ticket handoff, no `/auth/session` on split-host)
- [ ] T027 [US2] Manual smoke dev → test → prod per `specs/main/quickstart.md` smoke checklist; record results in PR description

**Checkpoint**: All three environments pass operator smoke.

---

## Phase 5: Polish & Auth refactor (Cross-Cutting)

**Purpose**: Simplify auth code paths; remove unjustified conditions; keep mobile BFF working.

- [x] T028 [P] Consolidate ticket read logic: single helper used by `main.dart`, `app_router.dart`, `OAuthBffSuccessPage` in `frontend/lib/features/auth/web/bff_ticket_from_browser.dart`
- [x] T029 [P] Rename or alias `AuthApi.completeLinkedInMobile` → `completeBffTicket` with deprecated alias in `frontend/lib/features/auth/data/auth_api.dart` (update call sites)
- [x] T030 Simplify `frontend/lib/app/auth/auth_session.dart`: `syncWebCookieSession` only callable when `WebAuthMode.sameOriginCookie`; document in dartdoc
- [x] T031 [P] Remove dead/legacy LinkedIn PKCE client paths if still referenced (grep `flutter_appauth`, `exchangeLinkedIn` on sign-in UI) in `frontend/lib/features/auth/` — no `flutter_appauth` in lib; `exchangeLinkedIn` retained only for dev backend sign-in
- [x] T032 [P] Backend: extract redirect URL builder using forwarded headers into small helper in `backend/src/FelloWay.Api/Auth/` if `LinkedInBffAuthHandler` grows; keep handler thin
- [x] T033 Run `flutter analyze` and `dart format` in `frontend/`; fix any new issues
- [x] T034 Run `dotnet test` in `backend/tests/`; fix regressions
- [x] T035 Align `specs/main/spec.md` User Story 1 acceptance text with BFF flow (optional doc-only) to remove PKCE wording conflict

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **blocks US1 and US2**
- **Phase 3 (US1)**: Depends on Phase 2 — **MVP**
- **Phase 4 (US2)**: Depends on Phase 2; can overlap US1 after T012–T015 land
- **Phase 5 (Polish)**: Depends on US1 complete; US2 smoke (T027) ideally before merge

### User Story Dependencies

- **US1 (P1)**: No dependency on US2; delivers user-visible fix
- **US2 (P2)**: Infra/docs validation; can run parallel with US1 implementation after Phase 2

### Within US1

1. Tests T009–T011 (fail first)
2. Foundational service (Phase 2) must be done
3. T012–T020 implementation
4. Validate dev smoke before test/prod

### Parallel Opportunities

- T002, T003 (Setup)
- T007, T008 (Foundational tests)
- T009, T010, T011 (US1 tests)
- T016, T019 (US1 backend/frontend parallel)
- T021–T023 (US2 infra/docs parallel)
- T028–T032 (Polish refactor parallel)

---

## Parallel Example: User Story 1

```bash
# Tests in parallel:
T009  frontend/test/unit/bff_ticket_from_browser_test.dart
T010  frontend/test/unit/oauth_bff_success_page_test.dart
T011  backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs

# Implementation in parallel after tests fail:
T016  frontend/lib/shared/network/api_client.dart
T019  backend/tests/... + Program.cs forwarded headers
```

---

## Implementation Strategy

### MVP First (User Story 1 on dev only)

1. Complete Phase 1–2
2. Complete Phase 3 (US1) through T020
3. **STOP and VALIDATE**: dev smoke per quickstart (ticket POST + `/users/me` 200)
4. Then Phase 4 for test/prod operator verification

### Incremental Delivery

1. Foundation → US1 dev fix (MVP)
2. US2 test + prod smoke + docs
3. Polish refactor + spec alignment

---

## Notes

- Root cause: split-host web treated cookie session as primary; `/auth/session` 401 is expected cross-origin.
- Infra may already set `X-Forwarded-Proto` in `infra/terraform/modules/api_cdn/main.tf`; still verify OAuth redirect uses `https://` (T019).
- Environments: **dev**, **test**, **prod** only — no staging.
- [P] tasks = different files, no ordering conflict within the same phase checkpoint.
