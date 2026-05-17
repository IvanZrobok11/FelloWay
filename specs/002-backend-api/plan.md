# Implementation Plan: FelloWay Backend API (MVP)

**Branch**: `002-backend-api` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: Plan backend application with REST API per PRD and TECH_PLAN. Consumed by [frontend/](../../frontend/) (`felloway_client`).

## Summary

Implement an **ASP.NET Core 8** REST API in `backend/` with PostgreSQL (EF Core), OAuth token exchange for LinkedIn/Facebook, JWT session management, Azure Blob avatars, and GetStream user/channel orchestration. Contracts live in `shared/api-contracts/`; delivery follows TECH_PLAN backend phases 1–5 (admin endpoints last). The Flutter app switches from `API_MODE=mock` to `live` against staging as endpoints land.

## Technical Context

**Language/Version**: C# 12 / .NET 8  
**Primary Dependencies**: ASP.NET Core, EF Core 8 + Npgsql, Swashbuckle, FluentValidation, Stream Chat .NET SDK, Azure.Storage.Blobs, Hangfire (PostgreSQL storage), Polly (HTTP resilience for OAuth)  
**Storage**: PostgreSQL (primary); Azure Blob (avatars); GetStream (chat state); refresh tokens in DB (hashed)  
**Testing**: xUnit, WebApplicationFactory, Testcontainers.PostgreSql, Moq/NSubstitute for externals  
**Target Platform**: Linux App Service (Azure), container-ready  
**Project Type**: Backend Web API (`backend/`) in monorepo with `frontend/` and `shared/api-contracts/`  
**Performance Goals**: NFR-B001 — p95 &lt; 300 ms reads on staging; event list pagination default page size 20  
**Constraints**: Secrets via Key Vault / user secrets; no provider tokens logged; GDPR-minded PII minimization on logs  
**Scale/Scope**: MVP ~25 MAU pilot (GetStream free tier); all REST paths in [rest-endpoints legacy index](../001-event-networking-app/contracts/rest-endpoints.md) plus admin slice

## Constitution Check

*GATE: Repository constitution is Flutter-oriented. Backend delivery uses **equivalent** gates documented below.*

| Principle (constitution) | Backend adaptation | Status |
|--------------------------|-------------------|--------|
| Code quality gate | `dotnet format`, analyzers, nullable enabled, PR review | ✅ Planned |
| Test strategy | Unit + integration tests; critical paths: OAuth, attend, trip join/approve | ✅ Planned |
| UX consistency | N/A (API); consistent error/pagination contracts in `shared/api-contracts/common/` | ✅ Planned |
| Performance budgets | NFR-B001 latency; load test checklist in quickstart | ✅ Planned |
| Flutter analyze | N/A — **exception** (see Complexity Tracking) | ✅ Justified |
| Evidence plan | CI workflow artifacts, OpenAPI diff on PR | ✅ Planned |

*Re-check post Phase 1: contracts and data model cover all spec FR-B* items.*

## Project Structure

### Documentation (this feature)

```text
specs/002-backend-api/
├── plan.md              # This file
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/           # Links + notes; canonical OpenAPI in shared/api-contracts/
└── tasks.md             # (/speckit.tasks — not created by /speckit.plan)
```

### Source Code (repository root)

```text
backend/
├── FelloWay.sln
├── src/
│   ├── FelloWay.Api/              # Controllers, middleware, DI composition
│   ├── FelloWay.Application/      # Commands/queries, validators, interfaces
│   ├── FelloWay.Domain/           # Entities, enums, domain exceptions
│   └── FelloWay.Infrastructure/   # EF Core, OAuth, Blob, Stream, Hangfire
└── tests/
    ├── FelloWay.Api.Tests/        # Integration tests (WebApplicationFactory)
    └── FelloWay.Application.Tests/

shared/api-contracts/
├── auth/
├── users/
├── common/
└── events/

frontend/                          # Existing Flutter client (consumer)
```

**Structure Decision**: Single .NET solution under `backend/` with Clean Architecture layers. HTTP contracts are **not** duplicated under `specs/002-backend-api/contracts/` except README pointers — canonical OpenAPI lives in `shared/api-contracts/` for frontend/backend parity.

## Delivery Phases (Backend mapping from TECH_PLAN)

| Phase | TECH_PLAN | Backend deliverables |
|-------|-----------|---------------------|
| B0 | 0 | Repo skeleton, CI, EF migrations baseline, Key Vault wiring, health checks |
| B1 | 1 | OAuth + JWT refresh, users/me, avatar blob, Stream user sync + stream-token |
| B2 | 2 | Events CRUD (admin + pending), attend/unjoin, list/search/geo, attendees |
| B3 | 3 | Trips, join requests, approve, block, Stream channels + webhooks |
| B4 | 4 | Reviews, push preferences, Hangfire jobs for feedback/custom push |
| B5 | 5 | Admin endpoints: pending events, ban, reports |

## Integration Boundaries

| System | Responsibility |
|--------|----------------|
| LinkedIn / Facebook OAuth | Provider tokens exchanged server-side; map to internal `User` |
| GetStream | Channels for event/trip/DM; server is membership authority |
| Azure Blob | Avatar objects |
| Flutter client | Bearer JWT on REST; Stream SDK with token from API |
| Admin web (later) | Same API with `Admin` role |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Constitution assumes Flutter-only gates | Backend is new surface in same monorepo | Ignoring quality gates would block release discipline |
| Clean Architecture (4 projects) | Testability + swap Infrastructure | Single-project Web API insufficient at ~40+ endpoints |
| Hangfire in API process | MVP scheduling without extra Azure Function app | Manual cron / Functions add ops overhead for pilot |

## Risks

- **LinkedIn app verification** — start in B0 (TECH_PLAN).
- **GetStream 25 MAU** — monitor pilot; plan paid tier.
- **Contract drift** — enforce PR checklist: update `shared/api-contracts/` + Flutter mock catalog when REST changes.
