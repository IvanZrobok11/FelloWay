# Implementation Plan: Remove mock and local-only client runtime paths

**Branch**: `015-remove-mock-local` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Spec + clarification: validation on **deployed** dev/test/prod only (no product mock/local runtime)

## Summary

Remove the parallel **mock API** and **local-only** paths from the Flutter client so every shipped build behaves like CI deploy: **live HTTP + real auth only**. Delete `ApiMode` / `useMockApi`, `lib/shared/mocks`, demo data modules, demo/local sign-in UI, and Stream `demoSkipped`; simplify `AppConfig` and repositories; update tests to use `test/` fixtures; align README and operator quickstart with `013` live-only deploy policy.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter stable (`frontend/`, SDK `^3.10.4`)

**Primary Dependencies**: `dio`, `go_router`, `flutter_appauth` / BFF web auth, `stream_chat`, existing repositories + `AppConfig`

**Storage**: N/A (no client-side mock stores); `TokenStorage` unchanged

**Testing**: `flutter test` (unit/widget); update tests that used `ApiMode.mock`; optional `integration_test/` constructor updates; grep gate `useMockApi` absent from `lib/`

**Target Platform**: Flutter Web (primary acceptance on deployed dev); Android/iOS share same `lib/` — live-only applies to all shipped targets

**Project Type**: Flutter app in `frontend/` + .NET API (out of scope for code changes)

**Performance Goals**: No regression in web cold start (removing branches should slightly reduce work); no new per-screen mode checks (NFR-PERF-001)

**Constraints**:

- No mock fallback when API fails (error/retry only)
- CI already passes `API_MODE=live` — client stops reading mock/auto
- Backend test DB harness unchanged
- Test fakes stay under `test/` only

**Scale/Scope**: ~15–20 Dart files in `lib/`; 4 delete targets in `lib/shared/mocks` + `demo_*.dart`; l10n 2 keys; 1 enum value; README + specs cross-links

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | Delete dead code; `flutter analyze` on touched paths |
| Test strategy | Pass | Update widget/unit tests; add grep/regression for no mock in `lib/` |
| UX consistency | Pass | Remove debug buttons; keep error/empty patterns for API failures |
| Performance | Pass | Fewer runtime branches; no new network |
| Flutter checks | Pass | `flutter analyze`, `dart format`, full `flutter test` |
| Evidence | Pass | [quickstart.md](./quickstart.md) deployed smoke + CI green |

**Post-design re-check**: Pass. No constitution exceptions.

## Project Structure

### Documentation (this feature)

```text
specs/015-remove-mock-local/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/live-only-client-policy.md
└── tasks.md                    # /speckit.tasks
```

### Source Code (touch list)

```text
frontend/lib/
├── app/config/
│   ├── app_config.dart         # remove ApiMode, useMockApi, example.com heuristics
│   └── api_mode.dart           # DELETE
├── app/app.dart                # drop useMockApi from scope
├── main.dart                   # simplify web auth wiring
├── features/auth/
│   ├── presentation/oauth_sign_in_page.dart  # remove demo + local backend sign-in
│   └── domain/web_auth_mode.dart             # drop useMockApi param
├── features/events/data/
│   ├── events_repository.dart  # HTTP only
│   └── demo_events.dart        # DELETE
├── features/trips/data/
│   ├── trips_repository.dart
│   └── demo_trips.dart         # DELETE
├── features/profile/data/
│   ├── users_repository.dart
│   └── demo_reviews.dart       # DELETE
├── features/chats/
│   ├── data/stream_chat_service.dart
│   └── presentation/chats_list_page.dart
├── features/profile/presentation/profile_page.dart
├── shared/mocks/               # DELETE directory
└── l10n/                       # remove demoSignIn, chatsDemoHint

frontend/test/
├── unit/app_config_api_mode_test.dart   # DELETE or replace with live-only tests
├── widget/app_smoke_test.dart           # remove ApiMode.mock
└── fixtures/                            # absorb any needed demo payloads

.github/workflows/              # optional: remove API_MODE define when unused
frontend/README.md              # deployed-only operator docs
```

**Structure Decision**: Single Flutter app (`frontend/`); no new packages. Refactor is deletion + simplification within existing feature folders.

## Implementation Phases

### Phase A — Config surface (FR-004)

1. Delete `api_mode.dart`; remove `apiMode` / `useMockApi` from `AppConfig`.
2. `fromEnvironment`: require non-empty `API_BASE_URL` (fail in `loadAppConfig` with message pointing to CI defines).
3. Remove `example.com` → localhost callback fallback; use `{apiBaseUrl}/auth/linkedin/callback` only.
4. Update `AppScope` / `web_auth_mode.dart` / `main.dart` to stop passing `useMockApi`.

### Phase B — Repositories & chat (FR-001, FR-003)

1. Strip all `if (_config.useMockApi)` branches from `EventsRepository`, `TripsRepository`, `UsersRepository`.
2. Delete `mock_event_attendance_store.dart` usage (live attend flows only).
3. `StreamChatService`: remove mock branch; delete `demoSkipped` enum value and handler in `chats_list_page.dart`.

### Phase C — Auth UI & l10n (FR-002, FR-005)

1. Remove `_demoSignIn`, `_devBackendSignIn`, and related UI blocks from `oauth_sign_in_page.dart`.
2. Remove `demoSignIn`, `chatsDemoHint` from ARB files; run `flutter gen-l10n`.
3. Simplify onboarding completion paths that branched on `useMockApi` (`pushDraft`, `homeCityId`).

### Phase D — Delete demo modules (FR-003)

1. Delete `lib/shared/mocks/`, `demo_events.dart`, `demo_trips.dart`, `demo_reviews.dart`.
2. If tests need payloads, add minimal copies under `test/fixtures/`.

### Phase E — Tests & docs (FR-006, FR-007, VR-001–005)

1. Update widget/unit tests to `AppConfig` without mock mode; fix `app_smoke_test.dart`.
2. Delete or rewrite `app_config_api_mode_test.dart`.
3. Rewrite `frontend/README.md`: remove API modes / localhost matrix; point to [quickstart.md](./quickstart.md) and `013`.
4. Optional: add CI grep step or document manual `rg` in quickstart.
5. Cross-link `005`/`001`/`011` quickstarts where they mention `API_MODE=mock`.

### Phase F — Deployed validation (VR-004)

1. Merge → push `main` → verify dev deploy.
2. Execute [quickstart.md](./quickstart.md) smoke on dev web URL.

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
| Contract | [contracts/live-only-client-policy.md](./contracts/live-only-client-policy.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Next Step

**`/speckit.tasks`** — break phases into ordered, testable tasks.
