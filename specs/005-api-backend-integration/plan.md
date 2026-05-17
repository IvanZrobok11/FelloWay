# Implementation Plan: Connect Mobile App to Live Backend API

**Branch**: `005-api-backend-integration` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: Wire Flutter client to running FelloWay backend; verify auth, profile, and events via contract-aligned HTTP; document smoke checklist.

## Summary

Repositories already call Dio when `AppConfig.useMockApi` is false. This feature **completes the live path**: backend JWT acquisition (dev OAuth exchange + optional AppAuth), **contract-aligned JSON mapping**, token **refresh** on 401, structured **error parsing**, and a **documented smoke checklist** proving login → profile → events against `dotnet run` backend.

Codegen package `felloway_api` (004) remains available; MVP uses fixed mappers on existing repositories with optional follow-up to generated types.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter stable; .NET 8 backend (verification only)  
**Primary Dependencies**: `dio`, `flutter_appauth`, `felloway_api` (path dep, optional mappers), ASP.NET JWT auth (002)  
**Storage**: `TokenStorage` (secure prefs) for access/refresh tokens  
**Testing**: `flutter test` (unit: mappers, auth client, refresh interceptor); manual smoke per [quickstart.md](./quickstart.md); optional `integration_test`  
**Target Platform**: Android 8+, iOS 14+ (emulator + device LAN)  
**Project Type**: Monorepo — `frontend/` + `backend/` + `shared/api-contracts/`  
**Performance Goals**: Profile + events visible within 5s on warm local backend (NFR-002)  
**Constraints**: No silent mock fallback in `API_MODE=live`; no secrets in repo beyond public OAuth client ids  
**Scale/Scope**: 3 user stories; ~6 REST endpoints; auth UI + 2 repositories + `ApiClient`

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `dart format`, `flutter analyze` on `frontend/`; no regressions in `backend` tests |
| Test strategy | ✅ Pass | Failing-first unit tests for mappers + refresh; manual smoke checklist; optional integration test for login→events |
| UX consistency | ✅ Pass | Reuse existing loading/error/empty patterns on profile and events screens |
| Performance budgets | ✅ Pass | NFR-002 validated during smoke; no new heavy work on main isolate |
| Flutter quality checks | ✅ Pass | Documented in quickstart §5 |
| Evidence plan | ✅ Pass | PR: smoke checklist results, analyzer output, `dotnet test` + `flutter test` |

**Post-design re-check**: No violations. No complexity tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/005-api-backend-integration/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/live-integration.md
└── tasks.md                    # /speckit.tasks
```

### Source Code (repository root)

```text
frontend/lib/
├── app/config/app_config.dart          # API_MODE / useMockApi (existing)
├── shared/network/api_client.dart      # Bearer + refresh interceptor
├── features/auth/
│   ├── data/auth_api.dart              # NEW: OAuth token + refresh calls
│   └── presentation/oauth_sign_in_page.dart  # dev live sign-in
├── features/profile/
│   ├── data/users_repository.dart      # contract field mapping
│   └── domain/user_profile.dart        # homeCityId, interestIds alignment
├── features/events/data/events_repository.dart  # validate list/detail mapping
└── generated/felloway_api/             # reference types (optional adapters)

backend/                                # no feature code unless contract bugs found
shared/api-contracts/                   # source of truth for wire shapes

test/
├── unit/auth_api_test.dart             # NEW
├── unit/user_profile_mapping_test.dart # NEW
└── unit/api_client_refresh_test.dart   # NEW
```

**Structure Decision**: Changes concentrated in `frontend/lib` auth + network + profile/events data layers; backend only if spec/implementation mismatch discovered during smoke.

## Implementation Phases (for `/speckit.tasks`)

### Phase 1 — Auth bridge (P1)

1. Add `AuthApi` (or extend auth data layer): `POST /auth/oauth/linkedin/token`, `POST /auth/refresh`.
2. **Dev live sign-in** on `OAuthSignInPage` when `API_MODE=live` and OAuth not configured: exchange `dev-{subject}` (configurable subject or fixed `dev-smoke-user`).
3. Keep `FlutterAppAuth` path when `OAUTH_CLIENT_ID` + discovery URL set (may still need backend exchange if tokens are provider-only — document in tasks).
4. Reject `demo-access-token` when `useMockApi` is false (disable demo button or show message in live mode).

### Phase 2 — Network hardening (P1)

1. Implement single-flight refresh in `ApiClient` on 401 → `POST /auth/refresh` → retry once.
2. Parse `ErrorResponse` in `mapDioError` for user-visible messages.
3. Confirm `ApiMode.live` never sets `useMockApi` true (unit test on `AppConfig`).

### Phase 3 — Contract mappers (P1)

1. Update `UserProfile.fromJson` / `toUpdateBody` for `interestIds`, `homeCity`, `homeCityId`, `aggregateRating`.
2. Align onboarding `PUT /users/me` with `UserProfileUpdate` (city id resolution if needed — may seed known UUID from backend seeder docs).
3. Validate `EventsRepository` list/detail against backend seeded JSON; add fixture-based unit tests.

### Phase 4 — Smoke & docs (P1)

1. Finalize [quickstart.md](./quickstart.md) with actual launch port.
2. Update `frontend/README.md` and root `README.md` with live-mode run example.
3. Run full manual smoke; file defects for attend/trips as follow-up tasks.

### Phase 5 — Optional codegen adapters (P2)

1. Map `felloway_api` `UserProfile` / `Event` to domain types for wired endpoints to reduce drift (004 consumption).

## Complexity Tracking

> No constitution violations.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Integration contract | [contracts/live-integration.md](./contracts/live-integration.md) |
| Quickstart / smoke | [quickstart.md](./quickstart.md) |

## Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Profile field mismatch | Fixture tests from OpenAPI examples + backend DTO |
| Android cleartext HTTP | `android:usesCleartextTraffic` for debug builds only if needed |
| Interest IDs vs labels | MVP show ids or map known seeder interests in follow-up |
| OAuth vs dev token confusion | Quickstart table for which sign-in to use |
