# Research: Backend Interests Catalog (011)

**Date**: 2026-05-20

## R1 — Catalog API shape

**Decision**: Add `GET /interests` returning `{ items: InterestCatalogItem[] }` where each item has `id` (uuid), `name` (string), `sortOrder` (int 1–10).

**Rationale**: Read-only reference data; mirrors cities pattern conceptually; no auth required for onboarding before sign-in (AllowAnonymous on controller action).

**Alternatives considered**:
- Embed full catalog in app config — rejected (spec: server source of truth).
- GraphQL — out of scope.

## R2 — Stable ids across environments

**Decision**: Seed the ten interests with **fixed GUIDs** in `InterestCatalogSeed` (new static class) invoked from `DataSeeder` and a dedicated EF migration `ReplaceInterestCatalog`.

**Rationale**: QA/dev/prod share same ids in docs and tests; `UserProfileService` validation already uses `Interest.Id`.

**Alternatives considered**:
- Random GUID per deploy — rejected (breaks cross-env testing and docs).

## R3 — Replacing dev seed interests

**Decision**: Migration `ReplaceInterestCatalog`:
1. Delete `user_interests` / `event_interests` referencing interests not in new catalog (or all, then re-link events manually in dev).
2. Delete all rows in `interests`.
3. Insert ten canonical rows with fixed GUIDs + Ukrainian names from spec FR-002.
4. Update `DataSeeder` to call shared seed if `interests` count ≠ 10.

**Rationale**: Current seed has `.NET`, `Flutter`, `DevOps`, `Product` — incompatible with product list. Dev event seed must map to new ids (e.g. IT + Design) in `DataSeeder.SeedEventsAsync`.

**Alternatives considered**:
- Rename in place — risky if ids already in user data with wrong semantics.

## R4 — Profile response enrichment

**Decision**: Extend `UserProfileDto` / OpenAPI `UserProfile` with optional `interests: InterestCatalogItem[]` (resolved names for `interestIds`), keep `interestIds` for backward compatibility.

**Rationale**: Profile page must show labels without a second round-trip; client can still fetch catalog for edit UI.

**Alternatives considered**:
- Client-only id→name map from cached catalog — works but profile breaks if catalog fetch failed; enrichment is safer.

## R5 — Flutter onboarding draft

**Decision**: Store **catalog interest UUID strings** in `OnboardingDraft.interests` (field name unchanged); remove `_interestOptions`. `InterestsPage` loads catalog via new `InterestsRepository` or `ReferenceApi`.

**Rationale**: `UserProfile.toUpdateBody()` already sends UUIDs in `interestIds`; pending registration flow in `oauth_sign_in_page` unchanged structurally.

**Alternatives considered**:
- Separate `interestIds` field on draft — clearer but more refactor; reuse list with uuid strings.

## R6 — Profile edit UI

**Decision**: Replace free-text `_interests` `TextEditingController` with `Wrap` of `FilterChip` driven by catalog (same as onboarding), selected state from profile `interestIds`.

**Rationale**: Spec FR-006; prevents free-text invalid ids.

## R7 — OpenAPI layout

**Decision**: New fragment `shared/api-contracts/reference/openapi.yaml`; run `generate-api-client.sh` to merge into `openapi.json` and regenerate Dart.

**Rationale**: Matches domain-folder convention; README table updated in implementation.

## R8 — Caching on client

**Decision**: In-memory cache on `InterestsCatalogService` (singleton via `AppScope`) for session; refetch on pull-to-retry or cold start.

**Rationale**: NFR-PERF-001; catalog rarely changes.
