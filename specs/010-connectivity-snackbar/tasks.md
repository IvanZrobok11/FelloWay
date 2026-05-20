# Tasks: Connectivity SnackBar

**Input**: Design documents from `/specs/010-connectivity-snackbar/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/connectivity-snack-bar-api.md](./contracts/connectivity-snack-bar-api.md)

**Tests**: Required per spec (NFR-FLUTTER-TEST-001) and tasks template — failing-first unit + widget tests.

**Organization**: Tasks grouped by user story for independent implementation and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to spec user stories US1–US4

## Path Conventions

All paths relative to `frontend/` (package `felloway_client`).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Localization keys required by snack bar content.

- [X] T001 Add `connectivityActionUnavailable` to `lib/l10n/app_en.arb` and `lib/l10n/app_uk.arb` per [contracts/connectivity-snack-bar-api.md](./contracts/connectivity-snack-bar-api.md)
- [X] T002 Run `flutter gen-l10n` in `frontend/` and verify `lib/l10n/app_localizations*.dart` includes `connectivityActionUnavailable`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Connectivity error classification used by integrations (US4). Blocks US4 only; US1–US3 can proceed after Phase 1.

**⚠️ CRITICAL**: Complete before US4 integration tasks.

- [X] T003 Implement `isConnectivityDioException` and `isConnectivityFailure` in `lib/shared/errors/connectivity_failure.dart` per [data-model.md](./data-model.md) ConnectivityFailureSignal table

**Checkpoint**: Classification API ready; widget work (US1–US3) can proceed in parallel with T003 after Phase 1.

---

## Phase 3: User Story 1 — Understand why an action failed (Priority: P1) 🎯 MVP

**Goal**: User sees a standardized floating dark snack bar with wifi-off icon and localized connectivity message when an action fails offline.

**Independent Test**: Pump test harness, call `ConnectivitySnackBar.show`, find icon + `connectivityActionUnavailable` text + `SnackBarBehavior.floating`; manual offline tap on any integrated screen.

### Tests for User Story 1 ⚠️

> **NOTE: Write test first; ensure it FAILS before T005.**

- [X] T004 [P] [US1] Add widget test for show, `Icons.wifi_off`, localized message, and floating behavior in `test/widget/connectivity_snack_bar_test.dart`

### Implementation for User Story 1

- [X] T005 [US1] Implement `ConnectivitySnackBar.show` in `lib/shared/widgets/connectivity_snack_bar.dart` with `SnackBarBehavior.floating`, `RoundedRectangleBorder(borderRadius: 12)`, `backgroundColor: Color(0xFF212121)`, `duration: 4s`, `Row` content (icon + spacing + l10n text)
- [X] T006 [US1] Add `Semantics(liveRegion: true)` on snack bar content in `lib/shared/widgets/connectivity_snack_bar.dart` (align with `lib/shared/widgets/error_display.dart`)

**Checkpoint**: US1 independently testable via widget test + manual `show` from a scaffold test screen.

---

## Phase 4: User Story 2 — Dismiss without waiting (Priority: P2)

**Goal**: User can close the notification immediately via a close control.

**Independent Test**: Widget test taps close → snack bar hidden before 4s timer.

### Tests for User Story 2 ⚠️

- [X] T007 [P] [US2] Extend `test/widget/connectivity_snack_bar_test.dart` to assert close action dismisses snack bar before timeout

### Implementation for User Story 2

- [X] T008 [US2] Add close `InkWell` with `Icons.close` calling `hideCurrentSnackBar` in `lib/shared/widgets/connectivity_snack_bar.dart`

**Checkpoint**: US1 + US2 both pass widget tests.

---

## Phase 5: User Story 3 — Rapid repeated actions do not stack (Priority: P2)

**Goal**: Multiple rapid `show` calls produce at most one visible snack bar.

**Independent Test**: Widget test calls `show` twice; assert single snack bar / `clearSnackBars` behavior.

### Tests for User Story 3 ⚠️

- [X] T009 [P] [US3] Extend `test/widget/connectivity_snack_bar_test.dart` to assert double `show` does not stack (clear-before-show)

### Implementation for User Story 3

- [X] T010 [US3] Call `ScaffoldMessenger.of(context).clearSnackBars()` before `showSnackBar` in `lib/shared/widgets/connectivity_snack_bar.dart`

**Checkpoint**: US1–US3 complete; core widget contract satisfied.

---

## Phase 6: User Story 4 — Simple integration for action handlers (Priority: P3)

**Goal**: Developers invoke one `show` (or classifier + show) from API error handlers; reference screens use connectivity UI for offline failures.

**Independent Test**: Unit test Dio type matrix; profile edit / create trip show connectivity snack bar when `isConnectivityFailure` true, generic snack bar for HTTP errors.

### Tests for User Story 4 ⚠️

- [X] T011 [P] [US4] Add unit test Dio/`AppFailure` matrix in `test/unit/connectivity_failure_test.dart` (fail before T003 if not done)

### Implementation for User Story 4

- [X] T012 [US4] Integrate `isConnectivityFailure` + `ConnectivitySnackBar.show` in `lib/features/profile/presentation/profile_edit_page.dart` `_save` `Failure` branch
- [X] T013 [US4] Integrate `isConnectivityFailure` + `ConnectivitySnackBar.show` in `lib/features/trips/presentation/create_trip_page.dart` submit error branch
- [X] T014 [P] [US4] Optional stretch: integrate same pattern in `lib/features/trips/presentation/trip_join_flow.dart` error snack bar branches

**Checkpoint**: US4 reference flows wired; unit tests green.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, docs, optional helper.

- [X] T015 [P] Optional: implement `showActionFailureSnackBar` helper in `lib/shared/errors/connectivity_failure.dart` per contract stretch
- [X] T016 Run `dart format .` and `flutter analyze` in `frontend/`
- [X] T017 Run `flutter test test/unit/connectivity_failure_test.dart test/widget/connectivity_snack_bar_test.dart` in `frontend/`
- [ ] T018 Execute manual offline smoke steps in `specs/010-connectivity-snackbar/quickstart.md` (web + one mobile target)

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends on | Blocks |
|-------|------------|--------|
| 1 Setup | — | 2, 3, 4, 5, 6 |
| 2 Foundational | 1 | US4 (T012–T014) |
| 3 US1 | 1 | — |
| 4 US2 | 3 (T005) | — |
| 5 US3 | 3 (T005) | — |
| 6 US4 | 2, 3–5 (widget + classifier) | — |
| 7 Polish | 3–6 | — |

### User Story Dependencies

| Story | Depends on | Independent of |
|-------|------------|----------------|
| US1 | Phase 1 | US2–US4 for core widget |
| US2 | US1 implementation file | US3, US4 |
| US3 | US1 implementation file | US4 |
| US4 | Phase 2 + widget from US1–US3 | — |

**Note**: US2 and US3 can be implemented in one pass on `connectivity_snack_bar.dart` after US1 T005; phases separate verification checkpoints.

### Within Each User Story

1. Tests written and failing  
2. Implementation  
3. Tests passing  
4. Checkpoint before next priority

### Parallel Opportunities

- **After Phase 1**: T003 [Foundational] ∥ T004 [US1 test]  
- **After T005**: T007 [US2 test] ∥ T009 [US3 test]  
- **After widget complete**: T011 [US4 unit test] ∥ T012 [profile_edit] (different files)  
- **Polish**: T015 ∥ T016

---

## Parallel Example: User Story 4

```bash
# After Phase 2 + widget done:
Task T011: "Unit test in test/unit/connectivity_failure_test.dart"
Task T012: "Integrate profile_edit_page.dart"
# T013 create_trip_page.dart after T012 or in parallel [P]
```

---

## Parallel Example: User Story 1 + Foundational

```bash
# After Phase 1:
Task T003: "connectivity_failure.dart"
Task T004: "widget test connectivity_snack_bar_test.dart"
# Then T005 implements widget
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1 (T001–T002)  
2. Complete Phase 3 (T004–T006)  
3. **STOP and VALIDATE**: `flutter test test/widget/connectivity_snack_bar_test.dart`  
4. Demo via temporary debug button or manual `show` in a scaffold screen  

### Incremental Delivery

1. Setup → US1 (MVP snack bar)  
2. US2 (dismiss) + US3 (no stack)  
3. Foundational classifier + US4 (profile + trip integrations)  
4. Polish (analyze, full test, manual smoke)  

### Suggested MVP Scope

**Phases 1 + 3 only** (T001–T006): delivers FR-001–FR-006 visual/behavior core without screen integrations.

---

## Task Summary

| Metric | Value |
|--------|-------|
| **Total tasks** | 18 |
| **Phase 1 Setup** | 2 |
| **Phase 2 Foundational** | 1 |
| **US1** | 3 |
| **US2** | 2 |
| **US3** | 2 |
| **US4** | 4 |
| **Polish** | 4 |

| User Story | Task IDs | Count |
|------------|----------|-------|
| US1 | T004–T006 | 3 |
| US2 | T007–T008 | 2 |
| US3 | T009–T010 | 2 |
| US4 | T011–T014 | 4 |

**Format validation**: All tasks use `- [ ] Tnnn [P?] [USn?] Description with file path`.

---

## Notes

- All paths under `frontend/` unless `specs/010-connectivity-snackbar/quickstart.md` (T018).  
- Do not modify `lib/shared/network/api_client.dart` `mapDioError` in v1 (per plan).  
- `NetworkFailure` with `HTTP \d+` prefix must **not** trigger connectivity snack bar (classifier + integration reviews).  
- T014 is optional stretch; skip for minimal v1 if time-boxed.
