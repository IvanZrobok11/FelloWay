# Feature Specification: Remove mock and local-only client runtime paths

**Feature Branch**: `015-remove-mock-local`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: "видали код який стосується локального або моканого запуску"

## Clarifications

### Session 2026-05-26

- Q: Does the team still run the mobile/web app locally for day-to-day validation? → A: **No** — validation happens on **deployed environments** (dev, test, prod) only, consistent with `013-clarify-env-json`.
- Q: Should automated tests keep isolated fakes? → A: **Yes** — test-only doubles in the test suite may remain; product code (`lib/`) must not ship alternate “demo” or “offline” data paths that bypass the real API.
- Q: Is backend test infrastructure (in-memory DB, integration tests) in scope? → A: **No** — this feature targets **end-user client runtime** and its configuration surface, not server-side or CI database test harnesses.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One real API path in every shipped build (Priority: P1)

As a user on dev, test, or prod, I always interact with the same product behavior: data comes from the deployed backend, never from embedded demo catalogs or debug sign-in shortcuts.

**Why this priority**: Mock and local-only branches create “works on my machine” behavior that does not match deployed builds—the main source of “I deployed but nothing changed” confusion.

**Independent Test**: Install or open the app from a deployed environment URL, sign in through the supported auth flow, and browse events, profile, and trips; every screen that shows data must reflect the backend (or a clear error/retry), with no demo-only screens or fake tokens.

**Acceptance Scenarios**:

1. **Given** a production-like build from CI, **When** the user opens any primary feature (events list, profile, onboarding interests), **Then** the client requests the live API and **does not** silently show hardcoded demo content.
2. **Given** the backend is unreachable, **When** the user opens a data-driven screen, **Then** the user sees an explicit error or retry state—not a fallback to in-app mock data.
3. **Given** the sign-in screen on a deployed build, **When** the user looks for entry options, **Then** only supported authentication flows are offered (no “demo sign-in” or equivalent debug entry).

---

### User Story 2 - Operators have a single configuration model (Priority: P2)

As an operator or engineer deploying the client, I need one documented way to configure the app: environment URLs and keys at **build time** for that environment—without choosing between “mock”, “auto”, or “live” modes.

**Why this priority**: Multiple runtime modes multiply deploy mistakes and make support checklists ambiguous.

**Independent Test**: Read deployment and client README material; confirm only the deployed-environment build matrix is described (no mock/local quick-start as a supported product path).

**Acceptance Scenarios**:

1. **Given** CI deploy workflows for dev, test, and prod, **When** a web build completes successfully, **Then** the resulting artifact is configured for live API use only (no mock mode flag in the supported operator docs).
2. **Given** onboarding documentation for new engineers, **When** they ask how to run the product, **Then** the answer points to **deployed dev** smoke steps—not a parallel mock API workflow.

---

### User Story 3 - Support triages failures without mock/local red herrings (Priority: P3)

As support, when users report missing data or auth issues on deployed hosts, I need failure modes that clearly indicate API, auth, or deploy config problems—not confusion with demo mode or local-only features.

**Why this priority**: Removing mock paths reduces false negatives where the app “works” with fake data while production API is broken.

**Independent Test**: Walk through support checklist for “empty events after deploy” and “sign-in fails”; no step suggests switching to mock mode or local-only tokens.

**Acceptance Scenarios**:

1. **Given** a user on deployed dev with invalid auth, **When** they attempt sign-in, **Then** they receive a clear auth error from the real flow—not success via a debug token.
2. **Given** troubleshooting docs updated for this feature, **When** applied to a deployed issue, **Then** no action recommends enabling mock API or demo sign-in.

---

### Edge Cases

- Widget or unit tests that previously relied on mock mode in product configuration must be updated to use test-scoped fakes without reintroducing mock branches in `lib/`.
- Partial removal (mock data deleted but `useMockApi` flag remains) leaves dead configuration—acceptance requires no user-visible mock switches in shipped configuration.
- Chat or trips features that skipped backend calls in mock mode must either call the real API or show an explicit “unavailable” state on deployed builds.
- Historical docs in older specs referencing `API_MODE=mock` must be superseded or cross-linked so operators do not follow obsolete instructions.
- OpenAPI-generated client code and shared contract fixtures remain for codegen/tests and are not mistaken for runtime demo data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Shipped client builds for dev, test, and prod MUST use the **live backend API** as the only data and auth source for product features.
- **FR-002**: The client MUST NOT expose user-facing **demo sign-in**, **mock API mode**, or equivalent shortcuts that bypass real authentication on deployed builds.
- **FR-003**: Data repositories and services in product code MUST NOT branch to in-app demo catalogs, seeded offline lists, or local-only stores when the network or API fails.
- **FR-004**: Configuration surface for operators MUST NOT include `mock`, `auto`-to-mock heuristics, or localhost-specific defaults as a **supported product runtime mode** (build-time URL/key injection for each deployed environment remains valid).
- **FR-005**: User-visible copy tied to demo/mock behavior (e.g. demo sign-in labels, demo chat hints) MUST be removed or replaced with messaging appropriate to live-only operation.
- **FR-006**: Documentation (`frontend/README`, deploy quickstarts, and operator checklists) MUST describe **deployed-environment verification only** and MUST NOT present mock or local-only run paths as supported workflows.
- **FR-007**: Automated client tests MUST continue to pass using **test-scoped** fakes; test doubles MUST NOT require re-adding mock runtime mode to product code.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis requirements with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover core live-path flows and regressions after mock branches are removed.
- **NFR-UX-001**: Error and empty states on deployed builds MUST remain clear when the API is down (no silent demo substitution).
- **NFR-PERF-001**: Removing mock branches MUST NOT increase cold-start or navigation cost on deployed web.
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Test suite MUST be updated wherever it depended on mock runtime mode in product configuration.
- **NFR-FLUTTER-UX-001**: Sign-in and onboarding flows MUST remain consistent with the design system after debug controls are removed.
- **NFR-FLUTTER-PERF-001**: No additional runtime mode detection or hostname heuristics on each screen load.

### Validation Requirements *(mandatory)*

- **VR-001**: Code review: no `useMockApi`, demo sign-in, or `lib/shared/mocks` usage in product `lib/` (test folder exempt).
- **VR-002**: Documentation review: no supported instructions for `API_MODE=mock` or mock-only quick starts in primary README paths.
- **VR-003**: CI web build matrix unchanged for live deploy (`API_MODE=live` or equivalent single mode).
- **VR-004**: Deployed dev smoke: sign-in → events → profile → interests without demo data appearing when API returns empty or errors appropriately.
- **VR-005**: Full `flutter test` green on the feature branch.

### Key Entities

- **Live-only client configuration**: Build-time values (API base URL, public keys) fixed per environment at CI build; no runtime mode switch.
- **Deployed environment**: dev, test, or prod host served via the standard release pipeline—not a developer workstation runtime.
- **Test-scoped fake**: Data or auth stub used only inside automated tests, not compiled into user-facing mock branches.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of primary data screens on deployed dev (events, profile, onboarding interests) either show API-backed content or an explicit error/retry—never silent demo data after this change ships.
- **SC-002**: Support checklist for “app shows wrong/old data after deploy” contains **zero** steps referencing mock mode, demo sign-in, or local-only run—verified by doc review before merge.
- **SC-003**: Operator-facing README sections for running the product list **only** deployed-environment verification paths (count of documented mock/local product run workflows = 0).
- **SC-004**: Automated client test suite passes on the feature branch with no reintroduction of mock runtime mode in `lib/`.
- **SC-005**: Engineering time to explain “why dev deploy differs from my old mock build” drops to a single configuration story (deployed live API only), measurable by absence of mock-related questions in the first release cycle after merge.

## Assumptions

- The team continues to validate exclusively on **deployed** dev/test/prod URLs (aligned with `013-clarify-env-json`).
- **Backend** integration/unit tests and Terraform/local API development for server engineers remain out of scope.
- **CI** already builds web with live API defines; this feature aligns product code and docs with that reality.
- **OAuth and BFF** flows for deployed web remain the supported auth path; removing demo sign-in does not remove LinkedIn or ticket-based auth.
- **Test fixtures** may duplicate small payload shapes in `test/` for widget tests; they are not the canonical product catalog (aligned with `011-backend-interests-catalog` policy).
- **Dev backend sign-in** (`dev-smoke-user` style) against a real deployed API may remain if it is a live API exchange—not a mock token stored only on device; implementation plan will confirm keep/remove per security policy.

## Dependencies

- `013-clarify-env-json` — deployed-only config policy.
- `005-api-backend-integration` — live API paths and token storage (this feature removes the parallel mock path).
- `011-backend-interests-catalog` — server-owned catalog; no client mock fallback in production code.
- `008-aws-deploy-pipeline` — dev/test/prod deploy and smoke targets.
