# Data Model: AWS infrastructure & deploy artifacts

**Feature**: `008-aws-deploy-pipeline` | **Date**: 2026-05-17

**Scope**: Exactly **three** runtime environments: `dev`, `test`, `prod`.

## Environment (logical)

| Attribute | dev | test | prod |
|-----------|-----|------|------|
| Purpose | Integration from `main` | Pre-prod QA | Live users |
| Auto deploy | Yes (on `main` push) | Manual promote | Manual promote (after test) |
| Terraform root | `environments/dev` | `environments/test` | `environments/prod` |
| GitHub Environment | `dev` | `test` | `prod` |
| IAM deploy role | `felloway-github-deploy-dev` | `...-test` | `...-prod` |

## Terraform inputs (per environment root)

| Variable | Type | Notes |
|----------|------|-------|
| `environment` | string | Must be `dev`, `test`, or `prod` |
| `aws_region` | string | Default `eu-central-1` |
| `domain_name` | string | Apex domain (e.g. `felloway.com`) |
| `api_subdomain` | string | Full API FQDN (computed or set) |
| `web_subdomain` | string | Full web FQDN |
| `vpc_cidr` | string | Unique per env |
| `db_instance_class` | string | Smaller for dev/test |
| `ecs_cpu` / `ecs_memory` | number | Fargate sizing |
| `desired_count` | number | ECS tasks |

## AWS resources (per environment, 1:1)

| Resource | Identifier pattern | Notes |
|----------|-------------------|-------|
| VPC | `felloway-{env}-vpc` | Isolated per env |
| ALB | `felloway-{env}-alb` | Internet-facing, public subnets |
| ECS cluster | `felloway-{env}` | Fargate |
| ECS service | `felloway-api-{env}` | Rolling deploy |
| ECR repository | `felloway-api-{env}` | Image promotion copies tag |
| RDS instance | `felloway-{env}` | Private subnet |
| S3 bucket | `felloway-web-{env}-{account_id}` | Web artifacts |
| CloudFront distribution | per env | OAC to S3 |
| Secrets Manager | `felloway/{env}/api` | DB URL, JWT, OAuth |
| Route 53 records | A/AAAA alias | API → ALB, web → CF |

## Deploy artifact (CI)

| Field | Description |
|-------|-------------|
| `image_tag` | Git SHA or semver used for ECR |
| `web_artifact_path` | Uploaded `build/web` zip or S3 prefix |
| `source_sha` | Commit on `main` that built artifact |
| `promoted_from` | `dev` → `test` → `prod` chain |

**Promotion rule**: test/prod deploy jobs MUST reuse `image_tag` from dev build, not rebuild Docker image with different SHA unless explicitly re-run build workflow.

## State transitions (promotion)

```text
[push main] → build+test → deploy dev
                ↓ (manual)
            deploy test  (requires dev artifact metadata)
                ↓ (manual, gated)
            deploy prod
```

## Relationships

- One **Environment** → one VPC, one RDS, one ECS service, one CloudFront, one ECR repo.
- **No shared RDS** across dev/test/prod.
- **Route 53** hosted zone may be shared (apex domain) with per-env records.
