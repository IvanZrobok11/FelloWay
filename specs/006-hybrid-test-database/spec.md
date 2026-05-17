# Feature Specification: Hybrid Database Strategy for API Tests

**Feature Branch**: `006-hybrid-test-database`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Api tests can use in-memory database, but test environment should use real database

## Summary

Establish a **two-tier testing model** for the backend API: fast automated tests that do not require an external database, and integration tests that run the application in the **Testing** environment against a **real** data store (same initialization and behavior as non-production deployments). This reduces friction for daily development while keeping confidence that SQL, constraints, and startup initialization work in production-like conditions.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Fast local test runs (Priority: P1)

As a developer, I want to run the default API test suite without installing or configuring PostgreSQL so I get quick feedback on controllers, auth, and business rules during everyday work.

**Why this priority**: Blocks contributors when every test requires Docker or a local server.

**Independent Test**: Run the fast test suite on a clean machine with no database service; all tests pass in under two minutes.

**Acceptance Scenarios**:

1. **Given** no external database is running, **When** the developer runs the default API test command, **Then** tests complete successfully using an isolated in-process data store.
2. **Given** the fast suite, **When** tests finish, **Then** no persistent data remains on the developer machine from that run.
3. **Given** a failing test, **When** the developer re-runs a single test class, **Then** startup time is acceptable for iterative debugging (under 30 seconds for a focused run).

---

### User Story 2 — Real database integration for Testing environment (Priority: P1)

As a maintainer, I need tests that exercise the **Testing** environment with a **real** database so schema creation, seeding rules, health checks, and data access behave like staging—not like an in-memory substitute.

**Why this priority**: In-memory stores hide provider-specific failures (constraints, transactions, connection pooling, startup order with background jobs).

**Independent Test**: Run the integration test suite with Testing environment + real database configured; health readiness and representative CRUD flows pass.

**Acceptance Scenarios**:

1. **Given** a configured real test database, **When** the application starts with environment **Testing**, **Then** database initialization runs (schema present, non-production seed policy applied).
2. **Given** integration tests against the real store, **When** `GET /health/ready` is called with a healthy database, **Then** the response indicates ready.
3. **Given** integration tests, **When** a test intentionally uses an unreachable database, **Then** readiness reports not ready without crashing unrelated suites.
4. **Given** parallel integration runs, **When** each run uses isolated data, **Then** tests do not corrupt each other’s data.

---

### User Story 3 — Clear suite separation in CI and docs (Priority: P2)

As a team lead, I want CI and README to distinguish **fast** vs **integration** tests so pipelines stay fast on every PR while nightly or pre-merge jobs validate the real database path.

**Why this priority**: Prevents either skipping real-DB coverage or slowing every commit.

**Independent Test**: Documentation lists two commands/filters; CI configuration runs fast on PR and integration on schedule or labeled jobs.

**Acceptance Scenarios**:

1. **Given** project documentation, **When** a new contributor reads testing instructions, **Then** they know which command needs PostgreSQL and which does not.
2. **Given** CI, **When** a pull request builds, **Then** the fast suite runs without external database services.
3. **Given** CI integration job, **When** it runs, **Then** it provisions or connects to a real database and runs only integration-tagged tests.

---

### Edge Cases

- Developer has PostgreSQL running but runs fast suite — in-memory tests must not accidentally connect to shared local databases.
- Integration suite run without database — fails fast with a clear message (not opaque connection timeouts).
- Schema/model drift — integration failures should point to initialization or migration mismatch.
- Tests that need both speed and SQL fidelity — classified as integration, not forced into in-memory.
- Unavailable-database scenarios remain isolated and do not require a real server to be down globally.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The API test project MUST support an **in-memory** data store for the default/fast test suite.
- **FR-002**: The default test suite MUST NOT require an external database service to pass.
- **FR-003**: A separate **integration** test suite MUST run the application with environment **Testing** against a **real** database.
- **FR-004**: **Testing** environment startup MUST apply the same database initialization policy as other non-production environments (schema ensure/create, non-production seeding rules).
- **FR-005**: Integration tests MUST use **isolated** database instances or databases per run to avoid cross-test pollution.
- **FR-006**: Tests that validate readiness when the database is unavailable MUST remain independent of the fast in-memory suite.
- **FR-007**: Documentation MUST describe how to run fast vs integration suites locally and in CI.
- **FR-008**: Test categorization (attributes, filters, or projects) MUST make suite selection explicit and discoverable.
- **FR-009**: Fast in-memory tests MUST still validate HTTP endpoints, auth flows, and core business rules at the API boundary where SQL fidelity is not required.
- **FR-010**: Integration tests MUST cover at least health readiness and one representative authenticated data path (e.g. profile or events read).

### Non-Functional Requirements

- **NFR-001**: Default/fast suite on a typical dev laptop completes in **under 2 minutes**.
- **NFR-002**: Integration suite failure messages MUST state that a real database is required when misconfigured.
- **NFR-003**: No production database or production seed data may be used by either suite.

### Key Entities

- **Fast test suite**: In-memory, no external DB, daily developer use.
- **Integration test suite**: Testing environment + real DB, CI/pre-release.
- **Testing environment**: Named deployment profile with real persistence and non-production seed policy.
- **Test host factory**: Configures environment and data store per suite type.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: **100%** of default/fast API tests pass on a machine with **no** database service installed.
- **SC-002**: **100%** of integration tests pass when a real test database is available and documented setup is followed.
- **SC-003**: Contributors can identify which suite to run from documentation in **under 1 minute** (two commands, clearly labeled).
- **SC-004**: CI pull-request pipeline runs fast suite without database provisioning; integration coverage runs in a defined job at least once per merge cycle.
- **SC-005**: Zero reported incidents of fast tests mutating a developer’s shared local application database after this feature ships.

## Assumptions

- PostgreSQL (or the project’s chosen production data store) remains the **real** database for integration and non-production environments.
- Existing `Testing` environment name is retained for integration hosts.
- `FelloWay.Application.Tests` remains unit-focused and is out of scope unless affected by shared initialization.
- Docker/Testcontainers or a CI service container may provision the real database for integration jobs; choice is an implementation detail.
- Current behavior that forces all API tests through PostgreSQL is replaced by this hybrid model.

## Out of Scope

- Changing production database initialization policy.
- Replacing EF with another ORM.
- Full end-to-end tests through the Flutter client.
- Performance/load testing against large datasets.
- Migrating from `EnsureCreated` to migration-based deploy (separate feature if needed).
