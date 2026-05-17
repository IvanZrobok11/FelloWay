# Research: AWS Deploy Pipeline & Infrastructure

**Feature**: `008-aws-deploy-pipeline` | **Date**: 2026-05-17

## R1: Environment model (exactly three)

**Decision**: **Only** `dev`, `test`, and `prod` — no fourth environment (no separate “staging”, “qa”, or “integration” stacks).

**Rationale**: User clarification and spec session; simplifies Terraform workspaces, GitHub Environments, and OIDC roles.

**Alternatives considered**:
- **Four envs** (dev/staging/test/prod) — Rejected per user note.
- **Single prod + previews** — Rejected; conflicts with three-env clarify answer.

## R2: Terraform layout

**Decision**: Shared modules under `infra/terraform/modules/`; per-env roots at `infra/terraform/environments/{dev,test,prod}/` with **separate remote state** keys (`felloway/dev`, `felloway/test`, `felloway/prod`).

**Rationale**: Clear blast radius, independent `terraform apply`, matches three isolated VPC/RDS stacks.

**Alternatives considered**:
- **Single workspace toggle** — Harder to parallelize and easy to apply wrong env.
- **CDK** — Rejected; spec requires Terraform.

## R3: CI/CD promotion

**Decision**: One **build** workflow on `push` to `main` (test + build artifacts); **deploy-dev** auto; **promote-test** and **promote-prod** as `workflow_dispatch` reusing stored image tag + web artifact digest; GitHub **Environments** `dev`, `test`, `prod` with protection on `prod`.

**Rationale**: Matches clarify answer; immutable promotion (FR-011).

## R4: GitHub → AWS auth

**Decision**: **OIDC** (`token.actions.githubusercontent.com`) → IAM role per environment (`felloway-github-deploy-dev|test|prod`).

**Rationale**: No long-lived keys; trust policy scoped to repo + environment.

## R5: Client hosting

**Decision**: `flutter build web` → **S3** (OAC) → **CloudFront**; ACM cert in **us-east-1** for CloudFront; API on **ALB** in regional ACM.

**Rationale**: Spec clarify; standard static Flutter web pattern.

## R6: Network topology

**Decision**: Per env: **VPC** `/16`, 2 AZs, **public subnets** (ALB only), **private subnets** (ECS Fargate + RDS), **NAT gateway** (single NAT for dev/test cost savings; optional dual NAT for prod in plan tasks).

**Rationale**: FR-003/ NFR-SEC-001 — RDS not public despite user mentioning “ALB in public subnet”.

## R7: Container & DB

**Decision**: **ECS Fargate** service (512 CPU / 1024 MB dev-test, larger prod); **RDS PostgreSQL 16** single-AZ dev/test, Multi-AZ optional prod; connection string via **Secrets Manager** injected as ECS secrets.

**Rationale**: Matches existing Npgsql API; Hangfire uses same DB.

## R8: Domain pattern

**Decision**: Configurable apex `var.domain_name`; defaults:
- API: `dev.api.<domain>`, `test.api.<domain>`, `api.<domain>`
- Web: `dev.app.<domain>`, `test.app.<domain>`, `app.<domain>`

**Rationale**: Clarify answer B; stable CORS origins per env.

## R9: AWS region

**Decision**: Primary region **`eu-central-1`** (variable `aws_region`); CloudFront + ACM for CDN still **us-east-1** where required.

**Rationale**: Reasonable EU default; overridable in tfvars.

## R10: Existing CI

**Decision**: Keep **`.github/workflows/backend-ci.yml`** for PR validation; add **`.github/workflows/deploy.yml`** (and promote workflows) for AWS — no merge until tests pass on PR.

**Rationale**: Avoid breaking current contributor flow.
