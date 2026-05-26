# Feature Specification: Chats tab connects when Stream is configured

**Feature Branch**: `012-chats-stream-connect`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: "коли переходжу на chats нічого не відбувається, пише повідомлення що Щоб увімкнути GetStream, задайте STREAM API_KEY але немає запитів до бекенду"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Signed-in user opens Chats with working chat (Priority: P1)

An authenticated user who has completed onboarding opens the **Chats** tab. The app establishes a chat session, shows a loading state while connecting, then displays their conversation list (or an empty state if they have no channels yet). The user can tap a conversation to open it.

**Why this priority**: Without this, the core social value of the product (messaging) is unavailable even when the user is logged in.

**Independent Test**: Sign in on a correctly configured environment (Stream public key present, backend chat token endpoint healthy), open **Chats**, verify conversation UI or empty state appears—not a static configuration hint.

**Acceptance Scenarios**:

1. **Given** the user is signed in and chat is enabled for the environment, **When** they open **Chats**, **Then** they see a connecting indicator followed by either a channel list or an empty-state message—not a prompt to set `STREAM_API_KEY`.
2. **Given** the user is signed in and chat is enabled, **When** they open **Chats**, **Then** the app requests a chat session token from the backend before showing the channel list.
3. **Given** the user has at least one conversation, **When** the channel list loads, **Then** they can open a conversation and see messages or an empty thread.

---

### User Story 2 - Clear feedback when chat is not configured (Priority: P2)

When chat cannot start because the Stream public key is missing from the deployed client build (or local run configuration), the user sees an explanation that chat is not enabled for this build—and that signing in or refreshing alone will not fix it. The message MUST NOT imply that the backend is down when no configuration request was attempted.

**Why this priority**: The reported bug shows a misleading message: users think the backend failed, but the client never attempted token retrieval.

**Independent Test**: Run or deploy a build without a Stream public key, sign in, open **Chats**, verify the message explains client/build configuration and that no backend chat-token request occurs.

**Acceptance Scenarios**:

1. **Given** a build with no Stream public key configured, **When** a signed-in user opens **Chats**, **Then** they see a configuration message (not a generic load error) and no backend chat-token request is made.
2. **Given** a build with no Stream public key, **When** the user opens **Chats**, **Then** the UI does not show an infinite spinner or blank screen.

---

### User Story 3 - Recoverable errors when backend or Stream fails (Priority: P3)

When the Stream public key is present but the backend cannot issue a token (network, 401, server error, Stream misconfiguration), the user sees a specific error with a **Retry** action. Opening **Chats** again or tapping **Retry** triggers a new token request.

**Why this priority**: Distinguishes real outages from missing build configuration and supports support/debugging.

**Independent Test**: Configure a valid Stream public key but break backend token endpoint (or revoke auth); open **Chats** and verify error + retry triggers a new backend request.

**Acceptance Scenarios**:

1. **Given** a valid Stream public key and a signed-in user, **When** the backend token request fails, **Then** the user sees an error message referencing connection or server failure (not `STREAM_API_KEY`) and can retry.
2. **Given** a failed token request, **When** the user taps **Retry**, **Then** the app issues another backend token request.

---

### Edge Cases

- User opens **Chats** before chat sync finishes after sign-in: show connecting state, then resolve to list, empty, or error—not configuration hint if key is present.
- User signs out while on **Chats**: chat disconnects; guest/sign-in prompt or empty state per existing auth rules.
- Demo/mock mode: chat may be intentionally skipped; message must differ from “set STREAM_API_KEY” in live mode.
- Web deploy where key is only in CI build defines vs runtime `env.json`: live environments must receive the public key through one supported channel documented for operators.
- User switches tabs (Events → Chats → Events): **Chats** state is preserved or re-synced without requiring app restart.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: For signed-in users in live (non-demo) mode, the system MUST attempt to obtain a chat session token from the backend when the Stream public key is configured in the client.
- **FR-002**: The system MUST NOT show the “set STREAM_API_KEY” (or equivalent) message when a Stream public key is already configured in the client.
- **FR-003**: When the Stream public key is missing from the client configuration, the system MUST show a dedicated configuration-unavailable state on **Chats** and MUST NOT call the backend chat-token endpoint.
- **FR-004**: Deployed web builds for dev, test, and prod MUST include a non-empty Stream public key via the project’s supported configuration path (build-time define and/or deployed runtime config file), so signed-in users can reach backend token exchange in those environments.
- **FR-005**: On **Chats**, the system MUST show distinct UI states: connecting, connected (list or empty), configuration missing, and retriable error.
- **FR-006**: On retriable failure, the user MUST be able to retry without restarting the app.
- **FR-007**: Operators MUST have documented steps to verify chat configuration (public key present in build, backend token endpoint returns success for an authenticated user).

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis requirements with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover core flows and regressions for bugs addressed by this feature.
- **NFR-UX-001**: User-facing interactions MUST follow the project design system and consistent loading/empty/error/accessibility patterns.
- **NFR-PERF-001**: Opening **Chats** after the user is already connected MUST show feedback within 2 seconds under normal network conditions (connecting indicator or result).
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Feature MUST define required unit, widget, and integration test coverage for configuration-missing vs token-success vs token-failure paths.
- **NFR-FLUTTER-UX-001**: Feature MUST preserve theme/design-token consistency and platform-appropriate behavior.
- **NFR-FLUTTER-PERF-001**: Chat connect MUST not block navigation to other tabs; failures remain isolated to **Chats**.

### Validation Requirements *(mandatory)*

- **VR-001**: `flutter analyze` passes for `frontend/`.
- **VR-002**: Unit/widget tests cover: missing key (no backend call), present key + successful token (connecting → list/empty), present key + failed token (error + retry).
- **VR-003**: Manual smoke on at least one live environment: signed-in user opens **Chats**, network trace shows chat-token request, UI is not stuck on configuration hint.
- **VR-004**: Manual smoke on web deploy: confirm Stream public key is present in built artifact or runtime config for that environment.

### Key Entities

- **Stream public key**: Client-side identifier required to initialize the chat SDK; not secret but must be present per environment build.
- **Chat session token**: Short-lived credential issued by the backend for the signed-in user to connect to the chat service.
- **Chat connection state**: One of: not configured, connecting, connected, error, disconnected.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a correctly configured dev/test/prod environment, at least 95% of signed-in **Chats** tab opens (manual sample of 20 attempts) show connecting then list/empty—not the `STREAM_API_KEY` configuration hint.
- **SC-002**: On a correctly configured environment, 100% of successful **Chats** opens after sign-in include at least one backend chat-token request in network traces.
- **SC-003**: On a build without a Stream public key, 100% of **Chats** opens show the configuration message and zero backend chat-token requests.
- **SC-004**: Support/debug time to distinguish “key missing in build” vs “backend token failed” is under 1 minute using UI state and network trace (no ambiguous combined message).

## Assumptions

- Chat uses a third-party messaging provider (GetStream) requiring both a client public key and a server-minted user token.
- Backend already exposes (or will expose as part of this feature scope) an authenticated endpoint to obtain a Stream token for the current user.
- Live environments (dev, test, prod) are intended to have chat enabled; demo/mock mode may skip live chat by design.
- The reported issue occurs in live mode where the client believes `streamApiKey` is empty at runtime (e.g., web deploy without key in build or runtime config), causing early exit before any backend call.
- Fixing operator/CI configuration for `STREAM_API_KEY` on web builds is in scope alongside clearer UX and connect flow verification.

## Out of Scope

- Building new chat features (reactions, attachments, push for chat) beyond establishing connect + list + open channel.
- Migrating away from GetStream to another provider.
- Chat moderation/admin tooling.
