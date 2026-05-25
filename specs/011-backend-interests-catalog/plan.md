# Implementation Plan: Backend Interests Catalog

**Branch**: `011-backend-interests-catalog` | **Date**: 2026-05-20 | **Spec**: [spec.md](./spec.md)  
**Input**: Server-owned catalog of ten professional interests with stable ids; onboarding and profile use API, not client-local master list.

## Summary

Expose **`GET /interests`** (public catalog), **replace** dev seed interests with the ten Ukrainian labels from the spec, enrich **`GET /users/me`** with resolved `interests[]` for display, and refactor Flutter **`InterestsPage`**, **profile view**, and **profile edit** to load/select by catalog id. Reuse existing `interests` / `user_interests` tables and `UserProfileService` validation.

## Technical Context

**Language/Version**: C# 12 / .NET 8 (API); Dart 3.10+ / Flutter stable  
**Primary Dependencies**: EF Core 8 + Npgsql; ASP.NET Core controllers; OpenAPI merge + `openapi-generator` dart-dio; existing `dio` / `go_router`  
**Storage**: PostgreSQL `interests`, `user_interests` (existing)  
**Testing**: xUnit API tests (`GET /interests`, invalid `interestIds`); Flutter unit/widget for catalog chips  
**Target Platform**: API + Flutter Web/Android/iOS  
**Project Type**: Monorepo `backend/` + `frontend/` + `shared/api-contracts/`  
**Performance Goals**: Catalog `GET` p95 &lt; 200 ms local; client session cache for repeat chip renders  
**Constraints**: Fixed seed GUIDs; migration clears legacy interest rows; no free-text interests on profile edit  
**Scale/Scope**: 10 catalog rows; 3 Flutter screens + 1 new repository; 1 new API controller

## Constitution Check

*GATE: Pass (pre- and post-design).*

| Gate | Plan evidence |
|------|----------------|
| Code quality | `dotnet build`, `flutter analyze`; OpenAPI regen in CI |
| Test strategy | API: catalog count/names, invalid interest on PUT; Flutter: interests page widget with mock catalog |
| UX consistency | Reuse `FilterChip` onboarding pattern; profile list subtitle shows names |
| Performance | Small payload (10 items); in-memory client cache |
| Flutter checks | `flutter test` + analyze in CI |
| Evidence | Test output; quickstart manual checklist |

**Post-design**: No exceptions.

## Project Structure

### Documentation (this feature)

```text
specs/011-backend-interests-catalog/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/interests-api.md
└── tasks.md              # /speckit.tasks
```

### Source Code (repository root)

```text
backend/src/
├── FelloWay.Domain/Entities/Interest.cs          # optional SortOrder
├── FelloWay.Application/Reference/               # NEW: IInterestCatalogService
├── FelloWay.Api/Controllers/InterestsController.cs  # NEW: GET /interests
├── FelloWay.Application/Users/UserProfileService.cs # enrich Map() with names
├── FelloWay.Infrastructure/
│   ├── Persistence/Seed/InterestCatalogSeed.cs   # NEW: 10 fixed GUIDs
│   ├── Persistence/Seed/DataSeeder.cs              # use catalog + event links
│   └── Migrations/*_ReplaceInterestCatalog.cs     # NEW

shared/api-contracts/
├── reference/openapi.yaml                        # NEW
└── users/openapi.yaml                            # UserProfile.interests[]

frontend/lib/
├── features/onboarding/presentation/interests_page.dart
├── features/onboarding/data/interests_repository.dart  # NEW
├── features/profile/presentation/profile_page.dart
├── features/profile/presentation/profile_edit_page.dart
├── features/profile/domain/user_profile.dart
└── app/app_scope.dart                            # wire repository

frontend/test/
├── unit/interest_catalog_test.dart               # NEW
└── widget/onboarding_interests_page_test.dart    # NEW
```

**Structure Decision**: Extend existing clean architecture; reference data controller separate from `UsersController`.

## Implementation Phases

### Phase A — Backend catalog + migration

1. Add `SortOrder` to `Interest` entity (optional but recommended).
2. `InterestCatalogSeed` — ten rows with fixed GUIDs and Ukrainian names (spec FR-002).
3. EF migration `ReplaceInterestCatalog`: clear FK dependents, replace `interests` rows.
4. `InterestCatalogService` + `GET /interests` (`AllowAnonymous`).
5. Extend `UserProfileDto` + `Map()` to include `IReadOnlyList<InterestCatalogItemDto> Interests` joined from DB.
6. Update `DataSeeder` event interest links to new ids (e.g. IT, Design, Product → business mapping).

### Phase B — OpenAPI + codegen

1. Add `shared/api-contracts/reference/openapi.yaml`.
2. Extend `users/openapi.yaml` `UserProfile.interests`.
3. Run `generate-api-client.sh`; commit `openapi.json` + generated Dart if repo policy requires.

### Phase C — Flutter onboarding + profile

1. `InterestsRepository` — `fetchCatalog()`, session cache, error handling.
2. `InterestsPage` — async load, loading/error/retry, chips by `name`, selection stores **id**.
3. Remove `_interestOptions` constant.
4. `UserProfile` — map `interests` array to `List<InterestRef>` or names for display.
5. `ProfilePage` — show `interests.map((e) => e.name).join(', ')`.
6. `ProfileEditPage` — chip UI like onboarding; `toUpdateBody()` sends `interestIds`.

### Phase D — Tests & verification

| Test | Purpose |
|------|---------|
| `InterestsEndpointTests` | GET returns 10, names contain «ІТ» |
| `UsersMeEndpointTests` | PUT valid/invalid interestIds |
| `onboarding_interests_page_test` | chips from mock API |
| Manual quickstart | End-to-end onboarding → profile |

## Artifact Index

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| API contract | [contracts/interests-api.md](./contracts/interests-api.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
