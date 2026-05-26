# Research: Chats tab Stream connect (012)

**Date**: 2026-05-26

## 1. Root cause of “set STREAM_API_KEY” with no backend requests

**Decision**: Treat as **client-side early exit** when `AppConfig.streamApiKey` is empty at runtime, not a backend outage.

**Rationale**:

- `StreamChatService.syncWithSession` returns `StreamChatConnectStatus.missingApiKey` when `_config.streamApiKey.isEmpty` **before** any HTTP call (`frontend/lib/features/chats/data/stream_chat_service.dart` lines 51–53).
- `ChatsListPage` maps `missingApiKey` to `l10n.chatsStreamKeyHint` (“Щоб увімкнути GetStream, задайте STREAM_API_KEY.”).
- Backend token path is `GET /chat/stream-token` (`ChatController`), only reached from `_fetchStreamToken()` after key check and `getMe()` succeed.

**Alternatives considered**:

- Backend misconfiguration only — rejected; no request is sent when key is empty on client.
- StreamChat wrapper bug — rejected; status enum and UI mapping are explicit.

## 2. How Stream public key reaches Flutter web in deploy

**Decision**: **Compile-time only** — `--dart-define=STREAM_API_KEY=...` from GitHub `DEV_/TEST_/PROD_STREAM_API_KEY` at `flutter build web`. **No** runtime `/env.json` on S3 (aligned with `specs/013-clarify-env-json`).

**Rationale**:

- `AppConfig.fromEnvironment()` reads `String.fromEnvironment('STREAM_API_KEY')` at compile time.
- Deployed web issues are almost always: CI variable unset, old artifact, or CloudFront cache — not a missing runtime file on the host.
- CI workflows fail the build when the variable is empty or too short.

**Alternatives considered**:

- Runtime `env.json` on S3 — **rejected** (013 policy).
- Remove startup requirement — rejected; spec requires clear configuration vs silent failure.

## 3. Backend token endpoint behavior

**Decision**: Keep `GET /chat/stream-token` as the single token source; no new endpoint required.

**Rationale**:

- `ChatController.GetStreamToken` returns `{ token }` for authenticated users.
- `StreamChatService` (Infrastructure) mints JWT via GetStream SDK when `Stream:ApiKey` + `Stream:ApiSecret` configured; otherwise returns dev placeholder token `dev-stream-token-{userId}` (local dev without Stream secrets).

**Alternatives considered**:

- New `/chat/connect` aggregate endpoint — rejected; unnecessary for this fix.

## 4. UX for configuration vs server failure

**Decision**: Separate copy and UI state for **chat not enabled in this build** vs **could not connect (retry)**.

**Rationale**:

- Spec FR-003 / SC-004 require operators to distinguish missing key vs token failure in &lt;1 minute via UI + network trace.
- Current `chatsStreamKeyHint` reads like a developer instruction; replace with user-facing “chat unavailable in this app version” plus optional dev-only detail in non-prod.

**Alternatives considered**:

- Single generic error — rejected; caused reported confusion.

## 5. When to trigger chat sync

**Decision**: Keep global `_syncChat()` on auth change and app start; **add** explicit re-sync when user navigates to **Chats** (main shell tab) when authenticated — mainly for retry after transient `error`.

**Rationale**:

- Today sync runs in `FellowayApp.initState` post-frame and on `authSession` listener—not on tab switch.
- If first sync failed transiently, user may open Chats without retry unless they re-auth.
- Low-cost: `ChatsListPage` or shell callback invokes `syncWithSession` when tab selected and authenticated.

**Alternatives considered**:

- Poll on Chats only — rejected; auth-time sync still needed for DM from event detail.

## 6. Web deploy verification

**Decision**: CI passes `--dart-define=STREAM_API_KEY=...` only; **no** `env.json` on S3 (`specs/013-clarify-env-json`). Smoke: no `/env.json` request; Chats shows `/chat/stream-token` when authenticated.

**Rationale**:

- Single config channel; matches removed runtime fallback in `loadAppConfig()`.

**Alternatives considered**:

- Terraform-only key injection — out of scope; Flutter artifact is built in GitHub Actions, not on S3 directly from Terraform.
