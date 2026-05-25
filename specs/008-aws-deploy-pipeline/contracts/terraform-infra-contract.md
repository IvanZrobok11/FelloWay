# Contract: Terraform infrastructure

**Feature**: `008-aws-deploy-pipeline`  
**Environments**: `dev` | `test` | `prod` (**exactly three**)

## Repository layout

```text
infra/terraform/
├── bootstrap/           # S3 state bucket, OIDC provider (once)
├── modules/
│   ├── network/         # VPC, subnets, NAT, SGs
│   ├── alb/             # ALB, listeners, target group, ACM (regional)
│   ├── ecs/             # Cluster, task def, service, ECR
│   ├── rds/             # PostgreSQL, subnet group, secrets
│   ├── web/             # S3, CloudFront, OAC, ACM us-east-1 alias
│   └── dns/             # Route 53 records
└── environments/
    ├── dev/
    ├── test/
    └── prod/
```

## Module: network

| Output | Used by |
|--------|---------|
| `vpc_id` | alb, ecs, rds |
| `public_subnet_ids` | alb |
| `private_subnet_ids` | ecs, rds |
| `ecs_tasks_security_group_id` | ecs |
| `alb_security_group_id` | alb |

**Rule**: RDS security group ingress **only** from ECS tasks SG on port 5432.

## Module: alb

- Internet-facing ALB in **public** subnets
- HTTPS listener (ACM cert for `api` hostname)
- Target group → ECS service port 8080 (or 80)
- Health check path `/health`

## Module: ecs

- Launch type: **FARGATE**
- Task execution role: ECR pull, logs, secrets
- Task role: app runtime (minimal)
- Environment from Secrets Manager: `ConnectionStrings__Default`, `Jwt__*`, `Cors__AllowedOrigins__*`
- `ASPNETCORE_ENVIRONMENT=Production` (app config); `Database__DisableHangfire=false` in AWS

## Module: rds

- Engine: postgres 16
- `publicly_accessible = false`
- Subnet group: **private** subnets only

## Module: web

- S3 bucket block public access; CloudFront OAC only
- Default root object `index.html`
- SPA error routing: 403/404 → `/index.html`

## Per-environment tfvars example

```hcl
environment     = "dev"   # dev | test | prod only
domain_name     = "example.com"
api_host        = "dev.api.example.com"
web_host        = "dev.app.example.com"
vpc_cidr        = "10.10.0.0/16"
db_instance_class = "db.t4g.micro"
```

## CI validation

- On PR: `terraform fmt -check`, `terraform validate` for each env dir
- `terraform plan` optional comment bot (phase 2)

## Outputs (per env)

| Output | Consumer |
|--------|----------|
| `api_url` | README, CORS config |
| `web_url` | README, smoke tests |
| `ecr_repository_url` | deploy workflow |
| `ecs_cluster_name` | deploy workflow |
| `ecs_service_name` | deploy workflow |
| `cloudfront_distribution_id` | invalidation |
