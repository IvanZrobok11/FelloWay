# Data model: Chats Stream connect (012)

## Client configuration

### `AppConfig.streamApiKey`

| Field | Type | Source | Validation |
|-------|------|--------|------------|
| `streamApiKey` | string | `--dart-define=STREAM_API_KEY` (compile-time; CI on deploy) | Non-empty required at startup unless `STREAM_API_KEY_OPTIONAL=true` |

## Chat connection state machine

`StreamChatConnectStatus` (client):

| State | Meaning | Backend calls |
|-------|---------|---------------|
| `disconnected` | Signed out or not started | None |
| `missingApiKey` | `streamApiKey` empty in live mode | None |
| `demoSkipped` | `useMockApi` true | None |
| `connecting` | Fetching token + connecting SDK | `GET /users/me`, then `GET /chat/stream-token` |
| `connected` | SDK user connected | Stream SDK (external) |
| `error` | Token or connect failed | Same as connecting path; may have failed mid-flight |

### Transitions (signed-in, live mode)

```text
disconnected → connecting → connected
                ↓
              error → (retry) → connecting
missingApiKey (terminal until new build/config)
```

## API entities

### `GET /chat/stream-token` (existing)

**Auth**: Bearer JWT or session (policy scheme).

**Response 200**:

```json
{ "token": "<stream_user_jwt>" }
```

**Response 401**: Unauthenticated.

**Server**: Uses GetStream server SDK when `Stream:ApiKey` + `Stream:ApiSecret` configured; dev fallback token when not configured.

## UI mapping (Chats tab)

| Status | User-visible pattern |
|--------|----------------------|
| `missingApiKey` | Configuration unavailable (not “backend down”) |
| `demoSkipped` | Demo/mock hint (existing) |
| `connecting` | Spinner + “connecting” copy |
| `error` | `ErrorDisplay` + Retry |
| `connected` + no channels | Empty state |
| `connected` + channels | `StreamChannelListView` |

## Deploy artifacts (web)

| Artifact | Purpose |
|----------|---------|
| Compiled `STREAM_API_KEY` in web bundle | Only channel for deploy (013 policy) |
| `deploy_env.js` | dev/test/prod label (Eruda); unrelated to Stream key |
