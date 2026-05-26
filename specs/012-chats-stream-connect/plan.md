# Implementation Plan: Chats tab connects when Stream is configured

**Branch**: `012-chats-stream-connect` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/012-chats-stream-connect/spec.md`

## Summary

Signed-in users on **Chats** see “set STREAM_API_KEY” with **no backend traffic** because `StreamChatService` returns `missingApiKey` when `AppConfig.streamApiKey` is empty—**before** `GET /chat/stream-token`.

Fix: ensure **dev/test/prod web builds** embed the Stream public key via CI `--dart-define` only (see `specs/013-clarify-env-json`), improve **Chats UX** to distinguish missing client config vs server/token errors, add **retry on Chats tab**, and add **tests** for the three paths (missing key / success / failure).

Backend `GET /chat/stream-token` already exists; no new API required.

## Technical Context

**Languages/Versions**:

- **Frontend**: Dart 3.10+ / Flutter stable
- **Backend**: C# 12 / .NET 8 (verification only; endpoint exists)

**Primary Dependencies**:

- **Frontend**: `stream_chat`, `stream_chat_flutter`, `dio`, existing `StreamChatService`, `AppConfig` / `loadAppConfig`
- **Backend**: GetStream server SDK (`FelloWay.Infrastructure.Stream.StreamChatService`)

**Storage**: N/A (Stream public key in compile-time `--dart-define` only on deployed web)

**Testing**:

- Frontend: `flutter test` — unit tests for `StreamChatService` state machine; widget tests for `ChatsListPage` states
- Manual: Network trace on dev web (Eruda) for `/chat/stream-token`

**Target Platform**: Flutter Web (primary report), iOS/Android (same `StreamChatService` path)

**Performance Goals**: Chats tab shows connecting or result within **2s** under normal network (NFR-PERF-001)

**Constraints**:

- Do not call `/chat/stream-token` when public key is absent (FR-003)
- Live deploys must ship non-empty key (FR-004)

**Scale/Scope**: `StreamChatService`, `ChatsListPage`, l10n strings, CI web build steps, docs/quickstart

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality (`flutter analyze`, format) | Pass | Planned in tasks |
| Test strategy (unit/widget + regression) | Pass | VR-002; extend `chats_tab_test` + new service tests |
| UX consistency (loading/empty/error) | Pass | Distinct states for missing key vs error + Retry |
| Performance budget (2s feedback on Chats) | Pass | Connecting UI already present; verify in smoke |
| Evidence plan | Pass | CI logs + quickstart smoke table |

**Post-design re-check**: No constitution violations; no Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/012-chats-stream-connect/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── chat-stream-token.md
└── tasks.md             # Phase 2 (/speckit.tasks)
```

### Source Code (repository root)

```text
frontend/
├── lib/
│   ├── app/
│   │   ├── app.dart                    # _syncChat on auth
│   │   └── config/
│   │       ├── app_config.dart
│   │       └── app_config_loader.dart  # dart-define only (013)
│   └── features/chats/
│       ├── data/stream_chat_service.dart
│       └── presentation/chats_list_page.dart
├── lib/l10n/                           # chatsStreamKeyHint → user-facing copy
└── test/
    ├── unit/                           # stream_chat_service_test.dart (new)
    └── widget/chats_tab_test.dart

backend/
└── src/FelloWay.Api/Controllers/ChatController.cs  # GET /chat/stream-token (existing)

.github/workflows/
├── deploy.yml                          # DEV_STREAM_API_KEY
├── promote-test.yml
└── promote-prod.yml
```

**Structure Decision**: Flutter-first fix in `frontend/`; CI/docs for web deploy; backend unchanged unless token errors need clearer API envelope (optional follow-up).

## Implementation Phases

### Phase A — Configuration & deploy (FR-004, FR-007)

1. **Verify GitHub variables** `DEV_STREAM_API_KEY`, `TEST_STREAM_API_KEY`, `PROD_STREAM_API_KEY` are set (document in `quickstart.md` / `frontend/README.md`).
2. **CI build**: Pass `--dart-define=STREAM_API_KEY=...` in `deploy.yml`, `promote-test.yml`, `promote-prod.yml` only — **no** `env.json` on S3 (policy: `specs/013-clarify-env-json`).
3. **CI assert**: Fail job if `STREAM_API_KEY` is empty or shorter than 8 characters.

### Phase B — Client behavior & UX (FR-001–003, FR-005–006)

1. **`StreamChatService`**
   - Keep early return for empty key (correct—no backend call).
   - Ensure `_fetchStreamToken` errors map to `StreamChatConnectStatus.error` with `NetworkFailure` messages (not dev key hint).
2. **`ChatsListPage`**
   - Replace `chatsStreamKeyHint` usage with new l10n: user-facing “Chat is not available in this version” (+ dev/test subtitle with operator hint if `deploy_env !== prod`).
   - On build: when authenticated and status is `error` or `disconnected`, call `syncWithSession` once (e.g. `initState` / tab visibility).
3. **`FellowayStreamChatScope`** — no change required for this bug; ensure Chats branch still wraps list when connected.

### Phase C — Tests (NFR-TEST-001, VR-002)

1. **Unit**: `StreamChatService` with empty key → `missingApiKey`, mock HTTP adapter asserts **zero** calls to `/chat/stream-token`.
2. **Unit**: non-empty key + mocked `getMe` + token 200 → `connected`.
3. **Unit**: non-empty key + token 401 → `error`.
4. **Widget**: `ChatsListPage` shows new copy for `missingApiKey`; shows `ErrorDisplay` for `error`.

### Phase D — Validation (VR-003–004)

Manual smoke per `quickstart.md` on dev web after deploy.

## Complexity Tracking

> No violations.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Contract | [contracts/chat-stream-token.md](./contracts/chat-stream-token.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Next Step

Run **`/speckit.tasks`** to break Phase A–D into ordered implementation tasks.
