# Implementation Plan: Event Networking Mobile MVP (Flutter Client Only)

**Branch**: `001-event-networking-app` | **Date**: 2026-04-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-event-networking-app/spec.md`

**Scope note**: This plan covers **only the Flutter mobile application** (iOS + Android). Backend, database, admin web, and Azure hosting are **out of scope** for this repository; integration assumes those services exist per `TECH_PLAN.md` and expose stable HTTP/OAuth and GetStream capabilities.

## Summary

Deliver the FelloWay event-networking MVP as a Flutter client: onboarding **S1 welcome** (get started vs log in) plus **S2–S4** profile steps, **OAuth** (LinkedIn/Facebook) on a dedicated sign-in screen and other entry points, four-tab shell (events, map, chats, profile), event discovery with guest vs signed-in behavior, event detail and join/unjoin, map discovery with filters, GetStream-powered chat list and channels (event-wide, trip-local, DM), trip-chat flows on the event screen, push handling and notification preferences, ratings/reviews UI, and reporting/blocking entry points. The app consumes REST APIs and GetStream; it does not implement server logic.

## Technical Context

**Language/Version**: Dart 3.x (SDK ^3.10 per project), Flutter stable channel

**Primary Dependencies** (from `TECH_PLAN.md` frontend guidance; exact versions to pin during implementation):

- `flutter_appauth` — OAuth 2.0 (LinkedIn, Facebook)
- `flutter_secure_storage` — access/refresh token storage
- Stream Chat Flutter SDK — chats (event, trip, DM), lists, push integration with GetStream
- HTTP client (e.g. `dio`) — REST integration with backend
- Router (e.g. `go_router`) — deep links and tab/shell navigation
- State management — team choice (e.g. Riverpod, Bloc); align with constitution testability
- Maps — Google Maps **or** Mapbox Flutter (per product/license decision in research)
- `flutter_localizations` + ARB — Ukrainian (MVP) + English from day one

**Storage**: `flutter_secure_storage` for tokens; optional `shared_preferences` for non-sensitive flags; in-memory/session state for navigation and chat

**Testing**: `flutter test` (unit/widget), `integration_test`, golden tests for stable chrome (cards, key screens); constitution requires failing-first coverage on critical flows

**Target Platform**: iOS + Android (Flutter); no admin web in this repo

**Project Type**: Flutter mobile app (`felloway_client`)

**Performance Goals**: Align with spec NFRs — primary screens ≤2s p95 under normal network; smooth scrolling on event lists and chat; cold start budget TBD with product (e.g. &lt;3s on mid-range device)

**Constraints**: Guest vs authenticated UI; chat access revoked on unjoin per spec; GetStream MAU limits on free tier (pilot risk per `TECH_PLAN.md`); OAuth LinkedIn verification lead time (coordination with backend/product, not implemented here)

**Scale/Scope**: Full MVP surface from spec Phases 1–4 **frontend** slices only; admin panel explicitly excluded

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Code quality**: `dart format` + `flutter analyze` clean; PR scope and review for null-safety and layering (UI / state / data).
- **Tests**: Unit tests for auth/session and join-state logic; widget tests for onboarding and event card states; integration tests for sign-in → list → detail → join (against staging/mock); goldens where layout is acceptance-critical.
- **UX**: Shared theme, loading/empty/error, accessibility labels; Material/Cupertino appropriateness; UA + EN strings via l10n.
- **Performance**: List pagination, image loading strategy, map marker limits documented; chat list scroll performance considered.
- **Evidence**: CI runs analyze + tests; manual checklist for map and push on real devices documented in quickstart.

## Delivery Phases (Frontend-Only Mapping from TECH_PLAN)

Aligned with `TECH_PLAN.md` **Flutter** bullets only; backend phases are reference-only for API readiness.

| Plan phase | TECH_PLAN phase | Flutter focus |
|------------|-----------------|---------------|
| P0 | 0 (shared prep) | Repo/app setup: l10n, analysis, CI, env/flavors, secure storage, OAuth redirect config placeholders, GetStream app key wiring (staging) |
| P1 | 1 | Onboarding S1 (welcome: get started → S2–S4, log in → `/sign-in`) + S2–S4, OAuth via appauth on sign-in route, tokens in secure storage, tab shell + router, profile tab (avatar, name, links, interests, rating display) |
| P2 | 2 | Events tab: paginated list, search, guest vs auth card behavior, event detail, join/unjoin; Map tab: provider choice, markers, filters, popup → event |
| P3 | 3 | Chats tab via Stream SDK; event trips section; create trip chat; join requests + approval UI; low-rating warning on requests; DM entry from participants |
| P4 | 4 | Push foreground/background handling; profile notification settings; post-event feedback screen; reviews list UI |

**Out of repo**: Phase 5 admin web; all .NET/PostgreSQL/Azure implementation.

## Project Structure

### Documentation (this feature)

```text
specs/001-event-networking-app/
├── plan.md              # This file
├── research.md          # Frontend decisions and risks
├── data-model.md        # Client-side models and API mapping notes
├── quickstart.md        # Local run, env, and device checks
├── contracts/           # REST boundaries the client depends on
└── tasks.md             # Task breakdown (/speckit.tasks)
```

### Source Code (repository root)

Current repo is a single Flutter app with `lib/main.dart` only. Target layout:

```text
lib/
├── app/                 # App widget, theme, router, localization
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── events/
│   ├── map/
│   ├── chats/
│   ├── profile/
│   └── trips/
├── shared/              # widgets, extensions, errors, constants
└── main.dart

test/
├── unit/
├── widget/
└── golden/

integration_test/
└── app_test.dart
```

**Structure Decision**: Monorepo with `frontend/` (Flutter package `felloway_client`, feature-first folders under `lib/features/`), `backend/` (API, placeholder), and `shared/api-contracts/` (`auth/`, `users/`, `common/`, `events/`). Optional later extraction: `packages/design_system` or `packages/api_client`.

## Integration Boundaries (Not Implemented Here)

The Flutter app **depends on** (assumed provided elsewhere):

- OAuth 2.0 authorization server and token exchange compatible with `flutter_appauth`
- REST API for users/me, events, attend, attendees, trips, join/approve, blocks, reports, reviews, preferences (see `shared/api-contracts/` and feature `contracts/`)
- GetStream project: user sync on registration (server-side), channels for event/trip/DM, push via FCM/APNs through GetStream dashboard

Frontend work includes **calling** these capabilities and **handling** errors, empty states, and token refresh UX (re-login on invalid refresh).

## Risks (Frontend-Relevant from TECH_PLAN)

- **GetStream MAU**: Free tier 25 MAU — pilot sizing; client should degrade gracefully if chat init fails.
- **LinkedIn OAuth verification**: May delay profile fields; client handles partial profile and edit flows.
- **Custom push triggers**: Non-chat pushes (same-city attendee, new matching event) may arrive via FCM directly or via backend; client handlers must route by payload type once contract is fixed.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | Constitution check satisfied for planned scope |
