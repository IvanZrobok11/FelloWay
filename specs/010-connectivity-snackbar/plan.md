# Implementation Plan: Connectivity SnackBar

**Branch**: `010-connectivity-snackbar` | **Date**: 2026-05-20 | **Spec**: [spec.md](./spec.md)  
**Input**: Reusable floating connectivity snack bar + `show(context)` service for offline/unreachable backend on user actions.

## Summary

Add a shared **`ConnectivitySnackBar`** widget/service and **`isConnectivityFailure`** helpers in the Flutter client so feature code can show a consistent, localized, floating dark snack bar (wifi-off icon, close action, 4s duration, clear-before-show) when API actions fail due to no network or unreachable backend—without duplicating layout. v1 includes l10n (EN/UK), unit + widget tests, and reference integration in profile edit and create trip flows.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter stable (`frontend/`, SDK `^3.10.4`)  
**Primary Dependencies**: `flutter` (Material `SnackBar`, `ScaffoldMessenger`), `dio` (error classification only), existing `app_localizations`  
**Storage**: N/A (ephemeral UI)  
**Testing**: `flutter test` — `test/unit/connectivity_failure_test.dart`, `test/widget/connectivity_snack_bar_test.dart`  
**Target Platform**: Android, iOS, Web (any screen with `ScaffoldMessenger`)  
**Project Type**: Monorepo; feature scoped to `frontend/` only  
**Performance Goals**: Show path synchronous, &lt; 100 ms perceived latency; no extra frames or background work (NFR-PERF-001)  
**Constraints**: No new packages; do not change `ApiClient.mapDioError` in v1; `clearSnackBars()` replaces all pending snack bars (spec-approved)  
**Scale/Scope**: 2 new lib files, 2 ARB keys, 2 test files, 2 reference screen integrations (optional 3rd in tasks)

## Constitution Check

*GATE: Pass (pre- and post-design).*

| Gate | Plan evidence |
|------|----------------|
| Code quality | `flutter analyze`, `dart format`; files under `lib/shared/` |
| Test strategy | Failing-first unit (Dio matrix) + widget (layout, floating, dismiss); no integration_test required for v1 |
| UX consistency | Floating snack pattern aligned with `AppTheme.snackBarTheme`; dedicated charcoal + connectivity copy per spec |
| Performance | Sync `show`; manual 10-tap smoke in quickstart; no connectivity listeners |
| Flutter checks | CI `frontend` analyze + test jobs |
| Evidence | Test output in CI; quickstart manual checklist |

**Post-design**: No violations; Complexity Tracking table empty.

## Project Structure

### Documentation (this feature)

```text
specs/010-connectivity-snackbar/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/connectivity-snack-bar-api.md
├── checklists/requirements.md
└── tasks.md             # /speckit.tasks (next)
```

### Source Code (repository root)

```text
frontend/lib/shared/
├── widgets/connectivity_snack_bar.dart    # NEW: ConnectivitySnackBar.show
└── errors/connectivity_failure.dart       # NEW: isConnectivityFailure, isConnectivityDioException

frontend/lib/l10n/
├── app_en.arb                             # connectivityActionUnavailable
└── app_uk.arb

frontend/lib/features/profile/presentation/profile_edit_page.dart   # integrate _save
frontend/lib/features/trips/presentation/create_trip_page.dart      # integrate submit

frontend/test/
├── unit/connectivity_failure_test.dart    # NEW
└── widget/connectivity_snack_bar_test.dart # NEW
```

**Structure Decision**: Flutter monorepo `frontend/` package `felloway_client`; shared widgets/errors pattern matches `error_display.dart`, `app_failure.dart`.

## Implementation Phases

### Phase A — Core widget + l10n

1. Add `connectivityActionUnavailable` to `app_en.arb` / `app_uk.arb`; run `flutter gen-l10n`.
2. Implement `ConnectivitySnackBar.show`:
   - `clearSnackBars()` then `showSnackBar`
   - `SnackBarBehavior.floating`, `shape` radius 12, `backgroundColor: Color(0xFF212121)`
   - `duration: Duration(seconds: 4)`
   - `content`: `Row` — `Icon(Icons.wifi_off)`, `SizedBox(12)`, `Text(l10n.connectivityActionUnavailable)`
   - `action`: close → `hideCurrentSnackBar`
3. Semantics: optional `Semantics(liveRegion: true)` on content for screen readers (align with `ErrorDisplay`).

### Phase B — Failure classification

1. `connectivity_failure.dart` with `isConnectivityDioException` and `isConnectivityFailure`.
2. Document that `NetworkFailure` with `HTTP \d+` prefix is **not** connectivity.
3. Optional stretch: `showActionFailureSnackBar` helper (see contract).

### Phase C — Tests

| Test file | Covers |
|-----------|--------|
| `connectivity_failure_test.dart` | Dio types → true/false |
| `connectivity_snack_bar_test.dart` | Icon, text, floating, close, double-show clears |

### Phase D — Reference integrations

1. `profile_edit_page.dart` — `Failure` branch in `_save`.
2. `create_trip_page.dart` — submit error branch.
3. Follow-up (tasks): `trip_join_flow`, `profile` avatar upload, etc.

### Phase E — Validation

```bash
cd frontend && dart format . && flutter analyze && flutter test
```

Manual offline smoke per [quickstart.md](./quickstart.md).

## Artifact Index

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| API contract | [contracts/connectivity-snack-bar-api.md](./contracts/connectivity-snack-bar-api.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Complexity Tracking

> No constitution exceptions.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
