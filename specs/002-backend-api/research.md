# Research: Backend API (002-backend-api)

**Date**: 2026-05-17

## 1. API framework and solution layout

**Decision**: ASP.NET Core 8 Web API with Clean Architecture layers (`Api` → `Application` → `Domain` ← `Infrastructure`).

**Rationale**: Matches TECH_PLAN; strong DI, OpenAPI, auth middleware, EF Core integration, Azure-first hosting.

**Alternatives considered**:
- Minimal APIs only — rejected for larger MVP surface (many endpoints, policies).
- Node/Nest — rejected; team stack is .NET.

## 2. Persistence

**Decision**: PostgreSQL via EF Core 8; migrations in `Infrastructure`; snake_case column naming optional (team preference: PascalCase in C#, default EF).

**Rationale**: TECH_PLAN; relational model fits events, attendance, trips, reviews.

**Alternatives considered**:
- PostGIS — deferred; Haversine in SQL/expressions for MVP geo sort.

## 3. Authentication

**Decision**: Mobile OAuth via authorization code + PKCE handled by `flutter_appauth`; backend exposes token exchange endpoints (`POST /auth/oauth/{provider}/callback` or BFF-style `POST /auth/token`) issuing **JWT access** (short) + **refresh token** (stored hashed in DB).

**Rationale**: PRD requires refresh sessions; mobile already uses secure storage.

**Alternatives considered**:
- Session cookies only — poor fit for native mobile.
- Pass-through provider tokens to API — rejected; need server-side user identity and Stream sync.

## 4. Authorization

**Decision**: ASP.NET Core JWT bearer + policy-based authorization (`AdminOnly`, `EventSubscriber`, `TripOwner`).

**Rationale**: Fine-grained rules for attendees, trip owners, admins.

## 5. GetStream integration

**Decision**: Server-side `StreamChatClient` (official .NET SDK) for user upsert, channel create, member add/remove; `GET /chat/stream-token` mints user JWT; optional webhook endpoint for message/member events (Phase 3).

**Rationale**: TECH_PLAN; mobile SDK only connects with token.

**Alternatives considered**:
- Client-created channels — rejected; membership must follow server rules.

## 6. File storage

**Decision**: Azure Blob Storage for avatars; return HTTPS URL in profile DTO.

**Rationale**: TECH_PLAN Phase 1.

## 7. Background jobs

**Decision**: Hangfire (in-process) for MVP post-event review prompts and custom push fan-out; migrate to Azure Functions if hosting constraints require.

**Rationale**: TECH_PLAN Phase 4 mentions Hangfire or Functions.

## 8. API documentation

**Decision**: OpenAPI 3 YAML per domain under `shared/api-contracts/`; Swashbuckle serves merged doc from `backend` in Development.

**Rationale**: Monorepo contract-first alignment with Flutter mocks.

## 9. Testing strategy

**Decision**: xUnit + WebApplicationFactory integration tests against Testcontainers PostgreSQL; unit tests for application services and join-approval policy.

**Rationale**: Constitution spirit (automated gates); no Flutter analyzer on backend.

## 10. CI/CD

**Decision**: GitHub Actions — `dotnet format`, `dotnet build`, `dotnet test`, publish to Azure App Service on `main`/tags (Phase 0 shared with mobile).

**Rationale**: TECH_PLAN Phase 0.

## Resolved clarifications

| Topic | Resolution |
|-------|------------|
| Pagination | Cursor-based preferred for `GET /events` (`nextCursor`); offset acceptable for MVP if simpler |
| Id format | UUID v7 or GUID strings in JSON |
| Localization | Store user-facing content as provided; API returns raw strings; client localizes chrome |
| Reports mobile path | `POST /reports` (TBD body) — add in contracts Phase 3 |
