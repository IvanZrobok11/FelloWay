# Contract: Connectivity SnackBar (Flutter client)

**Version**: 1.0  
**Date**: 2026-05-20  
**Consumers**: Feature presentation layers (`lib/features/**/presentation`)  
**Provider**: `lib/shared/widgets/connectivity_snack_bar.dart`

## Public API

### `ConnectivitySnackBar`

```dart
abstract final class ConnectivitySnackBar {
  /// Clears all snack bars on [context]'s [ScaffoldMessenger], then shows the
  /// standardized connectivity floating snack bar (4s, dismissible).
  static void show(BuildContext context);
}
```

**Preconditions**:
- `context` is mounted.
- An ancestor `ScaffoldMessenger` exists (typically under `MaterialApp` + `Scaffold`).

**Postconditions**:
- At most one snack bar visible on that messenger after call (previous cleared).
- Snack bar uses floating behavior, 12px corner radius, `#212121` background.
- Content: `wifi_off` icon + localized connectivity message + close action.

**Side effects**: Replaces any current snack bar on the same messenger.

---

### `isConnectivityFailure` / `isConnectivityDioException`

```dart
bool isConnectivityDioException(DioException exception);
bool isConnectivityFailure(AppFailure failure, {DioException? cause});
```

**Purpose**: Let callers branch before `show` vs generic error snack bar.

**Rules** (normative): See [data-model.md](../data-model.md) → ConnectivityFailureSignal table.

---

### Optional: `showActionFailureSnackBar` (stretch)

```dart
void showActionFailureSnackBar(BuildContext context, AppFailure failure, {DioException? cause});
```

If implemented: routes to `ConnectivitySnackBar.show` or `SnackBar(content: Text(failure.message))`.

## Localization contract

| Key | EN | UK |
|-----|----|----|
| `connectivityActionUnavailable` | Action unavailable. No internet connection. | Дія недоступна. Немає інтернету. |

Generated accessor: `AppLocalizations.of(context)!.connectivityActionUnavailable`.

## Visual contract

| Property | Value |
|----------|-------|
| `SnackBarBehavior` | `floating` |
| `shape` | `RoundedRectangleBorder(borderRadius: 12)` |
| `backgroundColor` | `#212121` |
| `duration` | 4 seconds |
| Leading icon | `Icons.wifi_off`, light color |
| Dismiss | Close control → `hideCurrentSnackBar` |

## Non-goals

- Does not detect connectivity proactively.
- Does not modify `ApiClient.mapDioError`.
- Does not replace full-screen `ErrorDisplay` for list/load failures.

## Versioning

Breaking changes (message keys, signature) require bumping this contract version and updating widget/unit tests.
