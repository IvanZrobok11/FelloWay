# Tasks: Remove mock and local-only client runtime paths

**Input**: Design documents from `/specs/015-remove-mock-local/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/live-only-client-policy.md](./contracts/live-only-client-policy.md)

**Tests**: Included per spec NFR-TEST-001 / NFR-FLUTTER-TEST-001 and constitution.

**Organization**: Tasks grouped by user story. Complete **Foundational (Phase 2)** before repository/auth removal in US1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks in same story)
- **[Story]**: US1, US2, US3 per [spec.md](./spec.md)

## Path Conventions

- Flutter app: `frontend/lib/`, `frontend/test/`, `frontend/integration_test/`
- CI: `.github/workflows/`
- Docs: `frontend/README.md`, `specs/015-remove-mock-local/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm scope and baseline before deletions.

- [x] T001 Review [spec.md](./spec.md), [plan.md](./plan.md), and [contracts/live-only-client-policy.md](./contracts/live-only-client-policy.md) for live-only scope (lib/ only; backend tests out of scope)
- [x] T002 Run baseline inventory: `rg "useMockApi|MockApiCatalog|ApiMode\.mock|demoSignIn" frontend/lib` and record hit list in PR description
- [x] T003 Confirm feature branch `015-remove-mock-local` and `flutter pub get` in `frontend/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Remove `ApiMode` / `useMockApi` from configuration; fail fast without `API_BASE_URL`. **Blocks all user stories.**

**⚠️ CRITICAL**: Complete before stripping repository mock branches (US1).

- [x] T004 Delete `frontend/lib/app/config/api_mode.dart` and remove `apiMode`, `useMockApi`, `isDemoBackend`, `_parseApiMode`, and `example.com` auto-mock logic from `frontend/lib/app/config/app_config.dart`
- [x] T005 Require non-empty `apiBaseUrl` in `frontend/lib/app/config/app_config_loader.dart` (or `main.dart`) with error text referencing CI `--dart-define=API_BASE_URL`; remove `https://api.example.com` as silent default
- [x] T006 Remove `example.com` → `localhost:7086` fallback in `AppConfig.linkedInBffCallbackUriForApi` in `frontend/lib/app/config/app_config.dart`
- [x] T007 Update `frontend/lib/main.dart`, `frontend/lib/app/app.dart`, and `frontend/lib/features/auth/domain/web_auth_mode.dart` to stop passing or reading `useMockApi`
- [x] T008 [P] Delete `frontend/test/unit/app_config_api_mode_test.dart` and add `frontend/test/unit/app_config_live_only_test.dart` asserting live config has no mock getter
- [x] T009 [P] Add or extend `frontend/test/unit/app_config_loader_test.dart`: empty `API_BASE_URL` throws with deploy-oriented message

**Checkpoint**: Project compiles only after US1 repository work; config layer is live-only.

---

## Phase 3: User Story 1 - One real API path in every shipped build (Priority: P1) 🎯 MVP

**Goal**: All product data/auth paths use live HTTP only; no demo catalogs, demo sign-in, or chat `demoSkipped`.

**Independent Test**: Deployed dev build — sign in via LinkedIn BFF; events/profile show API data or explicit errors; no demo sign-in button; Chats does not show demo API hint.

### Tests for User Story 1

- [x] T010 [P] [US1] Add `frontend/test/unit/live_only_lib_policy_test.dart` (or extend existing) failing if `frontend/lib` imports `shared/mocks` or defines `useMockApi`
- [x] T011 [P] [US1] Update `frontend/test/widget/app_smoke_test.dart` to use `AppConfig` without `ApiMode.mock`
- [x] T012 [P] [US1] Add or update `frontend/test/widget/oauth_sign_in_live_test.dart` to assert no `demoSignIn` / local-backend button in widget tree

### Implementation for User Story 1

- [x] T013 [P] [US1] Remove all `useMockApi` branches and `MockApiCatalog` imports from `frontend/lib/features/events/data/events_repository.dart`; remove `mock_event_attendance_store` usage
- [x] T014 [P] [US1] Remove all `useMockApi` branches from `frontend/lib/features/trips/data/trips_repository.dart`
- [x] T015 [P] [US1] Remove all `useMockApi` branches from `frontend/lib/features/profile/data/users_repository.dart`
- [x] T016 [US1] Remove mock branch and `StreamChatConnectStatus.demoSkipped` from `frontend/lib/features/chats/data/stream_chat_service.dart`
- [x] T017 [US1] Remove `demoSkipped` UI branch from `frontend/lib/features/chats/presentation/chats_list_page.dart`
- [x] T018 [P] [US1] Remove `useMockApi` guards from `frontend/lib/features/profile/presentation/profile_page.dart`
- [x] T019 [US1] Delete `frontend/lib/shared/mocks/mock_api_catalog.dart`, `frontend/lib/shared/mocks/mock_event_attendance_store.dart`, `frontend/lib/features/events/data/demo_events.dart`, `frontend/lib/features/trips/data/demo_trips.dart`, `frontend/lib/features/profile/data/demo_reviews.dart`
- [x] T020 [US1] Remove `_demoSignIn`, `_devBackendSignIn`, and `useMockApi` UI branches from `frontend/lib/features/auth/presentation/oauth_sign_in_page.dart`; simplify onboarding completion (`pushDraft`, `homeCityId`) to live-only paths
- [x] T021 [P] [US1] Remove `demoSignIn` and `chatsDemoHint` from `frontend/lib/l10n/app_en.arb` and `frontend/lib/l10n/app_uk.arb`; run `flutter gen-l10n` in `frontend/`
- [x] T022 [US1] Fix compile errors across `frontend/lib/` from deleted symbols; run `flutter analyze` in `frontend/`

**Checkpoint**: `rg useMockApi frontend/lib` and `rg shared/mocks frontend/lib` return no matches; US1 independently verifiable on deployed dev.

---

## Phase 4: User Story 2 - Operators have a single configuration model (Priority: P2)

**Goal**: Documentation and CI describe one live-only deploy model—no mock/auto/local product workflows.

**Independent Test**: Read `frontend/README.md` — no `API_MODE=mock` or localhost `flutter run` matrix as supported product path; CI still builds with env URLs + Stream key.

### Implementation for User Story 2

- [x] T023 [P] [US2] Rewrite `frontend/README.md`: remove API modes section and local/mock `flutter run` examples; point operators to [quickstart.md](./quickstart.md) and `013` deploy config
- [x] T024 [P] [US2] Audit `.github/workflows/deploy.yml`, `promote-test.yml`, `promote-prod.yml`: keep `--dart-define=API_MODE=live` or remove define once client ignores it; add comment that client is live-only
- [x] T025 [US2] Update `specs/015-remove-mock-local/contracts/live-only-client-policy.md` verification table if implementation choices differ from plan
- [x] T026 [P] [US2] Grep repo docs: `rg "API_MODE=mock" specs/ frontend/README.md` — add “superseded by 015” notes in `specs/001-event-networking-app/quickstart.md`, `specs/005-api-backend-integration/quickstart.md`, `specs/011-backend-interests-catalog/quickstart.md` where still referenced

**Checkpoint**: New engineers find only deployed dev smoke in primary README paths.

---

## Phase 5: User Story 3 - Support triages without mock/local red herrings (Priority: P3)

**Goal**: Troubleshooting guides never recommend mock mode, demo sign-in, or local-only tokens.

**Independent Test**: Walk [quickstart.md](./quickstart.md) troubleshooting tree — zero steps mention enabling mock or demo auth.

### Implementation for User Story 3

- [x] T027 [US3] Expand troubleshooting decision tree in `specs/015-remove-mock-local/quickstart.md` (empty data → API/deploy, not mock; auth → BFF/OAuth, not demo sign-in)
- [x] T028 [P] [US3] Add operator grep checklist to `specs/015-remove-mock-local/quickstart.md` matching [contracts/live-only-client-policy.md](./contracts/live-only-client-policy.md) static checks
- [x] T029 [P] [US3] Cross-link `specs/013-clarify-env-json/quickstart.md` if it still mentions mock/local client paths

**Checkpoint**: Support docs aligned with live-only policy.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Test suite green, integration tests updated, deployed validation.

- [x] T030 [P] Update `frontend/test/unit/auth_completion_service_test.dart`, `frontend/test/unit/oauth_bff_success_page_test.dart`, and other tests referencing `useMockApi` or `ApiMode`
- [x] T031 [P] Update `frontend/integration_test/us1_discover_join_test.dart` and `frontend/integration_test/us2_chat_navigation_test.dart` `AppConfig` constructors for live-only config
- [x] T032 Move any needed demo JSON/maps into `frontend/test/fixtures/` if widget tests break after demo module deletion
- [x] T033 Run `dart format .` and `flutter test` in `frontend/`; fix failures
- [x] T034 Run `flutter analyze` in `frontend/` with zero errors
- [x] T035 [P] Run static policy grep from [quickstart.md](./quickstart.md) (`useMockApi`, `MockApiCatalog`, `ApiMode.mock` in `lib/`)
- [ ] T036 Manual deployed dev smoke per [quickstart.md](./quickstart.md) (sign-in → events → profile → interests → chats; no demo controls)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS US1–US3 code changes**
- **US1 (Phase 3)**: Depends on Foundational — **MVP**
- **US2 (Phase 4)**: Depends on Foundational; can parallel US1 after T004–T007 if docs-only, but README should reflect final code
- **US3 (Phase 5)**: Depends on US2 quickstart/README themes; can start after US1 checkpoint
- **Polish (Phase 6)**: Depends on US1 complete minimum; full pass after US2–US3

### User Story Dependencies

- **US1 (P1)**: Requires Phase 2 — delivers live-only runtime
- **US2 (P2)**: Requires config/repo decisions from US1 for accurate README
- **US3 (P3)**: Requires US2 doc tone; troubleshooting references final behavior

### Within User Story 1

- T010–T012 (tests) may be written first (expect fail until T013–T021)
- T013–T015 repositories [P] in parallel
- T019 deletes files after repositories no longer import them
- T020–T021 auth + l10n after repositories compile

### Parallel Opportunities

- **Phase 2**: T008 ∥ T009
- **US1**: T010 ∥ T011 ∥ T012; T013 ∥ T014 ∥ T015; T018 ∥ T021 after T019
- **US2**: T023 ∥ T024 ∥ T026
- **US3**: T027 ∥ T028 ∥ T029
- **Polish**: T030 ∥ T031 ∥ T032; T035 ∥ T036 (manual)

---

## Parallel Example: User Story 1

```bash
# Repository stripping in parallel (after Phase 2):
T013 events_repository.dart
T014 trips_repository.dart
T015 users_repository.dart

# Tests in parallel before or during implementation:
T010 live_only_lib_policy_test.dart
T011 app_smoke_test.dart
T012 oauth_sign_in_live_test.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1–2 (config live-only)
2. Complete Phase 3 (US1) through T022
3. **STOP and VALIDATE**: `flutter test`, grep `lib/`, deployed dev smoke (T036 partial)
4. Merge when US1 acceptance scenarios pass

### Incremental Delivery

1. Setup + Foundational → config ready
2. US1 → live API path (MVP)
3. US2 → operator docs + CI comments
4. US3 → support quickstart
5. Polish → full test matrix + manual smoke

### Parallel Team Strategy

- Developer A: Phase 2 + US1 repositories (T013–T019)
- Developer B: US1 auth/l10n (T020–T021) after T004–T007
- Developer C: US2 docs (T023–T026) after US1 checkpoint

---

## Notes

- Do **not** remove backend InMemory/Testcontainers tests (out of scope)
- `frontend/web/env.json.example` may be deleted or left with deprecated note — prefer delete if unused (optional subtask under T023)
- `.vscode/launch.json` is maintainer-only; not required for acceptance
- Commit after each phase checkpoint; run `flutter test` before PR
