# Tasks: Backend Interests Catalog

**Input**: Design documents from `/specs/011-backend-interests-catalog/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/interests-api.md](./contracts/interests-api.md)

**Tests**: Required per spec (NFR-TEST-001, NFR-FLUTTER-TEST-001).

**Organization**: User stories from spec; **catalog seed/API (US4) is Phase 2 foundational** and blocks all client stories.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable (different files, no incomplete dependencies)
- **[Story]**: US1–US4 per [spec.md](./spec.md)

## Path Conventions

- Backend: `backend/src/...`
- Contracts: `shared/api-contracts/...`
- Flutter: `frontend/lib/...`, `frontend/test/...`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Contract scaffolding and feature wiring prep.

- [X] T001 Add `shared/api-contracts/reference/openapi.yaml` with `GET /interests` and `InterestCatalogItem` schema per [contracts/interests-api.md](./contracts/interests-api.md)
- [X] T002 Extend `shared/api-contracts/users/openapi.yaml` `UserProfile` with `interests` array referencing `InterestCatalogItem`
- [X] T003 [P] Document `reference/` folder in `shared/api-contracts/README.md` domain table

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Canonical catalog in DB + public API + enriched profile DTO. **No Flutter story work until this phase completes.**

**⚠️ CRITICAL**: Blocks US1–US3.

- [X] T004 Add `SortOrder` property to `backend/src/FelloWay.Domain/Entities/Interest.cs` and `InterestConfiguration.cs`
- [X] T005 Implement `backend/src/FelloWay.Infrastructure/Persistence/Seed/InterestCatalogSeed.cs` with ten fixed GUIDs and Ukrainian names from spec FR-002
- [X] T006 Create EF migration `ReplaceInterestCatalog` in `backend/src/FelloWay.Infrastructure/Migrations/` (clear legacy interests/FKs, insert catalog seed)
- [X] T007 Implement `IInterestCatalogService` + `InterestCatalogService` in `backend/src/FelloWay.Application/Reference/`
- [X] T008 Register reference services in `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [X] T009 Implement `backend/src/FelloWay.Api/Controllers/InterestsController.cs` with `GET /interests` (`AllowAnonymous`)
- [X] T010 Extend `UserProfileDto` and `UserProfileService.Map()` in `backend/src/FelloWay.Application/Users/` to include resolved `Interests` (id, name, sortOrder)
- [X] T011 Update `backend/src/FelloWay.Api/Controllers/UsersController.cs` response mapping if needed for enriched profile
- [X] T012 Update `backend/src/FelloWay.Infrastructure/Persistence/Seed/DataSeeder.cs` to use `InterestCatalogSeed` and relink `event_interests` to new catalog ids
- [X] T013 [P] Add `backend/tests/FelloWay.Api.Tests/Reference/InterestsEndpointTests.cs` (GET returns 10 items, contains «ІТ та розробка»)
- [X] T014 Run `shared/api-contracts/scripts/generate-api-client.sh` and commit `shared/api-contracts/openapi.json` + `frontend/lib/generated/felloway_api/` per repo policy

**Checkpoint**: `curl http://localhost:5161/interests` returns 10 items; `dotnet test` InterestsEndpointTests green.

---

## Phase 3: User Story 1 — Browse official interest options (Priority: P1) 🎯 MVP

**Goal**: `/onboarding/interests` loads ten chips from `GET /interests`; no `_interestOptions` hardcoding.

**Independent Test**: Widget test with mock catalog shows 10 chips; manual onboarding page matches API names.

### Tests for User Story 1 ⚠️

- [X] T015 [P] [US1] Add widget test in `frontend/test/widget/onboarding_interests_page_test.dart` (loading → 10 chips from mock catalog)

### Implementation for User Story 1

- [X] T016 [P] [US1] Create `frontend/lib/features/onboarding/data/interests_repository.dart` with `fetchCatalog()`, session cache, and error types
- [X] T017 [US1] Wire `InterestsRepository` in `frontend/lib/app/app_scope.dart` and `frontend/lib/app/app.dart`
- [X] T018 [US1] Refactor `frontend/lib/features/onboarding/presentation/interests_page.dart` to load catalog async, show loading/error/retry, remove `_interestOptions`, store selected **ids** in `OnboardingDraft.interests`
- [X] T019 [US1] Document in `frontend/lib/features/onboarding/domain/onboarding_draft.dart` that `interests` holds catalog UUID strings

**Checkpoint**: Onboarding interests screen shows 10 Ukrainian labels from live API.

---

## Phase 4: User Story 2 — Save selected interests to profile (Priority: P1)

**Goal**: Selected catalog ids persist via `PUT /users/me` / pending onboarding flow; invalid ids rejected.

**Independent Test**: API test rejects unknown `interestId`; onboarding completion stores only valid UUIDs on server.

### Tests for User Story 2 ⚠️

- [X] T020 [P] [US2] Extend `backend/tests/FelloWay.Api.Tests/Users/UsersMeEndpointTests.cs` for invalid `interestIds` → 400 and valid ids persisted

### Implementation for User Story 2

- [X] T021 [US2] Verify `frontend/lib/features/profile/domain/user_profile.dart` `toUpdateBody()` sends only UUID `interestIds` from draft selections
- [X] T022 [US2] Verify `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart` pending registration passes draft `interests` as ids after onboarding
- [X] T023 [US2] Update `frontend/lib/features/onboarding/domain/onboarding_completion.dart` / tests in `frontend/test/unit/onboarding_completion_test.dart` to use valid UUID strings instead of `IT` labels

**Checkpoint**: Complete onboarding → `GET /users/me` returns matching `interestIds`.

---

## Phase 5: User Story 3 — View and edit interests on profile (Priority: P2)

**Goal**: Profile shows interest **names**; edit uses catalog chips like onboarding.

**Independent Test**: Profile with two interests shows two Ukrainian names; edit save updates server.

### Tests for User Story 3 ⚠️

- [X] T024 [P] [US3] Add unit test in `frontend/test/unit/interest_catalog_test.dart` for mapping `UserProfile` enriched `interests` to display labels

### Implementation for User Story 3

- [X] T025 [US3] Extend `frontend/lib/features/profile/domain/user_profile.dart` to parse `interests[]` from API (id + name) for display
- [X] T026 [US3] Update `frontend/lib/features/profile/data/users_repository.dart` mapping for enriched profile fields
- [X] T027 [US3] Update `frontend/lib/features/profile/presentation/profile_page.dart` to show interest names (not raw UUIDs)
- [X] T028 [US3] Replace free-text interests field in `frontend/lib/features/profile/presentation/profile_edit_page.dart` with catalog `FilterChip` selection (reuse repository), save via `interestIds`

**Checkpoint**: Profile view/edit round-trip matches onboarding selections.

---

## Phase 6: User Story 4 — Stable catalog for discovery (Priority: P3)

**Goal**: Fresh seed/migration yields exactly ten canonical interests; no duplicate rows on re-seed.

**Independent Test**: Empty DB after migration has 10 rows with expected fixed ids; second seed idempotent.

### Tests for User Story 4 ⚠️

- [X] T029 [P] [US4] Add test in `backend/tests/FelloWay.Api.Tests/Reference/InterestsEndpointTests.cs` asserting distinct ids and `sortOrder` 1–10

### Implementation for User Story 4

- [X] T030 [US4] Ensure `InterestCatalogSeed.ApplyAsync` in `DataSeeder` is idempotent when `interests` count already equals 10
- [X] T031 [US4] Verify dev-only legacy names (.NET, Flutter, etc.) are removed after migration in local DB documentation note in `specs/011-backend-interests-catalog/quickstart.md` if needed

**Checkpoint**: US4 acceptance scenarios pass on fresh `dotnet ef database update`.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates and manual verification.

- [X] T032 Run `dotnet build` and `dotnet test` on `backend/tests/FelloWay.Api.Tests/`
- [X] T033 Run `dart format .`, `flutter analyze`, and `flutter test` in `frontend/`
- [ ] T034 Execute manual checklist in `specs/011-backend-interests-catalog/quickstart.md` (catalog, onboarding, profile, invalid id)

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends on | Blocks |
|-------|------------|--------|
| 1 Setup | — | 2 |
| 2 Foundational | 1 | US1, US2, US3 |
| 3 US1 | 2, 14 (codegen) | US2, US3 (UI patterns) |
| 4 US2 | 2, 3 | — |
| 5 US3 | 2, 3, 14 | — |
| 6 US4 | 2 | — (mostly satisfied in Phase 2; T029–T031 verify) |
| 7 Polish | 3–6 | — |

### User Story Dependencies

| Story | Depends on | Notes |
|-------|------------|-------|
| US4 | Phase 2 | Seed/API — implement in Foundational first |
| US1 | Foundational + codegen | Browse catalog |
| US2 | US1 + Foundational | Save ids |
| US3 | US1 + Foundational | Profile display/edit |

### Parallel Opportunities

- **Phase 1**: T001 ∥ T003  
- **Phase 2**: T013 ∥ T004–T012 (after T005 migration designed)  
- **US1**: T015 ∥ T016  
- **US3**: T024 ∥ T025  
- **Polish**: T032 ∥ T033  

---

## Parallel Example: User Story 1

```bash
Task T015: "widget test onboarding_interests_page_test.dart"
Task T016: "interests_repository.dart"
# Then T017–T018 sequential
```

---

## Implementation Strategy

### MVP First (Foundational + US1)

1. Phase 1 → Phase 2 (catalog API live)  
2. Phase 3 (US1 onboarding chips)  
3. **STOP and VALIDATE** quickstart catalog + onboarding UI  

### Incremental Delivery

1. Foundational → US1 → US2 (persist) → US3 (profile) → US4 verification → Polish  

### Suggested MVP Scope

**Phases 1–3** (T001–T019): `GET /interests` + onboarding from API. Profile save/display in US2–US3.

---

## Task Summary

| Metric | Value |
|--------|-------|
| **Total tasks** | 34 |
| **Phase 1 Setup** | 3 |
| **Phase 2 Foundational** | 11 |
| **US1** | 5 |
| **US2** | 4 |
| **US3** | 5 |
| **US4** | 3 |
| **Polish** | 3 |

| User Story | Task IDs | Count |
|------------|----------|-------|
| US1 | T015–T019 | 5 |
| US2 | T020–T023 | 4 |
| US3 | T024–T028 | 5 |
| US4 | T029–T031 | 3 |

**Format validation**: All tasks use `- [ ] Tnnn [P?] [USn?] Description with file path`.

---

## Notes

- `OnboardingDraft` local storage remains for pre-login flow; authoritative data is server `interestIds` after submit (spec FR-003).  
- Regenerate OpenAPI client (T014) before Flutter repository uses generated types (optional: hand-written DTO until codegen lands).  
- Event `interest` query filter mapping to catalog is out of scope.
