# Tasks: Mobile typography system (Ukrainian UI)

**Input**: Design documents from `/specs/014-mobile-typography/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/typography-tokens.md](./contracts/typography-tokens.md)

**Tests**: Included per spec NFR-TEST-001, plan, and constitution (widget tests required; golden optional).

**Organization**: Tasks grouped by user story. **Foundational (Phase 2) blocks all stories.**

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks in same story)
- **[Story]**: US1, US2, US3 per [spec.md](./spec.md)

## Path Conventions

- Flutter app: `frontend/lib/`, `frontend/test/`, `frontend/assets/`
- Theme: `frontend/lib/app/theme/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Font assets and project wiring.

- [x] T001 Add Onest variable font `Onest-wght.ttf` under `frontend/assets/fonts/onest/` per [quickstart.md](./quickstart.md)
- [x] T002 Register `Onest` family in `frontend/pubspec.yaml` `flutter: fonts:` section (variable font)
- [x] T003 [P] N/A — `fonts:` entry bundles TTF without separate assets entry
- [x] T004 [P] Document OFL license attribution in `frontend/assets/fonts/onest/README.md` (source: Google Fonts Onest)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Central typography and text color tokens in theme. **Blocks US1–US3.**

**⚠️ CRITICAL**: Complete before Profile or feature screen changes.

- [x] T005 Create `frontend/lib/app/theme/felloway_text_colors.dart` with `ThemeExtension` (`textPrimary` 96%, `textSecondary` 74%, `textTertiary` 58%, `textAccent` = `FellowayColors.brandYellow`) per [data-model.md](./data-model.md)
- [x] T006 Create `frontend/lib/app/theme/felloway_typography.dart` with `ThemeExtension<FellowayTypography>` roles: `screenTitle`, `sectionLabel`, `menuRow`, `bodySupporting`, `tabLabel`, `tabLabelSelected` (Onest sizes/weights from spec)
- [x] T007 Implement `buildOnestTextTheme()` in `frontend/lib/app/theme/felloway_typography.dart` mapping M3 roles (`headlineMedium`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelSmall`) per [data-model.md](./data-model.md)
- [x] T008 Wire `AppTheme.light()` in `frontend/lib/app/theme/app_theme.dart`: `fontFamily: 'Onest'`, `textTheme`, `extensions: [FellowayTypography, FellowayTextColors]`
- [x] T009 Update `appBarTheme.titleTextStyle` in `frontend/lib/app/theme/app_theme.dart` to use `screenTitle` (document chosen app bar size 22–28sp in code comment)
- [x] T010 Update `navigationBarTheme.labelTextStyle` in `frontend/lib/app/theme/app_theme.dart` to use `tabLabel` / `tabLabelSelected` + `FellowayTextColors` (remove raw `Colors.white70`)
- [x] T011 [P] Add `BuildContext` extension or helper in `frontend/lib/app/theme/felloway_typography.dart` for `context.fellowayTypography` / `context.fellowayTextColors` (optional thin accessor file)

**Checkpoint**: `flutter pub get` succeeds; app launches with Onest on default screens.

---

## Phase 3: User Story 1 - Read Profile and settings comfortably (Priority: P1) 🎯 MVP

**Goal**: Profile screen and bottom nav use Onest type scale; Ukrainian text readable at 12–16sp on gradient UI.

**Independent Test**: Open Profile signed in → title, menu rows, interests/hobbies, tab labels readable; Cyrillic QA strings render correctly (spec SC-001 manual).

### Tests for User Story 1

- [x] T012 [P] [US1] Add widget test `frontend/test/widget/profile_typography_test.dart`: signed-in Profile uses `fontFamily` Onest on title and `ListTile` titles (pump with `AppScope` harness)
- [x] T013 [P] [US1] Add widget test in `frontend/test/widget/profile_typography_test.dart`: guest Profile uses theme body styles for guest message
- [x] T014 [P] [US1] Add widget test `frontend/test/widget/navigation_typography_test.dart`: `NavigationBar` selected/unselected labels differ by weight and color token (not size)

### Implementation for User Story 1

- [x] T015 [US1] Refactor `frontend/lib/features/profile/presentation/profile_page.dart`: apply `sectionLabel` for section `ListTile` titles («Інтереси», «Хобі»); `menuRow` for action rows; `bodySupporting` for subtitles
- [x] T016 [US1] Ensure `profile_page.dart` `ListTile` long titles (`profileMenuNotifications`) use `maxLines: 2` and `overflow: TextOverflow.ellipsis` per spec edge case
- [x] T017 [US1] Replace hardcoded styles in `frontend/lib/app/theme/app_theme.dart` `snackBarTheme` / `chipTheme` label styles to inherit Onest via `textTheme` where touched in this story
- [x] T018 [US1] Verify `frontend/lib/app/shell/main_shell.dart` bottom nav inherits updated `navigationBarTheme` (no local `TextStyle` overrides)

**Checkpoint**: Profile + nav MVP; widget tests green for US1.

---

## Phase 4: User Story 2 - Consistent typography across the app (Priority: P2)

**Goal**: Events, Map, Chats, onboarding use same type roles—no ad-hoc `fontSize` on primary labels.

**Independent Test**: Side-by-side tab audit; design reviewer confirms one family and scale on four main tabs (spec US2).

### Tests for User Story 2

- [x] T019 [P] [US2] Add widget smoke test `frontend/test/widget/app_typography_smoke_test.dart`: `FellowayApp` root `ThemeData.fontFamily` equals `Onest`

### Implementation for User Story 2

- [x] T020 [P] [US2] Migrate `frontend/lib/features/events/presentation/` screens: replace inline `TextStyle` / `fontSize` with `theme.textTheme` or `FellowayTypography` roles for screen titles and list rows
- [x] T021 [P] [US2] Migrate `frontend/lib/features/chats/presentation/` screens: apply theme roles to page titles and placeholder/error text (Stream Chat SDK exempt per plan)
- [x] T022 [P] [US2] Migrate `frontend/lib/features/map/presentation/` screens: apply theme roles to labels and markers text where app-controlled
- [x] T023 [US2] Migrate `frontend/lib/features/onboarding/presentation/welcome_page.dart` and related onboarding pages: replace `FontWeight.bold` / hardcoded sizes with theme roles
- [x] T024 [US2] Run `rg "fontSize:|fontWeight:|fontFamily:" frontend/lib/features` and fix remaining high-traffic violations per [contracts/typography-tokens.md](./contracts/typography-tokens.md)

**Checkpoint**: Grep shows no ad-hoc font family in `lib/features/`; four tabs visually consistent.

---

## Phase 5: User Story 3 - Accessible contrast on dark gradients (Priority: P2)

**Goal**: Text color tokens meet contrast on gradient; tab/menu states distinguishable.

**Independent Test**: Screenshot contrast ≥4.5:1 primary menu text; tab labels readable (spec US3, SC-002).

### Tests for User Story 3

- [x] T025 [P] [US3] Add unit test `frontend/test/unit/felloway_text_colors_test.dart`: token alpha values match data model (96% / 74% / 58%)

### Implementation for User Story 3

- [x] T026 [US3] Audit `profile_page.dart` and nav against gradient: apply `FellowayTextColors.textPrimary` / `textSecondary` explicitly where `ListTile` defaults fail contrast
- [x] T027 [US3] If contrast audit fails on profile header band, add localized scrim (8–12% black or existing `brandDark` alpha) behind profile header block only—document in `profile_page.dart` comment
- [x] T028 [US3] Document contrast verification steps and sample screenshots checklist in `specs/014-mobile-typography/quickstart.md` §5 (operator fills screenshots on device)
- [ ] T029 [US3] Manual smoke: system text scale 1.3× on Profile + tab bar (no clipped labels); record result in PR description

**Checkpoint**: Contrast + text-scale validation documented; token unit test passes.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, optional goldens, performance note.

- [ ] T030 [P] Optional golden test `frontend/test/golden/profile_typography_golden_test.dart` for Profile + nav on gradient fixture (skip in CI if flaky—document)
- [x] T031 Run `dart format` and `flutter analyze` in `frontend/`; fix issues in touched theme files
- [x] T032 Run `flutter test` for `test/widget/profile_typography_test.dart`, `test/widget/navigation_typography_test.dart`, `test/unit/felloway_text_colors_test.dart`
- [ ] T033 [P] Measure cold-start delta before/after fonts on one Android device; note in PR if within 150ms budget (spec NFR-PERF-001)
- [ ] T034 [P] Cyrillic QA pass on device with strings from [data-model.md](./data-model.md) («Їжак», «Європа», «Ґрунт», «Налаштування сповіщень»)
- [x] T035 Update `frontend/README.md` typography section: Onest, token usage, link to `specs/014-mobile-typography/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** (foundational) → **US1** → **US2** / **US3** (US2 and US3 can overlap after US1 theme is stable)
- **Phase 6** after US1 minimum; full polish after US2–US3

### User Story Dependencies

| Story | Depends on | Can parallel with |
|-------|------------|-------------------|
| US1 (P1) | Phase 2 complete | — |
| US2 (P2) | Phase 2 + US1 theme landed | US3 after T005–T010 |
| US3 (P2) | Phase 2 (tokens) | US2 file migrations [P] |

### Within User Story 1

1. Tests T012–T014 (may fail until T015–T018)
2. Implementation T015–T018
3. Re-run tests

### Parallel Opportunities

```bash
# Phase 1 parallel:
T003 pubspec assets
T004 OFL README

# Phase 2 after T005–T006:
T009 appBarTheme
T010 navigationBarTheme

# US2 parallel (different feature folders):
T020 events/
T021 chats/
T022 map/
```

---

## Parallel Example: User Story 2

```bash
# Migrations in parallel after foundational theme merges:
flutter test test/widget/app_typography_smoke_test.dart
# Developers split: events/, chats/, map/, onboarding/
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2 (fonts + theme tokens)
2. Complete Phase 3 US1 (Profile + nav + widget tests)
3. **STOP**: Manual Profile read test + Cyrillic spot check (T034 partial)
4. Then US2 rollout and US3 contrast validation

### Incremental Delivery

1. Foundation → Profile/nav (MVP)
2. US2 app-wide grep migration
3. US3 contrast + text scale evidence
4. Polish: analyze, full test suite, optional golden

---

## Notes

- Total tasks: **35**
- US1: 3 test + 4 implementation = **7**
- US2: 1 test + 5 implementation = **6**
- US3: 1 test + 4 implementation = **5**
- Setup: **4**; Foundational: **7**; Polish: **6**
- Stream Chat internal UI remains best-effort exempt per plan
- Suggested MVP scope: **Phase 1 + Phase 2 + US1 + T031–T032**
