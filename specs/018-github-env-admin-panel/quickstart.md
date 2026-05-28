# Quickstart: Admin panel (per-environment ECS)

## Overview

Each environment has its **own** admin site (separate ECS container) and **own** login from GitHub Environment secrets—not shared across dev/test/prod.

## GitHub Environment secrets (per env)

In GitHub → Settings → Environments → **dev** (repeat for **test**, **prod**):

| Secret | Description |
|--------|-------------|
| `ADMIN_USERNAME` | Operator login for this environment only |
| `ADMIN_PASSWORD` | Strong password unique to this environment |
| `ADMIN_SERVICE_KEY` | Random string; must match API secret key for same env |

Also ensure existing deploy secrets/vars (`AWS_ACCOUNT_ID`, OIDC role, etc.) per `008-aws-deploy-pipeline`.

## After deploy

**Custom domain** (`use_custom_domain = true` + `admin_host`):

| Environment | Admin URL (example) | API URL |
|-------------|---------------------|---------|
| dev | `https://admin.dev.<domain>` | `https://dev.api.<domain>` |
| test | `https://admin.test.<domain>` | `https://test.api.<domain>` |
| prod | `https://admin.<domain>` | `https://api.<domain>` |

**Technical URLs** (`use_custom_domain = false` + `admin_service_key` in tfvars):

```bash
cd infra/terraform/environments/dev
terraform output admin_url   # https://dxxxxxxxx.cloudfront.net
terraform output api_url
terraform output web_url
```

## Smoke checklist

1. Open admin URL for **dev**; sign in with **dev** `ADMIN_*` secrets → dashboard.
2. Create event (title, dates, city, description, cover image) → save.
3. Open consumer app on **dev** web → event appears in list.
4. Try **prod** password on **dev** admin URL → sign-in **fails**.
5. Confirm no `ADMIN_PASSWORD` in repository (`git grep ADMIN_PASSWORD`).

## Local development (maintainers)

```bash
# Terminal 1 — API
cd backend
dotnet run --project src/FelloWay.Api

# Terminal 2 — Admin (after implementation)
cd admin
dotnet user-secrets set "AdminAuth:Username" "local-admin"
dotnet user-secrets set "AdminAuth:Password" "local-dev-password"
dotnet user-secrets set "AdminAuth:ServiceKey" "<same-as-api-AdminAuth__ServiceKey>"
dotnet user-secrets set "Api:BaseUrl" "https://localhost:7086"
dotnet run
```

## Troubleshooting

```text
Cannot sign in on dev admin?
├─ Using prod credentials? → Each env has its own ADMIN_* in GitHub Environment
├─ Secret not in Secrets Manager? → Re-run deploy workflow for that env
└─ ECS admin service unhealthy? → Check /ecs/felloway-admin-dev logs

Event not in app?
├─ Created on dev admin but viewing prod app? → Same environment only
└─ API service key mismatch? → ADMIN_SERVICE_KEY must match API config
```

## Related

- [admin-panel-deployment.md](./contracts/admin-panel-deployment.md)
- [plan.md](./plan.md)
