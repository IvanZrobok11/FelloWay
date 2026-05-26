# Research: Remove mock and local-only client runtime paths

**Feature**: `015-remove-mock-local` | **Date**: 2026-05-26

## R1 — Scope of “local” vs “deployed-only” validation

**Decision**: Remove all product-runtime paths intended for workstation-only use (mock API, demo sign-in, “local backend” dev sign-in, `example.com` auto-mock). Acceptance and docs target **deployed dev/test/prod** only (aligned with `013-clarify-env-json`).

**Rationale**: Team does not use `flutter run` for product validation; keeping local/mock branches causes deploy vs dev confusion and dead UI on CloudFront.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep mock mode for maintainers only | Still ships in `lib/`; tests can use `test/` fakes instead |
| Keep `API_MODE=auto` with `example.com` heuristic | Hidden mock on default URL; contradicts live-only policy |
| Keep “local backend” sign-in on deployed dev | Misleading on CloudFront; uses `dev-smoke-user` against wrong host |

## R2 — `ApiMode` and `useMockApi`

**Decision**: Delete `ApiMode` enum and `AppConfig.useMockApi`. Treat all shipped builds as **live HTTP**. CI continues `--dart-define=API_MODE=live` until workflows are simplified in implementation (optional cleanup: drop define when unused).

**Rationale**: Single code path in repositories; no `if (_config.useMockApi)` branches.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep enum with only `live` | Dead API surface |
| Runtime flag from hostname | Same class of bugs as `auto` + `example.com` |

## R3 — Demo data modules (`lib/shared/mocks`, `demo_*.dart`)

**Decision**: Delete `lib/shared/mocks/*`, `demo_events.dart`, `demo_trips.dart`, `demo_reviews.dart`. Move minimal JSON/maps into `test/fixtures/` only where widget tests need sample payloads.

**Rationale**: FR-003; `011` already forbids client mock catalog as product truth.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep files but unreachable | Dead code violates constitution quality gate |
| Keep `MockApiCatalog` in `test/` | OK as renamed test helper if tests need it |

## R4 — Dev / demo sign-in UI

**Decision**: Remove `_demoSignIn`, demo sign-in l10n keys, and **“Sign in (local backend)”** (`_devBackendSignIn`). Deployed auth = LinkedIn BFF (web) + configured OAuth buttons only.

**Rationale**: Both are non-production entry points; deployed team never uses them.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep dev backend sign-in on deployed dev | Security/UX noise; not real LinkedIn flow |
| Gate behind `kDebugMode` only | Still in release web builds if not stripped |

## R5 — Stream chat `demoSkipped` status

**Decision**: Remove `StreamChatConnectStatus.demoSkipped` and `chatsDemoHint` UI branch; chat always attempts token path when authenticated and key present.

**Rationale**: Mock mode was the only path to `demoSkipped`.

## R6 — Default `API_BASE_URL`

**Decision**: Change `fromEnvironment` default from `https://api.example.com` to **empty string** and fail fast in `loadAppConfig()` (or `main`) when `apiBaseUrl` is empty on non-test builds.

**Rationale**: Prevents accidental mock heuristic and silent wrong host; CI always sets URL.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep example.com default | Triggers auto-mock if any code path remains |

## R7 — Tests and `STREAM_API_KEY_OPTIONAL`

**Decision**: Widget/unit tests inject `AppConfig` with explicit `apiBaseUrl` + `streamApiKey` (or test-only optional flag). Delete `app_config_api_mode_test.dart` mock cases; add regression test that repositories never import `shared/mocks`.

**Rationale**: FR-007; test pyramid stays intact without product mock mode.

## R8 — Documentation and CI

**Decision**: Rewrite `frontend/README.md` deploy section; add `quickstart.md` smoke for deployed dev; grep older specs for `API_MODE=mock` and add cross-links to `015` policy. CI workflows: keep `API_MODE=live` (harmless) or remove in same PR when code no longer reads it.

**Rationale**: FR-006, SC-003.

## R9 — `localhost` in `linkedInBffCallbackUriForApi`

**Decision**: Remove `example.com` → `localhost:7086` fallback; require non-empty `apiBaseUrl` to build callback URI as `{apiBaseUrl}/auth/linkedin/callback`.

**Rationale**: Local-only default; deployed builds always have real API URL from CI.

## R10 — Files explicitly out of scope

**Decision**: No changes to backend InMemory tests, `integration_test/` device runners (may update config constructors), `frontend/web/env.json.example` (delete or mark deprecated in README only), `.vscode/launch.json` (maintainer optional; not product path).

**Rationale**: Spec clarifications.
