# felloway_client

Flutter mobile client for FelloWay.

## Run the app

1. Install Flutter (stable) and verify setup:
   - `flutter doctor`
2. From this directory (`frontend/`):
   - `flutter pub get`
   - `flutter run`

You can pass runtime config with `--dart-define`.

Example:

```bash
flutter run --dart-define=API_BASE_URL=https://staging.api.example --dart-define=API_MODE=live --dart-define=STREAM_API_KEY=your_stream_key
```

## Runtime config

Main defines:

- `API_BASE_URL` (default: `https://api.example.com`)
- `API_MODE` (`auto`, `mock`, `live`)
- `STREAM_API_KEY`
- `OAUTH_ISSUER`
- `OAUTH_CLIENT_ID`
- `OAUTH_REDIRECT_URL` (default: `com.felloway.app:/oauthredirect`)
- `OAUTH_DISCOVERY_URL`

## API modes (`API_MODE`)

- `mock`:
  - Forces in-app mock data for supported REST flows.
  - Useful for UI development without backend availability.
- `live`:
  - Forces real HTTP calls to `API_BASE_URL`.
  - Use this when working against staging/production backend.
- `auto` (default):
  - Chooses mode from URL heuristic:
    - if `API_BASE_URL` contains `example.com` -> mock
    - otherwise -> live

Quick examples:

```bash
# Force mocks
flutter run --dart-define=API_MODE=mock

# Force live API
flutter run --dart-define=API_BASE_URL=https://staging.api.example --dart-define=API_MODE=live

# Local backend (iOS Simulator)
flutter run --dart-define=API_BASE_URL=http://localhost:5161 --dart-define=API_MODE=live

# Local backend (Android Emulator)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5161 --dart-define=API_MODE=live
```

Use **Sign in (local backend)** on the sign-in screen when OAuth is not configured. Start the API with `dotnet run --project backend/src/FelloWay.Api`. See [specs/005-api-backend-integration/quickstart.md](../specs/005-api-backend-integration/quickstart.md).

### Live vs mock by feature (live mode)

| Feature | Backend HTTP |
|---------|----------------|
| Auth (dev exchange), profile, events read | Yes |
| Trips, Stream chat | Mock / dev stubs until wired |

```bash
# Default behavior (auto)
flutter run
```

## Development Standards

Project delivery standards are defined in
`../.specify/memory/constitution.md`, including required quality gates for
code quality, automated testing, UX consistency, and performance budgets.
