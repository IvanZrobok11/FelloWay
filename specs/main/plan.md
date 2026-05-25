# Implementation Plan: Production LinkedIn OAuth Sign-In

**Branch**: `main` | **Date**: 2026-05-19 | **Spec**: [spec.md](./spec.md)

**Input**: Enable real LinkedIn sign-in: mobile authorization code → backend exchange → FelloWay JWT; hybrid `dev-{subject}` when secrets absent.

## Summary

Replace the **dev-only** OAuth exchanger and the **client-side token exchange** with a production path: `flutter_appauth` obtains a LinkedIn authorization code (PKCE), `AuthApi.exchangeLinkedIn` posts it to `POST /auth/oauth/linkedin/token`, and a new **`LinkedInOAuthTokenExchanger`** (plus composite routing) exchanges with LinkedIn OIDC server-side. Facebook and dev smoke remain unchanged. Verify on **local** and **staging** with a registered LinkedIn app.

## Technical Context

**Language/Version**: C# 12 / .NET 8; Dart 3.10+ / Flutter stable  
**Primary Dependencies**: `flutter_appauth`, `dio`; ASP.NET Core, EF Core 8, `HttpClient`, Polly (LinkedIn HTTP), existing `AuthService` / JWT  
**Storage**: PostgreSQL (`users`, `oauth_identities`, `refresh_tokens`); optional new `users.email` column  
**Testing**: xUnit + `WebApplicationFactory` (backend); `flutter test` unit/widget (frontend); manual smoke per [quickstart.md](./quickstart.md)  
**Target Platform**: Android 8+, iOS 14+; Linux App Service (staging API)  
**Project Type**: Monorepo — `backend/`, `frontend/`, `shared/api-contracts/`  
**Performance Goals**: Sign-in flow &lt; 30s (NFR-001); no extra round-trips beyond authorize + token + userinfo + API exchange  
**Constraints**: Client secret server-only; no contract path change; LinkedIn-only (Facebook dev exchanger unchanged)  
**Scale/Scope**: 1 OAuth provider productionized; 1 Flutter screen (`oauth_sign_in_page.dart`); ~4 new backend types + DI

## Constitution Check

*GATE: Constitution is Flutter-oriented; backend uses equivalent gates (see 002-backend-api plan).*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `dotnet format` / analyzers; `dart format` / `flutter analyze` |
| Test strategy | ✅ Pass | Mocked LinkedIn HTTP tests; existing OAuth endpoint tests; Flutter `auth_api` + sign-in widget tests |
| UX consistency | ✅ Pass | Existing OAuth screen, snackbars for errors; hide dev button when LinkedIn defines set |
| Performance budgets | ✅ Pass | NFR-001 (30s sign-in); no blocking work on UI thread beyond AppAuth |
| Flutter quality checks | ✅ Pass | quickstart §7 |
| Evidence plan | ✅ Pass | PR: local + staging smoke checklist, CI `dotnet test` + `flutter test` |

**Post-design re-check**: No constitution violations. No complexity tracking required.

## Project Structure

### Documentation (this feature)

```text
specs/main/
├── plan.md              # This file
├── spec.md
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── linkedin-oauth-flow.md
└── tasks.md             # /speckit.tasks (not created by /speckit.plan)
```

### Source Code (repository root)

```text
backend/src/FelloWay.Infrastructure/Auth/
├── DevOAuthTokenExchanger.cs           # keep for dev + facebook
├── LinkedInOAuthTokenExchanger.cs      # NEW: token + userinfo HTTP
├── CompositeOAuthTokenExchanger.cs     # NEW: route by provider + secrets
└── OAuthOptions.cs                     # NEW: bind OAuth:LinkedIn:*

backend/src/FelloWay.Application/Auth/
└── AuthService.cs                      # map Email to User (after migration)

backend/src/FelloWay.Domain/Entities/
└── User.cs                             # add Email?

frontend/lib/features/auth/
├── presentation/oauth_sign_in_page.dart  # authorize → AuthApi (not exchange on device)
└── data/auth_api.dart                    # existing exchangeLinkedIn

shared/api-contracts/auth/openapi.yaml    # unchanged (reference only)

backend/tests/FelloWay.Api.Tests/Auth/
└── LinkedInOAuthTokenExchangerTests.cs   # NEW (mock handler)
```

**Structure Decision**: Touch Infrastructure auth layer + one Application mapping change + one Flutter presentation file; contracts stay in `shared/api-contracts/`.

## Implementation Phases (for `/speckit.tasks`)

### Phase A — Backend LinkedIn exchanger (P1)

1. Add `OAuthOptions` (`OAuth:LinkedIn:ClientId`, `ClientSecret`) and configuration validation.
2. Implement `LinkedInOAuthTokenExchanger`:
   - POST `accessToken` with `grant_type=authorization_code`, `code`, `redirect_uri`, `client_id`, `client_secret`, `code_verifier`.
   - GET userinfo with bearer; map `sub`, `name`, `email` → `OAuthUserInfo`.
   - Polly handler on named `HttpClient`.
3. Implement `CompositeOAuthTokenExchanger` per [research.md](./research.md) §3.
4. Replace DI: `services.AddScoped<IOAuthTokenExchanger, CompositeOAuthTokenExchanger>()`.
5. EF migration `AddUserEmail`; update `AuthService` to set `User.Email` when provided.
6. Tests: unit/integration for linkedin-with-secrets vs dev-code rejection vs no-secrets dev path.

### Phase B — Flutter sign-in flow (P1)

1. Change `_exchangeOAuth` to `appAuth.authorize` + `AuthApi.exchangeLinkedIn`.
2. Pass `redirectUri` and PKCE verifier from authorize result to API body.
3. Store API tokens via `authSession.setAuthenticated` (unchanged).
4. Keep `_devBackendSignIn` when `!oauthReady && !useMock` (FR-010).
5. Facebook button: keep current handler or disable real OIDC until follow-up (no Facebook production work).
6. Tests: unit test sign-in path mocks `AuthApi`; manual smoke per quickstart.

### Phase C — Operator docs & staging (P2)

1. Finalize [quickstart.md](./quickstart.md) with local/staging checklist.
2. Document staging secret keys for deploy pipeline (`008-aws-deploy-pipeline`).
3. Run SC-001: real LinkedIn on local + staging.

## Integration Boundaries

| System | Responsibility |
|--------|----------------|
| LinkedIn OIDC | Authorize (mobile); token + userinfo (backend only) |
| FelloWay API | Issue JWT; link `OAuthIdentity`; optional `User.Email` |
| Flutter | PKCE authorize; never hold LinkedIn secret |
| Facebook | Unchanged dev exchanger |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Composite exchanger (2 implementations) | Hybrid dev + production on same endpoint | Single class with growing if-chains harms testability |
| `User.Email` migration | FR-012 requires persist when present | Leaving email only in OAuthUserInfo loses data after request |

## Risks

| Risk | Mitigation |
|------|------------|
| LinkedIn verification delay | Email optional; manual profile completion |
| Redirect URI mismatch | Document single mobile scheme; same value in AppAuth + API body |
| Tests depend on dev exchanger | Factory tests without secrets; separate tests with mocked LinkedIn HTTP |

## Artifacts Generated

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Contract notes | [contracts/linkedin-oauth-flow.md](./contracts/linkedin-oauth-flow.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
| Plan | [plan.md](./plan.md) |

**Next command**: `/speckit.tasks` — break Phases A–C into ordered tasks.
