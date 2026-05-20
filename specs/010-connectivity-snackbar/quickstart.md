# Quickstart: Connectivity SnackBar (010)

**Branch**: `010-connectivity-snackbar`

## Prerequisites

- Flutter SDK (Dart 3.10+ per `frontend/pubspec.yaml`)
- App runs with `Scaffold` on target screens (existing shell)

## Implement (developer)

1. **ARB** — add to `frontend/lib/l10n/app_en.arb` and `app_uk.arb`:

   ```json
   "connectivityActionUnavailable": "Action unavailable. No internet connection."
   ```

   ```json
   "connectivityActionUnavailable": "Дія недоступна. Немає інтернету."
   ```

2. **Regenerate l10n** (from `frontend/`):

   ```bash
   flutter gen-l10n
   ```

3. **Files to add**:
   - `lib/shared/widgets/connectivity_snack_bar.dart`
   - `lib/shared/errors/connectivity_failure.dart`

4. **Use in a catch / Failure branch**:

   ```dart
   import 'package:felloway_client/shared/errors/app_failure.dart';
   import 'package:felloway_client/shared/errors/connectivity_failure.dart';
   import 'package:felloway_client/shared/widgets/connectivity_snack_bar.dart';

   case Failure(:final error):
     if (isConnectivityFailure(error)) {
       ConnectivitySnackBar.show(context);
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(error.message)),
       );
     }
   ```

   When catching raw `DioException`:

   ```dart
   } on DioException catch (e) {
     if (isConnectivityDioException(e)) {
       ConnectivitySnackBar.show(context);
     } else {
       final failure = api.mapDioError(e);
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(failure.message)),
       );
     }
   }
   ```

## Verify locally

From `frontend/`:

```bash
dart format .
flutter analyze
flutter test test/unit/connectivity_failure_test.dart
flutter test test/widget/connectivity_snack_bar_test.dart
```

### Manual smoke (web)

1. Run app: `flutter run -d chrome` (with your usual `--dart-define` flags).
2. Open profile edit or create trip.
3. DevTools → Network → Offline (or block API host).
4. Tap Save / Create — expect floating dark snack bar with wifi-off icon and localized message.
5. Tap close — snack bar hides immediately.
6. Tap Save 5× quickly — only one snack bar at a time.

### Manual smoke (mobile)

Repeat with airplane mode or disabled Wi‑Fi on a device/emulator.

## Reference integrations (v1)

- `lib/features/profile/presentation/profile_edit_page.dart` — `_save`
- `lib/features/trips/presentation/create_trip_page.dart` — submit handler

## Troubleshooting

| Issue | Fix |
|-------|-----|
| No snack bar appears | Context not under `ScaffoldMessenger`; use scaffold body context |
| HTTP 500 shows connectivity UI | Use `isConnectivityFailure`; do not treat all `NetworkFailure` as connectivity |
| Wrong language | Ensure `AppLocalizations` delegate in `MaterialApp` |
