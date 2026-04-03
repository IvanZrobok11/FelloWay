# Research: Event Networking Flutter Client

**Feature**: `001-event-networking-app`  
**Date**: 2026-04-03  
**Scope**: Frontend-only; backend behavior described in `TECH_PLAN.md` is treated as given.

## Decisions

| Topic | Decision | Rationale |
|-------|----------|-----------|
| OAuth client | `flutter_appauth` with platform-specific redirect URIs | Matches `TECH_PLAN.md` Phase 1 Flutter guidance |
| Token storage | `flutter_secure_storage` | Required for refresh token handling |
| Chats | GetStream Flutter SDK | `TECH_PLAN.md` specifies Stream for chat + push |
| Navigation | Declarative router (e.g. `go_router`) with shell for 4 tabs | Deep links to event/chat and testability |
| Localization | Flutter gen-l10n, UA primary + EN | `TECH_PLAN.md` UA + EN from day one |
| Maps | Google Maps **or** Mapbox | `TECH_PLAN.md` allows either; pick one before Phase 2 based on billing/keys |

## Dependencies on External Teams

- OAuth app registration (LinkedIn, Facebook) and redirect URL whitelist
- Backend base URL, API versioning, and OpenAPI or contract doc ownership
- GetStream API key (client-safe vs server-only token strategy — confirm with backend)
- FCM/APNs configuration in GetStream dashboard for chat pushes

## Open Items (Non-Blocking for Plan)

- Exact map SDK and API keys storage (flavors: `dev` / `staging` / `prod`)
- Whether Stream user/token is issued by backend endpoint or embedded in login response
- Payload schema for custom push notifications (same-city, new event)

## References

- `TECH_PLAN.md` — Flutter subsections under Phases 1–4
- `PRD_Event_Networking.md` — product rules (guest blur, unjoin chat access, trip approval rules)
