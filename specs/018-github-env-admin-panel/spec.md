# Feature Specification: Admin panel with environment-configured access and event creation

**Feature Branch**: `018-github-env-admin-panel`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: Implement an admin panel; login and password stored in GitHub environment variables; ability to create events with description, images, and related details.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Operator signs in to the admin panel (Priority: P1)

As an operations team member, I need to sign in to a dedicated admin panel using credentials that are configured securely for each deployment environment, so only authorized staff can manage platform content.

**Why this priority**: Without protected access, event management would be exposed to unauthorized users.

**Independent Test**: Open the admin panel sign-in page, enter valid configured credentials → access granted; enter invalid credentials → access denied with a clear message.

**Acceptance Scenarios**:

1. **Given** valid admin credentials configured for the deployed environment, **When** the operator submits the correct username and password, **Then** the operator reaches the admin panel home (authenticated session).
2. **Given** incorrect credentials, **When** the operator attempts sign-in, **Then** access is denied and no admin functions are available.
3. **Given** an unauthenticated visitor, **When** they try to open admin management pages directly, **Then** they are redirected to sign-in or receive an access-denied response.
4. **Given** deployment configuration, **When** credentials are provisioned, **Then** they are supplied through environment-specific secrets (e.g. GitHub environment variables for CI/CD deploy) and are not stored in the application source repository.

---

### User Story 2 - Operator creates a new event with rich content (Priority: P1)

As an operator, I need to create events in the admin panel with title, description, schedule, location, and images, so mobile and web users see complete, accurate listings in the public app.

**Why this priority**: Core business value—populating the events catalog without developer intervention.

**Independent Test**: Sign in, create an event with required fields plus description and at least one image → event appears in the public events experience for end users.

**Acceptance Scenarios**:

1. **Given** an authenticated admin session, **When** the operator fills required event fields (title, start/end time, city or location) and saves, **Then** a new event is created and visible to end users in the events list.
2. **Given** an authenticated admin session, **When** the operator adds a textual description, **Then** the description is stored and shown on the event detail view in the consumer app.
3. **Given** an authenticated admin session, **When** the operator adds a cover image (and optional additional images if supported), **Then** images are associated with the event and displayed in list/detail views where the consumer app shows event media.
4. **Given** missing or invalid required fields, **When** the operator attempts to save, **Then** the system shows validation errors and does not publish a broken event record.
5. **Given** a successfully created admin event, **When** an end user opens the public app, **Then** the event appears without requiring a separate manual database step.

---

### User Story 3 - Operator reviews and updates existing events (Priority: P2)

As an operator, I need to see events I manage and update their details when information changes, so the catalog stays accurate after initial creation.

**Why this priority**: Events change (time, venue, copy, images); create-only flow is insufficient for ongoing operations.

**Independent Test**: Sign in, open an existing event created via the panel, edit description or image, save → changes reflect in the consumer app.

**Acceptance Scenarios**:

1. **Given** an authenticated admin session, **When** the operator opens the events list in the admin panel, **Then** previously created (and permitted) events are listed with enough summary to identify them.
2. **Given** an existing event, **When** the operator updates description, schedule, location, or images and saves, **Then** the public event views show the updated information.
3. **Given** an event that should no longer be promoted, **When** the operator unpublishes, archives, or rejects it (per product policy), **Then** it no longer appears as an active listing for end users.

---

### Edge Cases

- Admin session expires during long editing → operator must sign in again; unsaved work handled with clear warning where possible.
- Image file too large or unsupported format → validation error before save.
- Image URL unreachable → optional warning or validation depending on policy; event save may still succeed with text-only if cover is optional.
- Duplicate or empty event title → blocked with validation message.
- End time before start time → blocked with validation message.
- Wrong environment credentials (e.g. prod password on dev URL) → sign-in fails; no cross-environment credential leakage.
- Concurrent edits by two operators → last save wins or conflict message (document chosen behavior in plan phase).
- Existing backend moderation flow (pending user-submitted events) may coexist; this feature focuses on **operator-created** events unless extended in plan.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product MUST provide a dedicated **admin panel** separate from the end-user mobile/web sign-in (LinkedIn BFF), for internal operators only.
- **FR-002**: Admin access MUST require a **username and password** validated against values configured for that deployment environment.
- **FR-003**: Admin credentials MUST be provisioned via **deployment environment configuration** (GitHub environment variables / secrets for deploy pipelines); they MUST NOT be committed to source control.
- **FR-004**: Unauthenticated users MUST NOT access event creation, editing, or other management functions.
- **FR-005**: Authenticated operators MUST be able to **create events** with at minimum: title, start time, end time, city/location, and description.
- **FR-006**: Authenticated operators MUST be able to attach at least a **cover image** to an event; additional images MAY be supported if aligned with existing event media model.
- **FR-007**: Optional event attributes supported by the existing events domain (e.g. venue name, capacity, official URL, tags/interests) SHOULD be editable in the panel where they exist in the product data model.
- **FR-008**: Admin-created events MUST become **visible to consumer app users** in the events feed/detail after successful save (default: published/active state unless product policy requires moderation).
- **FR-009**: Operators MUST be able to **list and edit** events they manage through the panel (US3).
- **FR-010**: Failed sign-in attempts MUST NOT reveal whether the username or password was wrong beyond a generic error (security best practice).
- **FR-011**: Admin sessions MUST expire after a reasonable idle period or browser close (exact duration defined in plan; default ≤ 8 hours idle).

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Implementation MUST pass project quality gates (lint, tests, review) with no unresolved critical findings.
- **NFR-SEC-001**: Credentials MUST only exist in secret stores / environment injection; rotation MUST not require code changes.
- **NFR-SEC-002**: Admin panel MUST be served over HTTPS on deployed environments.
- **NFR-TEST-001**: Automated tests MUST cover sign-in success/failure and event create/update happy paths plus validation failures.
- **NFR-UX-001**: Forms MUST show clear validation errors; loading and save confirmation states MUST be consistent with operator expectations.
- **NFR-PERF-001**: Event list and save operations MUST feel responsive for operators (typical form save completes within a few seconds under normal network conditions).

### Validation Requirements *(mandatory)*

- **VR-001**: Deployed environment smoke — sign-in with configured secrets succeeds; wrong password fails.
- **VR-002**: Create event with description + cover image → visible in consumer app events list/detail on same environment.
- **VR-003**: Repository scan — no plaintext admin password in tracked files.
- **VR-004**: CI/deploy docs — GitHub environment variable names documented for operators (in feature quickstart after plan).
- **VR-005**: Automated test suite green for new admin auth and event management flows.

### Key Entities

- **Admin operator**: Person using the panel; authenticated via environment-configured credentials (not end-user OAuth profile).
- **Admin session**: Authenticated state granting access to management functions until expiry or sign-out.
- **Event (admin-managed)**: Public catalog item with title, description, schedule, location, images, and status visible to app users.
- **Deployment credential set**: Username + password (or equivalent) injected per environment (dev/test/prod) from GitHub secrets.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of authorized operator smoke tests complete sign-in and reach the panel on first attempt with correct environment secrets.
- **SC-002**: 100% of test event creations with required fields + description + cover image appear in the consumer app within the same deployment environment without manual DB edits.
- **SC-003**: Zero plaintext admin credentials found in the git repository after implementation review.
- **SC-004**: Operators can create a complete event (required fields + description + image) in under 5 minutes in a guided usability check.
- **SC-005**: Invalid sign-in attempts are rejected 100% of the time in automated and manual security checks.

## Assumptions

- **One admin credential set per deployment environment** (dev, test, prod each has its own username/password—not shared across environments); not a multi-user admin directory.
- **Separate admin runtime per environment**: dedicated container/service on ECS Fargate (alongside the API), not bundled into the consumer web static host.
- **GitHub Environment secrets** (per `dev` / `test` / `prod`) supply admin credentials and deploy inject them into that environment’s admin ECS task (via Secrets Manager)—never committed to source.
- Admin panel is a **web application** on an environment-specific admin hostname (e.g. `admin.dev.example.com`), not inside the Flutter consumer app.
- Event fields align with the **existing backend event model** (title, description, dates, city, venue, cover image URL, etc.); image upload may use existing blob/storage infrastructure or URL entry in v1—plan chooses minimal viable image path.
- Admin-created events publish as **active** immediately; separate moderation APIs for user-submitted pending events remain available but are out of MVP unless explicitly included in plan.
- Consumer Flutter app already reads events from the API; no change to end-user auth required for this feature.
- Language of admin UI may be Ukrainian or English; not blocking for spec (operator-facing).

## Dependencies

- Existing **events API and data model** (`002-backend-api`, event list/detail in consumer app).
- Existing **admin moderation APIs** on backend (approve/reject pending) — complementary, not replaced by this feature.
- **008-aws-deploy-pipeline** — GitHub Actions environments and secrets for dev/test/prod.
- Optional: existing **blob/avatar storage** patterns for image hosting if file upload is chosen over URL-only.
