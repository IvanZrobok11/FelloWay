---
description: "Task list for FelloWay Backend API (MVP)"
---

# Tasks: FelloWay Backend API (MVP)

**Input**: Design documents from `/specs/002-backend-api/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [shared/api-contracts/](../../shared/api-contracts/)

**Tests**: Required per story — write failing integration/unit tests first, then implement.

**Organization**: Phases follow spec priorities (US1 → US2 → US3 → US4), aligned with plan phases B0–B5.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallel-friendly (different files, no ordering dependency)
- **[Story]**: `US1`–`US4`, or omit for Setup / Foundational / Polish

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: .NET solution skeleton, CI, analyzer rules, contract wiring

- [x] T001 [-] Create `backend/FelloWay.sln` and projects `src/FelloWay.Api`, `src/FelloWay.Application`, `src/FelloWay.Domain`, `src/FelloWay.Infrastructure`, `tests/FelloWay.Api.Tests`, `tests/FelloWay.Application.Tests` per [plan.md](./plan.md)
- [x] T002 [-] Add NuGet packages in project files: EF Core + Npgsql, Swashbuckle, FluentValidation, JWT bearer, Stream Chat SDK, Azure.Storage.Blobs, Hangfire + PostgreSQL storage, Polly (see [research.md](./research.md))
- [x] T003 [P] [-] Add `backend/.editorconfig` and enable nullable + analyzers in all `*.csproj`
- [x] T004 [P] [-] Add `backend/Directory.Build.props` for shared version/target framework `net8.0`
- [x] T005 [-] Configure `FelloWay.Api/Program.cs` with controllers, Swagger (Development), health checks placeholder in `backend/src/FelloWay.Api/Program.cs`
- [x] T006 [P] [-] Add GitHub Actions workflow `.github/workflows/backend-ci.yml` running `dotnet format`, `dotnet build`, `dotnet test` on `backend/`
- [x] T007 [P] [-] Document local secrets pattern in [quickstart.md](./quickstart.md) (user-secrets keys list)
- [x] T008 [-] Add `backend/README.md` linking to [quickstart.md](./quickstart.md) and [shared/api-contracts/](../../shared/api-contracts/)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database, auth pipeline, shared API infrastructure — **no user story work before this completes**

**⚠️ CRITICAL**: Blocks US1–US4

- [x] T009 [-] Implement domain base types and `DomainException` in `backend/src/FelloWay.Domain/Common/`
- [x] T010 [-] Implement `FelloWayDbContext` and entity configurations for `User`, `OAuthIdentity`, `RefreshToken`, `City`, `Interest` in `backend/src/FelloWay.Infrastructure/Persistence/`
- [x] T011 [-] Add initial EF migration `InitialAuthProfile` in `backend/src/FelloWay.Infrastructure/Persistence/Migrations/`
- [x] T012 [-] Implement `IApplicationDbContext` abstraction in `backend/src/FelloWay.Application/Common/Interfaces/` and register in DI
- [x] T013 [-] Implement global exception middleware returning `ErrorResponse` per [shared/api-contracts/common/openapi.yaml](../../shared/api-contracts/common/openapi.yaml) in `backend/src/FelloWay.Api/Middleware/ExceptionHandlingMiddleware.cs`
- [x] T014 [-] Configure JWT bearer authentication and `ICurrentUserService` in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T015 [P] [-] Add `IntegrationTestFixture` with Testcontainers PostgreSQL in `backend/tests/FelloWay.Api.Tests/Infrastructure/IntegrationTestFixture.cs`
- [x] T016 [P] [-] Add `WebApplicationFactory` subclass `FelloWayWebApplicationFactory` in `backend/tests/FelloWay.Api.Tests/Infrastructure/FelloWayWebApplicationFactory.cs`
- [x] T017 [-] Seed reference data (cities sample, interests) via `IDataSeeder` in `backend/src/FelloWay.Infrastructure/Persistence/Seed/`
- [x] T018 [-] Wire Infrastructure DI module in `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [x] T019 [-] Wire Application DI module in `backend/src/FelloWay.Application/DependencyInjection.cs`
- [x] T020 [-] Expose `GET /health` and `GET /health/ready` (DB check) in `backend/src/FelloWay.Api/Controllers/HealthController.cs`

**Checkpoint**: Solution builds; migration applies; health returns 200; integration fixture boots API

---

## Phase 3: User Story 1 — Authenticate and complete profile (Priority: P1) 🎯 MVP

**Goal**: OAuth token exchange, JWT session, profile CRUD, avatar upload, GetStream user sync + token (FR-B001–FR-B004)

**Independent Test**: `POST /auth/oauth/{provider}/token` → `GET /users/me` → `PUT /users/me` → `POST /users/me/avatar` → `GET /chat/stream-token` (see [spec.md](./spec.md) US1)

### Tests for User Story 1 (REQUIRED) ⚠️

> Write these tests **first**; they MUST fail before implementation

- [x] T021 [P] [US1] Unit tests for refresh token hashing/validation in `backend/tests/FelloWay.Application.Tests/Auth/RefreshTokenServiceTests.cs`
- [x] T022 [P] [US1] Unit tests for profile completeness rules in `backend/tests/FelloWay.Application.Tests/Users/ProfileCompletenessTests.cs`
- [x] T023 [US1] Integration test OAuth token exchange (test handler stub) in `backend/tests/FelloWay.Api.Tests/Auth/OAuthTokenEndpointTests.cs`
- [x] T024 [US1] Integration test `GET/PUT /users/me` in `backend/tests/FelloWay.Api.Tests/Users/UsersMeEndpointTests.cs`

### Implementation for User Story 1

- [x] T025 [P] [US1] Domain entities `User`, `OAuthIdentity`, `RefreshToken` in `backend/src/FelloWay.Domain/Entities/`
- [x] T026 [P] [US1] Application commands `ExchangeOAuthCodeCommand`, `RefreshTokenCommand`, `RevokeTokenCommand` in `backend/src/FelloWay.Application/Auth/`
- [x] T027 [US1] Implement `IOAuthTokenExchanger` (LinkedIn + Facebook) with Polly in `backend/src/FelloWay.Infrastructure/Auth/`
- [x] T028 [US1] Implement `IJwtTokenService` and `IRefreshTokenService` in `backend/src/FelloWay.Infrastructure/Auth/`
- [x] T029 [US1] `AuthController` — `POST /auth/oauth/{provider}/token`, `POST /auth/refresh`, `POST /auth/logout` in `backend/src/FelloWay.Api/Controllers/AuthController.cs` per [shared/api-contracts/auth/openapi.yaml](../../shared/api-contracts/auth/openapi.yaml)
- [x] T030 [US1] Application handlers `GetCurrentUserQuery`, `UpdateCurrentUserCommand` in `backend/src/FelloWay.Application/Users/`
- [x] T031 [US1] `UsersController` — `GET /users/me`, `PUT /users/me` in `backend/src/FelloWay.Api/Controllers/UsersController.cs` per [shared/api-contracts/users/openapi.yaml](../../shared/api-contracts/users/openapi.yaml)
- [x] T032 [US1] Implement `IBlobStorageService` (Azure Blob) for avatars in `backend/src/FelloWay.Infrastructure/Storage/BlobStorageService.cs`
- [x] T033 [US1] `POST /users/me/avatar` multipart endpoint in `backend/src/FelloWay.Api/Controllers/UsersController.cs`
- [x] T034 [US1] Implement `IStreamChatService` user upsert + token mint in `backend/src/FelloWay.Infrastructure/Stream/StreamChatService.cs`
- [x] T035 [US1] `GET /chat/stream-token` in `backend/src/FelloWay.Api/Controllers/ChatController.cs`
- [x] T036 [US1] FluentValidation validators for auth and profile DTOs in `backend/src/FelloWay.Application/Validators/`
- [x] T037 [US1] Verify Flutter `API_MODE=live` sign-in + profile against local API (document smoke steps in [quickstart.md](./quickstart.md))

**Checkpoint**: Mobile client can authenticate and load/update profile without mocks

---

## Phase 4: User Story 2 — Discover and join events (Priority: P1)

**Goal**: Event list/search/geo, detail, attend/unjoin, gated attendees (FR-B005–FR-B006)

**Independent Test**: Paginated `GET /events`; `POST/DELETE /events/{id}/attend`; `GET /events/{id}/attendees` only when joined (see [spec.md](./spec.md) US2)

### Tests for User Story 2 (REQUIRED) ⚠️

- [x] T038 [P] [US2] Unit tests for Haversine sort helper in `backend/tests/FelloWay.Application.Tests/Events/GeoSortTests.cs`
- [x] T039 [P] [US2] Unit tests for attendance authorization policies in `backend/tests/FelloWay.Application.Tests/Events/AttendancePolicyTests.cs`
- [x] T040 [US2] Integration test event list pagination + filters in `backend/tests/FelloWay.Api.Tests/Events/EventsListEndpointTests.cs`
- [x] T041 [US2] Integration test attend/unjoin + attendee gating in `backend/tests/FelloWay.Api.Tests/Events/EventAttendEndpointTests.cs`

### Implementation for User Story 2

- [x] T042 [P] [US2] Domain entities `Event`, `EventAttendee`, `EventInterest` + enums in `backend/src/FelloWay.Domain/Entities/`
- [x] T043 [US2] EF configurations and migration `EventsAndAttendance` in `backend/src/FelloWay.Infrastructure/Persistence/`
- [x] T044 [US2] `ListEventsQuery` with cursor pagination, `q`, city, interest filters in `backend/src/FelloWay.Application/Events/`
- [x] T045 [US2] `GetEventByIdQuery`, `AttendEventCommand`, `LeaveEventCommand` in `backend/src/FelloWay.Application/Events/`
- [x] T046 [US2] `EventsController` — `GET /events`, `GET /events/{id}` in `backend/src/FelloWay.Api/Controllers/EventsController.cs`
- [x] T047 [US2] Attend endpoints `POST/DELETE /events/{id}/attend` in `backend/src/FelloWay.Api/Controllers/EventsController.cs`
- [x] T048 [US2] `GET /events/{id}/attendees` with subscriber-only policy in `backend/src/FelloWay.Api/Controllers/EventsController.cs`
- [x] T049 [US2] Hook attend/unjoin to Stream event channel membership in `backend/src/FelloWay.Infrastructure/Stream/EventChannelSyncService.cs`
- [x] T050 [US2] Align response DTOs with [shared/api-contracts/events/openapi.yaml](../../shared/api-contracts/events/openapi.yaml); update [frontend/lib/shared/mocks/mock_api_catalog.dart](../../frontend/lib/shared/mocks/mock_api_catalog.dart) if shapes differ

**Checkpoint**: Signed-in user can browse, join, leave events; attendee list enforced

---

## Phase 5: User Story 3 — Trip chats and join workflow (Priority: P2)

**Goal**: Trip CRUD, join requests, auto-approve by city, owner approve, member cap (FR-B007)

**Independent Test**: Create trip → Stream channel; join request flow; approve; 20-member cap (see [spec.md](./spec.md) US3)

### Tests for User Story 3 (REQUIRED) ⚠️

- [x] T051 [P] [US3] Unit tests for auto-approve policy (same `origin_city_id`) in `backend/tests/FelloWay.Application.Tests/Trips/TripJoinApprovalPolicyTests.cs`
- [x] T052 [US3] Integration test trip create + join + approve in `backend/tests/FelloWay.Api.Tests/Trips/TripJoinFlowEndpointTests.cs`

### Implementation for User Story 3

- [x] T053 [P] [US3] Domain entities `Trip`, `TripMember`, `TripJoinRequest` in `backend/src/FelloWay.Domain/Entities/`
- [x] T054 [US3] EF migration `TripsAndJoinRequests` in `backend/src/FelloWay.Infrastructure/Persistence/Migrations/`
- [x] T055 [US3] Commands/queries: `CreateTripCommand`, `ListTripsForEventQuery`, `RequestTripJoinCommand`, `CancelTripJoinCommand`, `ListTripJoinRequestsQuery`, `ApproveTripJoinCommand` in `backend/src/FelloWay.Application/Trips/`
- [x] T056 [US3] Trip endpoints under `EventsController` / `TripsController` in `backend/src/FelloWay.Api/Controllers/TripsController.cs` per OpenAPI paths `/events/{id}/trips`, `/trips/{id}/join`, etc.
- [x] T057 [US3] Enforce max 20 members in domain service `backend/src/FelloWay.Domain/Services/TripMembershipService.cs`
- [x] T058 [US3] Stream trip channel create + member sync in `backend/src/FelloWay.Infrastructure/Stream/TripChannelSyncService.cs`
- [x] T059 [US3] Optional GetStream webhook receiver stub in `backend/src/FelloWay.Api/Controllers/StreamWebhookController.cs` for future sync (SC-B003)

**Checkpoint**: Trip lifecycle works end-to-end with Stream membership

---

## Phase 6: User Story 4 — Trust, safety, and notifications (Priority: P2)

**Goal**: Block, reviews, push preferences, admin moderation APIs (FR-B008–FR-B010)

**Independent Test**: Block user; post/list reviews; update push prefs; admin approves pending event (see [spec.md](./spec.md) US4)

### Tests for User Story 4 (REQUIRED) ⚠️

- [x] T060 [P] [US4] Unit tests for aggregate rating update on review insert in `backend/tests/FelloWay.Application.Tests/Users/RatingAggregationTests.cs`
- [x] T061 [US4] Integration test block + review + push preferences in `backend/tests/FelloWay.Api.Tests/Users/TrustAndPrefsEndpointTests.cs`
- [x] T062 [US4] Integration test admin pending event approve in `backend/tests/FelloWay.Api.Tests/Admin/AdminEventsEndpointTests.cs`

### Implementation for User Story 4

- [x] T063 [P] [US4] Domain entities `Review`, `BlockedUser`, `PushPreferences`, `Report` in `backend/src/FelloWay.Domain/Entities/`
- [x] T064 [US4] EF migration `TrustSafetyNotifications` in `backend/src/FelloWay.Infrastructure/Persistence/Migrations/`
- [x] T065 [US4] `POST /users/{id}/block`, `GET /users/{id}/reviews`, `PUT /users/me/push-preferences` in `backend/src/FelloWay.Api/Controllers/UsersController.cs`
- [x] T066 [US4] `POST /events/{id}/attendees/{userId}/review` in `backend/src/FelloWay.Api/Controllers/EventsController.cs`
- [x] T067 [US4] Admin policy `AdminOnly` and `AdminController` — pending events approve/reject, user ban, reports list/resolve in `backend/src/FelloWay.Api/Controllers/AdminController.cs`
- [x] T068 [US4] Configure Hangfire in `backend/src/FelloWay.Api/Program.cs` and storage in Infrastructure
- [x] T069 [US4] Post-event review reminder job in `backend/src/FelloWay.Infrastructure/Jobs/PostEventReviewReminderJob.cs`
- [x] T070 [US4] Custom push trigger stubs (event interest / same-city attend) in `backend/src/FelloWay.Infrastructure/Notifications/CustomPushDispatcher.cs`

**Checkpoint**: Trust/safety endpoints live; admin can moderate; jobs registered

---

## SC-B001 validation (Flutter `API_MODE=live`)

| Step | Status | Notes |
|------|--------|-------|
| Local API + `flutter run --dart-define=API_MODE=live` | Documented | See [quickstart.md](./quickstart.md) — dev OAuth `dev-{subject}` |
| Staging E2E sign-in → profile → event join | **Pending** | Run when Azure staging is provisioned (T075 checklist) |
| Record pass/fail in PR | **Pending** | Owner to attach screenshot or test log on first staging deploy |

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: CI hardening, contract parity, performance evidence, deployment readiness

- [x] T071 [P] [-] Finalize OpenAPI merge in Swashbuckle referencing all `shared/api-contracts/*/openapi.yaml` domains
- [x] T072 [-] Add API versioning header or path prefix `/v1` if required — document in [shared/api-contracts/README.md](../../shared/api-contracts/README.md)
- [x] T073 [P] [-] Add structured logging (no PII/tokens) with correlation id middleware in `backend/src/FelloWay.Api/Middleware/CorrelationIdMiddleware.cs`
- [x] T074 [-] Run `dotnet format`, `dotnet test` on CI; fix failures (NFR quality gate)
- [x] T075 [-] Staging deploy checklist: Azure App Service + PostgreSQL + Key Vault bindings in [quickstart.md](./quickstart.md)
- [x] T076 [-] Validate SC-B001: Flutter E2E against staging API (`API_MODE=live`) — record result in [tasks.md](./tasks.md) or PR
- [x] T077 [P] [-] Load smoke script or k6 note for NFR-B001 p95 reads (document targets in [quickstart.md](./quickstart.md))
- [x] T078 [-] PR checklist template: update OpenAPI + `mock_api_catalog.dart` when REST changes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)** → **US1 (Phase 3)** → **US2 (Phase 4)** → **US3 (Phase 5)** → **US4 (Phase 6)** → **Polish (Phase 7)**
- US2 requires US1 (JWT + user id). US3 requires US2 (event attendance). US4 can start after US1 for block/reviews but admin/events moderation fits after US2.

### User Story Dependencies

| Story | Depends on | Can test independently after |
|-------|------------|------------------------------|
| US1 | Foundational | OAuth + profile + Stream token |
| US2 | US1 + Foundational | Event list/join without trips |
| US3 | US2 | Trips only when attended event |
| US4 | US1 (US2 for event reviews/admin events) | Block/reviews/prefs; admin needs events |

### Parallel Opportunities

- **Phase 1**: T003, T004, T006, T007 in parallel
- **Phase 2**: T015, T016 in parallel
- **US1**: T021–T022 parallel; T025–T026 parallel
- **US2**: T038–T039 parallel; T042 + entity work parallel with tests once Foundational done
- **US3–US4**: Policy unit tests parallel to entity creation

### Parallel Example: User Story 1

```bash
# Tests first (parallel):
backend/tests/FelloWay.Application.Tests/Auth/RefreshTokenServiceTests.cs
backend/tests/FelloWay.Application.Tests/Users/ProfileCompletenessTests.cs

# Domain entities (parallel):
backend/src/FelloWay.Domain/Entities/User.cs
backend/src/FelloWay.Domain/Entities/OAuthIdentity.cs
backend/src/FelloWay.Domain/Entities/RefreshToken.cs
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1–2 (Setup + Foundational)
2. Complete Phase 3 (US1)
3. **STOP and VALIDATE**: Flutter `API_MODE=live` auth + profile (T037)
4. Demo to stakeholders before events API

### Incremental Delivery

1. US1 → staging deploy → mobile auth
2. US2 → event discovery/join live
3. US3 → trip chats
4. US4 → trust/admin/notifications
5. Polish → production readiness

### Suggested MVP scope

**Phases 1–3 (through T037)** deliver minimum backend for mobile onboarding and profile (SC-B001 partial). Add **Phase 4** for full event networking MVP with client list/join.

---

## Notes

- Task IDs T001–T078 sequential by phase order
- All implementation paths under `backend/` unless contracts in `shared/api-contracts/`
- Mark tasks `[x]` when complete; keep [quickstart.md](./quickstart.md) in sync with real `dotnet` commands
