# Data model: Live-only client runtime (015)

## Configuration (target)

| Field | Source | Required on deploy |
|-------|--------|-------------------|
| `apiBaseUrl` | CI `--dart-define=API_BASE_URL` | Yes |
| `streamApiKey` | CI `--dart-define=STREAM_API_KEY` | Yes (chat) |
| OAuth ids / discovery | Optional dart-defines | Per env setup |

**Removed concepts**: `apiMode`, `useMockApi`, `ApiMode.auto|mock`, `isDemoBackend`, runtime mock heuristics.

## Load sequence (target)

```text
main()
  → loadAppConfig() / AppConfig.fromEnvironment()
  → validate apiBaseUrl non-empty (fail fast)
  → validate streamApiKey non-empty unless STREAM_API_KEY_OPTIONAL (tests)
  → wire repositories (HTTP only)
```

## Repository behavior

| Repository | Before | After |
|------------|--------|-------|
| `EventsRepository` | mock branch + `MockEventAttendanceStore` | Dio only; errors → `Failure` |
| `TripsRepository` | mock branch | Dio only |
| `UsersRepository` | mock branch | Dio only |
| `StreamChatService` | `demoSkipped` when mock | token path or `missingApiKey` / `error` |
| `InterestsRepository` | already live-only | unchanged |

## Auth entry points (deployed)

| Flow | Kept |
|------|------|
| LinkedIn BFF (web) | Yes |
| OAuth providers configured via defines | Yes |
| Demo sign-in (fake tokens) | **No** |
| Dev backend exchange (`dev-smoke-user`) | **No** |

## UI / l10n entities to remove

| Key / state | Purpose (legacy) |
|-------------|------------------|
| `demoSignIn` | Debug mock auth button |
| `chatsDemoHint` | Mock API chat skip message |
| `StreamChatConnectStatus.demoSkipped` | Chat unavailable in mock mode |

## Test-scoped entities (allowed)

| Entity | Location | Rule |
|--------|----------|------|
| JSON fixtures | `frontend/test/fixtures/` | Shape samples for mappers/widget tests |
| `AppConfig` test instances | `test/`, `integration_test/` | Explicit URLs; no `ApiMode.mock` |
| `STREAM_API_KEY_OPTIONAL` | test dart-define | Widget tests without Stream |

## Policy entity

**LiveOnlyClientPolicy**

- **environments**: dev, test, prod (deployed)
- **dataSource**: backend API only
- **mockRuntimeAllowed**: false in `lib/`
- **verification**: no `useMockApi` in `lib/`; deployed smoke uses real auth + API
