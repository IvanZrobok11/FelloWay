# Implementation Plan: Cross-Origin Access for Web Clients

**Branch**: `007-api-cors-policy` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: Enable browser clients (Flutter web) to call the FelloWay API from a different origin without CORS blocks, using configurable allowlists per environment.

## Summary

Add ASP.NET Core **CORS middleware** to `FelloWay.Api` with environment-aware origin rules: **Development** permits any `localhost` / `127.0.0.1` origin (any port); **non-Development** uses `Cors:AllowedOrigins` from configuration only. Support preflight for `Authorization` and JSON methods. Add **automated API tests** and **quickstart/docs** for Flutter web + `https://localhost:7086`.

## Technical Context

**Language/Version**: C# 12 / .NET 8  
**Primary Dependencies**: ASP.NET Core CORS (built-in), existing `FelloWay.Api` pipeline, `Microsoft.AspNetCore.Mvc.Testing` (tests)  
**Storage**: N/A (configuration only)  
**Testing**: xUnit + `FelloWayWebApplicationFactory`; new `CorsPolicyTests` in fast suite  
**Target Platform**: Local dev (Flutter web + Kestrel); staging/production App Service  
**Project Type**: Monorepo — `backend/src/FelloWay.Api/`, `backend/tests/FelloWay.Api.Tests/`  
**Performance Goals**: Negligible overhead (middleware only); no new external calls  
**Constraints**: No `*` origin in production; no `AllowCredentials`; native mobile unchanged  
**Scale/Scope**: ~4 new/edited backend files, 1 test class, docs in `frontend/README.md` + quickstart

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `dotnet format` / `dotnet build` on backend |
| Test strategy | ✅ Pass | `CorsPolicyTests` — allowed + denied origin + OPTIONS preflight |
| UX consistency | ✅ Pass (docs) | Web users get API errors in-app, not opaque CORS console failures |
| Performance budgets | ✅ Pass | No measurable client impact |
| Flutter quality checks | ✅ N/A | Docs-only in `frontend/README.md` unless smoke note added |
| Evidence plan | ✅ Pass | CI fast suite + quickstart manual smoke |

**Post-design re-check**: No violations.

## Project Structure

### Documentation (this feature)

```text
specs/007-api-cors-policy/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/cors-policy-contract.md
└── tasks.md                    # /speckit.tasks
```

### Source Code (repository root)

```text
backend/src/FelloWay.Api/
├── Extensions/CorsExtensions.cs          # NEW: AddFelloWayCors, policy builder
├── Configuration/CorsOptions.cs          # NEW: bind Cors:AllowedOrigins
├── Program.cs                            # AddCors + UseCors
├── appsettings.json                      # Cors:AllowedOrigins: []
└── appsettings.Development.json          # optional extra origins (commented sample)

backend/tests/FelloWay.Api.Tests/
└── Cors/CorsPolicyTests.cs               # NEW

frontend/README.md                        # Flutter web + API_BASE_URL section
specs/002-backend-api/quickstart.md         # staging CORS bullet → link 007
```

**Structure Decision**: Backend-only implementation; Flutter client unchanged (already sends correct headers via Dio).

## Implementation Phases (for `/speckit.tasks`)

### Phase 1 — CORS middleware (P1)

1. Add `CorsOptions` + `CorsExtensions.AddFelloWayCors(services, configuration, environment)`.
2. Policy **Development**: `SetIsOriginAllowed` for `localhost` / `127.0.0.1`.
3. Policy **non-Development**: `WithOrigins(configured)` only; deny if not listed.
4. `WithMethods`, `WithHeaders` per [contracts/cors-policy-contract.md](./contracts/cors-policy-contract.md).
5. Wire `builder.Services.AddFelloWayCors(...)` and `app.UseCors()` in `Program.cs` (order per contract).

### Phase 2 — Configuration & docs (P1)

1. Add `Cors` section to `appsettings.json` (empty array).
2. Document staging/production override pattern in quickstart + `backend/README.md` snippet.
3. Update `frontend/README.md` with Flutter web live-mode example (`API_BASE_URL`, `API_MODE=live`).

### Phase 3 — Tests (P1)

1. `CorsPolicyTests`: GET `/health` with allowed `Origin` → `Access-Control-Allow-Origin` echoed.
2. OPTIONS preflight with `Access-Control-Request-Method: POST` + `authorization` header → success + allow headers.
3. Production-like factory: unlisted origin → no permissive allow header.
4. Ensure fast suite `Category!=Integration` stays green.

## Complexity Tracking

> No constitution violations requiring justification.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| CORS contract | [contracts/cors-policy-contract.md](./contracts/cors-policy-contract.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
