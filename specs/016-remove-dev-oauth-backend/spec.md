# Feature Specification: Remove backend development OAuth token exchange

**Feature Branch**: `016-remove-dev-oauth-backend`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: remove `DevOAuthTokenExchanger` (and related dev-code sign-in) the same way as client “Sign in (local backend)” was removed in `015-remove-mock-local`

## Clarifications

### Session 2026-05-26

- Q: Should deployed API environments accept `dev-*` OAuth codes? → A: **No** — dev, test, and prod MUST use real authentication (LinkedIn BFF on web; configured OAuth providers only).
- Q: May automated API tests still obtain JWTs without calling LinkedIn? → A: **Yes** — test-only token helpers or fakes in the **test** project are allowed; they MUST NOT ship in the production API assembly.
- Q: Is local `dotnet run` without LinkedIn secrets a supported product workflow? → A: **No** — aligned with `015`: team validates on deployed environments; maintainers configure OAuth secrets or use test harnesses.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deployed sign-in uses only real OAuth (Priority: P1)

As a user signing in on deployed dev, test, or prod, I must authenticate through the supported production flows (LinkedIn BFF for web, ticket/JWT handoff for mobile)—never by posting a fake `dev-smoke-user` (or similar) authorization code to the token endpoint.

**Why this priority**: The development OAuth exchanger bypasses real identity providers and mirrors the removed client “local backend sign-in,” creating false confidence that auth works in production.

**Independent Test**: On a deployed API with LinkedIn configured, attempt token exchange with code `dev-smoke-user`; receive an error (not a valid session). Complete normal LinkedIn BFF sign-in and obtain a working session.

**Acceptance Scenarios**:

1. **Given** deployed API with LinkedIn OAuth configured, **When** a client posts `dev-{subject}` to the OAuth token exchange endpoint, **Then** the API rejects the request with a clear error and **does not** issue JWT tokens.
2. **Given** deployed API, **When** a user completes LinkedIn BFF sign-in, **Then** the user receives valid access/refresh tokens and can call protected endpoints.
3. **Given** the public sign-in surface on deployed web (after `015`), **When** the user inspects available actions, **Then** no path exists that depends on dev OAuth codes (client and API aligned).

---

### User Story 2 - Operators have one auth troubleshooting model (Priority: P2)

As an operator debugging “cannot sign in” on deployed dev, I need failures to point to missing/misconfigured OAuth secrets or BFF flow—not to “use dev-smoke-user.”

**Why this priority**: Dev-code acceptance masked misconfiguration of LinkedIn secrets on ECS.

**Independent Test**: With LinkedIn secrets absent on a non-production test host used only in CI, token exchange with dev codes fails; documentation lists “configure OAuth / use BFF” not dev codes.

**Acceptance Scenarios**:

1. **Given** API without LinkedIn configured, **When** a user attempts legacy token exchange with a dev code, **Then** the API returns service-unavailable or invalid-request (not a successful dev user session).
2. **Given** operator runbooks for auth, **When** consulted after this change, **Then** no step recommends `dev-*` codes on deployed hosts.

---

### User Story 3 - Automated tests remain reliable without shipping dev auth (Priority: P3)

As a developer merging changes, I need the API test suite to still obtain authenticated sessions without reintroducing development OAuth in production code.

**Why this priority**: Many tests today use `dev-{subject}` via the production exchanger; removing it requires test-scoped substitutes.

**Independent Test**: CI runs `dotnet test` green; production DI registration does not include development OAuth exchanger.

**Acceptance Scenarios**:

1. **Given** the API test project, **When** tests need an authenticated user, **Then** they use a test-only mechanism (e.g. test host fake, seeded user + test signing helper) without `DevOAuthTokenExchanger` in Infrastructure.
2. **Given** a build of the API deployed to ECS, **When** dependencies are inspected, **Then** no development OAuth token exchanger is registered for request handling.

---

### Edge Cases

- Facebook token exchange currently routed only through development exchanger — must either require real Facebook configuration or reject with clear error (no silent dev user).
- `test-code` magic value used in tests — must not work on deployed API.
- Mobile `POST /auth/oauth/linkedin/token` vs BFF — ensure error messages still direct clients to BFF when appropriate.
- Existing `.http` files or README examples showing `dev-smoke-user` must be updated or marked obsolete.
- Postgres integration tests that login via dev codes must migrate to test doubles.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Deployed API (dev, test, prod) MUST NOT issue JWT sessions in exchange for development authorization codes (`dev-*`, `test-code`, or equivalent).
- **FR-002**: Production API composition MUST NOT register a development OAuth token exchanger for request handling.
- **FR-003**: OAuth token exchange endpoints MUST reject development codes with explicit errors suitable for operators (not generic 500).
- **FR-004**: When LinkedIn is configured, sign-in MUST use the BFF flow; token exchange with arbitrary codes MUST NOT succeed via a development bypass.
- **FR-005**: Facebook (if exposed) MUST NOT authenticate via development-only fake users in deployed environments.
- **FR-006**: API automated tests MUST continue to pass using **test-project-only** auth helpers; tests MUST NOT require re-adding development exchanger to production Infrastructure.
- **FR-007**: Documentation and HTTP examples MUST NOT present `dev-smoke-user` (or similar) as a supported sign-in path for deployed environments.
- **FR-008**: Behavior MUST stay consistent with client feature `015-remove-mock-local` (no parallel dev auth on web or API).

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy standard .NET analyzers with no new critical findings.
- **NFR-TEST-001**: All existing API unit/integration tests MUST be updated or replaced; CI MUST remain green.
- **NFR-SEC-001**: Removing dev OAuth MUST reduce risk of unauthenticated or weakly authenticated access on deployed hosts.
- **NFR-UX-001**: Error responses for rejected dev codes MUST be actionable (invalid grant / not supported), not misleading success.

### Validation Requirements *(mandatory)*

- **VR-001**: Deployed dev smoke: `dev-smoke-user` token exchange fails; BFF sign-in succeeds.
- **VR-002**: `dotnet test` on API solution passes.
- **VR-003**: Code review: no `DevOAuthTokenExchanger` (or equivalent) in production Infrastructure registration for shipped environments.
- **VR-004**: Grep/docs: no operator instructions to use dev codes on deployed API.

### Key Entities

- **Development authorization code**: Client-supplied string matching `dev-{subject}` or `test-code` used today to bypass real OAuth.
- **OAuth token exchange**: Server endpoint that trades an authorization code for JWT access/refresh tokens.
- **LinkedIn BFF flow**: Supported production web/mobile authentication path via `/auth/linkedin/login` and ticket completion.
- **Test-only auth helper**: Mechanism confined to test assemblies to create sessions without real LinkedIn.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of manual attempts to sign in on deployed dev using `dev-*` codes fail without issuing tokens (verified in smoke checklist).
- **SC-002**: LinkedIn BFF sign-in on deployed dev completes with protected API calls succeeding (e.g. profile or events) in the same session.
- **SC-003**: API test suite passes on CI with zero reliance on production-registered development OAuth exchanger.
- **SC-004**: Operator/auth troubleshooting docs contain zero steps recommending dev OAuth codes for deployed environments.
- **SC-005**: Security review confirms no alternate “fake user” login path remains on ECS-hosted API builds.

## Assumptions

- `015-remove-mock-local` removes client “Sign in (local backend)” and demo sign-in; this feature completes the same policy on the **API**.
- LinkedIn OAuth secrets are (or will be) configured on deployed dev/test/prod per existing infra (`009-linkedin-bff-auth`, Terraform secrets).
- Backend engineers running local API for experiments are out of product acceptance scope; they use configured OAuth or test projects.
- Testcontainers/Postgres integration tests are in scope for migration to test auth helpers (unlike `015` client scope).

## Dependencies

- `015-remove-mock-local` — client no longer calls dev token exchange for product sign-in.
- `009-linkedin-bff-auth` — BFF is the supported web auth path.
- `005-api-backend-integration` — documents prior dev sign-in; supersede with this policy.
