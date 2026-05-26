# Contract: OAuth token exchange policy (production API)

## Scope

FelloWay API (`FelloWay.Api` + `FelloWay.Infrastructure`) deployed to **dev**, **test**, and **prod**. Test assemblies may register a different `IOAuthTokenExchanger` implementation.

## Policy

1. Production MUST NOT issue JWT access/refresh tokens in exchange for **development authorization codes** (`dev-*`, `test-code`, or equivalent).
2. Production MUST NOT register `DevOAuthTokenExchanger` (or equivalent) in dependency injection.
3. When **LinkedIn OAuth is configured**, `POST /auth/oauth/linkedin/token` MUST NOT exchange authorization codes; clients MUST use BFF `GET /auth/linkedin/login` and ticket/mobile-complete flows.
4. When **LinkedIn OAuth is not configured**, token exchange MUST NOT fall back to synthetic users; requests MUST fail with a clear configuration error.
5. **Facebook** token exchange via development fake users is forbidden; endpoint MUST return unsupported/not configured until a real Facebook integration exists.
6. Automated tests MAY use `TestOAuthTokenExchanger` in `FelloWay.Api.Tests` only.

## Endpoint contract: `POST /auth/oauth/{provider}/token`

**Request body** (unchanged shape):

```json
{
  "code": "string",
  "redirectUri": "string",
  "codeVerifier": "string"
}
```

**Production responses** (examples):

| Request | Expected |
|---------|----------|
| `code`: `dev-smoke-user`, `provider`: `linkedin` | **4xx** — no `accessToken` in body |
| `code`: real LinkedIn code, LinkedIn configured | **4xx** — message directs to BFF |
| `provider`: `facebook`, any code | **4xx** — unsupported |

**Success** on production: only if a future real provider exchanger is implemented (not dev bypass).

## Verification

| Check | Pass criteria |
|-------|----------------|
| Deployed smoke | `dev-smoke-user` → 4xx; BFF sign-in → `GET /users/me` with Bearer 200 |
| CI | `dotnet test` on `FelloWay.slnx` green |
| Static | No `DevOAuthTokenExchanger` in `backend/src/` or registered from Infrastructure |
| Tests | `TestOAuthTokenExchanger` only under `backend/tests/` |

## Related

- Client policy: [015 live-only client](../../015-remove-mock-local/contracts/live-only-client-policy.md)
- BFF flow: [009 LinkedIn BFF](../../009-linkedin-bff-auth/contracts/linkedin-bff-oauth-flow.md)
