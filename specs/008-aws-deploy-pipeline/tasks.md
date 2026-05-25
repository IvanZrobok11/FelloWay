# Tasks: AWS Deploy Pipeline & Infrastructure

**Input**: Design documents from `/specs/008-aws-deploy-pipeline/`  
**Branch**: `008-aws-deploy-pipeline`  
**Environments**: **dev**, **test**, **prod** only (no fourth environment)

**Tests**: CI runs `dotnet test` and `flutter test` in deploy workflow (per spec validation requirements).

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Repository layout and tooling baseline

- [x] T001 Create `infra/terraform/` tree: `bootstrap/`, `modules/{network,alb,ecs,rds,web,dns}/`, `environments/{dev,test,prod}/` per `specs/008-aws-deploy-pipeline/contracts/terraform-infra-contract.md`
- [x] T002 [P] Add `infra/.gitignore` (`.terraform/`, `*.tfstate*`, `.terraform.lock.hcl`, `*.tfvars` secrets)
- [x] T003 [P] Add `infra/README.md` with links to `specs/008-aws-deploy-pipeline/quickstart.md` and three-env note

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Bootstrap, shared Terraform modules, API container — **blocks all user stories**

**⚠️ CRITICAL**: No deploy or full env apply until this phase completes

- [x] T004 Implement `infra/terraform/bootstrap/` (S3 state bucket, GitHub OIDC provider outputs)
- [x] T005 [P] Implement `infra/terraform/modules/network/` (VPC, public/private subnets, NAT, security groups)
- [x] T006 [P] Implement `infra/terraform/modules/alb/` (internet ALB, HTTPS listener, target group, `/health` check)
- [x] T007 [P] Implement `infra/terraform/modules/rds/` (PostgreSQL 16, private subnets, Secrets Manager password)
- [x] T008 [P] Implement `infra/terraform/modules/ecs/` (Fargate cluster, task definition skeleton, ECR repo, execution/task IAM)
- [x] T009 [P] Implement `infra/terraform/modules/web/` (S3 private bucket, CloudFront OAC, ACM us-east-1 for CF)
- [x] T010 [P] Implement `infra/terraform/modules/dns/` (Route 53 alias records for API → ALB, web → CloudFront)
- [x] T011 Add `backend/Dockerfile` multi-stage .NET 8 publish exposing port 8080 for `FelloWay.Api`
- [x] T012 Add `backend/.dockerignore` to minimize image context size

**Checkpoint**: `terraform validate` passes in each module; `docker build` succeeds locally

---

## Phase 3: User Story 3 — Reproducible infrastructure (Priority: P1)

**Goal**: Three isolated stacks (`dev`, `test`, `prod`) provisioned via Terraform.

**Independent Test**: `terraform apply` in `environments/dev` succeeds; outputs include `api_url`, `web_url`, `ecr_repository_url`; RDS not publicly accessible.

### Implementation for User Story 3

- [x] T013 [US3] Wire `infra/terraform/environments/dev/` calling all modules with `environment = "dev"` and unique `vpc_cidr`
- [x] T014 [P] [US3] Add `infra/terraform/environments/dev/terraform.tfvars.example` (domain_name, api_host, web_host, sizing)
- [x] T015 [P] [US3] Wire `infra/terraform/environments/test/` with `environment = "test"` and non-overlapping `vpc_cidr`
- [x] T016 [P] [US3] Wire `infra/terraform/environments/prod/` with `environment = "prod"` and production sizing variables
- [x] T017 [US3] Add OIDC IAM roles in bootstrap or env modules: `felloway-github-deploy-dev|test|prod` per `contracts/cicd-pipeline-contract.md`
- [x] T018 [US3] Configure remote backend in each env `backend.tf` pointing at bootstrap state bucket with keys `felloway/dev`, `felloway/test`, `felloway/prod`
- [x] T019 [US3] Document manual first-time `terraform apply` order (bootstrap → dev → test → prod) in `infra/README.md`

**Checkpoint**: All three env dirs plan cleanly; dev stack applied in AWS (manual or documented)

---

## Phase 4: User Story 1 — Automated backend release (Priority: P1) 🎯 MVP

**Goal**: Push to `main` builds/tests and auto-deploys API to **dev**; manual promote to **test** then **prod**.

**Independent Test**: Push to `main` updates dev ECS image; manual workflows promote same `image_tag` to test/prod; `GET https://dev.api.<domain>/health` → 200.

### Implementation for User Story 1

- [x] T020 [US1] Complete ECS module task definition: Secrets Manager env (`ConnectionStrings__Default`, `Jwt__*`), container port, health check
- [x] T021 [US1] Create `.github/workflows/deploy.yml` — on `push` to `main`: `dotnet test`, `docker build/push` to `felloway-api-dev`, ECS deploy dev, upload artifact metadata JSON
- [x] T022 [US1] Create `.github/workflows/promote-test.yml` — `workflow_dispatch`, OIDC role test, promote image tag + deploy ECS test
- [x] T023 [US1] Create `.github/workflows/promote-prod.yml` — `workflow_dispatch`, GitHub Environment `prod` protection, gated after test deploy
- [x] T024 [US1] Configure GitHub Environments `dev`, `test`, `prod` (document required reviewers on prod in `infra/README.md`)
- [x] T025 [US1] Add post-deploy smoke step `curl -f` against `https://<env>.api.<domain>/health` in each deploy workflow

**Checkpoint**: Push to `main` deploys dev API; promote buttons update test/prod with same tag

---

## Phase 5: User Story 2 — Flutter web on CloudFront (Priority: P1)

**Goal**: Flutter web built in CI, published to S3/CloudFront per env with correct `API_BASE_URL` and CORS.

**Independent Test**: `https://dev.app.<domain>` loads; browser can call dev API without CORS errors.

### Implementation for User Story 2

- [x] T026 [US2] Extend `deploy.yml` with `flutter test`, `flutter build web` using `--dart-define=API_BASE_URL=https://dev.api.<domain>` and `--dart-define=API_MODE=live`
- [x] T027 [US2] Add S3 sync + CloudFront invalidation steps to `deploy.yml` (dev bucket/distribution outputs from Terraform)
- [x] T028 [US2] Add web build/deploy steps to `promote-test.yml` and `promote-prod.yml` with test/prod API URLs respectively
- [x] T029 [US2] Store per-env `Cors:AllowedOrigins` in Secrets Manager / SSM and map into ECS task env for `dev`, `test`, `prod` web subdomains
- [x] T030 [US2] Add smoke step in workflows: `curl -f https://<env>.app.<domain>/` returns 200

**Checkpoint**: Web + API work end-to-end in dev; promotion updates test/prod web hosts

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: CI validation, docs, rollback

- [x] T031 [P] Add `.github/workflows/terraform-ci.yml` — on PR: `terraform fmt -check`, `validate` for `environments/{dev,test,prod}`
- [x] T032 [P] Update root `README.md` with AWS deploy overview and link to quickstart
- [x] T033 Extend `specs/008-aws-deploy-pipeline/quickstart.md` with rollback steps for ECS task definition and S3/CloudFront
- [x] T034 Verify existing `.github/workflows/backend-ci.yml` remains for PRs (no regression to local CI path)

---

## Dependencies & Execution Order

### Phase Dependencies

| Phase | Depends on | Delivers |
|-------|------------|----------|
| 1 Setup | — | Directory layout |
| 2 Foundational | Phase 1 | Modules + Dockerfile |
| 3 US3 | Phase 2 | AWS infra (dev/test/prod) |
| 4 US1 | Phase 3 (dev min) | CI/CD API deploy |
| 5 US2 | Phase 3 + US1 workflows | Web deploy + CORS |
| 6 Polish | US1–US2 | Docs + TF CI |

### User Story Dependencies

- **US3** first (infra required for ECR/ECS/S3/CF endpoints)
- **US1** depends on US3 dev + Dockerfile
- **US2** extends US1 workflows (same pipeline files)

### Parallel Opportunities

```text
Phase 1:  T002 || T003
Phase 2:  T005–T010 parallel after T004
Phase 3:  T015 || T016 after T013–T014
Phase 6:  T031 || T032
```

---

## Parallel Example: Phase 2 modules

```bash
# After T004 bootstrap:
# T005 network, T006 alb, T007 rds, T008 ecs, T009 web, T010 dns — different module dirs
```

---

## Implementation Strategy

### MVP First (US3 dev + US1 dev deploy)

1. Phase 1–2 → modules + Dockerfile  
2. Phase 3 → `terraform apply` **dev only**  
3. Phase 4 → `deploy.yml` auto dev API  
4. **Validate** `/health` on dev API  

### Incremental Delivery

1. Add US2 web deploy to dev  
2. Add test/prod Terraform + promote workflows  
3. Polish docs + terraform-ci  

---

## Notes

- **Only** `dev`, `test`, `prod` — do not add `staging`, `qa`, or `integration` environments.  
- ALB in **public** subnets; ECS and RDS in **private** subnets.  
- No `AWS_ACCESS_KEY_ID` in GitHub for deploy jobs — OIDC only.  
- Promotion must reuse the same `image_tag` artifact from the `main` build.
