# Feature Specification: AWS Deploy Pipeline & Infrastructure

**Feature Branch**: `008-aws-deploy-pipeline`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Deploy backend and client to AWS: GitHub push pipeline (build, test, push to ECR, update ECS Fargate); Terraform IaC for VPC, ECS Fargate, RDS, ALB in public subnet, CloudFront for client, etc.

## Summary

Deliver repeatable **AWS hosting** for the FelloWay **.NET API** and **Flutter web client**, with **GitHub Actions** on push to build, test, publish API images to **ECR**, roll out **ECS Fargate**, and publish the web build to **S3** behind **CloudFront**. Provision core infrastructure with **Terraform**: **VPC**, **ECS Fargate**, **RDS (PostgreSQL)**, **Application Load Balancer** (public subnets), **S3 + CloudFront** for static web assets.

## Clarifications

### Session 2026-05-17

- Q: What does “deploy client” mean for v1? → A: **Flutter web** hosted on **S3 + CloudFront**; iOS/Android store releases **out of scope** for v1.
- Q: How many AWS environments? → A: **Three environments: dev, test, and prod** (each with isolated infra: VPC or stack per env, own RDS/ECS/ALB/S3/CloudFront).
- Q: How should GitHub Actions authenticate to AWS? → A: **GitHub OIDC** federated to **IAM roles** (no long-lived access keys in GitHub Secrets).
- Q: Which Git branches deploy to which environment? → A: **Every push to `main`** runs CI and **auto-deploys to dev**; **manual workflow dispatch** promotes to **test**; after test deploy succeeds, a **second manual button** enables deploy to **prod** (sequential promotion, not parallel branch-per-env).
- Q: Public URLs and TLS? → A: **Custom domain** with per-environment subdomains (e.g. `dev.api.<domain>`, `test.api.<domain>`, `api.<domain>` and matching web hosts); **ACM** certificates + **Route 53** DNS.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Automated backend release (Priority: P1)

As a maintainer, when I **push to `main`**, the pipeline builds, tests, and **automatically deploys to dev** (API + web). I can then **manually promote** the same artifact to **test**, and after test succeeds, **manually promote** to **prod**.

**Why this priority**: Unblocks continuous dev feedback while keeping test/prod human-gated.

**Independent Test**: Push to `main` → dev updated; run manual “Deploy to test” → test updated; run manual “Deploy to prod” → prod updated; `/health` returns 200 in each env.

**Acceptance Scenarios**:

1. **Given** a green build on push to `main`, **When** the workflow completes, **Then** **dev** ECR/ECS and dev S3/CloudFront are updated (test and prod unchanged).
2. **Given** failing backend or frontend tests, **When** the workflow runs, **Then** no deploy to any environment occurs.
3. **Given** a successful dev deploy, **When** the operator runs the manual **deploy-to-test** workflow, **Then** test receives the same image tag / web artifact hash as dev.
4. **Given** test deploy completed, **When** the operator runs **deploy-to-prod**, **Then** prod is updated; the prod job is **not available** before test deploy succeeds.

---

### User Story 2 — Flutter web on CloudFront (Priority: P1)

As a user, I can open the Flutter **web** app from a CloudFront HTTPS URL; it loads static assets from S3 and calls the deployed API successfully.

**Why this priority**: End-to-end product availability on AWS.

**Independent Test**: Open the CloudFront URL (or configured domain); app loads and live API calls succeed.

**Acceptance Scenarios**:

1. **Given** a successful `flutter build web` in CI, **When** artifacts sync to S3 and CloudFront invalidation runs, **Then** users see the new web build at the distribution URL.
2. **Given** CORS allows the web subdomain and `API_BASE_URL` targets the matching API subdomain, **When** the web app uses live mode, **Then** API requests succeed over HTTPS without browser blocking.

---

### User Story 3 — Reproducible infrastructure (Priority: P1)

As an operator, I can create or update **dev**, **test**, and **prod** stacks from Terraform (separate workspaces or equivalent) so each environment has its own VPC, ALB, ECS, RDS, S3, and CloudFront.

**Why this priority**: IaC is an explicit requirement.

**Independent Test**: `terraform plan` per workspace (`dev`, `test`, `prod`) is clean; `apply` to dev succeeds; destroy/plan cycle documented for dev/test.

**Acceptance Scenarios**:

1. **Given** Terraform modules, **When** applied for each of `dev`, `test`, and `prod`, **Then** each environment has VPC, public ALB, private RDS, ECS service, S3 bucket, and CloudFront distribution with no shared database between envs.
2. **Given** RDS in private subnets, **When** API tasks start, **Then** they connect without exposing the database to the public internet.

---

### Edge Cases

- Pipeline failure mid-deploy (image pushed but ECS rollback needed).
- Database migration timing vs new API revision.
- Secret rotation (JWT, DB password, OAuth) without plaintext in Git.
- Cold start / health check failures on new ECS tasks.
- CloudFront cache invalidation after client release.
- Accidental promotion (e.g. dev image tag deployed to prod) — mitigated by separate ECR repos or tags per env and OIDC `sub`/`environment` conditions per role.
- OIDC trust misconfiguration granting overly broad `*` repo access.
- Operator runs prod deploy without test — mitigated by workflow `needs:` / environment protection and disabled prod job until test job succeeded.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On **push to `main`**, GitHub Actions MUST restore, build, test backend (`dotnet test`) and frontend (`flutter test`, `flutter build web`), then **auto-deploy to dev only**.
- **FR-001a**: Separate **workflow_dispatch** jobs MUST deploy to **test** (manual button) and **prod** (manual button enabled only after latest test deploy success).
- **FR-002**: Backend workflow MUST push container images to **ECR** and update **ECS Fargate** service to the new image.
- **FR-003**: Terraform MUST provision **VPC** with public subnets (ALB) and private subnets (ECS tasks, RDS) per security best practice.
- **FR-004**: Terraform MUST provision **RDS PostgreSQL** compatible with existing API connection string pattern.
- **FR-005**: Terraform MUST provision **ALB** in public subnets with **HTTPS** (ACM cert) and DNS records pointing API subdomains per environment.
- **FR-006**: Terraform MUST provision **S3** (private origin) and **CloudFront** for Flutter web with **HTTPS** (ACM in `us-east-1` for CloudFront) and per-env web subdomains (e.g. `dev.app.<domain>`, `test.app.<domain>`, `app.<domain>`).
- **FR-014**: Terraform MUST manage **Route 53** records (or document delegation) linking API and web subdomains to ALB and CloudFront per environment.
- **FR-015**: CI MUST inject environment-specific `API_BASE_URL` (and CORS allowlist on API) matching the target env subdomain at `flutter build web` time.
- **FR-009**: Client pipeline MUST upload `build/web` to S3 and trigger CloudFront invalidation (or versioned object keys) on deploy.
- **FR-007**: Application secrets MUST NOT be committed; use AWS Secrets Manager / SSM and GitHub Secrets for non-AWS tokens only.
- **FR-012**: Bootstrap Terraform MUST create GitHub OIDC identity provider and **per-environment IAM roles** (or one role with `sub`/`ref` conditions) granting least privilege for ECR push, ECS deploy, S3 sync, and CloudFront invalidation.
- **FR-008**: Documentation MUST describe one-time bootstrap, deploy flow, and rollback steps.
- **FR-010**: Terraform MUST support **three named environments** (`dev`, `test`, `prod`) via workspaces or separate var files, with non-prod sized smaller than prod where applicable.
- **FR-011**: Promotion flow MUST be **dev (auto on `main`) → test (manual) → prod (manual, gated on test)**; the same immutable image tag / web build id MUST be promoted, not rebuilt differently per env.
- **FR-013**: GitHub Environments (or equivalent) SHOULD enforce **required reviewers** or protection rules on **prod** manual deploy.

### Non-Functional Requirements

- **NFR-SEC-001**: RDS MUST NOT be internet-routable; only ECS security groups may reach DB port.
- **NFR-REL-001**: ECS service MUST use health checks aligned with `/health` and `/health/ready`.
- **NFR-OBS-001**: Deploy failures MUST be visible in GitHub Actions logs and ECS events.

### Validation Requirements

- Backend: `dotnet test` in CI; post-deploy smoke `GET /health`.
- Terraform: `terraform validate` in CI; plan artifact on PRs.
- Client: `flutter build web` in CI; post-deploy CloudFront URL returns 200 for `index.html`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Push-to-deploy completes in under 20 minutes for backend (excluding first-time infra).
- **SC-002**: Push to `main` updates **dev** with zero manual steps; promotion to test/prod uses GitHub UI buttons only (no AWS console).
- **SC-003**: New engineer can redeploy from README/terraform docs in under 60 minutes (bootstrap excluded).

## Assumptions

- GitHub Actions uses **OIDC** to assume AWS IAM roles; no static `AWS_ACCESS_KEY_ID` in repository secrets for deploy jobs.
- Existing monorepo layout: `backend/`, `frontend/`.
- API is container-friendly (.NET 8 Kestrel).
- All three environments (`dev`, `test`, `prod`) deploy to **one AWS region** per account (region chosen in plan; ACM for CloudFront still uses `us-east-1`).
- Environment names in AWS/Terraform: `dev`, `test`, `prod` (test = pre-production QA, not “unit tests”).
- Operator owns a **registered domain** (exact name configured in Terraform variables); subdomains differ per env for API and web.

## Out of Scope

- Multi-region active-active (unless clarified).
- Kubernetes/EKS (ECS Fargate chosen).
- **iOS/Android app store** build and release automation (TestFlight, Play Console).
- Native mobile binaries on ECS or ECR (web-only on S3/CloudFront for v1).

## Dependencies

- Existing backend tests and health endpoints (`003-custom-health-checks`).
- CORS configuration for browser client (`007-api-cors-policy`) — prod/staging web subdomains must be added to `Cors:AllowedOrigins` per env.
