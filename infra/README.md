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

- Push to `main` → auto deploy **dev** (see `.github/workflows/deploy.yml`); CI registers a new ECS task definition with the ECR API image. `ASPNETCORE_ENVIRONMENT` matches the env name: `dev`, `test`, or `prod`.
- Manual **Promote to test** → `.github/workflows/promote-test.yml`
- Manual **Promote to prod** → `.github/workflows/promote-prod.yml` (requires the image tag to exist in **test** ECR; configure GitHub Environment `prod` with required reviewers)

Uses **GitHub OIDC** — no long-lived `AWS_ACCESS_KEY_ID` in secrets.

## LinkedIn OAuth (Secrets Manager)

Put credentials in **local** `terraform.tfvars` per environment (never commit real values):

```hcl
linkedin_client_id     = "..."
linkedin_client_secret = "..."
```

`terraform apply` writes them to `felloway/{env}/app` in Secrets Manager. ECS injects `OAuth__LinkedIn__ClientId`, `OAuth__LinkedIn__ClientSecret`, and `Frontend__BaseUrl` (same URL as web/CORS origin).

## GetStream (chat)

In **local** `terraform.tfvars` per environment:

```hcl
stream_api_key    = "..."   # public key (Dashboard)
stream_api_secret = "..."   # secret (server only)
```

GitHub variable **`DEV_STREAM_API_KEY`** must match `stream_api_key` (public GetStream key). Terraform does **not** inject this into Flutter — CI writes `env.json` on the web bucket at deploy time, and the web app loads `/env.json` at startup.

After `terraform apply`, redeploy ECS (API) and re-run deploy workflow (web). Check: `https://<web_url>/env.json` should return `{"streamApiKey":"..."}`.

In the [LinkedIn Developer Portal](https://www.linkedin.com/developers/), set **Authorized redirect URL** to:

`https://<api-public-host>/auth/linkedin/callback`

(e.g. dev technical: `terraform output -raw api_url` + `/auth/linkedin/callback`)

After changing secrets or the ECS task definition, force a new deployment so tasks pick up values:

```bash
aws ecs update-service --cluster felloway-dev --service felloway-api-dev --force-new-deployment
```

## GitHub setup

1. Repository variables: `AWS_ACCOUNT_ID`, `AWS_REGION` (e.g. `eu-central-1`); either `DEV_API_BASE_URL` + `DEV_WEB_BASE_URL` (technical) or `DOMAIN_NAME` (custom domain); `DEV_STREAM_API_KEY` (GetStream **public** API key for Flutter web build; optional but required for chat UI)
2. Environments: `dev`, `test`, `prod`
3. Ensure OIDC roles from Terraform match workflow `environment:` values

## Docs

- [specs/008-aws-deploy-pipeline/quickstart.md](../specs/008-aws-deploy-pipeline/quickstart.md)
- [specs/008-aws-deploy-pipeline/contracts/](../specs/008-aws-deploy-pipeline/contracts/)

## Rollback

- **ECS**: `aws ecs update-service --cluster <cluster> --service <service> --task-definition <previous-arn>`
- **Web**: Re-run promote workflow with previous git SHA artifact, or restore S3 object version
