---
description: "Task list for LinkedIn BFF OAuth sign-in (009-linkedin-bff-auth)"
---

# Tasks: LinkedIn Sign-In via Backend-Controlled Flow (BFF)

**Input**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/linkedin-bff-oauth-flow.md](./contracts/linkedin-bff-oauth-flow.md), [quickstart.md](./quickstart.md)

**Organization**: Tasks grouped by user story. **MVP** = Phase 1–3 (US1). Phases A–C largely implemented; **Phase 7** closes FR-016 (HTTPS-only local) and test/doc gaps.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Packages and configuration for BFF LinkedIn (`AddLinkedIn`).

- [x] T001 Add `AspNet.Security.OAuth.LinkedIn` package reference in `backend/src/FelloWay.Api/FelloWay.Api.csproj`
- [x] T002 Add `flutter_web_auth_2` dependency in `frontend/pubspec.yaml` (mobile only; no web import)
- [x] T003 [P] Set **HTTPS-only** `OAuth:LinkedIn`, `Frontend:BaseUrl`, and sample values in `backend/src/FelloWay.Api/appsettings.json` and `appsettings.Development.json` per `specs/009-linkedin-bff-auth/quickstart.md`
- [x] T004 [P] Set `Cors:AllowedOrigins` to **HTTPS** Flutter web origins only in `backend/src/FelloWay.Api/appsettings.Development.json`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: `AddLinkedIn`, cookies, JWT policy scheme, mobile tickets, client wrappers.

**⚠️ CRITICAL**: No user story work until this phase is complete.

- [x] T005 Implement `MobileAuthTicketStore` in `backend/src/FelloWay.Infrastructure/Auth/MobileAuthTicketStore.cs`
- [x] T006 Register `IMobileAuthTicketStore` in `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [x] T007 Implement `AddLinkedIn`, `AddCookie(WebSession)`, and Smart policy scheme in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T008 Enable `AllowCredentials()` in `backend/src/FelloWay.Api/Extensions/CorsExtensions.cs`
- [x] T009 Implement `LinkedInBffAuthHandler.HandleTicketReceived` (claims → user, cookie/ticket redirects) in `backend/src/FelloWay.Api/Auth/LinkedInBffAuthHandler.cs`
- [x] T010 Wire `AddFelloWayAuthentication` in `backend/src/FelloWay.Api/Program.cs`
- [x] T011 [P] Add credentialed `dio` (`withCredentials` on web) in `frontend/lib/features/auth/data/dio_credentials.dart` and `auth_api.dart`
- [x] T012 [P] Create `frontend/lib/features/auth/mobile/linkedin_bff_auth.dart` with `kIsWeb` guard
- [x] T013 [P] Create `frontend/lib/features/auth/web/linkedin_bff_web_auth_web.dart` (+ stub) for same-window API login
- [x] T014 Add `/auth/success` route in `frontend/lib/app/router/app_router.dart`

**Checkpoint**: Foundation ready.

---

## Phase 3: User Story 1 — Sign in with LinkedIn (Priority: P1) 🎯 MVP

**Goal**: BFF sign-in — web cookie, mobile JWT — no client LinkedIn codes (FR-001–FR-009).

**Independent Test**: HTTPS local quickstart §4 (web) + §5 (mobile): login → success → `GET /users/me` authenticated.

### Tests for User Story 1 (REQUIRED)

- [x] T015 [P] [US1] API test: `GET /auth/linkedin/login` returns 503 when secrets missing in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T016 [P] [US1] API tests: mobile ticket complete happy path, invalid ticket, single-use in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T017 [P] [US1] API test: web callback sets session `Set-Cookie` (test handler or integration) in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T018 [P] [US1] Extend `FelloWayWebApplicationFactory.cs` with LinkedIn-configured host and cookie client helpers in `backend/tests/FelloWay.Api.Tests/Infrastructure/FelloWayWebApplicationFactory.cs`
- [x] T019 [P] [US1] Widget test: LinkedIn button launches BFF login URL (mock) in `frontend/test/widget/oauth_sign_in_bff_test.dart`
- [x] T020 [P] [US1] Unit test: mobile ticket/error URI parsing in `frontend/test/unit/linkedin_bff_auth_test.dart`

### Implementation for User Story 1

- [x] T021 [US1] Implement `GET /auth/linkedin/login` with `Challenge(LinkedInAuthenticationDefaults.AuthenticationScheme)` in `backend/src/FelloWay.Api/Controllers/AuthController.cs`
- [x] T022 [US1] Implement `POST /auth/linkedin/mobile/complete` in `backend/src/FelloWay.Api/Controllers/AuthController.cs`
- [x] T023 [US1] Remove legacy `GET /auth/oauth/linkedin/callback` code-forward from `backend/src/FelloWay.Api/Controllers/AuthController.cs`
- [x] T024 [US1] Configure `AddLinkedIn` callback `/auth/linkedin/callback` and event hooks in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T025 [US1] Reject real LinkedIn codes when BFF configured in `backend/src/FelloWay.Infrastructure/Auth/CompositeOAuthTokenExchanger.cs`
- [x] T026 [P] [US1] Implement `completeLinkedInMobile` in `frontend/lib/features/auth/data/auth_api.dart`
- [x] T027 [US1] Refactor BFF paths in `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart`
- [x] T028 [US1] Implement `FlutterWebAuth2.authenticate` in `frontend/lib/features/auth/mobile/linkedin_bff_auth.dart`
- [x] T029 [US1] Implement web same-window login in `frontend/lib/features/auth/web/linkedin_bff_web_auth_web.dart`
- [x] T030 [US1] Implement `OAuthBffSuccessPage` + cookie/JWT completion in `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart`
- [x] T031 [US1] Android intent-filter `com.felloway.app` auth callback in `frontend/android/app/src/main/AndroidManifest.xml`
- [x] T032 [US1] iOS URL scheme for auth callback in `frontend/ios/Runner/Info.plist`
- [x] T033 [US1] L10n loading/error strings in `frontend/lib/l10n/app_en.arb` and `app_uk.arb`

**Checkpoint**: US1 functional; complete T017–T019 and HTTPS Phase 7 before release sign-off.

---

## Phase 4: User Story 2 — Stay signed in (Priority: P2)

**Goal**: Session persists across navigation/restart until expiry or sign-out.

**Independent Test**: Sign in once; reload app/tab; protected routes work; expired session returns to sign-in.

### Tests for User Story 2 (REQUIRED)

- [x] T034 [P] [US2] API test: authenticated `GET /users/me` with session cookie after sign-in in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T035 [P] [US2] API test: mobile refresh token works after BFF `IssueTokensForUserAsync` in `backend/tests/FelloWay.Api.Tests/Auth/LinkedInBffLoginTests.cs`
- [x] T036 [P] [US2] Unit test: `AuthSession` persistence in `frontend/test/unit/auth_session_bff_test.dart`

### Implementation for User Story 2

- [x] T037 [US2] Policy scheme forwards Cookie vs JWT in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T038 [US2] Web API client sends credentials in `frontend/lib/app/` / `auth_api.dart`
- [x] T039 [US2] Mobile uses `TokenStorage` only; web uses `setAuthenticatedFromCookie` in `frontend/lib/app/auth/auth_session.dart`
- [x] T040 [US2] Expired cookie/JWT redirects to `/sign-in` with message in `frontend/lib/app/router/app_router.dart`
- [x] T041 [US2] Optional `GET /auth/session` probe in `backend/src/FelloWay.Api/Controllers/AuthController.cs`

**Checkpoint**: US2 complete when T034–T036 and T040 pass.

---

## Phase 5: User Story 3 — Operator and developer verification (Priority: P3)

**Goal**: HTTPS quickstart, OpenAPI, smoke validation (FR-013, FR-016).

**Independent Test**: Follow `quickstart.md` on local HTTPS + staging without code changes.

### Tests for User Story 3

- [x] T042 [P] [US3] API test: `dev-{subject}` accepted when LinkedIn secrets **absent** in `backend/tests/FelloWay.Api.Tests/Auth/OAuthDevCodeWithoutSecretsTests.cs`

### Implementation for User Story 3

- [x] T043 [P] [US3] Document BFF routes in `shared/api-contracts/auth/openapi.yaml`
- [x] T044 [US3] Update BFF examples to **HTTPS** URLs in `backend/src/FelloWay.Api/FelloWay.Api.http`
- [x] T045 [US3] HTTPS operator steps in `specs/009-linkedin-bff-auth/quickstart.md`
- [x] T046 [US3] Add BFF vs dev sign-in section in `frontend/README.md`
- [x] T047 [US3] Manual HTTPS smoke checklist in `specs/009-linkedin-bff-auth/SMOKE_RESULTS.md` (copy to PR when run)

**Checkpoint**: Operators can configure LinkedIn portal + local HTTPS per quickstart.

---

## Phase 6: Polish & Cross-Cutting (Legacy removal)

**Purpose**: Remove superseded client-OAuth artifacts (FR-017); CI green.

- [x] T048 [P] Remove `oauth_pkce.dart`, `linked_in_web_auth.dart`, `oauth_browser*.dart`, `oauth_native_support.dart` under `frontend/lib/features/auth/`
- [x] T049 [P] Remove `LinkedInOAuthTokenExchanger` registration from `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [x] T050 Remove `LinkedInOAuthTokenExchanger.cs`, `LinkedInOAuthReturnOriginParser.cs`, and obsolete tests under `backend/tests/FelloWay.Api.Tests/Auth/`
- [x] T051 [P] Remove AppAuth `RedirectUriReceiverActivity` from `frontend/android/app/src/main/AndroidManifest.xml`
- [x] T052 Run `dotnet test backend/tests/FelloWay.Api.Tests/FelloWay.Api.Tests.csproj` and fix failures
- [x] T053 Run `flutter analyze` and `flutter test test/unit/ test/widget/` in `frontend/` and fix failures (incl. T019 widget test)
- [x] T054 Cross-story UX audit: cancel/deny paths and accessibility on `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart`

---

## Phase 7: HTTPS-only local alignment (FR-016) 🎯 Release blocker

**Purpose**: Plan Phase D — all documented/default local URLs use `https://`.

- [x] T055 [P] Set `Frontend:BaseUrl` and CORS to `https://localhost:7357` in `backend/src/FelloWay.Api/appsettings.Development.json`
- [x] T056 [P] Make `https` launch profile default; document `dotnet run --launch-profile https` in `backend/src/FelloWay.Api/Properties/launchSettings.json` comments or README
- [x] T057 [P] Replace HTTP fallbacks with HTTPS in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs` and `LinkedInBffAuthHandler.cs`
- [x] T058 [P] Default VS Code launch to HTTPS API in `frontend/.vscode/launch.json`; remove or demote HTTP-only config for BFF
- [x] T059 [P] Ensure `frontend/lib/app/config/app_config.dart` defaults and deprecations reference HTTPS BFF base URL
- [x] T060 [P] Remove deprecated `OAUTH_REDIRECT_URL` dart-defines from launch configs where BFF uses server `/auth/linkedin/callback`
- [x] T061 [US3] Manual smoke steps documented in `specs/009-linkedin-bff-auth/SMOKE_RESULTS.md` + `quickstart.md` (operator execution)
- [x] T062 Run full auth test filter: `dotnet test --filter "FullyQualifiedName~Auth"` and `flutter analyze`

**Checkpoint**: FR-016 satisfied in config, code fallbacks, docs, and smoke.

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends on | Blocks |
|-------|------------|--------|
| 1 Setup | — | 2 |
| 2 Foundational | 1 | 3–7 |
| 3 US1 (P1) | 2 | MVP demo |
| 4 US2 (P2) | 3 sign-in | — |
| 5 US3 (P3) | 3 routes | — |
| 6 Polish | 3 | — |
| 7 HTTPS | 1, 3 | Release |

### User Story Dependencies

| Story | Depends on | Independent test |
|-------|------------|------------------|
| US1 (P1) | Foundational | quickstart §4–5 |
| US2 (P2) | US1 working | reload + `/users/me` |
| US3 (P3) | US1 stable | quickstart full path |

### Within User Story 1

1. T015–T020 tests (T017–T019 still open)
2. Backend T021–T025 ✅
3. Flutter T026–T033 ✅

---

## Parallel Execution Examples

### Phase 7 (HTTPS)

```text
Parallel: T055 appsettings | T058 launch.json | T059 app_config
Then: T057 AuthExtensions | T061 manual smoke
```

### User Story 1 (remaining tests)

```text
Parallel: T017 cookie test | T019 widget test | T018 factory helpers
```

### User Story 3 (docs)

```text
Parallel: T044 FelloWay.Api.http | T046 frontend/README.md
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2 ✅ (finish T003–T004 in Phase 7)
2. Complete Phase 3 implementation ✅; close T017–T019
3. **VALIDATE**: quickstart HTTPS §4–5
4. Phase 7 before staging/production LinkedIn rollout

### Suggested MVP Scope

**Minimum shippable**: Phases 1–3 implementation + T015–T016 + T020 + Phase 7 (T055–T062).

**Full feature**: + Phase 4–6 + all test tasks.

---

## Task Summary

| Phase | Task IDs | Total | Done (approx.) |
|-------|----------|-------|----------------|
| Setup | T001–T004 | 4 | 2 |
| Foundational | T005–T014 | 10 | 10 |
| US1 | T015–T033 | 19 | 15 |
| US2 | T034–T041 | 8 | 4 |
| US3 | T042–T047 | 6 | 2 |
| Polish | T048–T054 | 7 | 5 |
| HTTPS (FR-016) | T055–T062 | 8 | 0 |
| **Total** | **T001–T062** | **62** | **38** |

| User Story | Tasks | Open |
|------------|-------|------|
| US1 | T015–T033 | T017–T019 |
| US2 | T034–T041 | T034–T036, T040 |
| US3 | T042–T047, T061 | T042, T044, T046–T047, T061 |

**Parallel opportunities**: T003–T004, T017–T019, T034–T036, T055–T060, T043–T046.

**Format validation**: All tasks use `- [x]` or `- [x]` + `T###` + optional `[P]` + optional `[US#]` + file path.
