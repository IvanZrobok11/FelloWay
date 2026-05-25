# felloway_client

Flutter mobile client for FelloWay.

## Run the app

1. Install Flutter (stable) and verify setup:
   - `flutter doctor`
2. From this directory (`frontend/`):
   - `flutter pub get`
   - `flutter run`

You can pass runtime config with `--dart-define`.

**Flutter Web — фіксований порт:** використовуй опцію **`flutter run`**, а не `dart-define`:

```bash
flutter run -d chrome --web-port=7357 --dart-define=API_BASE_URL=https://localhost:7086 ...
```

`--dart-define=web-port=...` не задає порт dev-сервера й буде ігнорований.

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
- `OAUTH_REDIRECT_URL` (legacy; **not used for LinkedIn BFF** — callback is `{API_BASE_URL}/auth/linkedin/callback` on the server)
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

# Flutter web + local HTTPS API (requires backend CORS in Development)
flutter run -d chrome --dart-define=API_BASE_URL=https://localhost:7086 --dart-define=API_MODE=live
```

## LinkedIn sign-in (BFF)

Production LinkedIn uses a **backend-for-frontend** flow (`AspNet.Security.OAuth.LinkedIn` / `AddLinkedIn` on the API):

1. App opens `GET {API_BASE_URL}/auth/linkedin/login` (web: same-window navigation; mobile: `flutter_web_auth_2`).
2. LinkedIn redirects to **`{API_BASE_URL}/auth/linkedin/callback`** (register this URL in LinkedIn Developer Portal — not the Flutter origin).
3. **Web**: API sets an HttpOnly session cookie → redirect to `{frontend}/auth/success`.
4. **Mobile**: API redirects `com.felloway.app://auth/callback?ticket=...` → app calls `POST /auth/linkedin/mobile/complete` → stores JWT.

**Local HTTPS (required for BFF):**

```bash
dotnet run --project backend/src/FelloWay.Api --launch-profile https
flutter run -d chrome --web-port=7357 --dart-define=API_BASE_URL=https://localhost:7086 --dart-define=API_MODE=live
```

See [specs/009-linkedin-bff-auth/quickstart.md](../specs/009-linkedin-bff-auth/quickstart.md).

**Dev sign-in (no LinkedIn secrets):** use **Sign in (local backend)** or `POST /auth/oauth/linkedin/token` with `dev-{subject}` when `OAuth:LinkedIn:ClientId` is empty.

For CORS + cookies on Flutter web, see [specs/007-api-cors-policy/quickstart.md](../specs/007-api-cors-policy/quickstart.md).

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
