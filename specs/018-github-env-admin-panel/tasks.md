# Tasks: Admin panel (per-environment ECS + GitHub secrets)

**Input**: Design documents from `/specs/018-github-env-admin-panel/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/admin-panel-deployment.md](./contracts/admin-panel-deployment.md)

**Tests**: Included per spec NFR-TEST-001 and plan test strategy.

**Organization**: US1 = operator sign-in (admin app); US2 = create events (API + UI); US3 = list/edit; Infra/CI in final phases. **Foundational API service-key auth blocks US2/US3** but US1 admin UI can be built in parallel after scaffold.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable (different files, no incomplete dependencies)
- **[Story]**: US1, US2, US3

## Path Conventions

- Admin web: `admin/`
- API: `backend/src/FelloWay.Api/`, `backend/src/FelloWay.Application/`
- Infra: `infra/terraform/`
- CI: `.github/workflows/`, `.github/scripts/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Review scope and prepare solution layout.

- [x] T001 Review [spec.md](./spec.md), [plan.md](./plan.md), [contracts/admin-panel-deployment.md](./contracts/admin-panel-deployment.md), and per-env credential clarification
- [x] T002 Add `admin/FelloWay.Admin.csproj` and include project in `backend/FelloWay.slnx` (or repo solution file)
- [x] T003 [P] Document required GitHub Environment secret names in [quickstart.md](./quickstart.md) (`ADMIN_USERNAME`, `ADMIN_PASSWORD`, `ADMIN_SERVICE_KEY`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: API service-key authentication and shared admin/API configuration types. **Blocks US2 and US3.**

**⚠️ CRITICAL**: Complete before event CRUD endpoints and `AdminApiClient` calls.

- [x] T004 Add `AdminAuthOptions` and `AdminServiceKeyOptions` in `backend/src/FelloWay.Application/Admin/` (or `FelloWay.Api/Options/`) bound from configuration
- [x] T005 Add `AdminServiceKeyAuthenticationHandler` and scheme registration in `backend/src/FelloWay.Api/Auth/AdminServiceKeyAuthenticationHandler.cs` and `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T006 Add policy `AdminContent` requiring `X-Admin-Service-Key` header validation in `backend/src/FelloWay.Api/Extensions/AuthExtensions.cs`
- [x] T007 [P] Add `admin/appsettings.json` and `admin/appsettings.Development.json` with `AdminAuth` and `Api:BaseUrl` sections (no secrets committed)
- [x] T008 [P] Add `admin/Program.cs` skeleton: Razor Pages, cookie auth placeholder, `HttpClient` for API base URL

**Checkpoint**: API can authenticate service-key requests; admin project builds.

---

## Phase 3: User Story 1 - Operator signs in to the admin panel (Priority: P1)

**Goal**: Cookie-based login per environment credentials; protected pages redirect to login.

**Independent Test**: Run admin locally with user-secrets; valid login → dashboard; invalid → generic error; `/Events` without cookie → redirect to login.

### Tests for User Story 1

- [x] T009 [P] [US1] Add `backend/tests/FelloWay.Admin.Tests/FelloWay.Admin.Tests.csproj` and `AdminLoginPageTests.cs` (valid/invalid login via `WebApplicationFactory`)

### Implementation for User Story 1

- [x] T010 [US1] Implement `admin/Services/AdminCredentialValidator.cs` comparing username/password to `AdminAuth:*` configuration
- [x] T011 [US1] Configure cookie authentication and authorization in `admin/Program.cs` (8h idle, secure cookie in non-Development)
- [x] T012 [US1] Add `admin/Pages/Login.cshtml` and `Login.cshtml.cs` with generic failure message (FR-010)
- [x] T013 [US1] Add `admin/Pages/Index.cshtml` as authenticated home/dashboard with sign-out
- [x] T014 [US1] Add `admin/Pages/Shared/_Layout.cshtml` and authorize folder via `admin/Pages/_ViewStart.cshtml` / conventions
- [x] T015 [US1] Add `[Authorize]` to future Events pages folder and verify unauthenticated redirect to `/Login`

**Checkpoint**: US1 independently testable locally without ECS deploy.

---

## Phase 4: User Story 2 - Operator creates a new event with rich content (Priority: P1)

**Goal**: API creates active events with description and cover image; admin UI form calls API with service key.

**Independent Test**: Sign in locally; create event with description + image → `GET /events` on API shows new event (active).

### Tests for User Story 2

- [x] T016 [P] [US2] Add `backend/tests/FelloWay.Api.Tests/Admin/AdminEventsContentEndpointTests.cs` for POST create, validation errors, cover upload with service key header

### Implementation for User Story 2 — API

- [x] T017 [US2] Add DTOs `AdminEventCreateRequest`, `AdminEventUpdateRequest`, `AdminEventListItemDto` in `backend/src/FelloWay.Application/Admin/`
- [x] T018 [US2] Implement `IAdminEventContentService` and `AdminEventContentService.cs` in `backend/src/FelloWay.Application/Admin/` (create with `EventStatus.Active`, city FK validation)
- [x] T019 [US2] Register `IAdminEventContentService` in `backend/src/FelloWay.Infrastructure/DependencyInjection.cs`
- [x] T020 [US2] Add `GET /admin/events/cities` (or include cities in create form API) in `backend/src/FelloWay.Api/Controllers/AdminEventsContentController.cs` for city dropdown
- [x] T021 [US2] Implement `POST /admin/events`, `POST /admin/events/{id}/cover` in `backend/src/FelloWay.Api/Controllers/AdminEventsContentController.cs` with `[Authorize(Policy = "AdminContent")]`
- [x] T022 [US2] Extend `IBlobStorageService` / `LocalBlobStorageService` (or event-specific path) for event cover uploads under `backend/src/FelloWay.Infrastructure/Storage/`
- [x] T023 [US2] Wire `AdminAuth__ServiceKey` (or `Admin__ServiceKey`) in `backend/src/FelloWay.Api/appsettings.Development.json` example and document pairing with admin app user-secrets

### Implementation for User Story 2 — Admin UI

- [x] T024 [US2] Implement `admin/Services/AdminApiClient.cs` sending `X-Admin-Service-Key` on all API calls
- [x] T025 [US2] Add `admin/Pages/Events/Create.cshtml` and `Create.cshtml.cs` with title, description, dates, city select, venue, capacity, cover file upload
- [x] T026 [US2] Add client-side and server-side validation (required fields, end after start) on create page
- [x] T027 [US2] On successful create, redirect to event list or edit with success message

**Checkpoint**: US2 complete — new events visible in consumer API list on same environment.

---

## Phase 5: User Story 3 - Operator reviews and updates existing events (Priority: P2)

**Goal**: List, edit, and unpublish/archive events from admin panel.

**Independent Test**: Edit description and cover on existing event → consumer detail reflects changes; set status non-active → hidden from public list.

### Tests for User Story 3

- [x] T028 [P] [US3] Extend `backend/tests/FelloWay.Api.Tests/Admin/AdminEventsContentEndpointTests.cs` for GET list, GET by id, PUT update, status change

### Implementation for User Story 3

- [x] T029 [US3] Implement `GET /admin/events` and `GET /admin/events/{id}` in `backend/src/FelloWay.Api/Controllers/AdminEventsContentController.cs`
- [x] T030 [US3] Implement `PUT /admin/events/{id}` including optional status (`active` / `rejected`) in `AdminEventContentService.cs`
- [x] T031 [US3] Add `admin/Pages/Events/Index.cshtml` listing events with links to edit
- [x] T032 [US3] Add `admin/Pages/Events/Edit.cshtml` and `Edit.cshtml.cs` reusing create form fields + cover replace
- [ ] T033 [P] [US3] Optional: add link from admin dashboard to existing pending moderation (`/admin/events/pending` via API proxy or documented manual use of API tools) — skip if out of MVP

**Checkpoint**: US1 + US2 + US3 functional locally end-to-end.

---

## Phase 6: Infrastructure per environment (P1 deploy)

**Purpose**: Separate ECS admin service per dev/test/prod; ALB host routing; secrets in Secrets Manager.

- [x] T034 [P] Add `infra/terraform/modules/ecs/admin.tf`: ECR `admin`, log group, task definition, service `felloway-admin-{env}`, secrets for admin auth + `Api__BaseUrl`
- [x] T035 [P] Extend `infra/terraform/modules/ecs/variables.tf` and `outputs.tf` for admin target group ARN and ECR URL
- [x] T036 Add `infra/terraform/modules/alb/admin.tf`: target group port 8080, listener rules `host_header` for `var.admin_host`
- [x] T037 Wire `admin_host`, `admin_target_group_arn`, and module outputs in `infra/terraform/environments/dev/main.tf`, `test/main.tf`, `prod/main.tf`
- [x] T038 Add Route53 `admin` records and ACM certificate SANs (or separate cert) in environment DNS modules
- [x] T039 Extend `aws_secretsmanager_secret_version.app` JSON in each environment with `Admin__Username`, `Admin__Password`, `Admin__ServiceKey`, `AdminAuth__ServiceKey` (API) — variables from tfvars/CI, not committed
- [x] T040 Run `terraform validate` in `infra/terraform/environments/dev` (and document test/prod)

**Checkpoint**: Terraform plans show admin service + listener per environment.

---

## Phase 7: CI/CD (P1 deploy)

**Purpose**: Build and deploy admin image per environment with GitHub Environment secrets.

- [x] T041 Add `admin/Dockerfile` multi-stage publish for `FelloWay.Admin`
- [x] T042 Add `.github/scripts/ecs-deploy-admin-image.sh` mirroring `ecs-deploy-api-image.sh` for admin ECR/service
- [x] T043 Extend `.github/workflows/deploy.yml` to build/push admin image and deploy admin ECS service to **dev** environment
- [x] T044 Extend `.github/workflows/promote-test.yml` and `promote-prod.yml` for admin image deploy
- [x] T045 Ensure GitHub Actions use `environment: dev|test|prod` so `ADMIN_*` secrets are environment-scoped

**Checkpoint**: Dev deploy produces running `felloway-admin-dev` task with env-specific secrets.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T046 Run `dotnet test backend/FelloWay.slnx` and fix failures
- [x] T047 Run `dotnet format` on `admin/` and touched `backend/` projects
- [x] T048 [P] Static gate: `git grep -i "ADMIN_PASSWORD"` on tracked files → no literal secrets
- [ ] T049 Manual smoke per [quickstart.md](./quickstart.md) VR-001–VR-003 on **deployed dev** (dev credentials only; create event visible in dev app)
- [ ] T050 [P] Manual verify prod credentials fail on dev admin URL (cross-env isolation)
- [x] T051 Mark completed items in this `tasks.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)** → **US1 (Phase 3)** can parallel **API part of US2** after T004–T006
- **US2 (Phase 4)** depends on **Foundational** + **US1** (admin login before create UI)
- **US3 (Phase 5)** depends on **US2** API client patterns
- **Infra (Phase 6)** + **CI (Phase 7)** can start after **admin/Dockerfile** exists (T041); full deploy after US2 locally works
- **Polish (Phase 8)** after US2 minimum for deploy smoke; US3 optional before first prod deploy

### User Story Dependencies

| Story | Depends on | Delivers |
|-------|------------|----------|
| **US1** | Phase 2 scaffold | Login + session |
| **US2** | US1 + Phase 2 | Event create + API |
| **US3** | US2 | List/edit/unpublish |

### Parallel Opportunities

- **Phase 1**: T002 ∥ T003
- **Phase 2**: T007 ∥ T008 after T004–T006
- **US1**: T009 ∥ T010–T014 (after T008)
- **US2 API**: T016 ∥ T017–T022 (after foundational)
- **US2 UI**: T024–T027 after T021
- **Infra**: T034 ∥ T036; T037–T039 sequential per env
- **CI**: T043 ∥ T044 after T041–T042

---

## Parallel Example: User Story 2 (API)

```bash
# After T006, in parallel:
# AdminEventContentService.cs, AdminEventsContentController.cs, blob storage extension
# Then AdminEventsContentEndpointTests.cs
# Then admin/Pages/Events/Create.cshtml + AdminApiClient.cs
```

---

## Implementation Strategy

### MVP First (US1 + US2 + deploy dev)

1. Phase 1–2: Setup + service key auth  
2. Phase 3: US1 login  
3. Phase 4: US2 API + create UI  
4. Phase 6–7: Terraform + deploy dev  
5. **STOP and VALIDATE**: [quickstart.md](./quickstart.md) smoke on dev  
6. Phase 5: US3 list/edit  
7. Phase 8: Polish + test/prod promote  

### Suggested PR split

- **PR1**: API service key + event content endpoints + tests (US2 backend)  
- **PR2**: Admin Razor app US1+US2  
- **PR3**: Terraform + CI/CD  
- **PR4**: US3 list/edit  

---

## Task Summary

| Phase | Task IDs | Count |
|-------|----------|-------|
| Setup | T001–T003 | 3 |
| Foundational | T004–T008 | 5 |
| US1 | T009–T015 | 7 |
| US2 | T016–T027 | 12 |
| US3 | T028–T033 | 6 |
| Infra | T034–T040 | 7 |
| CI/CD | T041–T045 | 5 |
| Polish | T046–T051 | 6 |
| **Total** | **T001–T051** | **51** |

### Per user story

| Story | Tasks | Independent test |
|-------|-------|------------------|
| US1 | 7 | Login valid/invalid; protected routes |
| US2 | 12 | Create event + image in consumer app |
| US3 | 6 | List/edit/unpublish |

### MVP scope

**US1 + US2 (T001–T027)** plus **Infra/CI (T034–T045)** for deployed dev validation.
