# FelloWay AWS Infrastructure

Terraform for **three environments only**: `dev`, `test`, `prod`.

## Layout

```text
infra/terraform/
├── bootstrap/          # State bucket, lock table, GitHub OIDC (run once)
├── modules/            # Shared modules
└── environments/
    ├── dev/
    ├── test/
    └── prod/
```

## First-time apply order

1. **Bootstrap** (once per AWS account/region):

   ```bash
   cd infra/terraform/bootstrap
   cp terraform.tfvars.example terraform.tfvars   # set github_repository
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

1. Repository variables: `AWS_ACCOUNT_ID`, `AWS_REGION` (e.g. `eu-central-1`), `DOMAIN_NAME`
2. Environments: `dev`, `test`, `prod`
3. Ensure OIDC roles from Terraform match workflow `environment:` values

## Docs

- [specs/008-aws-deploy-pipeline/quickstart.md](../specs/008-aws-deploy-pipeline/quickstart.md)
- [specs/008-aws-deploy-pipeline/contracts/](../specs/008-aws-deploy-pipeline/contracts/)

## Rollback

- **ECS**: `aws ecs update-service --cluster <cluster> --service <service> --task-definition <previous-arn>`
- **Web**: Re-run promote workflow with previous git SHA artifact, or restore S3 object version
