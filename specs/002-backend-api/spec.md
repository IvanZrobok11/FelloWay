# Feature Specification: FelloWay Backend API (MVP)

**Feature Branch**: `002-backend-api`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Plan backend application with REST API per [PRD_Event_Networking.md](../../PRD_Event_Networking.md) and [TECH_PLAN.md](../../TECH_PLAN.md). Mobile client: [specs/001-event-networking-app/spec.md](../001-event-networking-app/spec.md).

## Summary

Deliver the **ASP.NET Core REST API** and persistence layer that powers the FelloWay mobile app: OAuth sign-in (LinkedIn, Facebook), user profiles, work-conference events, attendance, trip chats (GetStream provisioning), reviews, blocks, push-preference sync, and admin moderation endpoints. The API is the single source of truth for authorization, visibility rules, and chat membership; GetStream handles real-time messaging.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Authenticate and complete profile (Priority: P1)

As a new attendee, I want to sign in with LinkedIn or Facebook and have my profile stored so the mobile app can show my name, city, and interests.

**Independent Test**: OAuth callback creates or links a user; `GET /users/me` returns profile; conditional `PUT /users/me` after onboarding draft merge; avatar upload stores URL in Blob.

### User Story 2 — Discover and join events (Priority: P1)

As a signed-in user, I want to list, search, and join work conferences so I can access event chat and participants.

**Independent Test**: Paginated `GET /events` with filters; `POST/DELETE .../attend`; attendee list gated to subscribers; unjoin revokes trip/event chat access server-side.

### User Story 3 — Trip chats and join workflow (Priority: P2)

As an event attendee, I want to create or join route-specific trip chats with approval rules based on city.

**Independent Test**: Create trip → Stream channel; join request → auto-approve same city / manual otherwise; owner approve endpoint; member cap 20 enforced.

### User Story 4 — Trust, safety, and notifications (Priority: P2)

As a user, I want to block others, leave reviews, and control push categories; admins moderate content.

**Independent Test**: Block hides interaction; review after event; push preferences persisted; admin pending events and reports (Phase 5 slice).

## Functional Requirements

- **FR-B001**: System MUST accept OAuth 2.0 authorization codes for LinkedIn and Facebook and issue **access + refresh tokens** for the mobile client.
- **FR-B002**: System MUST expose `GET /users/me` and `PUT /users/me` (display name, bio, interests, home city) and MUST NOT require profile PUT during client onboarding S2–S4 (client-only draft until OAuth).
- **FR-B003**: System MUST store avatars in Azure Blob via `POST /users/me/avatar` (multipart).
- **FR-B004**: System MUST sync each registered user to GetStream and return a Stream user token via `GET /chat/stream-token`.
- **FR-B005**: System MUST list/filter events (`GET /events`) with pagination, text search, city, interest/tag filters, and optional geo sort (Haversine on city coordinates for MVP).
- **FR-B006**: System MUST manage event attendance (`POST/DELETE /events/{id}/attend`) and enforce chat access based on participation.
- **FR-B007**: System MUST implement trip chat CRUD and join/approve flows per [shared/api-contracts/events/](../../shared/api-contracts/events/).
- **FR-B008**: System MUST support reviews (`POST .../review`, `GET /users/{id}/reviews`) and user blocks (`POST /users/{id}/block`).
- **FR-B009**: System MUST persist notification preferences (`PUT /users/me/push-preferences`) for custom push triggers (Phase 4).
- **FR-B010**: Admin role MUST protect moderation endpoints (pending events, bans, reports) per TECH_PLAN Phase 5.

## Non-Functional Requirements

- **NFR-B001**: Authenticated API p95 latency &lt; 300 ms for read endpoints on staging under nominal load (excluding avatar upload).
- **NFR-B002**: All public contract changes MUST be reflected in `shared/api-contracts/` OpenAPI before merge.
- **NFR-B003**: Secrets (OAuth, DB, Stream, Blob) MUST come from configuration / Key Vault, never committed.
- **NFR-B004**: API MUST return consistent error envelope (see `shared/api-contracts/common/`).
- **NFR-B005**: PostgreSQL schema changes MUST be applied via versioned EF Core migrations.

## Key Entities

See [data-model.md](./data-model.md): `User`, `Interest`, `Event`, `EventAttendee`, `Trip`, `TripMember`, `TripJoinRequest`, `Review`, `BlockedUser`, `PushPreferences`, `RefreshToken`, `Report` (admin).

## Success Criteria

- **SC-B001**: Flutter app `API_MODE=live` completes sign-in → profile → event join against staging API without mock catalog.
- **SC-B002**: &lt; 2% 4xx/5xx on attend/join/approve paths in staging soak test.
- **SC-B003**: Stream channel membership matches DB participation within 60s of attend/unjoin/approve (webhook or explicit sync job).

## Assumptions

- Monorepo layout: `backend/` solution, contracts in `shared/api-contracts/`.
- Admin web UI is a separate .NET app (out of this feature’s code scope; shares API).
- Entertainment events remain out of scope.
- MVP uses simple Haversine, not PostGIS.

## Out of Scope (this feature)

- Flutter UI (covered by `001-event-networking-app`).
- Admin Razor/Blazor UI implementation (endpoints only).
- Payment, ticketing, non-work event categories.
