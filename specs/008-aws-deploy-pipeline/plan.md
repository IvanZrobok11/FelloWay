# Implementation Plan: AWS Deploy Pipeline & Infrastructure

**Branch**: `008-aws-deploy-pipeline` | **Date**: 2026-05-17 | **Spec**: [spec.md](./spec.md)

**Input**: GitHub push pipeline (build, test, ECR, ECS Fargate), Terraform (VPC, ECS, RDS, ALB, CloudFront), **exactly three environments: dev, test, prod** (no additional envs).

## Summary

Provision **three isolated AWS stacks** (`dev`, `test`, `prod`) via **Terraform**, each with VPC (public ALB + private ECS/RDS), **ECS Fargate** API, **RDS PostgreSQL**, **S3 + CloudFront** for Flutter web, and **Route 53 + ACM** custom subdomains. **GitHub Actions** on `main` builds/tests, auto-deploys to **dev**, and provides manual **promote to test** → **promote to prod** workflows using **OIDC** (no static AWS keys).

## Technical Context

**Language/Version**: Terraform ≥ 1.5; .NET 8; Dart 3.10+ / Flutter stable; GitHub Actions  
**Primary Dependencies**: AWS provider, ECS Fargate, ECR, RDS PostgreSQL 16, ALB, S3, CloudFront, ACM, Route 53, Secrets Manager; `configure-aws-credentials` OIDC  
**Storage**: RDS per env; S3 web buckets; Terraform remote state S3  
**Testing**: `dotnet test` (fast filter), `flutter test`; post-deploy `curl /health`; `terraform validate` on PR  
**Target Platform**: AWS single region (`eu-central-1` default); CloudFront ACM in `us-east-1`  
**Project Type**: Monorepo — `infra/terraform/`, `backend/`, `frontend/`, `.github/workflows/`  
**Performance Goals**: Push-to-dev &lt; 20 min (SC-001)  
**Constraints**: **Only dev/test/prod**; RDS private; OIDC least privilege; immutable image promotion  
**Scale/Scope**: ~6 Terraform modules × 3 env roots + 3 workflows + API Dockerfile

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `terraform fmt`, `dotnet format`, `flutter analyze` in CI |
| Test strategy | ✅ Pass | Build blocked on test failure; smoke after deploy |
| UX consistency | N/A | Hosting only; web URLs per env |
| Performance budgets | ✅ Pass | SC-001 documented |
| Flutter quality checks | ✅ Pass | `flutter test` in deploy pipeline |
| Evidence plan | ✅ Pass | GitHub Actions logs, ECS events, quickstart |

**Post-design re-check**: No violations.

## Project Structure

### Documentation (this feature)

```text
specs/008-aws-deploy-pipeline/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── cicd-pipeline-contract.md
│   └── terraform-infra-contract.md
└── tasks.md                    # /speckit.tasks
```

### Source Code (repository root)

```text
infra/terraform/
├── bootstrap/
├── modules/{network,alb,ecs,rds,web,dns}
└── environments/{dev,test,prod}/    # exactly three

backend/
├── Dockerfile                       # NEW
└── src/FelloWay.Api/

frontend/
└── (flutter build web → S3)

.github/workflows/
├── backend-ci.yml                   # existing PR CI
├── deploy.yml                       # push main → dev
├── promote-test.yml                 # manual
└── promote-prod.yml                 # manual, gated
```

**Structure Decision**: Terraform modules shared across **dev**, **test**, **prod** only; no fourth environment directory.

## Implementation Phases (for `/speckit.tasks`)

### Phase 1 — Bootstrap & Terraform foundation (P1)

1. `infra/terraform/bootstrap` — state bucket, GitHub OIDC provider.
2. `modules/network` — VPC, public/private subnets, NAT, security groups.
3. `modules/alb`, `modules/ecs`, `modules/rds`, `modules/web`, `modules/dns`.
4. `environments/dev` — first full stack apply; document tfvars.
5. Replicate `environments/test` and `environments/prod` with unique CIDRs and hostnames.

### Phase 2 — Container & API config (P1)

1. Add `backend/Dockerfile` (multi-stage .NET 8 publish).
2. ECS task definition: port, health check, Secrets Manager env mapping.
3. Per-env `Cors:AllowedOrigins` secret matching `https://<env>.app.<domain>`.
4. RDS connection via Secrets Manager (no password in task def plaintext).

### Phase 3 — GitHub Actions (P1)

1. `deploy.yml` — build, test, push ECR dev, deploy ECS dev, sync S3, invalidate CF.
2. `promote-test.yml` / `promote-prod.yml` — workflow_dispatch + GitHub Environments.
3. OIDC IAM roles per env (terraform) wired in workflows.
4. Artifact metadata JSON for `image_tag` promotion chain.

### Phase 4 — Flutter web & DNS (P1)

1. Web build with per-target `API_BASE_URL` on promote jobs.
2. Route 53 + ACM validation for six hostnames (3 API + 3 web) or wildcard strategy in plan tasks.
3. Smoke tests in workflows per env URL.

### Phase 5 — Docs & polish (P2)

1. Root README + `infra/README.md` + link quickstart.
2. PR terraform plan job (validate only).
3. Rollback runbook in quickstart.

## Complexity Tracking

> No constitution violations requiring justification.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| CI/CD contract | [contracts/cicd-pipeline-contract.md](./contracts/cicd-pipeline-contract.md) |
| Terraform contract | [contracts/terraform-infra-contract.md](./contracts/terraform-infra-contract.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
