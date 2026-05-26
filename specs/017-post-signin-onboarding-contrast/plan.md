# Implementation Plan: Post-sign-in routing and readable onboarding/event text

**Branch**: `017-post-signin-onboarding-contrast` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Route to name or events after sign-in (not welcome); fix text contrast on onboarding name/city and event surfaces.

## Summary

Add a **shared post-sign-in route resolver** based on `UserProfile.displayName` from `GET /users/me`, and replace welcome redirects in `oauth_sign_in_page.dart`, `OAuthBffSuccessPage`, and `app_router.dart`. Fix **light-surface text contrast** by introducing `FellowayTextColors.onLightSurface` (or equivalent) and applying it to name/city inputs, dropdown items, and event card body text while preserving **onGradient** light text on brown/gradient chrome.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter stable (`frontend/`, SDK `^3.10.4`)

**Primary Dependencies**: `go_router`, `AppTheme` / `FellowayTextColors`, `UsersRepository.getMe()`, `OnboardingPreferences`, existing onboarding pages

**Storage**: `SharedPreferences` (`OnboardingPreferences`); profile from API

**Testing**: `flutter test` — unit (route resolver), widget (input colors), golden (`event_card_golden_test.dart`)

**Target Platform**: Flutter Web (deployed dev primary) + iOS/Android shared `lib/`

**Project Type**: Flutter client in `frontend/`

**Performance Goals**: No extra profile fetch beyond existing sign-in flow; routing decision synchronous after `getMe` returns (NFR-PERF-001)

**Constraints**:

- Do not break LinkedIn BFF `/auth/success` and mobile ticket flows
- Preserve gradient/brown shell typography (014-mobile-typography)
- Live-only auth (015/016) — no mock sign-in paths

**Scale/Scope**: ~8–12 Dart files: router, auth sign-in, name/city pages, theme tokens, event_card (+ optional event_detail), tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | `flutter analyze` + `dart format` on touched files |
| Test strategy | Pass | Unit route tests + golden event card + widget contrast where feasible |
| UX consistency | Pass | Theme tokens for light vs dark surfaces; no ad-hoc hex in pages |
| Performance | Pass | Reuse existing `getMe` in auth completion; no new polling |
| Flutter checks | Pass | Full `flutter test` in CI |
| Evidence | Pass | [quickstart.md](./quickstart.md) manual smoke + test output |

**Post-design re-check**: Pass.

## Project Structure

### Documentation (this feature)

```text
specs/017-post-signin-onboarding-contrast/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/post-sign-in-navigation.md
└── tasks.md                    # /speckit.tasks
```

### Source Code

```text
frontend/lib/app/router/
├── resolve_post_sign_in_route.dart    # NEW
├── resolve_initial_location.dart      # UPDATE (optional: name vs welcome)
└── app_router.dart                    # UPDATE redirect (name not welcome)

frontend/lib/features/auth/presentation/
└── oauth_sign_in_page.dart            # UPDATE _afterAuthenticated, _navigateAfterAuth

frontend/lib/app/theme/
├── felloway_text_colors.dart          # ADD onLightSurface
└── app_theme.dart                     # Wire input defaults if needed

frontend/lib/features/onboarding/presentation/
├── name_page.dart                     # Dark text on input
└── city_page.dart                     # Dark dropdown/list text

frontend/lib/features/events/presentation/
├── event_card.dart                    # onSurface styles on card body
└── event_detail_page.dart             # AUDIT mixed regions

frontend/test/
├── unit/resolve_post_sign_in_route_test.dart
├── widget/ (optional onboarding contrast)
└── golden/event_card_golden_test.dart
```

## Implementation Phases

### Phase A — Post-sign-in routing (US1, P1)

1. Add `resolvePostSignInRoute(String displayName)` → `/onboarding/name` | `/events`.
2. Refactor `oauth_sign_in_page.dart`: after `getMe`, call resolver; remove default `go('/onboarding/welcome')` on success paths (keep welcome only on explicit product choice if any).
3. Update `OAuthBffSuccessPage._navigateAfterAuth` same way.
4. Update `app_router.dart` redirect: authenticated + incomplete onboarding + no name → `/onboarding/name`; do not force welcome.
5. Optional: `resolve_initial_location.dart` for cold start with session.

### Phase B — Onboarding contrast (US2–US3, P2)

1. Add `FellowayTextColors.onLightSurface` (dark primary/secondary) to theme extensions.
2. `name_page.dart`: `TextField.style`, decoration labels → onLightSurface / `onSurface`.
3. `city_page.dart`: dropdown hint, items, selected value → onLightSurface.

### Phase C — Event contrast (US4, P2)

1. `event_card.dart`: card body `Text` and `Chip` labels use `ColorScheme.onSurface` (or onLightSurface typography).
2. Audit `event_detail_page.dart` for white panels vs brown headers; apply same rule per region.

### Phase D — Tests & validation

1. Unit tests for route resolver (empty name, whitespace, non-empty).
2. Update golden for event card light body text.
3. `flutter test` + manual deployed smoke per quickstart.

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
| Contract | [contracts/post-sign-in-navigation.md](./contracts/post-sign-in-navigation.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Dependencies

- **009-linkedin-bff-auth** — sign-in entry points
- **014-mobile-typography** — gradient text system; extend with light-surface variant
- **015-remove-mock-local** — live profile fetch only

## Next Step

**`/speckit.tasks`** — ordered tasks for Phase A→D.
