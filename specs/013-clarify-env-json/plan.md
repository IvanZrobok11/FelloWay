# Implementation Plan: Web config without `env.json` on deployed environments

**Branch**: `013-clarify-env-json` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Spec + clarification: team uses **only deployed** dev/test/prod, not local `flutter run`

## Summary

**`env.json` is not needed on S3/CloudFront.** Deployed web must get the Stream public key (and other public defines) **only** from CI at `flutter build web` via `--dart-define=STREAM_API_KEY=...`. The optional runtime fetch of `/env.json` in `loadAppConfig()` is misleading for server environments and should be removed; docs and `012-chats-stream-connect` plan must align (no post-build `env.json`).

## Technical Context

**Languages/Versions**:

- **Frontend**: Dart 3.10+ / Flutter stable (web deploy)
- **CI**: GitHub Actions (`deploy.yml`, `promote-test.yml`, `promote-prod.yml`)

**Primary Dependencies**:

- `AppConfig.fromEnvironment()` / `loadAppConfig()`
- `web_deploy_env_web.dart` (to remove or gate off)
- Existing CI: `DEV_/TEST_/PROD_STREAM_API_KEY` → `--dart-define`

**Storage**: N/A (compile-time constants in web bundle only)

**Testing**:

- Unit: `loadAppConfig` / `AppConfig` without env.json mock
- CI: build fails when Stream key var unset (already)
- Manual: deploy smoke — no `/env.json` request; Chats token call

**Target Platform**: Flutter Web on AWS (dev, test, prod)

**Performance Goals**: No extra startup HTTP for config on deploy (remove env.json fetch)

**Constraints**:

- No `env.json` on S3 for any server environment
- Local dev workflow out of acceptance scope (may keep `env.json.example` as undocumented helper only)

**Scale/Scope**: `app_config_loader.dart`, `web_deploy_env_web.dart`, README, `012` plan artifacts, optional CI assert

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | `flutter analyze` on touched files |
| Test strategy | Pass | Unit tests for config load without HTTP fallback |
| UX consistency | Pass | Chats copy from 012; no user-facing env.json mentions on deploy |
| Performance | Pass | Remove unnecessary startup fetch |
| Evidence | Pass | quickstart smoke table + CI logs |

**Post-design re-check**: Pass. No unjustified complexity.

## Project Structure

### Documentation (this feature)

```text
specs/013-clarify-env-json/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/web-deploy-config-policy.md
└── tasks.md                    # /speckit.tasks
```

### Source Code

```text
frontend/lib/app/config/
├── app_config.dart
├── app_config_loader.dart      # remove env.json fallback path
├── web_deploy_env_web.dart       # delete or stub no-op
└── web_deploy_env_stub.dart

frontend/README.md                # single policy: CI only on deploy

.github/workflows/
├── deploy.yml                    # verify dart-define only (no env.json write)
├── promote-test.yml
└── promote-prod.yml

specs/012-chats-stream-connect/   # align: drop env.json from plan/research/quickstart
```

## Implementation Phases

### Phase A — Code: single config path for deploy (FR-001, FR-002, FR-005)

1. **`loadAppConfig()`**: After `AppConfig.fromEnvironment()`, if `streamApiKey` empty → `StateError` (unchanged) **without** calling `loadStreamApiKeyFromDeploy()`.
2. **Remove** `web_deploy_env_web.dart` fetch logic (or entire conditional import if unused).
3. Update error message to mention **CI `--dart-define=STREAM_API_KEY`** for deploy, not `env.json`.
4. Keep `STREAM_API_KEY_OPTIONAL` for tests only.

### Phase B — Docs & cross-feature alignment (FR-003, FR-006)

1. **`frontend/README.md`**: Deploy section = CI variables only; remove “loads web/env.json or /env.json” for server paths.
2. **`specs/012-chats-stream-connect/`**: Edit plan.md, research.md, data-model.md, quickstart.md — remove “CI writes env.json” and runtime fallback; dart-define only.
3. Add pointer from 012 quickstart to 013 policy.

### Phase C — CI verification (FR-004)

1. Confirm all three workflows already fail when `STREAM_API_KEY` empty (no change or explicit comment).
2. **Optional**: Post-build script checks `build/web` does not contain accidental empty define (grep/heuristic)—document in quickstart.
3. **Do not** add step writing `build/web/env.json`.

### Phase D — Validation (VR-001–004)

1. Deploy dev after merge; Eruda: no `/env.json`, Chats → `/chat/stream-token`.
2. Documentation grep: no “upload env.json to S3” for prod.

### Coordination with 012

Implement **013** before or together with **012** Phase A so chat work does not reintroduce `env.json`.

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
| Contract | [contracts/web-deploy-config-policy.md](./contracts/web-deploy-config-policy.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Next Step

**`/speckit.tasks`** — then implement 013 + align 012 (Chats UX/tests without env.json).
