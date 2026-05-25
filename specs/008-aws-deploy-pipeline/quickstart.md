# Quickstart: AWS deploy (dev / test / prod)

**Feature**: `008-aws-deploy-pipeline`  
**Environments**: exactly **`dev`**, **`test`**, **`prod`**

## Prerequisites

- AWS account, IAM admin for bootstrap
- **Local AWS auth** before `terraform apply` (CLI profile or access keys): `aws sts get-caller-identity` must succeed. GitHub OIDC is only for deploy workflows after bootstrap.
- **Either** technical URLs (`use_custom_domain = false`, no domain purchase) **or** Route 53 zone for `felloway.click` when `use_custom_domain = true`
- GitHub repo admin (Environments, OIDC)
- Tools: Terraform ≥ 1.5, AWS CLI, Docker, Flutter stable

## 1. Bootstrap (once)

```bash
cd infra/terraform/bootstrap
# Uses committed terraform.tfvars (non-secret); edit bucket name / github_repository if needed
terraform init && terraform apply
# Creates: state S3 bucket, GitHub OIDC provider
```

Note outputs: state bucket name, OIDC provider ARN.

## 2. Provision infrastructure (per env)

```bash
cd infra/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # edit domain_name, etc.
terraform init
terraform plan
terraform apply
```

Repeat for `test` and `prod` with **different** `vpc_cidr` and hostnames.

## 3. Configure GitHub

1. Repository **Variables**: `AWS_ACCOUNT_ID`, `AWS_REGION`; after dev apply either `DEV_API_BASE_URL` + `DEV_WEB_BASE_URL` from `terraform output`, or `DOMAIN_NAME` for custom domain
2. **Environments**: create `dev`, `test`, `prod` (add required reviewers on `prod`)
3. Ensure workflows use OIDC roles created by Terraform

## 4. First deploy

```bash
git push origin main
```

- CI builds and deploys to **dev** only
- Verify URLs from `terraform output` (technical) or `https://dev.api.<domain>/health`

## Minimal cost (recommended to start)

- Dev **`use_custom_domain = false`** — no domain fee; CloudFront default hostnames
- Apply Terraform for **`dev` only** until you need test/prod
- GitHub: `DEV_API_BASE_URL`, `DEV_WEB_BASE_URL`, `DEV_CLOUDFRONT_DISTRIBUTION_ID` from terraform outputs

## 5. Promote

1. GitHub → Actions → **Promote to test** → Run workflow
2. After test smoke passes → **Promote to prod** (requires approval if configured)

## 6. Rollback

### API (ECS)

```bash
# List previous task definition revisions
aws ecs list-task-definitions --family-prefix felloway-api-dev --sort DESC

aws ecs update-service \
  --cluster felloway-dev \
  --service felloway-api-dev \
  --task-definition felloway-api-dev:PREVIOUS_REVISION \
  --force-new-deployment
```

### Web (S3 + CloudFront)

- Re-run **Promote** workflow with an older `image_tag` from a known-good commit, or
- Restore S3 object version (if versioning enabled) and create CloudFront invalidation `/*`

### Full stack

Revert git on `main` and push (re-deploys **dev** only); promote to test/prod again when verified.

## Local Docker smoke

```bash
cd backend
docker build -t felloway-api:local -f Dockerfile .
docker run -p 8080:8080 -e ConnectionStrings__Default="..." felloway-api:local
```

## Troubleshooting

| Issue | Check |
|-------|--------|
| OIDC assume role failed | Trust policy `sub` matches `environment:dev` |
| ECS tasks unhealthy | `/health/ready`, RDS secret, security groups |
| CORS on web | `Cors:AllowedOrigins` includes `https://dev.app.<domain>` |
| CloudFront 403 | OAC, bucket policy, index.html exists |
