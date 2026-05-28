# Contract: Per-environment admin panel deployment

## Scope

FelloWay operator admin UI deployed as **one ECS Fargate service per environment** (dev, test, prod), credentials and API URL **scoped to that environment only**.

## Topology (per environment)

| Resource | Naming pattern |
|----------|----------------|
| ECS cluster | `${project}-${environment}` (shared with API) |
| ECS service | `${project}-admin-${environment}` |
| ECR repository | `${project}-admin-${environment}` |
| Target group | `${project}-${environment}-admin` |
| Log group | `/ecs/${project}-admin-${environment}` |
| Public hostname | `admin.<env-suffix>.<domain>` (HTTPS) |

## Credential contract

1. **GitHub Environment** (separate for `dev`, `test`, `prod`) MUST define:
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD`
   - `ADMIN_SERVICE_KEY` (shared with API validation for server-side calls)

2. Values MUST NOT appear in git-tracked files.

3. Deploy pipeline MUST inject into AWS Secrets Manager for that environment only.

4. Admin container MUST receive secrets as ECS task `secrets` (not plain environment variables in task definition JSON in repo).

## Admin application contract

| Capability | Behavior |
|------------|----------|
| Sign-in | POST form username/password; validate against configured secrets |
| Session | HTTP-only secure cookie; unauthenticated → login page |
| Create event | Form → API `POST /admin/events` with service key |
| Update event | Form → API `PUT /admin/events/{id}` |
| List events | API `GET /admin/events` |
| Cover image | Multipart upload → API stores URL on event |

## API contract (admin content)

All routes require header `X-Admin-Service-Key` matching environment secret.

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/admin/events` | List events (paginated) |
| GET | `/admin/events/{id}` | Get for edit form |
| POST | `/admin/events` | Create (status active) |
| PUT | `/admin/events/{id}` | Update |
| POST | `/admin/events/{id}/cover` | Upload cover image |

Existing moderation routes (`/admin/events/pending`, approve/reject) remain on JWT `AdminOnly` policy or migrate to service key—plan chooses single admin auth story for MVP.

## Verification

| Check | Pass |
|-------|------|
| dev admin URL + dev credentials | Sign-in OK; prod credentials fail |
| Create event on dev admin | Visible on dev consumer app |
| prod admin cannot use dev API URL in task env | Wrong env data not shown |
| `terraform plan` | Admin service + listener rule per env |

## Related

- [008 terraform contract](../../008-aws-deploy-pipeline/contracts/terraform-infra-contract.md)
- [spec.md](../spec.md)
