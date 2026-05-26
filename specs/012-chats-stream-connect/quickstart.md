# Quickstart: Fix Chats tab Stream connect (012)

## Symptom

Signed-in user opens **Chats** → message about `STREAM_API_KEY` → **no** `GET /chat/stream-token` in network tab.

## Root cause (short)

Client exits early when `streamApiKey` is empty; backend is never called.

## Verify configuration

### GitHub (per environment)

| Variable | Used in |
|----------|---------|
| `DEV_STREAM_API_KEY` | `deploy.yml` web build |
| `TEST_STREAM_API_KEY` | `promote-test.yml` |
| `PROD_STREAM_API_KEY` | `promote-prod.yml` |

Value = GetStream **public** API key (same as app’s Stream dashboard key).

### Local Flutter web

```powershell
cd frontend
flutter run -d chrome --web-port=7357 `
  --dart-define=API_BASE_URL=https://localhost:7086 `
  --dart-define=API_MODE=live `
  --dart-define=STREAM_API_KEY=your_public_key
```

Use `--dart-define=STREAM_API_KEY=...` for local runs. Deployed web: see [specs/013-clarify-env-json/quickstart.md](../../013-clarify-env-json/quickstart.md) (CI variables only; no `env.json` on S3).

### Backend (local)

`appsettings.Development.json` or user secrets:

```json
"Stream": {
  "ApiKey": "<public>",
  "ApiSecret": "<secret>"
}
```

Without secrets, API still returns `dev-stream-token-{userId}` for local testing.

## Manual smoke (happy path)

1. Sign in (live API, non-mock).
2. Open **Chats**.
3. Expect: brief connecting UI → channel list or empty state.
4. Network (Eruda or desktop devtools):
   - `GET .../users/me` → 200
   - `GET .../chat/stream-token` → 200 with `token`

## Manual smoke (missing key)

1. Run/build **without** `STREAM_API_KEY` and with `STREAM_API_KEY_OPTIONAL=true` (tests only), or inspect old artifact.
2. Open **Chats** while signed in.
3. Expect: configuration-unavailable message; **no** `/chat/stream-token` request.

## Manual smoke (token failure)

1. Valid `STREAM_API_KEY` in client; break API auth or stop backend.
2. Open **Chats**.
3. Expect: error + **Retry**; not `STREAM_API_KEY` hint.

## Deployed web check

After CI deploy, open dev/test web URL:

1. Confirm app starts (CI must pass non-empty `STREAM_API_KEY` at build).
2. Eruda: **no** `GET /env.json` on cold load.
3. Sign in → **Chats** → see `/chat/stream-token`.
4. Policy: [specs/013-clarify-env-json/quickstart.md](../../013-clarify-env-json/quickstart.md).

## Tests

```powershell
cd frontend
flutter test test/widget/chats_tab_test.dart
flutter test test/unit/stream_chat_service_test.dart
```

(Add service tests as part of implementation tasks.)
