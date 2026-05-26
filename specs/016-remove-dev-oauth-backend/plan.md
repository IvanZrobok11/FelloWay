# Implementation Plan: Remove backend development OAuth token exchange

**Branch**: `016-remove-dev-oauth-backend` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Remove `DevOAuthTokenExchanger` and dev-code JWT issuance on deployed API (align with `015-remove-mock-local`)

## Summary

Remove the **development OAuth bypass** from production Infrastructure: delete `DevOAuthTokenExchanger`, replace `CompositeOAuthTokenExchanger` with a **production-only** exchanger that rejects `dev-*` codes and enforces LinkedIn BFF when configured. Move dev-code exchange logic to **`TestOAuthTokenExchanger`** registered only in `FelloWay.Api.Tests` web factories so CI stays green. Update auth tests and HTTP examples; smoke deployed dev with failed `dev-smoke-user` + successful BFF.

## Technical Context

**Language/Version**: C# 12 / .NET 8

**Primary Dependencies**: ASP.NET Core, `IOAuthTokenExchanger`, `AuthService`, `OAuthOptions`, LinkedIn BFF (`009-linkedin-bff-auth`)

**Storage**: PostgreSQL (unchanged); test InMemory / Testcontainers

**Testing**: xUnit `FelloWay.Api.Tests`, `Category!=Integration` in CI; Postgres integration tests in scope for factory DI override

**Target Platform**: API on ECS (dev/test/prod); test host `ASPNETCORE_ENVIRONMENT=Testing`

**Project Type**: `backend/src` + `backend/tests`

**Performance Goals**: No measurable regression (branch removal only)

**Constraints**:

- No dev JWT on deployed hosts
- Test-only exchanger must not be referenced from Infrastructure
- LinkedIn BFF remains primary web auth
- Coordinate with merged `015` client (no client dev token calls)

**Scale/Scope**: ~5 production auth files; ~12 test files with `LoginAsync`; 2–3 auth-specific tests to invert expectations

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | Standard .NET analyzers on touched projects |
| Test strategy | Pass | Invert rejection tests; shared `TestAuthExtensions`; integration factories updated |
| UX consistency | N/A (API); client already live-only per 015 |
| Performance | Pass | No new allocations on hot path |
| Evidence | Pass | [quickstart.md](./quickstart.md) + `dotnet test` |

**Post-design re-check**: Pass.

## Project Structure

### Documentation (this feature)

```text
specs/016-remove-dev-oauth-backend/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/oauth-token-exchange-policy.md
└── tasks.md                    # /speckit.tasks
```

### Source Code

```text
backend/src/FelloWay.Infrastructure/Auth/
├── DevOAuthTokenExchanger.cs           # DELETE
├── CompositeOAuthTokenExchanger.cs     # DELETE → ProductionOAuthTokenExchanger.cs
├── OAuthDevCode.cs                     # DELETE or production-only reject helper
└── ProductionOAuthTokenExchanger.cs    # NEW

backend/src/FelloWay.Infrastructure/DependencyInjection.cs   # register production exchanger only

backend/tests/FelloWay.Api.Tests/
├── Auth/TestOAuthTokenExchanger.cs     # NEW (dev logic moved here)
├── Auth/TestAuthExtensions.cs          # NEW shared LoginAsync
├── Infrastructure/FelloWayWebApplicationFactory.cs        # swap IOAuthTokenExchanger
├── Infrastructure/PostgresWebApplicationFactory.cs        # same swap
├── Auth/OAuthDevCodeRejectionTests.cs  # invert DevCode test
├── Auth/OAuthDevCodeWithoutSecretsTests.cs                # expect rejection
└── **/*EndpointTests.cs               # optional refactor to TestAuthExtensions

backend/src/FelloWay.Api/
├── FelloWay.Api.http                   # remove dev-smoke example
└── Controllers/AuthController.cs         # unchanged surface; behavior via exchanger
```

## Implementation Phases

### Phase A — Production exchanger (FR-001–FR-005)

1. Add `ProductionOAuthTokenExchanger` with rules from [research.md](./research.md) R2.
2. Delete `DevOAuthTokenExchanger.cs`, `CompositeOAuthTokenExchanger.cs`.
3. Update `DependencyInjection.cs`: `IOAuthTokenExchanger` → `ProductionOAuthTokenExchanger` only.
4. Remove or inline `OAuthDevCode.cs` for rejection in production only.

### Phase B — Test harness (FR-006)

1. Add `TestOAuthTokenExchanger` (current dev exchange behavior).
2. Register in `FelloWayWebApplicationFactory` and `PostgresWebApplicationFactory` via `RemoveAll` + `AddScoped`.
3. Add `TestAuthExtensions.LoginAsync` for DRY in endpoint tests.
4. Update `OAuthDevCodeRejectionTests`: dev code **rejected** when production exchanger used — use dedicated factory **without** test override for that test class, or split factories.
5. Update/delete `OAuthDevCodeWithoutSecretsTests` to expect failure without secrets.

### Phase C — Docs (FR-007)

1. Update `FelloWay.Api.http`.
2. Supersede note in `specs/005-api-backend-integration/quickstart.md` (link 016).
3. Optional: `backend/README` if dev login documented.

### Phase D — Validation (VR-001–004)

1. `dotnet test` full/fast suite.
2. Deployed dev smoke per [quickstart.md](./quickstart.md).
3. `rg DevOAuthTokenExchanger backend/src` → empty.

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
| Contract | [contracts/oauth-token-exchange-policy.md](./contracts/oauth-token-exchange-policy.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Coordination

- **015-remove-mock-local**: Client must not call `dev-smoke-user` on token endpoint (already removed sign-in UI).
- **009-linkedin-bff-auth**: BFF remains required path for web LinkedIn.
- **Out of scope**: `StreamChatService` dev stream tokens when misconfigured.

## Next Step

**`/speckit.tasks`** — ordered tasks for Phase A→D.
