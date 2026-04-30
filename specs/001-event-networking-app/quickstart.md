# Quickstart: Flutter Client Development

**Feature**: `001-event-networking-app`  
**Date**: 2026-04-03

## Prerequisites

- Flutter SDK (stable), Dart 3.x
- Xcode (iOS), Android Studio / SDK (Android)
- Access to staging backend URL and OAuth client IDs (from team)
- GetStream app id / key policy for development builds

## Run the App

```bash
cd felloway_client
flutter pub get
flutter run
```

### `--dart-define` (environment)

The app reads build-time defines in `AppConfig.fromEnvironment()`:

| Define | Purpose | Default (dev) |
|--------|---------|----------------|
| `API_BASE_URL` | REST base URL | `https://api.example.com` |
| `API_MODE` | `mock` = in-app REST stubs; `live` = always use HTTP; omit or `auto` = mock if URL contains `example.com`, else live | `auto` (implicit) |
| `STREAM_API_KEY` | GetStream client key | empty (chat UI limited without key) |
| `OAUTH_ISSUER` | OIDC issuer | empty |
| `OAUTH_CLIENT_ID` | Native client id | empty |
| `OAUTH_REDIRECT_URL` | Redirect URI | `com.felloway.app:/oauthredirect` |
| `OAUTH_DISCOVERY_URL` | Optional discovery override | empty |

Example (real backend, even if the hostname happens to include `example.com`):

```bash
flutter run --dart-define=API_BASE_URL=https://staging.api.example --dart-define=API_MODE=live --dart-define=STREAM_API_KEY=your_key
```

Example (force offline-friendly stubs against any base URL):

```bash
flutter run --dart-define=API_BASE_URL=https://staging.api.example --dart-define=API_MODE=mock
```

### Flavors

Product flavors (`dev` / `staging` / `prod`) are not in the template yet; use `--dart-define` per build variant or add `flutter` flavors under `android/` and `ios/` when you standardize signing and bundle IDs.

## Quality Gates (Constitution)

Run from repository root (`felloway_client/`):

```bash
dart format .
flutter analyze
flutter test
```

Golden files (update after intentional UI changes):

```bash
flutter test test/golden/event_card_golden_test.dart --update-goldens
```

Optional integration tests (device or emulator):

```bash
flutter test integration_test/app_test.dart
flutter test integration_test/us1_discover_join_test.dart
flutter test integration_test/us2_chat_navigation_test.dart
```

### CI checklist (T066)

On your CI image, run in order:

1. `dart format . --set-exit-if-changed`
2. `flutter analyze`
3. `flutter test`
4. Optionally `flutter test integration_test/...` on a device job

Commit generated `test/golden/goldens/*.png` when goldens change; expect possible pixel drift across OS/fonts—regenerate on the CI OS or pin fonts if needed.

## Device Checks (Manual)

- **Welcome (S1)**: **Get started** continues to name/interests/city; **Log in** pushes `/sign-in` (OAuth). Screen reader label summarizes both paths (`onboardingWelcomeSemanticsLabel`).
- Onboarding **S2–S4**: collect **display name, interests/hobbies, home city** into a **local draft** only; after S4 the primary action goes to **`/sign-in`**. **No `PUT /users/me`** during S2–S4. After successful OAuth, the app runs **`GET /users/me`** and applies **`PUT /users/me`** from the draft only when the server profile is still incomplete (empty display name or home city). TalkBack / VoiceOver: section labels on onboarding; event list search field is exposed as a text field
- Event list / cards: cover images use decoded cache bounds (smaller memory); pull-to-refresh + infinite scroll uses one list request per page
- Chats: Stream channel list uses SDK lazy loading; chat connection errors use shared `ErrorDisplay` + localized retry
- Trips on event detail: one `GET …/trips` per refresh; profile loaded once for join policy (see `EventTripsSection` doc comment)

- OAuth redirect opens and returns to app (iOS + Android)
- Token persistence across app restart
- Push: wire FCM/APNs to `PushHandler.handleForegroundData` / `handleNotificationOpened` (`lib/app/notifications/push_handler.dart`); verify deep link opens event or `/chats/channel`
- Profile: notification toggles persist; avatar pick + upload on real backend
- Map: markers load and popup navigates to event detail

## Frontend-Only Caveat

Without a running backend, use **`API_MODE=mock`** (or default `API_MODE=auto` with `API_BASE_URL` containing `example.com`) so REST repositories return in-app data; use a **Stream test app** for chat UI iteration.
