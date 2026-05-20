# Research: Connectivity SnackBar (010)

**Date**: 2026-05-20  
**Feature**: [spec.md](./spec.md)

## R1 — SnackBar placement and styling

**Decision**: Implement `ConnectivitySnackBar` as a `abstract final class` with static `show(BuildContext context)` in `frontend/lib/shared/widgets/connectivity_snack_bar.dart`, building an explicit `SnackBar` that sets `behavior: SnackBarBehavior.floating`, `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`, `backgroundColor: const Color(0xFF212121)`, `duration: const Duration(seconds: 4)`.

**Rationale**: Matches user UX spec (charcoal `#212121`) while reusing Material floating pattern already in `AppTheme.snackBarTheme`. Explicit properties on the instance override theme where needed without changing global theme for all snack bars.

**Alternatives considered**:
- Rely only on `Theme.of(context).snackBarTheme` — rejected: global theme uses `FellowayColors.brandDark` (`0xFF3E2723`), not the requested charcoal; success/other snack bars should stay on brand theme.
- Custom overlay/`OverlayEntry` — rejected: unnecessary complexity vs `ScaffoldMessenger`.

## R2 — Content layout and dismiss

**Decision**: `content`: `Row` with `Icons.wifi_off` (white70), `SizedBox(width: 12)`, expanded localized text (white `bodyMedium`), `action`: `SnackBarAction` with `Icons.close` (or `IconButton` via `SnackBarAction` label widget) calling `hideCurrentSnackBar`.

**Rationale**: Meets FR-003–FR-005; `wifi_off` chosen over `cloud_off` for unified offline+backend copy per spec assumptions.

**Alternatives considered**:
- `Icons.cloud_off` for backend-only — rejected for v1 single message.
- Text-only dismiss — rejected; icon close is more compact on mobile.

## R3 — Clear-before-show

**Decision**: `ScaffoldMessenger.of(context).clearSnackBars()` immediately before `showSnackBar`.

**Rationale**: Spec FR-007 and user requirement; prevents queue when user taps rapidly. Intentionally clears *all* snack bars (spec edge case accepted).

**Alternatives considered**:
- Track snack bar tag and clear only connectivity — rejected: Flutter `SnackBar` has no built-in tag filter; custom queue adds complexity.

## R4 — Connectivity failure classification

**Decision**: Add `frontend/lib/shared/errors/connectivity_failure.dart` with:

```dart
bool isConnectivityFailure(AppFailure failure);
bool isConnectivityDioException(DioException e);
```

Rules:
- `DioExceptionType.connectionError`, `connectionTimeout`, `sendTimeout`, `receiveTimeout` → connectivity.
- `DioException` with `response == null` and type `unknown` → connectivity (typical socket/DNS failures).
- `NetworkFailure` where message indicates no HTTP status (no `HTTP \d+` prefix from `mapDioError`) **and** underlying cause was connectivity-class `DioException` — prefer checking `DioException` at catch site when available.
- **Exclude**: `badResponse` with 4xx/5xx (server reached), `cancel`, validation/business errors.

Optional helper for UI layers:

```dart
void showErrorSnackBar(BuildContext context, AppFailure failure) {
  if (isConnectivityFailure(failure)) {
    ConnectivitySnackBar.show(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
  }
}
```

**Rationale**: `mapDioError` wraps all Dio errors as `NetworkFailure` including HTTP errors; callers must not show connectivity UI for `HTTP 403: ...`. Classification at presentation layer keeps `ApiClient` unchanged.

**Alternatives considered**:
- Split `NetworkFailure` into `ConnectivityFailure` vs `HttpFailure` in `app_failure.dart` — rejected for v1 scope (touches all repositories).
- `connectivity_plus` package — rejected: spec triggers on failed *actions*, not proactive monitoring; no new dependency.

## R5 — Localization

**Decision**: Add ARB keys `connectivityActionUnavailable` in `app_en.arb` / `app_uk.arb`:

| Locale | Copy |
|--------|------|
| `uk` | Дія недоступна. Немає інтернету. |
| `en` | Action unavailable. No internet connection. |

Run `flutter gen-l10n` (or project’s existing codegen step) after ARB edit.

**Rationale**: FR-010; matches spec default Ukrainian and assumed English.

## R6 — Integration scope (v1)

**Decision**: Ship widget + classifier + tests; adopt in **two** reference screens: `profile_edit_page.dart` (`_save`) and `create_trip_page.dart` (submit). Other screens remain on generic `SnackBar(content: Text(error.message))` until follow-up tasks.

**Rationale**: SC-004 asks ≥3 flows eventually; plan targets 2 in implementation phase with third (e.g. `trip_join_flow`) as optional stretch in tasks.

## R7 — Testing approach

**Decision**:
- **Widget test** `frontend/test/widget/connectivity_snack_bar_test.dart`: pump `MaterialApp` + `Scaffold`, call `show`, find `Icons.wifi_off`, localized text, close action, `SnackBarBehavior.floating`.
- **Unit test** `frontend/test/unit/connectivity_failure_test.dart`: matrix of `DioExceptionType` → bool.

No golden in v1 unless flaky; optional later.

**Rationale**: NFR-FLUTTER-TEST-001; constitution widget + unit pyramid.

## R8 — Performance

**Decision**: No async work in `show`; no listeners. Budget: show path &lt; 1 frame on UI thread.

**Rationale**: NFR-PERF-001 / constitution IV.
