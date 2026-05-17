---

description: "Task list for Event Networking Mobile MVP (Flutter client only)"
---

# Tasks: Event Networking Mobile MVP

**Input**: Design documents from `/specs/001-event-networking-app/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Required per story: write failing tests first, then implement.

**Organization**: Phases follow spec priorities (US1 → US2 → US3), then cross-cutting polish (plan P4).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallel-friendly (different files, no ordering dependency)
- **[Story]**: `US1`, `US2`, `US3`, or `-` for shared

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, l10n, repo layout, CI alignment with constitution

- [x] T001 [-] Create `lib/app/`, `lib/features/{auth,onboarding,events,map,chats,profile,trips}/`, `lib/shared/` per [plan.md](./plan.md)
- [x] T002 [-] Add dependencies in `pubspec.yaml`: `flutter_appauth`, `flutter_secure_storage`, HTTP client (e.g. `dio`), router (e.g. `go_router`), Stream Chat Flutter SDK, `flutter_localizations`; enable `generate: true` for l10n
- [x] T003 [P] [-] Add `l10n.yaml` and `lib/l10n/app_en.arb`, `lib/l10n/app_uk.arb` with shell strings (welcome, tabs, common actions)
- [x] T004 [P] [-] Configure `analysis_options.yaml` / `flutter_lints` for project standards; document `dart format` + `flutter analyze` in CI or `specs/.../quickstart.md`
- [x] T005 [P] [-] Add `test/unit/`, `test/widget/`, `test/golden/`, `integration_test/` placeholders and a smoke `test/widget/app_smoke_test.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: App shell, config, API client, session — **no user story work before this completes**

**⚠️ CRITICAL**: Blocks all of US1–US3

- [x] T006 [-] Implement root `MaterialApp` / theme in `lib/app/theme/app_theme.dart` and wire in `lib/app/app.dart`
- [x] T007 [-] Implement environment config (e.g. `--dart-define=API_BASE_URL=`) in `lib/app/config/app_config.dart`
- [x] T008 [-] Implement secure token read/write in `lib/features/auth/data/token_storage.dart` using `flutter_secure_storage`
- [x] T009 [-] Implement REST client with auth header injection and 401 → refresh/re-login handling in `lib/shared/network/api_client.dart` (contracts in [contracts/rest-endpoints.md](./contracts/rest-endpoints.md))
- [x] T010 [-] Implement app router with authenticated vs guest redirects in `lib/app/router/app_router.dart` (shell route for four tabs)
- [x] T011 [-] Implement main tab shell (Events, Map, Chats, Profile) in `lib/app/shell/main_shell.dart`
- [x] T012 [P] [-] Add shared error/empty/loading widgets in `lib/shared/widgets/`
- [x] T013 [P] [-] Add shared domain errors and `Result`-style handling in `lib/shared/errors/`
- [x] T014 [-] Wire `main.dart` to `App` + router + localization delegates

**Checkpoint**: Cold start shows shell; unauthenticated users can reach guest-safe routes per spec

---

## Phase 3: User Story 1 — Join and Discover Events (Priority: P1) 🎯 MVP

**Goal**: Onboarding S1–S4 (S1: welcome with get started + log in; OAuth on `/sign-in` and other CTAs), personalized event list with pagination/search, guest vs signed-in card behavior, event detail, join/unjoin, map discovery (FR-003–FR-008, FR-021, FR-001–FR-002, FR-005–FR-006)

**Independent Test**: New user completes onboarding, sees event list, opens detail, joins; guest is prompted to sign in on join

### Tests for User Story 1 (REQUIRED) ⚠️

> Write these tests **first**; they MUST fail before implementation

- [x] T015 [P] [US1] Unit tests for onboarding completion guard in `test/unit/onboarding_completion_test.dart`
- [x] T016 [P] [US1] Widget tests for onboarding steps S1–S4 in `test/widget/onboarding_flow_test.dart`
- [x] T017 [P] [US1] Widget tests for event card guest vs authenticated preview in `test/widget/event_card_visibility_test.dart`
- [x] T018 [US1] Integration test: guest browse → sign-in prompt on join in `integration_test/us1_discover_join_test.dart` (mock API or staging)

### Implementation for User Story 1

- [x] T019 [P] [US1] Domain models `Event`, `EventSummary`, `AttendStatus` in `lib/features/events/domain/event.dart`
- [x] T020 [US1] `EventsRepository` + DTO mapping in `lib/features/events/data/events_repository.dart` (`GET /events`, `GET /events/{id}`, attend/delete attend)
- [x] T021 [US1] OAuth sign-in flow (LinkedIn/Facebook) in `lib/features/auth/presentation/oauth_sign_in_page.dart` using `flutter_appauth`
- [x] T022 [US1] Onboarding S1 welcome (hero, get started → S2, log in → `/sign-in`) in `lib/features/onboarding/presentation/welcome_page.dart`; OAuth providers remain on `oauth_sign_in_page.dart` (T021)
- [x] T023 [US1] Onboarding S2 display name in `lib/features/onboarding/presentation/name_page.dart` (local draft; no API until post-OAuth sync)
- [x] T024 [US1] Onboarding S3 interests/hobbies chips in `lib/features/onboarding/presentation/interests_page.dart`
- [x] T025 [US1] Onboarding S4 cascade city in `lib/features/onboarding/presentation/city_page.dart` + save draft → `/sign-in`; post-OAuth `GET`/`PUT /users/me` in `oauth_sign_in_page.dart`
- [x] T026 [US1] Events list with infinite scroll + search (name/tag/city) in `lib/features/events/presentation/events_list_page.dart`
- [x] T027 [US1] Event detail: required fields, optional fields, participant list, join/unjoin in `lib/features/events/presentation/event_detail_page.dart`
- [x] T028 [US1] Guest blur / sign-in CTA on detail per PRD in `lib/features/events/presentation/event_detail_page.dart`
- [x] T029 [US1] Map tab: map SDK setup, event markers, date/interest filters, popup → navigate to event in `lib/features/map/presentation/map_page.dart`
- [x] T030 [US1] Profile tab read-only MVP: avatar, name, links, interests, rating display from `GET /users/me` in `lib/features/profile/presentation/profile_page.dart`
- [x] T031 [US1] Verify UX/a11y (semantics, contrast) on onboarding + list + detail
- [x] T032 [US1] Verify list scroll and image loading performance (caching, pagination batch size)

**Checkpoint**: US1 acceptance scenarios in [spec.md](./spec.md) pass

---

## Phase 4: User Story 2 — Communicate with Event Participants (Priority: P2)

**Goal**: Chats tab via Stream SDK: event-wide channel, DM between co-attendees; after unjoin, remove event/trip channels; DM history read-only (FR-009–FR-012, FR-010–FR-011)

**Independent Test**: Joined user opens event chat and DM; after unjoin, event chat gone, old DM visible without composer

### Tests for User Story 2 (REQUIRED) ⚠️

- [x] T033 [P] [US2] Unit tests for chat access rules (joined vs left) in `test/unit/chat_access_policy_test.dart`
- [x] T034 [P] [US2] Widget test for chats tab empty/loading states in `test/widget/chats_tab_test.dart`
- [x] T035 [US2] Integration test: open channel from event context in `integration_test/us2_chat_navigation_test.dart` (Stream test env or mock)

### Implementation for User Story 2

- [x] T036 [US2] Stream client bootstrap (token from backend) in `lib/features/chats/data/stream_chat_service.dart`
- [x] T037 [US2] Chats list (event, trip, DM) in `lib/features/chats/presentation/chats_list_page.dart`
- [x] T038 [US2] Channel route wrapper for event-wide chat in `lib/features/chats/presentation/channel_page.dart`
- [x] T039 [US2] Start DM from attendee profile / event participants in `lib/features/chats/presentation/dm_launcher.dart`
- [x] T040 [US2] Enforce unjoin: disconnect/remove event + trip channels; DM read-only composer lock in `lib/features/chats/application/chat_access_controller.dart` (or equivalent state layer)
- [x] T041 [US2] Report message/user entry points (UI + `POST` report when contract finalized) in `lib/features/chats/presentation/report_sheet.dart`
- [x] T042 [US2] Block user action from profile/chat (`POST /users/{id}/block`) in `lib/features/profile/presentation/block_user_action.dart`
- [x] T043 [US2] Verify UX consistency with shared widgets and l10n for chat errors
- [x] T044 [US2] Verify chat list scroll performance under typical channel count

**Checkpoint**: US2 acceptance scenarios in [spec.md](./spec.md) pass

---

## Phase 5: User Story 3 — Coordinate Travel in Local Trip Chats (Priority: P3)

**Goal**: Event “Trips” section: list trips, create trip (route, time, role, cap 20), join requests, auto vs manual approval UI, low-rating warning for owner (FR-013–FR-018, FR-024)

**Independent Test**: Participant sees trips, creates one, joins another; same-city auto-approve; other-city pending until approve

### Tests for User Story 3 (REQUIRED) ⚠️

- [x] T045 [P] [US3] Unit tests for join approval mode (city match vs manual) in `test/unit/trip_join_policy_test.dart`
- [x] T046 [P] [US3] Widget test for trip create form validation in `test/widget/trip_create_form_test.dart`
- [x] T047 [US3] Widget test for pending requests list + low-rating banner in `test/widget/trip_requests_test.dart`

### Implementation for User Story 3

- [x] T048 [P] [US3] Domain models `TripChat`, `TripJoinRequest`, transport role enum in `lib/features/trips/domain/trip_chat.dart`
- [x] T049 [US3] `TripsRepository` in `lib/features/trips/data/trips_repository.dart` (`POST /events/{id}/trips`, `POST /trips/{id}/join`, `POST /trips/{id}/approve/{userId}`)
- [x] T050 [US3] Trips section on event detail in `lib/features/trips/presentation/event_trips_section.dart`
- [x] T051 [US3] Create trip flow in `lib/features/trips/presentation/create_trip_page.dart`
- [x] T052 [US3] Join request + cancel request UI in `lib/features/trips/presentation/trip_join_flow.dart`
- [x] T053 [US3] Owner inbox: approve + show requester rating warning in `lib/features/trips/presentation/trip_owner_requests_page.dart`
- [x] T054 [US3] Open Stream trip channel after membership granted in `lib/features/trips/presentation/trip_channel_opener.dart`
- [x] T055 [US3] Support multiple trip chats per event (navigation + list state)
- [x] T056 [US3] Verify UX/a11y for trips section and forms
- [x] T057 [US3] Verify no N+1 network patterns on trip list refresh

**Checkpoint**: US3 acceptance scenarios in [spec.md](./spec.md) pass

---

## Phase 6: Polish & Cross-Cutting (Plan P4)

**Purpose**: Push, notification preferences, post-event feedback, reviews UI, hardening

- [x] T058 [P] [-] Foreground/background push handling + deep link to chat/event in `lib/app/notifications/push_handler.dart`
- [x] T059 [-] Profile: per-chat / global notification toggles UI + API sync in `lib/features/profile/presentation/notification_settings_page.dart`
- [x] T060 [-] Post-event feedback screen (stars + optional text) + `POST` review in `lib/features/profile/presentation/event_feedback_page.dart`
- [x] T061 [-] User profile: reviews list from `GET /users/{id}/reviews` in `lib/features/profile/presentation/reviews_list.dart`
- [x] T062 [-] Profile edit: avatar upload flow + `POST /users/me/avatar` in `lib/features/profile/presentation/profile_edit_page.dart`
- [x] T063 [-] Golden tests for event card and onboarding chrome in `test/golden/event_card_golden_test.dart`
- [x] T064 [P] [-] Cross-story UX + accessibility audit (tabs, focus order, screen reader labels)
- [x] T065 [P] [-] Update [quickstart.md](./quickstart.md) with flavors, defines, and device checklists
- [x] T066 [-] Run full `dart format .`, `flutter analyze`, `flutter test`, and `integration_test/` on CI target

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5 (US3)** → **Phase 6** → **Phase 7 (optional hardening)** → **Phase 8 (optional map clustering rework)**
- US2/US3 assume US1 event join + profile data exist; still keep access-policy logic testable in isolation
- **Phase 7** depends on Phase 6 (or any build where repositories exist); can start after T020+T049+T036 are present
- **Phase 8** depends on map foundation from US1 (T029) and can start after Phase 3; recommended after Phase 7 to reuse consolidated mock/live behavior

### Within Each User Story

- Tests before implementation
- Domain models before repositories
- Repositories before UI pages
- Story checkpoint before starting next priority

### Parallel Opportunities

- T003/T004/T005 in Phase 1
- T012/T013 alongside T006–T011 in Phase 2
- T015/T016/T017 parallel in US1 tests
- T033/T034 parallel in US2 tests
- T045/T046 parallel in US3 tests
- T058/T063/T064/T065 in Phase 6 where independent
- **Phase 7**: T070/T071/T072/T073 after T069; T071–T073 parallel once T070 exists; T077 parallel with parts of T076
- **Phase 8**: T082/T083 can run in parallel after T081; T086/T087 can run in parallel after T084

---

## Phase 7: API mocks & config-driven networking (cross-cutting)

**Purpose**: One explicit **mock vs live** switch in config; **all REST-shaped services** (`EventsRepository`, `UsersRepository`, `TripsRepository`, `StreamChatService` token fetch) use the same rule; **no stray** URL-only checks scattered in widgets. Enables `API_BASE_URL` pointing at a real host while still forcing mocks for UI work, or the opposite.

**Context**: Today `AppConfig.isDemoBackend` is `apiBaseUrl.contains('example.com')`, with duplicate mock branches in repositories **and** several presentation files. This phase centralizes behavior and adds **`--dart-define`** overrides.

**Independent test**: With `API_MODE=mock`, app runs offline-capable lists/detail/profile/trips/chat-tab states without hitting real HTTP; with `API_MODE=live` and a non-demo base URL, repositories call `ApiClient.dio` only (Stream still requires key + token endpoint per existing rules).

### Tests for Phase 7

- [x] T067 [P] [-] Unit tests for API mode resolution (defines + URL fallback) in `test/unit/app_config_api_mode_test.dart`

### Implementation for Phase 7

- [x] T068 [-] Add `ApiMode` (`mock` / `live`) and parsing from `--dart-define=API_MODE=mock|live` in `lib/app/config/app_config.dart`; document precedence: explicit `API_MODE` wins; else **mock** if base URL matches legacy demo heuristic (`example.com`); else **live**
- [x] T069 [-] Expose a single predicate e.g. `bool get useMockApi` on `AppConfig` and deprecate or alias `isDemoBackend` to it; update all `lib/` call sites to use the new name
- [x] T070 [-] Create `lib/shared/mocks/mock_api_catalog.dart` (or `lib/shared/mocks/` split by domain) holding shared maps/DTOs for events, event detail, users/me, trips, join requests, stream-token shape; migrate bodies from `lib/features/events/data/demo_events.dart` and `lib/features/trips/data/demo_trips.dart` into this layer
- [x] T071 [P] [-] Refactor `lib/features/events/data/events_repository.dart` to branch on `useMockApi` only and import mock payloads from `lib/shared/mocks/` (remove duplicated inline JSON where any)
- [x] T072 [P] [-] Refactor `lib/features/profile/data/users_repository.dart` to branch on `useMockApi` only and use `lib/shared/mocks/` for stub profile, reviews, avatar, preferences responses
- [x] T073 [P] [-] Refactor `lib/features/trips/data/trips_repository.dart` to branch on `useMockApi` only and use `lib/shared/mocks/` (re-export from `demo_trips` if kept as thin wrappers)
- [x] T074 [-] Refactor `lib/features/chats/data/stream_chat_service.dart` so mock/demo skip and token `GET` behavior follow `useMockApi` (not a separate URL substring rule inconsistent with T068)
- [x] T075 [-] Remove redundant presentation-layer mock branches in `lib/features/events/presentation/events_list_page.dart`, `event_detail_page.dart`, `lib/features/map/presentation/map_page.dart`, `lib/features/profile/presentation/profile_page.dart`, `profile_edit_page.dart`, `event_feedback_page.dart`, `reviews_list.dart` — UI should consume repository/`Future` results only so mock vs live is one pipeline
- [x] T076 [-] Update `lib/main.dart`, `lib/features/auth/presentation/oauth_sign_in_page.dart` (if it keys off demo mode), and every `AppConfig(` / `FellowayApp(` construction in `test/**` and `integration_test/**` for the new config API
- [x] T077 [P] [-] Document `API_MODE`, `API_BASE_URL`, Stream key, and mock behavior in `specs/001-event-networking-app/quickstart.md` and `TECH_PLAN.md`
- [x] T078 [P] [-] Add a short note to `specs/001-event-networking-app/contracts/rest-endpoints.md` that the client may satisfy these contracts via in-process mocks when `API_MODE=mock`
- [x] T079 [-] Run `dart format .`, `flutter analyze`, and `flutter test`; fix any regressions from Phase 7 refactors

**Checkpoint**: Mock vs live is **only** controlled via `AppConfig` / dart-defines; repositories + stream token path are aligned; widgets do not re-implement demo data.

---

## Phase 8: Maps menu rework with clustering (US1 extension)

**Purpose**: Rework `Map` tab to use zoom-aware marker clustering with smooth transitions:
- low zoom: big clusters with event counts (e.g. `24 events`)
- medium zoom: smaller proximity clusters
- high zoom: disable clustering and show individual event markers with names
- dynamic updates on zoom/pan with animated transitions between states

**Independent test**: On a map with many events, pinch-zoom from far to near and pan around; verify cluster counts collapse/expand correctly and individual named markers appear at high zoom without stale cluster artifacts.

### Tests for Phase 8

- [x] T080 [P] [US1] Add map clustering unit tests (distance bucketing, zoom thresholds, cluster label text) in `test/unit/map_cluster_engine_test.dart`
- [x] T081 [P] [US1] Add widget test for map state transitions (low→medium→high zoom cluster rendering contract) in `test/widget/map_clustering_state_test.dart`

### Implementation for Phase 8

- [x] T082 [US1] Introduce map marker domain models (`MapMarkerNode`, `MapClusterNode`, `MapViewport`) in `lib/features/map/domain/map_marker_node.dart`
- [x] T083 [US1] Implement clustering engine service (`cluster(points, zoom, bounds)`) with low/medium/high zoom behavior in `lib/features/map/application/map_cluster_engine.dart`
- [x] T084 [US1] Add map camera state/controller (`zoom`, `bounds`, debounced move callbacks) in `lib/features/map/application/map_camera_controller.dart`
- [x] T085 [US1] Refactor `lib/features/map/presentation/map_page.dart` to render cluster markers and event markers from cluster engine output instead of a plain list fallback
- [x] T086 [P] [US1] Add localized cluster count label (e.g. `{count} events`) in `lib/l10n/app_en.arb`, `lib/l10n/app_uk.arb` and regenerate l10n (`lib/l10n/app_localizations*.dart`)
- [x] T087 [P] [US1] Implement smooth transition behavior (fade/scale or marker tween between cluster states) in `lib/features/map/presentation/widgets/map_cluster_marker.dart`
- [x] T088 [US1] Wire dynamic recalculation on zoom and pan, including throttling to avoid jank, in `lib/features/map/presentation/map_page.dart` + `lib/features/map/application/map_camera_controller.dart`
- [x] T089 [US1] Ensure high zoom disables clustering and displays individual event name markers in `lib/features/map/presentation/map_page.dart`
- [x] T090 [US1] Validate performance on dense datasets (frame times, recalculation frequency) and adjust thresholds in `lib/features/map/application/map_cluster_engine.dart`
- [x] T091 [US1] Run `dart format .`, `flutter analyze`, and map-related tests (`test/unit/map_cluster_engine_test.dart`, `test/widget/map_clustering_state_test.dart`)

**Checkpoint**: Map tab behavior is zoom-aware and animated; cluster counts are accurate at low zoom, broken down at medium zoom, and replaced by individual named markers at high zoom.

---

## Notes

- Backend and admin web are **out of scope**; use mocks or staging per [plan.md](./plan.md)
- Map provider (Google vs Mapbox) per [research.md](./research.md) — complete before T029
- Stream channel IDs and token endpoint: align with backend when available
- **Phase 7**: Optional follow-on to harden mock/live switching; does not replace shipped Phases 1–6
- **Phase 8**: Optional US1 extension focused on map UX quality and discoverability with clustering transitions
