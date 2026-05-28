# Data model: Admin panel (per-environment ECS)

## Deployment topology (per environment)

| Component | dev | test | prod |
|-----------|-----|------|------|
| ECS service `felloway-api-{env}` | ✓ | ✓ | ✓ |
| ECS service `felloway-admin-{env}` | ✓ | ✓ | ✓ |
| ECR `felloway-admin-{env}` | ✓ | ✓ | ✓ |
| Secrets `ADMIN_*` (unique) | dev GH env | test GH env | prod GH env |
| Admin hostname | `admin.dev.*` | `admin.test.*` | `admin.*` |
| API hostname | `api.dev.*` | `api.test.*` | `api.*` |

**Isolation rule**: Admin task in `dev` calls **only** `API_BASE_URL` for dev; credentials valid only in that environment.

## Runtime configuration (admin container)

| Variable / secret | Purpose |
|-------------------|---------|
| `AdminAuth__Username` | Cookie sign-in validation |
| `AdminAuth__Password` | Cookie sign-in validation |
| `AdminAuth__ServiceKey` | Server-side header to API (`X-Admin-Service-Key`) |
| `Api__BaseUrl` | Internal or public API URL for same env |
| `ASPNETCORE_ENVIRONMENT` | `dev` / `test` / `prod` |

## Operator session (admin app)

| Field | Notes |
|-------|-------|
| Authenticated | After successful form login |
| Expires | Idle timeout (default 8h) |

No row in `users` table — not LinkedIn OAuth.

## Event (admin-managed via API)

Uses existing **`events`** table:

| Field | Admin form | Validation |
|-------|------------|------------|
| title | required | non-empty |
| description | optional | max length per DB |
| starts_at, ends_at | required | ends > starts |
| city_id | required | FK to cities |
| venue | optional | |
| cover_image_url | via upload | URL after blob store |
| status | default `active` | admin create |
| capacity, official_url | optional | |

## API trust boundary

```
Browser → HTTPS → ALB → Admin ECS (cookie auth)
Admin ECS → HTTPS → API ECS (X-Admin-Service-Key + JSON)
API ECS → RDS PostgreSQL
```

## State transitions

| Action | Event status |
|--------|----------------|
| Admin create | `active` |
| Admin archive/unpublish | `rejected` or new status per plan |
| User submit (existing) | `pending` → admin moderation APIs |

## GitHub → AWS secret flow

```
GitHub Environment (dev)
  secrets: ADMIN_USERNAME, ADMIN_PASSWORD, ADMIN_SERVICE_KEY
    → deploy workflow
      → Secrets Manager felloway/dev/app (keys added)
        → ECS task definition admin container secrets[]
```
