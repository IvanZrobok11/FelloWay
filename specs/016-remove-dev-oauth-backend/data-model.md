# Data model: Production-only OAuth token exchange (016)

## Auth paths (runtime)

| Path | Deployed behavior (target) | Test host behavior |
|------|---------------------------|-------------------|
| `GET /auth/linkedin/login` | BFF Challenge when LinkedIn configured; 503 when not | Same (or test settings with fake client id) |
| `POST /auth/linkedin/mobile/complete` | Ticket → JWT | Unchanged |
| `POST /auth/oauth/{provider}/token` | Reject dev codes; LinkedIn → BFF hint; no dev user issuance | `TestOAuthTokenExchanger` accepts `dev-*` for JWT tests |
| `POST /auth/testing/web-session` | **404** (not Testing env) | Cookie session (Testing only) |
| `POST /auth/refresh` | Unchanged | Unchanged |

## Development authorization code (rejected in production)

| Pattern | Example | Production result |
|---------|---------|-------------------|
| Prefix | `dev-{subject}` | Rejected before user upsert |
| Magic | `test-code` | Rejected |
| Real provider code | LinkedIn auth code on token endpoint | Rejected when LinkedIn configured (use BFF) |

## JWT issuance (unchanged entities)

- `User`, `OAuthIdentity`, `RefreshToken` — still created via `AuthService.SignInFromProviderAsync` for **real** OAuth only in production.
- Test host: same upsert path via `TestOAuthTokenExchanger` → `OAuthUserInfo(subject, displayName, null)`.

## DI registration (target)

| Assembly | `IOAuthTokenExchanger` |
|----------|------------------------|
| `FelloWay.Infrastructure` | `ProductionOAuthTokenExchanger` only |
| `FelloWay.Api.Tests` | `TestOAuthTokenExchanger` (replaces production registration) |

## Error semantics (operator-facing)

| Condition | HTTP (typical) | Message intent |
|-----------|----------------|----------------|
| Dev code on deployed API | 400 / 422 | Development codes not supported |
| LinkedIn configured + token endpoint | 400 | Use BFF `/auth/linkedin/login` |
| LinkedIn not configured | 400 or 503 | Configure OAuth secrets |
| Facebook token exchange | 400 | Unsupported provider |

## Policy entity

**ProductionOAuthPolicy**

- **environments**: dev, test, prod (ECS)
- **devCodeAllowed**: false
- **bffRequiredForLinkedIn**: true when LinkedIn configured
- **testExchangerLocation**: `FelloWay.Api.Tests` only
