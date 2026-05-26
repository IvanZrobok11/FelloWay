# Quickstart: Production-only OAuth (016)

## Policy (one sentence)

**Deployed API: no `dev-*` OAuth codes — use LinkedIn BFF only; tests use `TestOAuthTokenExchanger` in the test project.**

## Operator: verify after deploy

1. Ensure LinkedIn secrets on ECS (`OAuth__LinkedIn__*` from Secrets Manager).
2. Attempt (must **fail**):

```http
POST https://dev.api.<domain>/auth/oauth/linkedin/token
Content-Type: application/json

{
  "code": "dev-smoke-user",
  "redirectUri": "com.felloway.app:/oauthredirect",
  "codeVerifier": "verifier"
}
```

3. Sign in on web via normal LinkedIn BFF (`/auth/linkedin/login` from client).
4. Confirm `GET https://dev.api.<domain>/users/me` with Bearer token returns 200.

## Maintainer: CI

```bash
cd backend
dotnet test FelloWay.slnx --filter "Category!=Integration"
```

Integration suite (Postgres) must also pass when run locally/CI.

## Maintainer: grep

```bash
rg "DevOAuthTokenExchanger" backend/src
# expect no matches after implementation

rg "dev-smoke-user" backend/src specs/005
# no production docs recommending dev login on deploy
```

## Test auth (not for deploy)

Integration tests obtain JWT via `dev-{subject}` only because `FelloWayWebApplicationFactory` registers `TestOAuthTokenExchanger`. This never ships in the API container image.

## Troubleshooting

```text
Cannot sign in on deployed dev?
├─ Tried dev-smoke-user on /auth/oauth/.../token?
│  └─ Not supported — use LinkedIn BFF from the web app
├─ LinkedIn login 503?
│  └─ Fix Secrets Manager + ECS redeploy API
└─ BFF works but /users/me 401?
   └─ CORS, cookie vs Bearer split-host — see 009 quickstart
```

## Related

- [oauth-token-exchange-policy.md](./contracts/oauth-token-exchange-policy.md)
- [015 client quickstart](../../015-remove-mock-local/quickstart.md)
