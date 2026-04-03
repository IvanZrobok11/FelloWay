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

Use flavor or `--dart-define` for environment once introduced (API base URL, Stream key if client-side).

## Quality Gates (Constitution)

Run from repository root (`felloway_client/`):

```bash
dart format .
flutter analyze
flutter test
```

Optional integration tests (device or emulator):

```bash
flutter test integration_test/app_test.dart
```

## Device Checks (Manual)

- OAuth redirect opens and returns to app (iOS + Android)
- Token persistence across app restart
- Push: foreground banner + background tap opens correct chat/event (after integration)
- Map: markers load and popup navigates to event detail

## Frontend-Only Caveat

Without a running backend, use **mock servers** or **stub repositories** for REST and a **Stream test app** for chat UI iteration. Document stub toggles in app config.
