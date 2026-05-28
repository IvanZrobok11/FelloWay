# Research: Per-environment admin panel on ECS

**Feature**: `018-github-env-admin-panel` | **Date**: 2026-05-26

**Clarification (plan input)**: Not one admin account shared across all environments—each environment (dev, test, prod) has **its own** admin deployment (separate ECS container/service) and **its own** credentials from GitHub Environment secrets.

## R1 — Hosting topology

**Decision**: Deploy **`FelloWay.Admin`** as a **second ECS Fargate service** per environment in the existing `${project}-${environment}` cluster, with its own ECR repository, task definition, target group, and ALB listener rule (host-based routing).

**Rationale**: User requirement; isolates admin UI from public API scaling; credentials and `API_BASE_URL` are environment-local in task env/secrets.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Static admin on S3/CloudFront | Cookie auth + server-side API calls need a server runtime |
| Admin routes inside `FelloWay.Api` | Mixes operator UI with public API surface; harder to lock down |
| One global admin pointing at all APIs | Violates per-env isolation |

## R2 — Admin application stack

**Decision**: New **`admin/`** ASP.NET Core **Razor Pages** app (.NET 8), cookie authentication, server-side `HttpClient` to the co-located environment API.

**Rationale**: Aligns with `TECH_PLAN.md` Phase 5; fast forms for event CRUD; same language as API.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Blazor WebAssembly | More moving parts; needs API CORS for browser calls |
| Flutter web admin | Duplicates stack; operator tool fits server-rendered web |
| Extend Flutter consumer app | Wrong audience and auth model |

## R3 — Credentials per environment

**Decision**:

- GitHub **Environment** secrets (e.g. `ADMIN_USERNAME`, `ADMIN_PASSWORD`) per `dev` / `test` / `prod`.
- On deploy, merge into **AWS Secrets Manager** secret `${project}/${env}/app` (new JSON keys) or dedicated `${project}/${env}/admin` secret.
- ECS admin task injects `AdminAuth__Username` / `AdminAuth__Password` (cookie validation) and optional `AdminAuth__ServiceKey` for API trust.

**Rationale**: FR-003, NFR-SEC-001; matches existing API secret pattern in `infra/terraform/modules/ecs/main.tf`.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Same password all envs | User explicitly rejected |
| OAuth for operators | Out of scope; user asked login/password in GitHub env |

## R4 — API integration for event CRUD

**Decision**: Add **`AdminEventsController`** (or extend admin area) on **`FelloWay.Api`** with endpoints:

- `GET/POST/PUT /admin/events` — list, create, update
- `POST /admin/events/{id}/cover` — upload cover image → `CoverImageUrl`

Protected by **`AdminServiceKey`** header (shared secret per env, only admin ECS task holds it) **plus** operator session is enforced in admin app before calling API.

**Rationale**: Single PostgreSQL via API; reuses `Event` entity and `EventService` patterns; consumer app unchanged.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| Admin app uses EF directly | Duplicates DbContext wiring and migrations coupling |
| JWT `admin` role from dev OAuth | Conflicts with 016 production-only OAuth policy |

## R5 — Images

**Decision**: v1 — **multipart upload** to API → `IBlobStorageService` (extend or reuse avatar storage path) → store HTTPS URL in `CoverImageUrl`.

**Rationale**: FR-006; operators expect file pick, not raw URLs only.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| URL text field only | Poor UX for "додати картинки" |
| S3 direct upload from browser | More infra; defer |

## R6 — DNS and ALB

**Decision**: Hostname **`admin.{env-suffix}.{domain}`** (e.g. `admin.dev.felloway.com`) → admin target group; ACM cert SAN or separate cert; listener rule priority above default API rule.

**Rationale**: Clear separation from `api.*` and consumer `app.*` / web CloudFront.

## R7 — Event publish state

**Decision**: Admin-created events saved with **`EventStatus.Active`** immediately.

**Rationale**: Spec FR-008; operator is trusted. User-submitted `pending` flow unchanged via existing `AdminController` moderation.

## R8 — Deploy pipeline

**Decision**: Extend `.github/workflows/deploy.yml` and promote workflows to build/push `admin` image and run `ecs-deploy-admin-image.sh` (parallel to API script).

**Rationale**: Same SHA tag as API for traceability; GitHub Environment gates secrets per env.
