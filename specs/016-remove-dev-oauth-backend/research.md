# Research: Remove backend development OAuth token exchange

**Feature**: `016-remove-dev-oauth-backend` | **Date**: 2026-05-26

## R1 — Production vs test auth split

**Decision**: Remove `DevOAuthTokenExchanger` from `FelloWay.Infrastructure`. Register `TestOAuthTokenExchanger` only in `FelloWay.Api.Tests` via `ConfigureServices` on test web application factories (in-memory + Postgres).

**Rationale**: Spec FR-002/FR-006: production DI must not ship dev exchanger; ~10 test files use `POST /auth/oauth/linkedin/token` with `dev-{subject}` and must keep working in CI.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Keep dev exchanger gated by `ASPNETCORE_ENVIRONMENT=Development` | ECS `dev` env name would still allow bypass |
| Issue JWT via `AuthService.IssueTokensForUserAsync` in each test | Duplicates HTTP contract; central test exchanger matches current `LoginAsync` pattern |
| Delete token endpoint entirely | Mobile/legacy clients may still hit endpoint; must reject cleanly |

## R2 — Replace `CompositeOAuthTokenExchanger`

**Decision**: Rename/replace with `ProductionOAuthTokenExchanger` (single class, no `DevOAuthTokenExchanger` dependency):

1. If code matches dev pattern (`dev-*`, `test-code`) → `DomainException` (invalid / not supported).
2. If provider `facebook` → `DomainException` (unsupported until real Facebook exchanger exists).
3. If provider `linkedin` and LinkedIn configured → existing BFF message (do not exchange raw codes).
4. If provider `linkedin` and LinkedIn **not** configured → `DomainException` (OAuth not configured); aligns with `AuthController.LinkedInLogin` 503.

**Rationale**: FR-001, FR-003, FR-004; removes silent dev fallback when secrets absent (today `OAuthDevCodeWithoutSecretsTests` expects OK — test must flip).

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Return 503 from exchanger | AuthService throws DomainException today; map to ProblemDetails in middleware/filter consistently |
| Keep facebook dev path | FR-005 |

## R3 — `OAuthDevCode` helper location

**Decision**: Move `OAuthDevCode.IsDevCode` to `ProductionOAuthTokenExchanger` as private static, **or** keep small `OAuthDevCode.cs` in Infrastructure for rejection-only (no exchange). Test project duplicates check in `TestOAuthTokenExchanger`.

**Rationale**: Production needs explicit rejection; tests need acceptance of dev codes only in test assembly.

## R4 — Test suite migration

**Decision**:

- Add `backend/tests/FelloWay.Api.Tests/Auth/TestOAuthTokenExchanger.cs` (copy current dev exchange logic).
- Add `backend/tests/FelloWay.Api.Tests/Auth/TestAuthExtensions.cs` with shared `LoginAsync(client, subject)` posting `dev-{subject}`.
- In `FelloWayWebApplicationFactory` / `PostgresWebApplicationFactory`: `services.RemoveAll<IOAuthTokenExchanger>(); services.AddScoped<IOAuthTokenExchanger, TestOAuthTokenExchanger>();`
- Update `OAuthDevCodeRejectionTests.DevCode_StillAccepted_*` → expect **400/422** (rejection).
- Update `OAuthDevCodeWithoutSecretsTests` → expect rejection (not OK) when using **production** host without test override, OR delete factory if redundant with rejection test.
- Keep `POST /auth/testing/web-session` for cookie-based tests only (already Testing env).

**Rationale**: FR-006, SC-003.

## R5 — Documentation and HTTP files

**Decision**: Update `FelloWay.Api.http` to remove `dev-smoke-user` example; add note pointing to BFF login. Supersede `005-api-backend-integration` quickstart dev sign-in section (link to 016).

**Rationale**: FR-007.

## R6 — Deployed smoke (VR-001)

**Decision**: Manual check after deploy: `POST .../auth/oauth/linkedin/token` with `dev-smoke-user` → 4xx; LinkedIn BFF flow on web → JWT + `GET /users/me` 200.

**Rationale**: SC-001, SC-002; pairs with `015` client smoke.

## R7 — Stream dev token (out of scope)

**Decision**: `StreamChatService` returning `dev-stream-token-*` when unconfigured is **out of scope** for 016 (separate hardening); note in plan assumptions.

**Rationale**: Spec focuses on OAuth token exchange path only.
