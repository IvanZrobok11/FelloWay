# FelloWay AWS Infrastructure

Terraform for **three environments only**: `dev`, `test`, `prod`.

## Layout

```text
infra/terraform/
├── bootstrap/          # State bucket, GitHub OIDC (run once)
├── modules/            # Shared modules
└── environments/
    ├── dev/
    ├── test/
    └── prod/
```

## Domain

**Default for dev (no registration):** `use_custom_domain = false` in `environments/dev/terraform.tfvars` — uses CloudFront URLs (`*.cloudfront.net`). After `terraform apply`, run `terraform output api_url web_url` and set GitHub variables `DEV_API_BASE_URL` / `DEV_WEB_BASE_URL`.

**Custom domain later:** set `use_custom_domain = true` and `felloway.click` (or any zone) in tfvars; use `DOMAIN_NAME` in GitHub instead of `DEV_*_BASE_URL`.

## Prerequisites

- Terraform ≥ 1.5, AWS CLI
- **AWS credentials** for the target account (bootstrap and env applies run locally, not via GitHub OIDC):
  - IAM user access keys: `aws configure` (or env `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
  - or SSO: `aws sso login --profile <name>` then `export AWS_PROFILE=<name>` (PowerShell: `$env:AWS_PROFILE = "<name>"`)
- Verify before any `terraform apply`:

  ```bash
  aws sts get-caller-identity
  ```

  You need permission to create S3, IAM (OIDC provider, roles, policies). GitHub deploy roles are created by bootstrap; CI uses those later.

## First-time apply order

1. **Bootstrap** (once per AWS account/region):

   ```bash
   cd infra/terraform/bootstrap
   # terraform.tfvars is committed (non-secret); edit github_repository / state_bucket_name if needed
   terraform init && terraform apply
   ```

2. **Per environment** (repeat for `dev`, then `test`, then `prod`):

   ```bash
   cd infra/terraform/environments/dev
   cp terraform.tfvars.example terraform.tfvars
   terraform init
   terraform plan
   terraform apply
   ```

Remote state keys: `felloway/dev`, `felloway/test`, `felloway/prod`.

## CI/CD

- Push to `main` → auto deploy **dev** (see `.github/workflows/deploy.yml`)
- Manual **Promote to test** → `.github/workflows/promote-test.yml`
- Manual **Promote to prod** → `.github/workflows/promote-prod.yml` (requires the image tag to exist in **test** ECR; configure GitHub Environment `prod` with required reviewers)

Uses **GitHub OIDC** — no long-lived `AWS_ACCESS_KEY_ID` in secrets.

## GitHub setup

1. Repository variables: `AWS_ACCOUNT_ID`, `AWS_REGION` (e.g. `eu-central-1`); either `DEV_API_BASE_URL` + `DEV_WEB_BASE_URL` (technical) or `DOMAIN_NAME` (custom domain)
2. Environments: `dev`, `test`, `prod`
3. Ensure OIDC roles from Terraform match workflow `environment:` values

## Docs

- [specs/008-aws-deploy-pipeline/quickstart.md](../specs/008-aws-deploy-pipeline/quickstart.md)
- [specs/008-aws-deploy-pipeline/contracts/](../specs/008-aws-deploy-pipeline/contracts/)

## Rollback

- **ECS**: `aws ecs update-service --cluster <cluster> --service <service> --task-definition <previous-arn>`
- **Web**: Re-run promote workflow with previous git SHA artifact, or restore S3 object version
