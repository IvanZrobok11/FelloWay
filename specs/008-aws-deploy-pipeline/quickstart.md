# Quickstart: AWS deploy (dev / test / prod)

**Feature**: `008-aws-deploy-pipeline`  
**Environments**: exactly **`dev`**, **`test`**, **`prod`**

## Prerequisites

- AWS account, IAM admin for bootstrap
- Registered domain + Route 53 hosted zone (or delegation ready)
- GitHub repo admin (Environments, OIDC)
- Tools: Terraform ≥ 1.5, AWS CLI, Docker, Flutter stable

## 1. Bootstrap (once)

```bash
cd infra/terraform/bootstrap
terraform init && terraform apply
# Creates: state S3 bucket, DynamoDB lock table, GitHub OIDC provider
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

1. Repository **Variables**: `AWS_ACCOUNT_ID`, `DOMAIN_NAME`, `AWS_REGION`
2. **Environments**: create `dev`, `test`, `prod` (add required reviewers on `prod`)
3. Ensure workflows use OIDC roles created by Terraform

## 4. First deploy

```bash
git push origin main
```

- CI builds and deploys to **dev** only
- Verify: `https://dev.api.<domain>/health` and `https://dev.app.<domain>`

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
