# Feature Specification: Backend Interests Catalog

**Feature Branch**: `011-backend-interests-catalog`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User description: "На бекенді повинен бути список інтересів, де кожен повинен мати свій id. Відображення на /onboarding/interests та в профілі користувача; не зберігати локально на клієнті."

## Clarifications

### Session 2026-05-20

- Q: Should the Flutter client embed the canonical ten-interest catalog (e.g. `mockCatalog` in `InterestsRepository`)? → A: **No.** Live/staging builds load the catalog only via `GET /interests`. The client may keep an in-memory session cache after a successful fetch. Demo/mock mode may simulate the same API response shape in test fixtures (`MockApiCatalog`) but must not be the product source of truth or a fallback when the network call fails.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse official interest options (Priority: P1)

A new or returning user opens the onboarding interests step (`/onboarding/interests`) and sees the same professional interest categories the product defines, each selectable as a chip or similar control. The list is loaded from the server, not from a hardcoded list in the app.

**Why this priority**: Without a server-owned catalog, onboarding and profile cannot stay in sync across platforms or after app updates.

**Independent Test**: Call the public interests catalog endpoint (or open onboarding with API available) and verify exactly ten interests are returned, each with a stable id and display name.

**Acceptance Scenarios**:

1. **Given** the catalog endpoint is available, **When** the client requests the interest list, **Then** the response contains exactly ten items, each with a unique stable identifier and a human-readable name.
2. **Given** the user opens `/onboarding/interests`, **When** the page loads successfully, **Then** all ten catalog names appear and match the server list order or sort defined by the product.
3. **Given** the catalog cannot be loaded, **When** the user opens `/onboarding/interests`, **Then** the user sees a clear error or retry state (not a silent fallback to a stale local list).

---

### User Story 2 - Save selected interests to the user profile (Priority: P1)

During onboarding (and later in profile edit), the user selects one or more interests. On continue or save, only valid catalog identifiers are sent to the user profile on the server. The client does not treat free-text labels as the source of truth.

**Why this priority**: Profile matching, events, and trust features depend on normalized interest ids stored per user.

**Independent Test**: Complete onboarding with two interests selected; verify `GET` profile returns the same two ids and rejecting an unknown id on update returns a validation error.

**Acceptance Scenarios**:

1. **Given** the user selects at least one interest on `/onboarding/interests`, **When** they continue onboarding and complete profile setup, **Then** the stored user profile contains only ids from the official catalog.
2. **Given** the user selects interests, **When** the profile is saved, **Then** no interest data is persisted only in local device storage as the authoritative copy (local draft may exist temporarily until submit).
3. **Given** a client sends an interest id not in the catalog, **When** the profile update is processed, **Then** the request is rejected with a clear validation outcome and the profile is not partially corrupted.

---

### User Story 3 - View interests on profile (Priority: P2)

An authenticated user opens their profile and sees the names of their selected professional interests (resolved from the catalog), not raw identifiers or comma-separated free text.

**Why this priority**: Profile is the primary place users confirm what they shared during onboarding.

**Independent Test**: User with two interests saved opens profile; UI shows two readable labels consistent with catalog names.

**Acceptance Scenarios**:

1. **Given** the user has interests saved on the server, **When** they view their profile, **Then** each selected interest is shown by display name (Ukrainian catalog labels unless locale-specific naming is added later).
2. **Given** the user has no interests selected, **When** they view profile, **Then** the interests section indicates empty state or omits chips without showing misleading defaults.
3. **Given** the user edits profile interests, **When** they save, **Then** the same catalog-driven selection UI as onboarding is used and changes persist on the server.

---

### User Story 4 - Stable catalog for discovery and admin (Priority: P3)

Product and support can refer to interests by stable id (e.g. in analytics, moderation, or future event tagging). The catalog content is versioned on the server; replacing dev-only placeholder interests (e.g. technology stack names) with the business domain list below.

**Why this priority**: Existing seed data does not match product intent; ids must remain stable once published.

**Independent Test**: Fresh environment seed or migration yields the ten defined interests; repeated deploys do not duplicate rows.

**Acceptance Scenarios**:

1. **Given** a fresh database seed, **When** the catalog is queried, **Then** the ten canonical interests exist with distinct ids.
2. **Given** the catalog is updated in a new release, **When** ids are unchanged for existing names, **Then** existing user selections remain valid.

---

### Edge Cases

- **Offline onboarding**: User cannot load catalog — show retry; do not invent a local master list that diverges from server.
- **Partial locale**: Catalog names are Ukrainian in v1; English UI may show the same labels or mapped copy in a follow-up without changing ids.
- **Legacy users**: Users linked to removed placeholder interests (old seed) — migration or re-prompt to pick from new catalog.
- **Duplicate selection**: UI prevents duplicate ids; server rejects duplicate ids in one request if sent.
- **Maximum selection**: No hard maximum in v1 unless product adds one; at least one interest required to continue onboarding (existing rule).
- **Profile edit free text**: Comma-separated interest text field is replaced by catalog chips, not dual mode.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose a read-only catalog of professional interests, each with a stable unique identifier and a display name.
- **FR-002**: The canonical catalog MUST contain exactly these ten interests (display names as product copy):

  | # | Display name (UK) |
  |---|-------------------|
  | 1 | ІТ та розробка |
  | 2 | Маркетинг/Продажі |
  | 3 | HR та рекрутинг |
  | 4 | Дизайн та візуалізація |
  | 5 | Освіта та навчання |
  | 6 | Здоров'я та медицина |
  | 7 | Розвиток бізнесу |
  | 8 | Логістика та ритейл |
  | 9 | Інвестиції та фінанси |
  | 10 | Мілітарі |

- **FR-003**: The system MUST persist user-selected interests on the user profile by reference to catalog identifiers only (not free-text labels as the stored value).
- **FR-004**: The onboarding interests screen (`/onboarding/interests`) MUST load options from `GET /interests` (via a repository that calls the API) and MUST NOT use a fixed client-only list as the source of truth. Constants duplicating FR-002 names/ids in Flutter production code are forbidden; offline/error states show retry, not a baked-in master list.
- **FR-005**: The user profile view MUST display selected interests using catalog display names (resolved via catalog or enriched profile response).
- **FR-006**: Profile edit MUST allow changing interests using the same catalog-driven selection pattern as onboarding.
- **FR-007**: The system MUST reject profile updates that include unknown or invalid interest identifiers.
- **FR-008**: Placeholder/dev interests (e.g. technology stack names used only for early seeding) MUST be removed or migrated so the production catalog matches FR-002.
- **FR-009**: The catalog endpoint MUST be callable without authentication for onboarding, or with the same access policy as other reference data documented in the plan phase.
- **FR-010**: Interest selection during onboarding MUST still require at least one interest before continuing (preserve existing completion rule).

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover catalog contents, invalid id rejection, and client mapping of ids to labels.
- **NFR-UX-001**: Loading and error states on onboarding and profile MUST follow existing app patterns (loading indicator, retry, accessible labels).
- **NFR-PERF-001**: Catalog load MUST feel instantaneous on repeat visits (caching allowed); first load within typical mobile network expectations (&lt; 2 s perceived).
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Widget or unit tests MUST verify onboarding and profile render catalog-driven chips when mock API returns the ten items.
- **NFR-FLUTTER-UX-001**: Chip selection MUST remain consistent with existing Material filter-chip onboarding pattern.
- **NFR-FLUTTER-PERF-001**: Client MAY cache catalog in memory for the session after a successful `GET /interests`; MUST refresh from server on cold start or explicit retry (never promote cache to master list when the server is unreachable).

### Validation Requirements *(mandatory)*

- **Quality gates**: Backend and frontend CI green; OpenAPI contract updated if new endpoint is added.
- **Test evidence**: API test asserts ten interests; Flutter test asserts onboarding uses API list; profile shows names not raw ids.
- **UX acceptance**: Manual walkthrough onboarding → profile shows same selections in Ukrainian labels.
- **Performance**: Catalog endpoint p95 within team API budget (documented in plan).
- **Verification**: Fresh DB seed + onboarding on web and one mobile target.

### Key Entities

- **Interest (catalog item)**: Stable id, display name; optional sort order for UI.
- **User profile interests**: Set of references to catalog interest ids (many-to-many with user).
- **Onboarding draft**: Temporary selection of interest ids until profile is submitted (not authoritative storage).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of successful catalog API responses in QA contain exactly ten interests with unique ids and names matching FR-002.
- **SC-002**: 95% of test users completing onboarding have only catalog ids stored on their profile (zero free-text-only interest rows in QA sample).
- **SC-003**: Users viewing profile see readable interest names (not uuid strings) in 100% of QA cases where interests are set.
- **SC-004**: Zero production reliance on hardcoded `_interestOptions`, `mockCatalog`, or equivalent Flutter constants as the master list after release; catalog labels and ids in UI come from `GET /interests` or enriched profile responses.
- **SC-005**: Invalid interest id on profile update is rejected in automated API tests with 100% consistency.

## Assumptions

- Existing data model (`interests` table, `user_interests`, profile `interestIds`) is reused; work focuses on seed/catalog API and client integration.
- Stable identifiers are server-generated and immutable per interest row once published (e.g. UUID), exposed to clients as opaque ids.
- Display names in FR-002 use Ukrainian as the server-side label for v1; item 4 uses «Дизайн та візуалізація» (corrected from user typo «на»).
- Onboarding draft in local storage may hold selected ids until submit but MUST be synced to the server on profile creation/update.
- OpenAPI and generated Dart client will be updated as part of implementation (out of spec detail).
- Event discovery `interest` query parameter remains separate; mapping event tags to catalog ids is out of scope unless already linked.

## Dependencies

- User profile create/update API already accepting `interestIds`.
- Onboarding flow routes: `/onboarding/interests`, profile routes.
- Database seed/migration pipeline for reference data.
- Flutter live API mode (not mock-only) for end-to-end verification.
