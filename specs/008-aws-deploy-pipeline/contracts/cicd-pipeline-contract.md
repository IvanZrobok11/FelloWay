# Contract: GitHub Actions deploy & promotion

**Feature**: `008-aws-deploy-pipeline`  
**Environments**: **`dev`**, **`test`**, **`prod` only**

## Workflows

| Workflow file | Trigger | Deploy target |
|---------------|---------|---------------|
| `deploy.yml` | `push` to `main` | **dev** (auto after green build) |
| `promote-test.yml` | `workflow_dispatch` | **test** |
| `promote-prod.yml` | `workflow_dispatch` | **prod** (requires prior test deploy) |

## Build job (deploy.yml)

1. Checkout
2. `dotnet test` in `backend/` (filter `Category!=Integration` for speed; optional integration job weekly)
3. `flutter test` in `frontend/`
4. `docker build` → tag `:${{ github.sha }}`
5. `flutter build web` with `API_BASE_URL=https://dev.api.<domain>` (dev only at build time for auto-deploy; promotion rebuilds web with correct URL OR stores generic build + env config — **plan uses per-promote web build with env URL** for simplicity)
6. Upload artifacts: image metadata JSON, web `build/web` tarball

## Deploy dev job

- Needs: build
- `configure-aws-credentials` OIDC → role `felloway-github-deploy-dev`
- ECR push `felloway-api-dev:${{ github.sha }}`
- ECS `update-service` / task definition revision
- S3 sync `build/web` → `felloway-web-dev-...`
- CloudFront invalidation `/*`
- Smoke: `curl -f https://dev.api.<domain>/health`

## Promote test job

- `workflow_dispatch` input: `image_tag` (default latest from dev)
- OIDC → `felloway-github-deploy-test`
- ECR: pull tag from dev repo OR copy image to `felloway-api-test` same tag
- ECS + S3 + CF for **test** URLs
- Record deployment in GitHub Environment `test`

## Promote prod job

- `workflow_dispatch`; GitHub Environment **prod** with required reviewers
- Precondition: successful deployment to `test` for same `image_tag` (workflow `needs` or artifact check)
- OIDC → `felloway-github-deploy-prod`
- Same promotion steps for prod hostnames

## OIDC trust (per role)

```json
{
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:<org>/<repo>:environment:<dev|test|prod>"
    }
  }
}
```

## Required GitHub secrets / variables

| Name | Where | Purpose |
|------|-------|---------|
| `AWS_ACCOUNT_ID` | repo variable | ECR URIs |
| `DOMAIN_NAME` | repo variable | Hostnames |
| `TF_STATE_BUCKET` | variable | Remote state (bootstrap) |

No `AWS_ACCESS_KEY_ID` for deploy roles.

## Failure contract

- Test failure → no ECR push, no ECS update
- Deploy failure → job red; previous ECS tasks remain serving
- Prod job unavailable until test job success for same artifact lineage
