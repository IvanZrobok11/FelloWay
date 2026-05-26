# Research: Web config without `env.json` (013)

**Date**: 2026-05-26

## 1. Is `env.json` required on deployed web?

**Decision**: **No.** Deployed dev/test/prod use **CI `--dart-define=STREAM_API_KEY=...` only**. No `env.json` on S3/CloudFront.

**Rationale**:

- User clarification: validation only on **server environments**, not local `flutter run`.
- CI already injects key at build: `deploy.yml`, `promote-test.yml`, `promote-prod.yml` pass `STREAM_API_KEY` and fail if unset.
- `String.fromEnvironment('STREAM_API_KEY')` bakes the value into the release bundle at compile time.
- Chats `missingApiKey` + zero backend calls happen when **build omitted the key**, not when S3 lacks `env.json`.

**Alternatives considered**:

- **CI writes `build/web/env.json` after build** (proposed in `012-chats-stream-connect` plan) — **rejected**; adds a second config channel and contradicts server-only policy.
- **Runtime-only `env.json` on S3** — **rejected**; harder to audit, cacheable separately from bundle, not used by team workflow.

## 2. What is `env.json` for in the codebase today?

**Decision**: Legacy **optional web fallback** in `loadAppConfig()` → `web_deploy_env_web.dart` fetches `/env.json` when compile-time key is empty.

**Rationale**:

- Helps local `flutter run` without `--dart-define` if `web/env.json` exists.
- On deploy, if CI passes dart-define correctly, fallback is never hit and should not be requested (FR-002 smoke: no `/env.json` request).

**Alternatives considered**:

- Keep fallback for deploy “just in case” — **rejected**; masks broken CI builds and confuses operators.

## 3. Client code change scope

**Decision**: **Remove** web `/env.json` fetch from production path; keep `env.json.example` only as optional local dev hint (out of spec acceptance scope) or remove example if team never runs locally.

**Rationale**:

- FR-005: do not document or rely on fallback for dev/test/prod.
- Removes extra startup network call (NFR-PERF-001).
- Simplifies `app_config_loader.dart` to: `fromEnvironment` → fail if empty (unless `STREAM_API_KEY_OPTIONAL` for tests).

**Alternatives considered**:

- Leave code, docs-only — **rejected**; deployed app could still request `/env.json` on misconfigured builds.

## 4. Relationship to `012-chats-stream-connect`

**Decision**: Implement **012** chat fixes using **dart-define only**; update `012` plan/research to **drop env.json post-build step**.

**Rationale**:

- Same root symptom (empty `streamApiKey` on deploy).
- 013 locks configuration policy; 012 delivers Chats UX + tests + CI verify.

## 5. CI verification enhancements

**Decision**: Rely on existing “fail if `STREAM_API_KEY` empty” **plus** optional post-build grep/assert that built `main.dart.js` (or const map) contains non-trivial key substring—document in quickstart, implement in tasks if low effort.

**Rationale**:

- Catches workflow typos that skip `--dart-define` while variable is set.
- No new runtime file on S3.

**Alternatives considered**:

- Ship `env.json` as safety net — **rejected** per 013 spec.
