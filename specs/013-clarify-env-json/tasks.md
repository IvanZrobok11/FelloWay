# Tasks: Web config without `env.json` on deployed environments

**Input**: Design documents from `/specs/013-clarify-env-json/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/web-deploy-config-policy.md](./contracts/web-deploy-config-policy.md)

**Tests**: Included per spec NFR-TEST-001 and constitution.

**Organization**: Tasks grouped by user story. Implement **Foundational (Phase 2) before US1** so Chats work in `012` does not reintroduce `env.json`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks in same story)
- **[Story]**: US1, US2, US3 per [spec.md](./spec.md)

## Path Conventions

- Flutter app: `frontend/lib/`, `frontend/test/`
- CI: `.github/workflows/`
- Docs: `frontend/README.md`, `specs/013-clarify-env-json/`, `specs/012-chats-stream-connect/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm scope and prerequisites before code changes.

- [x] T001 Review [spec.md](./spec.md), [plan.md](./plan.md), and [contracts/web-deploy-config-policy.md](./contracts/web-deploy-config-policy.md) for deploy-only policy (no local `env.json` on S3)
- [x] T002 Verify GitHub repository variables `DEV_STREAM_API_KEY`, `TEST_STREAM_API_KEY`, `PROD_STREAM_API_KEY` are documented in [quickstart.md](./quickstart.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Single config path at app startup—no runtime `/env.json` fetch. **Blocks all user stories.**

**⚠️ CRITICAL**: Complete before US1 deploy validation or `012` Chats implementation.

- [x] T003 Remove `loadStreamApiKeyFromDeploy()` call and env.json branch from `frontend/lib/app/config/app_config_loader.dart`
- [x] T004 [P] Remove or no-op HTTP fetch in `frontend/lib/app/config/web_deploy_env_web.dart`; keep stub in `frontend/lib/app/config/web_deploy_env_stub.dart` if import still required
- [x] T005 Update startup `StateError` message in `frontend/lib/app/config/app_config_loader.dart` to reference CI `--dart-define=STREAM_API_KEY` (not `env.json`) for deploy
- [x] T006 [P] Add unit tests in `frontend/test/unit/app_config_loader_test.dart`: config loads when `STREAM_API_KEY` provided via environment; no Dio/HTTP to `env.json`
- [x] T007 [P] Add unit test in `frontend/test/unit/app_config_loader_test.dart`: empty key throws without attempting env.json load (mock or spy if needed)
- [x] T008 [P] Align `specs/012-chats-stream-connect/plan.md`, `research.md`, `data-model.md`, `quickstart.md` to remove env.json post-build and runtime fallback (dart-define only)

**Checkpoint**: App startup never requests `/env.json`; 012 docs consistent with 013 policy.

---

## Phase 3: User Story 1 - Deployed web works with CI-only config (Priority: P1) 🎯 MVP

**Goal**: Dev/test/prod web bundles include Stream public key from CI; Chats can reach backend token endpoint without `env.json` on the host.

**Independent Test**: Deploy dev with CI variables only (no `env.json` on bucket). Eruda: no `GET /env.json`; after sign-in, `GET /chat/stream-token`; Chats not stuck on “set STREAM_API_KEY” when variable is set.

### Tests for User Story 1

- [x] T009 [P] [US1] Add unit test in `frontend/test/unit/app_config_stream_key_test.dart` asserting non-empty `AppConfig.streamApiKey` when compiled with `--dart-define=STREAM_API_KEY=test-key` (document pattern in test file comment)
- [x] T010 [P] [US1] Extend `frontend/test/widget/chats_tab_test.dart` or add `frontend/test/unit/stream_chat_service_test.dart`: empty `streamApiKey` → `missingApiKey` without mock HTTP to `/chat/stream-token`

### Implementation for User Story 1

- [x] T011 [P] [US1] Audit `.github/workflows/deploy.yml`, `promote-test.yml`, `promote-prod.yml`: confirm `--dart-define=STREAM_API_KEY="$STREAM_API_KEY"` and fail-fast when empty; add workflow comment that env.json is not used
- [x] T012 [US1] Confirm workflows do **not** write `build/web/env.json` (remove if any draft step exists)
- [x] T013 [P] [US1] Optional: add post-build check in `deploy.yml` that fails if `STREAM_API_KEY` length &lt; 8 (shell grep/heuristic on build log or define echo)
- [x] T014 [US1] Run `flutter build web --release` locally with defines to sanity-check startup (optional maintainer check; acceptance is deploy smoke)

**Checkpoint**: CI-only web artifact policy enforced in code + workflows; ready for deploy smoke.

---

## Phase 4: User Story 2 - Documentation states one rule (Priority: P2)

**Goal**: One clear rule everywhere: deployed envs = build-time dart-define only; no `env.json` on S3.

**Independent Test**: Grep docs for “env.json on S3” / “upload env.json”; answer to “need env.json on prod?” is **no** with link to [quickstart.md](./quickstart.md).

### Implementation for User Story 2

- [x] T015 [P] [US2] Update `frontend/README.md` Runtime config section: deploy = CI `DEV_/TEST_/PROD_STREAM_API_KEY` only; remove “loads `/env.json`” for server environments
- [x] T016 [P] [US2] Update `infra/README.md` GetStream section if it implies runtime `env.json` on deploy
- [x] T017 [US2] Add cross-link in `specs/012-chats-stream-connect/quickstart.md` pointing to `specs/013-clarify-env-json/quickstart.md` policy

**Checkpoint**: No contradictory deploy documentation.

---

## Phase 5: User Story 3 - Support triage checklist (Priority: P3)

**Goal**: Support resolves “Chats / STREAM_API_KEY on deploy” via CI variable + redeploy, not env.json upload.

**Independent Test**: Walk through [quickstart.md](./quickstart.md) tables for “empty key in bundle” vs “token 401” paths; actions differ and never say “add env.json”.

### Implementation for User Story 3

- [x] T018 [P] [US3] Expand troubleshooting section in `specs/013-clarify-env-json/quickstart.md` with decision tree (missing CI key vs backend token failure vs CloudFront cache)
- [x] T019 [US3] Add short operator checklist to `specs/013-clarify-env-json/contracts/web-deploy-config-policy.md` verification table if gaps found

**Checkpoint**: Support can triage in &lt;5 minutes using docs only.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, 012 Chats follow-up, manual deploy validation.

- [x] T020 [P] Implement or verify remaining `specs/012-chats-stream-connect` items (Chats UX copy, retry on tab, token path) **without** env.json—after T003–T008 complete
- [x] T021 Run `flutter analyze` in `frontend/` and fix any issues from config loader changes
- [x] T022 Run `flutter test` for `frontend/test/unit/app_config_loader_test.dart` and related chat tests
- [ ] T023 Manual deploy smoke on dev per [quickstart.md](./quickstart.md): VR-002 (no `/env.json`), VR-004 (`/chat/stream-token` after sign-in) — **operator: after merge/deploy**
- [x] T024 [P] Grep repo for “env.json” deploy recommendations; fix stragglers outside intentional `env.json.example` local hint

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** (foundational) → **US1 / US2 / US3** (US2/US3 can parallel after Phase 2)
- **Phase 6** depends on US1 code + docs; deploy smoke (T023) after merge/deploy

### User Story Dependencies

| Story | Depends on | Can parallel with |
|-------|------------|-------------------|
| US1 (P1) | Phase 2 complete | US2, US3 after Phase 2 |
| US2 (P2) | Phase 2 complete | US3 |
| US3 (P3) | Phase 2 complete | US2 |

### Within User Story 1

1. Tests T009–T010 (may fail until T003–T005)
2. Code foundational T003–T005
3. CI tasks T011–T013
4. Deploy smoke T023 (manual)

### Parallel Opportunities

```bash
# Phase 2 parallel:
T004 web_deploy_env_web.dart
T006 app_config_loader_test.dart
T007 app_config_loader_test.dart
T008 specs/012 alignment

# After Phase 2, US2 + US3 parallel:
T015 frontend/README.md
T018 quickstart.md troubleshooting
```

---

## Parallel Example: User Story 1

```bash
# Tests in parallel after foundational code lands:
flutter test test/unit/app_config_stream_key_test.dart
flutter test test/unit/stream_chat_service_test.dart

# CI workflow audits in parallel:
# Review deploy.yml, promote-test.yml, promote-prod.yml
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2 (remove env.json path + align 012 docs)
2. Complete Phase 3 US1 (CI verify + tests)
3. **STOP**: Deploy dev smoke (T023)—Chats + no env.json request
4. Then US2/US3 docs polish

### With 012-chats-stream-connect

1. Finish **013 Phase 2** first (policy locked)
2. Run **012** Chats UX/tests (T020) using dart-define-only deploy model
3. Do not add `env.json` to CI or S3 in either feature

---

## Notes

- Total tasks: **24**
- US1: **6** implementation/CI + **2** test tasks (+ foundational enables US1)
- US2: **3** tasks
- US3: **2** tasks
- Foundational: **6** tasks (includes 012 doc alignment)
- Local `web/env.json` remains optional for developers only; not part of deploy acceptance
- Suggested MVP scope: **Phase 2 + US1 + T023 deploy smoke**
