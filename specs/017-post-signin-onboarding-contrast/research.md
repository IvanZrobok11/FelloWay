# Research: Post-sign-in routing and readable onboarding/event text

**Feature**: `017-post-signin-onboarding-contrast` | **Date**: 2026-05-26

## R1 — Post-sign-in destination rule

**Decision**: Introduce shared helper `resolvePostSignInRoute({required String displayName})` in `frontend/lib/app/router/`:
- `displayName.trim().isEmpty` → `/onboarding/name` (with optional `OnboardingDraft` extra seeded from profile if partial)
- else → `/events`

Replace all post-auth `context.go('/onboarding/welcome')` in `oauth_sign_in_page.dart` (mobile `_afterAuthenticated`, web `OAuthBffSuccessPage._navigateAfterAuth`) and router redirect that sends incomplete onboarding to welcome.

**Rationale**: Spec FR-001–FR-003; current code uses `onboardingPreferences.isComplete` and always lands on welcome when incomplete (`app_router.dart` L98–101, `oauth_sign_in_page.dart` L157–160, L336–340).

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep welcome, skip button to name | Still adds friction; spec forbids welcome as default |
| Route to interests/city if name set but incomplete | Spec says name set → events; profile guards handle rest |
| Only change sign-in page, not router redirect | Deep links and refresh would still hit welcome |

## R2 — Profile data for routing

**Decision**: After auth success, call existing `UsersRepository.getMe()` once; use `UserProfile.displayName` for routing. No new API.

**Rationale**: FR-008, NFR-FLUTTER-PERF-001; `_afterAuthenticated` already fetches profile for pending draft sync.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Local onboarding draft only | New LinkedIn users may have empty local draft but server name from provider |
| JWT claims for name | Not available today |

## R3 — Onboarding input contrast (name + city)

**Decision**: Root cause is global `TextTheme` / typography built with `FellowayTextColors.onGradient` (white) while `InputDecorationTheme.fillColor` is light `scheme.surface`. Fix by:
1. Set explicit `TextField.style` and `InputDecorationTheme` hint/label to `ColorScheme.onSurface` on name/city pages **or**
2. Add theme extension `FellowayTextColors.onLightSurface` (dark primary/secondary) and apply via small helper `textOnLightSurface(context)` for inputs and dropdown items.

Prefer **(2) at theme level** + `inputDecorationTheme` alignment so city dropdown and name field share one token set (NFR-FLUTTER-UX-001).

**Rationale**: FR-004, FR-005; `name_page.dart` and `city_page.dart` use default theme styles on transparent scaffold over gradient.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Change global textTheme to dark | Breaks gradient shell, app bar, nav (brown areas) |
| White input backgrounds only | Does not fix inherited white text color |

## R4 — Event card / detail contrast

**Decision**: Classify regions per spec:
- **Light surface** (card body `Padding`, white/light `Card.color`): use `ColorScheme.onSurface` / `onLightSurface` text styles
- **Dark/brown surface** (app bar, gradient backdrop, hero overlays on brown): keep `FellowayTextColors.onGradient`

Update `event_card.dart` text/chip styles explicitly; audit `event_detail_page.dart` for mixed regions.

**Rationale**: FR-006, FR-007; `EventCard` uses `theme.textTheme.titleMedium` which inherits gradient-white colors on white card fill.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Darken card background to match white text | Violates design (cards are light panels) |
| Single global fix in CardTheme | Does not cover chips and detail page sections |

## R5 — Router initial location

**Decision**: Update `resolve_initial_location.dart` only for unauthenticated cold start; authenticated post-sign-in uses R1 helper. For authenticated user opening app with incomplete local onboarding but **has** display name → `/events` (align with spec).

**Rationale**: Edge case in spec; avoids welcome on refresh when name exists.

## R6 — Testing strategy

**Decision**:
- Unit: `resolve_post_sign_in_route_test.dart` (empty name → name route; non-empty → events)
- Widget: name/city pages assert `TextField`/`Text` color on surface
- Golden: update `event_card_golden_test.dart` for dark-on-light card body

**Rationale**: SC-005, constitution II + golden for visual components.

## R7 — Welcome screen fate

**Decision**: Keep `/onboarding/welcome` route; remove from automatic post-sign-in paths. Optional manual link from marketing later.

**Rationale**: Spec assumption; minimal scope.
