# Tasks: Cross-Origin Access for Web Clients

**Input**: Design documents from `/specs/007-api-cors-policy/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cors-policy-contract.md, quickstart.md  
**Branch**: `007-api-cors-policy`

**Tests**: Included per spec NFR-TEST-001 and plan (`CorsPolicyTests` in fast suite).

**Organization**: Tasks grouped by user story; backend-only implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to spec user stories US1–US3

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Configuration types and appsettings scaffold

- [x] T001 [P] Add `CorsOptions` class binding `Cors:AllowedOrigins` in `backend/src/FelloWay.Api/Configuration/CorsOptions.cs`
- [x] T002 [P] Add `Cors:AllowedOrigins` empty array to `backend/src/FelloWay.Api/appsettings.json`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: CORS middleware and pipeline wiring — **blocks all user stories**

**⚠️ CRITICAL**: No user story verification can complete until this phase is done

- [x] T003 Implement `AddFelloWayCors` in `backend/src/FelloWay.Api/Extensions/CorsExtensions.cs` (Development localhost/`127.0.0.1` predicate; non-Development explicit origins; methods/headers per `specs/007-api-cors-policy/contracts/cors-policy-contract.md`; no credentials)
- [x] T004 Register `AddFelloWayCors` and `UseCors` in `backend/src/FelloWay.Api/Program.cs` (middleware order: after `UseStaticFiles`, before `CorrelationIdMiddleware`)

**Checkpoint**: API starts in Development; manual `curl -H "Origin: http://localhost:9999"` to `/health` should return `Access-Control-Allow-Origin` after T003–T004

---

## Phase 3: User Story 1 — Local web client loads live data (Priority: P1) 🎯 MVP

**Goal**: Flutter web on ephemeral `http://localhost:<port>` can call `https://localhost:7086` without browser CORS blocks.

**Independent Test**: `GET /health` or `GET /events` with `Origin: http://localhost:<port>` returns `Access-Control-Allow-Origin` matching the request origin when API runs in Development.

### Tests for User Story 1

- [x] T005 [US1] Add `CorsPolicyTests.GetHealth_WithLocalhostOrigin_ReturnsAllowOrigin` in `backend/tests/FelloWay.Api.Tests/Cors/CorsPolicyTests.cs` using `FelloWayWebApplicationFactory` and Development-equivalent settings

### Implementation for User Story 1

- [x] T006 [US1] Ensure `CorsExtensions` Development policy allows any `localhost` / `127.0.0.1` port (http and https) in `backend/src/FelloWay.Api/Extensions/CorsExtensions.cs` — adjust T003 if needed until T005 passes

**Checkpoint**: T005 green; Flutter web smoke per `specs/007-api-cors-policy/quickstart.md` §2–3

---

## Phase 4: User Story 2 — Configurable allowed origins per environment (Priority: P1)

**Goal**: Operators control allowlist via configuration; unlisted origins denied outside Development.

**Independent Test**: Factory with explicit `Cors:AllowedOrigins` permits listed origin; production-like config rejects `https://evil.example`.

### Tests for User Story 2

- [x] T007 [P] [US2] Add `CorsPolicyTests.GetHealth_WithConfiguredOrigin_ReturnsAllowOrigin` in `backend/tests/FelloWay.Api.Tests/Cors/CorsPolicyTests.cs` (`UseSetting` for `Cors:AllowedOrigins__0`)
- [x] T008 [P] [US2] Add `CorsPolicyTests.GetHealth_WithUnlistedOrigin_DoesNotReturnAllowOrigin` in `backend/tests/FelloWay.Api.Tests/Cors/CorsPolicyTests.cs` (non-Development / Production environment, fixed allowlist)

### Implementation for User Story 2

- [x] T009 [US2] Validate and filter `Cors:AllowedOrigins` entries (absolute origin only; ignore invalid) in `backend/src/FelloWay.Api/Extensions/CorsExtensions.cs`

**Checkpoint**: T007–T008 green; staging config pattern documented

---

## Phase 5: User Story 3 — Preflight and authenticated browser calls (Priority: P2)

**Goal**: `OPTIONS` preflight succeeds for `POST` + `Authorization` from permitted origins.

**Independent Test**: `OPTIONS` with `Access-Control-Request-Method: POST` and `Access-Control-Request-Headers: authorization,content-type` returns 2xx with allow headers.

### Tests for User Story 3

- [x] T010 [US3] Add `CorsPolicyTests.OptionsPreflight_WithAuthorizationHeader_ReturnsAllowHeaders` in `backend/tests/FelloWay.Api.Tests/Cors/CorsPolicyTests.cs`

### Implementation for User Story 3

- [x] T011 [US3] Confirm `WithHeaders` includes `Authorization`, `Content-Type`, `Accept`, `X-Correlation-ID` and methods include `POST` in `backend/src/FelloWay.Api/Extensions/CorsExtensions.cs` — adjust until T010 passes

**Checkpoint**: T010 green; authenticated Flutter web `POST` flows no longer fail on preflight

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and validation

- [x] T012 [P] Add Flutter web + live API section to `frontend/README.md` (`API_MODE=live`, `API_BASE_URL=https://localhost:7086`, link to quickstart)
- [x] T013 [P] Add CORS configuration snippet to `backend/README.md` (reference `Cors:AllowedOrigins` and `specs/007-api-cors-policy/quickstart.md`)
- [x] T014 Update staging CORS bullet in `specs/002-backend-api/quickstart.md` to link `specs/007-api-cors-policy/quickstart.md`
- [x] T015 Run `dotnet test FelloWay.slnx --filter "Category!=Integration"` from `backend/` and confirm all tests pass

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends on | Delivers |
|-------|------------|----------|
| 1 Setup | — | `CorsOptions`, appsettings |
| 2 Foundational | Phase 1 | Working CORS middleware |
| 3 US1 | Phase 2 | Localhost dev CORS + test |
| 4 US2 | Phase 2 | Config allowlist + deny tests |
| 5 US3 | Phase 2 (T003 headers) | Preflight test |
| 6 Polish | Phases 3–5 | Docs + full test run |

### User Story Dependencies

- **US1**: After Foundational — **MVP** (unblocks Flutter web dev)
- **US2**: After Foundational — can parallel with US1 tests once T003 exists
- **US3**: After Foundational — preflight headers in T003; test T010 can follow T005

### Parallel Opportunities

```text
Phase 1:  T001 || T002
Phase 4:  T007 || T008  (same file, different tests — sequential edits OK)
Phase 6:  T012 || T013
```

---

## Parallel Example: User Story 2

```bash
# After T003–T004, add both tests (same file, one after the other):
# T007: configured origin allowed
# T008: unlisted origin denied in Production-like host
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2 (T001–T004)
2. Complete Phase 3 (T005–T006)
3. **Validate**: `dotnet test` + Flutter web quickstart §3
4. Optional: ship MVP before US2/US3 if timeboxed

### Incremental Delivery

1. Setup + Foundational → CORS enabled
2. US1 → local Flutter web unblocked (**MVP**)
3. US2 → production-safe allowlist
4. US3 → write/auth preflight
5. Polish → docs + CI evidence

---

## Notes

- No Flutter code changes required (Dio already sends `Authorization` / `Accept`).
- Use `FelloWayWebApplicationFactory` with `UseSetting` for test configuration (same pattern as `006-hybrid-test-database`).
- Do not use `AllowCredentials` or `*` origin in production policy.
