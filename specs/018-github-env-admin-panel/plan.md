# Implementation Plan: Admin panel (per-environment ECS + GitHub secrets)

**Branch**: `018-github-env-admin-panel` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Admin panel with login/password from GitHub Environment secrets; create events with description and images. **Clarification**: Each environment has its **own** admin ECS service and **own** credentials—not one shared admin across dev/test/prod.

## Summary

Add **`FelloWay.Admin`** (ASP.NET Core Razor Pages) as a **separate ECS Fargate service per environment**, with hostname `admin.<env>.<domain>`, cookie auth from per-env secrets (`ADMIN_USERNAME`, `ADMIN_PASSWORD`, `ADMIN_SERVICE_KEY` in GitHub Environments → Secrets Manager). Extend **`FelloWay.Api`** with admin content endpoints secured by service key for create/list/update events and cover image upload. Deploy via extended GitHub Actions (admin image + ECS service) alongside existing API pipeline.

## Technical Context

**Language/Version**: C# 12 / .NET 8 (admin web + API extensions); Terraform ≥ 1.5

**Primary Dependencies**: ASP.NET Core Razor Pages, cookie auth, `HttpClient`, EF Core (API only), existing `IBlobStorageService`, ALB host rules, ECS Fargate, Secrets Manager, GitHub Actions environments

**Storage**: PostgreSQL via API (existing `events` table); blob storage for cover images

**Testing**: xUnit API tests for admin content endpoints; admin app integration tests with `WebApplicationFactory`; Terraform validate

**Target Platform**: AWS ECS Fargate per env (dev/test/prod); operators use HTTPS admin hostname

**Project Type**: `admin/` (new), `backend/src` (API), `infra/terraform/`, `.github/workflows/`

**Performance Goals**: Admin form save &lt; 5s typical; admin task 256 CPU / 512 MB minimum (tune in Terraform)

**Constraints**:

- No credentials in git; per-environment GitHub Environment secrets only
- Admin container talks only to **same-environment** API base URL
- Separate from Flutter consumer app and LinkedIn BFF auth
- Align with `016` (no dev OAuth for production admin API access)

**Scale/Scope**: New admin project (~15–25 files), API admin content module (~8 files), ECS module extension + ALB rules, 3 env workflows, operator UI ~5 pages

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | `dotnet format`, analyzers on admin + API |
| Test strategy | Pass | API contract tests + admin auth tests |
| UX consistency | Pass | Razor forms with validation messages |
| Performance | Pass | Small Fargate task; server-side API calls |
| Evidence | Pass | [quickstart.md](./quickstart.md) per-env smoke |

**Post-design re-check**: Pass.

## Project Structure

### Documentation (this feature)

```text
specs/018-github-env-admin-panel/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/admin-panel-deployment.md
└── tasks.md
```

### Source Code

```text
admin/                                    # NEW Razor Pages app
├── FelloWay.Admin.csproj
├── Program.cs
├── Pages/
│   ├── Login.cshtml
│   ├── Index.cshtml
│   ├── Events/
│   │   ├── Index.cshtml
│   │   ├── Create.cshtml
│   │   └── Edit.cshtml
├── Services/
│   ├── AdminApiClient.cs
│   └── CookieAuthHandler.cs
└── appsettings.json

backend/src/FelloWay.Api/
├── Controllers/AdminEventsContentController.cs   # NEW
├── Auth/AdminServiceKeyAuthHandler.cs            # NEW
└── ...

backend/src/FelloWay.Application/
├── Admin/AdminEventContentService.cs             # NEW
└── Events/ (reuse patterns)

infra/terraform/modules/ecs/
├── admin.tf                                      # NEW service, task, ECR
infra/terraform/modules/alb/
├── admin_listener_rule.tf                          # host-based routing
.github/scripts/
├── ecs-deploy-admin-image.sh                     # NEW
.github/workflows/
├── deploy.yml, promote-test.yml, promote-prod.yml  # admin build/deploy
```

## Implementation Phases

### Phase A — API: admin content endpoints (P1)

1. `AdminServiceKey` options + auth handler (`X-Admin-Service-Key`).
2. `AdminEventContentService`: create/update/list events → `Active` status.
3. `POST /admin/events/{id}/cover` multipart → blob URL → `CoverImageUrl`.
4. Integration tests with service key header.

### Phase B — Admin web app (P1)

1. Scaffold `admin/FelloWay.Admin` Razor Pages + cookie auth from `AdminAuth:*` config.
2. Login page; events list/create/edit; call API via `AdminApiClient`.
3. Cover image upload on create/edit forms.

### Phase C — Infrastructure per environment (P1)

1. Extend `ecs` module: ECR admin, task definition, service, logs, secrets for admin auth + service key.
2. ALB: admin target group (port 8080), listener rule `host = admin.*`.
3. Route53 `admin` record per env; ACM SAN if needed.
4. Secrets Manager: add `Admin__Username`, `Admin__Password`, `Admin__ServiceKey` to app secret JSON (Terraform variables from CI or manual seed).

### Phase D — CI/CD (P1)

1. Dockerfile `admin/Dockerfile`.
2. `ecs-deploy-admin-image.sh` mirroring API script.
3. GitHub workflows: build/push admin image; deploy admin service per environment using **environment-scoped** secrets.
4. Document secret names in [quickstart.md](./quickstart.md).

### Phase E — Polish (P2)

1. List/filter events in admin UI; edit/archive.
2. Optional: pending events moderation links in admin UI (reuse existing API).
3. Manual smoke VR-001–VR-003 per environment.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Second ECS service per env | User requirement | Single container mixes operator UI with public API |
| Service key + cookie auth | Defense in depth | Cookie alone insufficient for API if URL leaked |

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Contract | [contracts/admin-panel-deployment.md](./contracts/admin-panel-deployment.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

## Coordination

- **008-aws-deploy-pipeline** — ECS, ALB, GitHub OIDC, environments
- **002-backend-api** — `Event` entity, list/detail for consumer app
- **016-remove-dev-oauth-backend** — admin API uses service key, not dev OAuth codes

## Next Step

**`/speckit.tasks`** — Phase A→D ordered tasks.
