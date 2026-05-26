# Tasks: Remove backend development OAuth token exchange

**Input**: Design documents from `/specs/016-remove-dev-oauth-backend/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/oauth-token-exchange-policy.md](./contracts/oauth-token-exchange-policy.md)

**Tests**: Included per spec NFR-TEST-001, FR-006, and user-story acceptance scenarios.

**Organization**: Tasks grouped by user story. **US1 (production exchanger) MUST complete before US3 (test harness)** so rejection logic exists before re-wiring CI helpers.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks in same story)
- **[Story]**: US1, US2, US3 per [spec.md](./spec.md)

## Path Conventions

- API: `backend/src/FelloWay.Infrastructure/`, `backend/src/FelloWay.Api/`
- Tests: `backend/tests/FelloWay.Api.Tests/`
- Docs: `specs/016-remove-dev-oauth-backend/`, `specs/005-api-backend-integration/`, `specs/main/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm scope and baseline before production auth changes.

- [x] T001 Review [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md), and [contracts/oauth-token-exchange-policy.md](./contracts/oauth-token-exchange-policy.md)
- [x] T002 Run baseline inventory: `rg "DevOAuthTokenExchanger|CompositeOAuthTokenExchanger|dev-smoke-user" backend` and record hit list for PR description
- [x] T003 Confirm feature branch `016-remove-dev-oauth-backend` and `dotnet restore` on `backend/FelloWay.slnx`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared test infrastructure types used by US1 verification and US3 migration. **No user-story completion until US1 production code lands.**

**⚠️ CRITICAL**: US1 production exchanger (Phase 3) blocks US3 factory registration validation.

- [x] T004 [P] Add `backend/tests/FelloWay.Api.Tests/Auth/TestOAuthTokenExchanger.cs` with dev-code exchange logic moved from `DevOAuthTokenExchanger.cs` (accept `dev-*`, `test-code`; linkedin + facebook)
- [x] T005 [P] Add `backend/tests/FelloWay.Api.Tests/Auth/TestAuthExtensions.cs` with shared `LoginAsync(HttpClient, string subject)` posting to `/auth/oauth/linkedin/token`

**Checkpoint**: Test-only types exist; production DI still unchanged until US1.

---

## Phase 3: User Story 1 - Deployed sign-in uses only real OAuth (Priority: P1) 🎯 MVP

**Goal**: Production API rejects development OAuth codes and enforces LinkedIn BFF when configured; no JWT from `dev-*` on deployed hosts.

**Independent Test**: `POST /auth/oauth/linkedin/token` with `dev-smoke-user` returns 4xx on host using production exchanger only; LinkedIn BFF sign-in on deployed dev still yields working Bearer session.

### Tests for User Story 1

- [x] T006 [P] [US1] Add `backend/tests/FelloWay.Api.Tests/Infrastructure/ProductionOAuthWebApplicationFactory.cs` extending `FelloWayWebApplicationFactory` **without** registering `TestOAuthTokenExchanger` (production `IOAuthTokenExchanger` only)
- [x] T007 [P] [US1] Add `backend/tests/FelloWay.Api.Tests/Infrastructure/LinkedInConfiguredProductionOAuthFactory.cs` with LinkedIn secrets set and **no** test exchanger override
- [x] T008 [US1] Update `backend/tests/FelloWay.Api.Tests/Auth/OAuthDevCodeRejectionTests.cs`: `DevCode_*` expects **4xx**; keep `RealLinkedInCode_ReturnsBadRequest_*` on `LinkedInConfiguredProductionOAuthFactory`
- [x] T009 [US1] Update `backend/tests/FelloWay.Api.Tests/Auth/OAuthDevCodeWithoutSecretsTests.cs` to use `ProductionOAuthWebApplicationFactory` and assert dev code **rejected** (not OK)

### Implementation for User Story 1

- [x] T010 [US1] Add `backend/src/FelloWay.Infrastructure/Auth/ProductionOAuthTokenExchanger.cs` per [research.md](./research.md) R2: reject `dev-*`/`test-code`; reject facebook; LinkedIn configured → BFF message; LinkedIn not configured → configuration error
- [x] T011 [US1] Update `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`: register `IOAuthTokenExchanger` → `ProductionOAuthTokenExchanger` only; remove `DevOAuthTokenExchanger` registration
- [x] T012 [US1] Delete `backend/src/FelloWay.Infrastructure/Auth/DevOAuthTokenExchanger.cs` and `backend/src/FelloWay.Infrastructure/Auth/CompositeOAuthTokenExchanger.cs`
- [x] T013 [US1] Delete `backend/src/FelloWay.Infrastructure/Auth/OAuthDevCode.cs` or inline `IsDevCode` rejection privately in `ProductionOAuthTokenExchanger.cs` only
- [x] T014 [US1] Run `dotnet test backend/tests/FelloWay.Api.Tests/FelloWay.Api.Tests.csproj --filter "FullyQualifiedName~OAuthDevCode"` and fix failures until US1 tests pass (expect broader suite red until US3)

**Checkpoint**: `rg DevOAuthTokenExchanger backend/src` empty; production-only rejection tests green; full API suite may still fail until US3.

---

## Phase 4: User Story 3 - Automated tests remain reliable without shipping dev auth (Priority: P3)

**Goal**: CI obtains JWTs via test-project `TestOAuthTokenExchanger` only; no development exchanger in Infrastructure.

**Independent Test**: `dotnet test` on API solution green; `FelloWayWebApplicationFactory` swaps `IOAuthTokenExchanger` to `TestOAuthTokenExchanger`.

**Note**: Implement immediately after US1; do not defer—endpoint tests depend on this.

### Tests for User Story 3

- [x] T015 [P] [US3] Add `backend/tests/FelloWay.Api.Tests/Auth/ProductionOAuthPolicyTests.cs` (or extend policy test): assert `backend/src` contains no `DevOAuthTokenExchanger` and `DependencyInjection.cs` does not register it

### Implementation for User Story 3

- [x] T016 [US3] Register `TestOAuthTokenExchanger` in `backend/tests/FelloWay.Api.Tests/Infrastructure/FelloWayWebApplicationFactory.cs` via `RemoveAll<IOAuthTokenExchanger>()` + `AddScoped<IOAuthTokenExchanger, TestOAuthTokenExchanger>()`
- [x] T017 [US3] Register `TestOAuthTokenExchanger` in `backend/tests/FelloWay.Api.Tests/Infrastructure/PostgresWebApplicationFactory.cs` the same way
- [x] T018 [P] [US3] Refactor `backend/tests/FelloWay.Api.Tests/Admin/AdminEventsEndpointTests.cs` to use `TestAuthExtensions.LoginAsync`
- [x] T019 [P] [US3] Refactor `backend/tests/FelloWay.Api.Tests/Users/UsersMeEndpointTests.cs` to use `TestAuthExtensions.LoginAsync`
- [x] T020 [P] [US3] Refactor `backend/tests/FelloWay.Api.Tests/Events/EventAttendEndpointTests.cs` to use `TestAuthExtensions.LoginAsync`
- [x] T021 [P] [US3] Refactor `backend/tests/FelloWay.Api.Tests/Users/TrustAndPrefsEndpointTests.cs` to use `TestAuthExtensions.LoginAsync`
- [x] T022 [P] [US3] Refactor `backend/tests/FelloWay.Api.Tests/Trips/TripJoinFlowEndpointTests.cs` to use `TestAuthExtensions.LoginAsync`
- [x] T023 [US3] Verify `backend/tests/FelloWay.Api.Tests/Auth/OAuthTokenEndpointTests.cs` still passes (`test-code`, facebook `dev-refresh-user` via test exchanger)
- [x] T024 [US3] Verify `backend/tests/FelloWay.Api.Tests/Chat/StreamTokenEndpointTests.cs` and `backend/tests/FelloWay.Api.Tests/Integration/PostgresApiIntegrationTests.cs` still pass with test exchanger
- [x] T025 [US3] Run `dotnet test backend/FelloWay.slnx --filter "Category!=Integration"` and fix any remaining dev-login failures

**Checkpoint**: Full fast API test suite green with zero `DevOAuthTokenExchanger` in `backend/src`.

---

## Phase 5: User Story 2 - Operators have one auth troubleshooting model (Priority: P2)

**Goal**: Runbooks and HTTP examples do not recommend `dev-smoke-user` on deployed API; failures point to OAuth secrets / BFF.

**Independent Test**: `rg "dev-smoke-user" specs/005 specs/main backend/src` shows no operator sign-in instructions; `FelloWay.Api.http` documents BFF path.

### Implementation for User Story 2

- [x] T026 [P] [US2] Update `backend/src/FelloWay.Api/FelloWay.Api.http`: remove `dev-smoke-user` token example; add comment pointing to `GET /auth/linkedin/login` BFF
- [x] T027 [US2] Supersede dev sign-in section in `specs/005-api-backend-integration/quickstart.md` with link to [016 quickstart](./quickstart.md) and [oauth-token-exchange-policy.md](./contracts/oauth-token-exchange-policy.md)
- [x] T028 [P] [US2] Update `specs/main/quickstart.md` auth section: remove “Sign in (local backend)” / `dev-smoke-user` steps; reference LinkedIn BFF and 016 policy
- [x] T029 [P] [US2] Add superseded note in `specs/005-api-backend-integration/plan.md` (dev live sign-in paragraph) pointing to 016

**Checkpoint**: VR-004 satisfied via doc grep; operators see single auth model.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validation, static gates, deployed smoke.

- [x] T030 Run `dotnet test backend/FelloWay.slnx` (full solution including Application.Tests)
- [x] T031 [P] Static gate: `rg "DevOAuthTokenExchanger|CompositeOAuthTokenExchanger" backend/src` → no matches
- [x] T032 [P] Static gate: `rg "dev-smoke-user" backend/src specs/005-api-backend-integration` → no operator sign-in examples (016 quickstart negative test allowed)
- [ ] T033 Manual deployed dev smoke per [quickstart.md](./quickstart.md) VR-001: `dev-smoke-user` → 4xx; LinkedIn BFF → `GET /users/me` 200
- [x] T034 [P] Mark completed items in this `tasks.md` and note coordination: ship with or after `015-remove-mock-local` on same deploy

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: After Setup — creates test-only types (T004–T005)
- **User Story 1 (Phase 3)**: After Foundational — production exchanger + production-only rejection tests
- **User Story 3 (Phase 4)**: **After US1** — factory swap + endpoint test refactors restore CI
- **User Story 2 (Phase 5)**: After US1 (can parallel with US3 doc-safe tasks T026–T029)
- **Polish (Phase 6)**: After US1 + US3 (+ US2 for VR-004)

### User Story Dependencies

| Story | Depends on | Delivers |
|-------|------------|----------|
| **US1 (P1)** | Phase 2 | Production rejection; MVP for deploy security |
| **US3 (P3)** | US1 | Green `dotnet test`; test exchanger only in tests |
| **US2 (P2)** | US1 (conceptually) | Operator docs aligned |

### Within Each User Story

- US1: Write/update rejection tests (T006–T009) → implement production exchanger (T010–T013) → run filtered tests (T014)
- US3: Factory registration (T016–T017) → refactor endpoint tests (T018–T024) → full fast suite (T025)
- US2: HTTP file + spec quickstarts (T026–T029) in parallel where marked [P]

### Parallel Opportunities

- **Phase 2**: T004 ∥ T005
- **US1 tests**: T006 ∥ T007 (before T008–T009)
- **US3 refactors**: T018–T022 all [P] after T016–T017
- **US2 docs**: T026 ∥ T028 ∥ T029
- **Polish**: T031 ∥ T032

---

## Parallel Example: User Story 3

```bash
# After T016–T017, refactor endpoint tests in parallel:
# AdminEventsEndpointTests.cs, UsersMeEndpointTests.cs, EventAttendEndpointTests.cs,
# TrustAndPrefsEndpointTests.cs, TripJoinFlowEndpointTests.cs
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1–2
2. Complete Phase 3 (US1) — production exchanger + rejection tests
3. **STOP**: Deploy API image to dev; verify `dev-smoke-user` fails (VR-001 partial)
4. Do **not** consider feature done until US3 restores CI

### Incremental Delivery

1. Setup + Foundational → test types ready
2. US1 → deployed API secure (dev codes rejected)
3. US3 → CI green
4. US2 → operator docs
5. Polish → full validation + manual smoke

### Suggested PR split (optional)

- PR1: US1 + US3 (code + tests)
- PR2: US2 docs only (or same PR if small)

---

## Task Summary

| Phase | Task IDs | Count |
|-------|----------|-------|
| Setup | T001–T003 | 3 |
| Foundational | T004–T005 | 2 |
| US1 (P1) | T006–T014 | 9 |
| US3 (P3) | T015–T025 | 11 |
| US2 (P2) | T026–T029 | 4 |
| Polish | T030–T034 | 5 |
| **Total** | **T001–T034** | **34** |

### Per user story

| Story | Tasks | Independent test |
|-------|-------|------------------|
| US1 | 9 (T006–T014) | Dev code 4xx on production factory; BFF unchanged |
| US3 | 11 (T015–T025) | `dotnet test` green; no dev exchanger in src |
| US2 | 4 (T026–T029) | Docs grep: no dev-smoke operator path |

### MVP scope

**User Story 1 (T006–T014)** — minimum to secure deployed API; follow immediately with **US3 (T015–T025)** before merge.

---

## Notes

- `StreamChatService` dev stream tokens when misconfigured remain **out of scope** (see [plan.md](./plan.md)).
- `POST /auth/testing/web-session` stays Testing-only; unrelated to OAuth dev codes.
- `LinkedInBffLoginTests.cs` should remain green; no dev-code dependency expected.
- Coordinate deploy with `015-remove-mock-local` so client and API auth policy align.
