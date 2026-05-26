# Feature Specification: Web config without `env.json` on deployed environments

**Feature Branch**: `013-clarify-env-json`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: "а чи потрібен взагалі env.json" + clarification: "я не запускаю локально, тільки на середовищах"

## Clarifications

### Session 2026-05-26

- Q: Is local development in scope for this decision? → A: **No** — the team validates and uses the app only on **deployed environments** (dev, test, prod), not via local `flutter run`.
- Q: Is `env.json` required on deployed web hosts? → A: **No** — deployed environments MUST rely on **build-time configuration** injected in CI (e.g. Stream public key at `flutter build web`). A runtime `env.json` on S3/CloudFront is **not** part of the supported deployment model.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deployed web works with CI-only config (Priority: P1)

As an operator deploying to dev, test, or prod, I need the web app to receive all required public runtime values (including chat) from the CI build step alone, so that features work on CloudFront without any `env.json` file on the host.

**Why this priority**: The reported Chats issue (“set STREAM_API_KEY” with no backend calls) occurs on deployed web when the build omitted the key—not because `env.json` was missing at runtime.

**Independent Test**: Deploy to one environment using only CI variables (no `env.json` on the bucket). Sign in, open **Chats**, confirm chat connects and network shows token request—not the configuration hint.

**Acceptance Scenarios**:

1. **Given** a successful CI web build with required public values embedded at build time, **When** the artifact is synced to S3/CloudFront, **Then** the app starts and chat initializes **without** `https://<web-host>/env.json` being present or requested.
2. **Given** dev, test, and prod deployment pipelines, **When** operators follow documented deploy steps, **Then** no step requires creating or uploading `env.json`.

---

### User Story 2 - Documentation states one rule for all server environments (Priority: P2)

As a team member, I need a single written policy: **deployed environments use build-time config only; `env.json` is not used**, so nobody wastes time adding or debugging a runtime file on S3.

**Why this priority**: Mixed messages in README/plan (dart-define vs optional `env.json`) caused confusion about whether deploys need a second config channel.

**Independent Test**: Read `frontend/README.md` and deployment docs; confirm they match the policy above with no contradictory “optional env.json on S3” wording for server environments.

**Acceptance Scenarios**:

1. **Given** the configuration policy document, **When** an engineer asks “do we need env.json on prod?”, **Then** the answer is **no** with reference to CI `STREAM_API_KEY` (and peers) at build time.
2. **Given** GitHub Actions web build jobs, **When** `DEV_/TEST_/PROD_STREAM_API_KEY` is set, **Then** the build fails fast if the key is missing—before sync to S3.

---

### User Story 3 - Support triages deploy config in under 5 minutes (Priority: P3)

As support, when deployed web shows “chat not configured” or similar, I need a checklist that points to **missing CI build variable or bad artifact**, not “upload env.json”.

**Why this priority**: Wrong triage path delays fixes (editing S3 instead of fixing CI variable or redeploying).

**Independent Test**: Walk through checklist for a build with empty Stream key vs healthy build; each path yields a distinct corrective action.

**Acceptance Scenarios**:

1. **Given** deployed web with empty Stream key in the built bundle, **When** the checklist is applied, **Then** the action is “fix CI variable and redeploy web”—not “add env.json”.
2. **Given** deployed web with valid build-time key but backend token failure, **When** the checklist is applied, **Then** the action targets API/auth/Stream server config—not client `env.json`.

---

### Edge Cases

- CI variable set but typo in workflow prevents passing it to `flutter build web`.
- Old CloudFront cache serves previous bundle without key after redeploy (invalidate required).
- Artifact inspected: `env.json` present from an old experiment—must not override or conflict with compile-time values (policy: do not ship it).
- Test/prod promote workflows use different variable names; one env missing key while others work.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: For **dev, test, and prod** web deployments, the authoritative source of public runtime values (including Stream) MUST be **build-time injection in CI**, not a runtime file on the web host.
- **FR-002**: Deployed web artifacts MUST NOT require `env.json` at the web origin for correct startup or chat.
- **FR-003**: Deployment documentation MUST state explicitly that `env.json` is **not used** on server environments and MUST NOT instruct operators to upload it to S3/CloudFront.
- **FR-004**: CI web build MUST fail when a required public value (e.g. Stream key) is missing, rather than producing a bundle that fails at runtime on **Chats**.
- **FR-005**: Any client-side fallback that loads `/env.json` on web MUST NOT be documented or relied upon for dev/test/prod; removal or de-emphasis in code/docs is in scope for implementation follow-up.
- **FR-006**: Troubleshooting guides for deployed web MUST distinguish “missing build-time key / bad deploy” from “backend token failure” without mentioning `env.json` as a fix for server environments.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis requirements with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover core flows and regressions for bugs addressed by this feature.
- **NFR-UX-001**: User-facing interactions MUST follow the project design system and consistent loading/empty/error/accessibility patterns.
- **NFR-PERF-001**: Deploy verification MUST not add a runtime network round-trip solely to load optional config files on startup for server environments.
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Feature MUST define verification that built web artifacts contain non-empty required public values when CI variables are set.
- **NFR-FLUTTER-UX-001**: Feature MUST preserve theme/design-token consistency where UI copy is updated.
- **NFR-FLUTTER-PERF-001**: Chat connect on deployed web MUST not depend on an extra config fetch before showing connecting state.

### Validation Requirements *(mandatory)*

- **VR-001**: Documentation review: zero references recommending `env.json` on S3 for dev/test/prod.
- **VR-002**: Deploy smoke per environment: no request to `/env.json` on cold load (network trace).
- **VR-003**: CI build fails when `STREAM_API_KEY` GitHub variable is unset (dry-run).
- **VR-004**: Chats smoke on deployed dev: `GET /chat/stream-token` after sign-in when CI key is set.

### Key Entities

- **Build-time public config**: Values baked into the web bundle during `flutter build web` in CI.
- **Deployed environment**: dev, test, or prod web/API hosts on AWS (CloudFront + S3 + ECS)—not local developer machines.
- **Configuration policy**: Single rule set for all three server environments.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of deployment docs answer “Is env.json needed on dev/test/prod?” with **no**.
- **SC-002**: 100% of successful deploy smokes show required public values in the built artifact without `/env.json` on the host.
- **SC-003**: Zero production incidents resolved by manually adding `env.json` to S3 (target process metric after rollout).
- **SC-004**: Support checklist resolves “Chats shows STREAM_API_KEY hint on deploy” to CI/redeploy root cause in ≥90% of drill cases.

## Assumptions

- The team does **not** use local `flutter run` for acceptance; validation happens only on deployed dev/test/prod.
- GitHub variables `DEV_STREAM_API_KEY`, `TEST_STREAM_API_KEY`, `PROD_STREAM_API_KEY` are the intended source of Stream public key for web builds.
- `deploy_env.js` (Eruda) is unrelated to Stream configuration and remains a separate concern.
- Aligning `specs/012-chats-stream-connect` plan (which proposed CI-written `env.json`) with this policy is a follow-up implementation task, not a contradiction in this spec.

## Out of Scope

- Local developer workflow (`web/env.json`, `flutter run` without dart-define).
- Storing secrets in `env.json` (public keys only; secrets stay on API/Secrets Manager).
- Changing GetStream or backend token API design.
