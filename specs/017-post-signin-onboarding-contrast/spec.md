# Feature Specification: Post-sign-in routing and readable onboarding/event text

**Feature Branch**: `017-post-signin-onboarding-contrast`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User description: After first sign-in, route to name onboarding or events (not welcome); fix text contrast on onboarding name/city inputs and event surfaces (dark on white, white on brown).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Smart destination after first sign-in (Priority: P1)

As a user who just signed in for the first time (or returned after sign-in), I want to land on the right screen immediately—name setup if I have no display name, or the events feed if I already have one—without being sent to the generic welcome screen first.

**Why this priority**: The welcome step adds friction and misroutes users who already have a profile name; it blocks access to the main app value (events).

**Independent Test**: Sign in with an account that has no display name → user sees the name onboarding screen. Sign in with an account that already has a display name → user sees the events list. Neither path shows the welcome screen as the first post-sign-in destination.

**Acceptance Scenarios**:

1. **Given** an authenticated user with no display name saved on their profile, **When** sign-in completes, **Then** the app opens the name onboarding step (not the welcome screen).
2. **Given** an authenticated user with a non-empty display name on their profile, **When** sign-in completes, **Then** the app opens the events feed (not the welcome screen).
3. **Given** a user who completes sign-in from the sign-in page, **When** navigation resolves, **Then** the welcome onboarding screen is not used as the default post-sign-in landing (unless the user navigates there manually from within onboarding).

---

### User Story 2 - Readable name entry on onboarding (Priority: P2)

As a user entering my name during onboarding, I need the text I type to be clearly visible (dark text on a light input background) so I can read and correct what I entered.

**Why this priority**: Illegible input text blocks onboarding completion and affects all new users.

**Independent Test**: Open the name onboarding step, type in the name field on a light/white background → typed characters appear in a dark, readable color.

**Acceptance Scenarios**:

1. **Given** the name onboarding step with a white or light input background, **When** the user types characters in the name field, **Then** the entered text is displayed in a dark color with sufficient contrast to read easily.
2. **Given** the name field label and hint (if shown), **When** displayed on a light background, **Then** they remain readable per the same contrast expectation.

---

### User Story 3 - Readable city selection on onboarding (Priority: P2)

As a user choosing my home city during onboarding, I need city names and related labels to appear in a dark color on a light background so I can scan and select the correct city.

**Why this priority**: Same accessibility issue as the name step; city selection is mandatory for profile completion.

**Independent Test**: Open the city onboarding step → city list and selection labels use dark text on white/light surfaces.

**Acceptance Scenarios**:

1. **Given** the city onboarding step on a light/white background, **When** the list of cities is shown, **Then** city names use a dark text color readable on that background.
2. **Given** a selected or highlighted city row on a light background, **When** the user views the row, **Then** text remains dark and readable (selection state must not reduce contrast below acceptable readability).

---

### User Story 4 - Correct event text contrast by background (Priority: P2)

As a user browsing events, I need event titles and related text to use colors that match the surface behind them—light text on brown/dark areas and dark text on white/light areas—so event information is always legible.

**Why this priority**: Event cards mix brown and white regions; wrong text color makes events hard to read.

**Independent Test**: View event list and event detail → text on brown regions is light; text on white regions is dark.

**Acceptance Scenarios**:

1. **Given** an event card or detail section with a brown (or dark brand) background, **When** event text (title, metadata, etc.) is shown on that region, **Then** the text color is light (e.g. white or near-white) for readable contrast.
2. **Given** an event card or detail section with a white or light background, **When** event text is shown on that region, **Then** the text color is dark (e.g. black or near-black) for readable contrast.
3. **Given** a single event UI that uses both brown and white areas, **When** the user views it, **Then** each text block follows the contrast rule for its local background without relying on a single global text color.

---

### Edge Cases

- User has a display name from the identity provider but has not finished interests/city onboarding: after sign-in they land on events per this feature; any remaining mandatory profile steps are handled by existing profile/onboarding guards (if any), not by forcing welcome first.
- User signs in on web via OAuth return URL: post-auth navigation must apply the same name-vs-events rule once the session is established.
- User refreshes the app mid-onboarding: routing should not send them to welcome if they already have a name; incomplete steps may resume from the appropriate onboarding screen.
- Empty or whitespace-only display name is treated as “name not set.”
- Dark mode or system high-contrast settings: minimum requirement is correct pairing on the designed light onboarding surfaces and brown/white event layouts described above.
- Very long event titles or city names: text remains readable within its contrast region (truncation/wrapping unchanged unless needed for readability).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: After successful sign-in, the app MUST route users with no display name to the name onboarding step instead of the welcome onboarding step.
- **FR-002**: After successful sign-in, the app MUST route users with a non-empty display name to the events feed instead of the welcome onboarding step.
- **FR-003**: The welcome onboarding step MUST NOT be the automatic default landing route immediately after sign-in for authenticated users (unless explicitly chosen later in the flow).
- **FR-004**: On the name onboarding step, text entered in the name input on a light/white background MUST render in a dark, readable color.
- **FR-005**: On the city onboarding step, city names and primary list labels on a light/white background MUST render in a dark, readable color.
- **FR-006**: On event list and event detail presentations, text on brown (or designated dark brand) backgrounds MUST use a light text color.
- **FR-007**: On event list and event detail presentations, text on white (or light) backgrounds MUST use a dark text color.
- **FR-008**: Contrast fixes MUST apply consistently across sign-in entry points that establish an authenticated session (e.g. sign-in page and OAuth return flow).

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Changes MUST satisfy project linting and static analysis with no new critical findings.
- **NFR-TEST-001**: Automated tests MUST cover post-sign-in routing (name missing vs present) and widget/golden coverage for contrast on name, city, and event surfaces where visual regression is applicable.
- **NFR-UX-001**: Text/background pairings MUST meet readable contrast for typical mobile and web viewing (target WCAG 2.1 contrast ratio ≥ 4.5:1 for normal body text where feasible).
- **NFR-PERF-001**: Routing and styling changes MUST NOT add noticeable delay to sign-in or screen transitions.
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Widget or golden tests MUST guard name/city input text color and event card text on brown vs white regions.
- **NFR-FLUTTER-UX-001**: Styling MUST use existing theme/design tokens where possible rather than one-off colors that diverge from the design system.
- **NFR-FLUTTER-PERF-001**: No additional network calls solely for routing; use existing profile/session data already loaded at sign-in.

### Validation Requirements *(mandatory)*

- **VR-001**: Manual smoke on deployed dev — new user (no name) sign-in → name onboarding; returning user (with name) sign-in → events; no welcome as first screen.
- **VR-002**: Manual check — type in name field and verify dark text on white input; scan city list for dark labels on white.
- **VR-003**: Manual check — event list/detail: white text on brown areas, dark text on white areas.
- **VR-004**: `flutter test` and `flutter analyze` green on touched packages.
- **VR-005**: Golden tests updated or added for event card and onboarding inputs if already in golden suite.

### Key Entities

- **Display name**: User-visible name on profile; empty means user must complete name onboarding.
- **Onboarding progress**: Client-side record of completed onboarding steps (separate from display name presence).
- **Post-sign-in route**: Destination screen chosen immediately after authentication succeeds.
- **Event surface**: Visual regions on event cards/details classified as dark (brown) or light (white) for text color rules.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of manual sign-in smoke cases land on name onboarding (no name) or events (has name), with zero cases defaulting to welcome immediately after sign-in.
- **SC-002**: 100% of checked name and city onboarding text samples on light backgrounds pass visual readability review (dark text visible while typing and in lists).
- **SC-003**: 100% of checked event UI samples show correct light-on-dark and dark-on-light text pairing on brown and white regions respectively.
- **SC-004**: No increase in onboarding abandonment due to unreadable inputs (qualitative: QA sign-off on contrast fixes).
- **SC-005**: Automated test suite includes at least one regression test per routing rule (name missing vs present) and visual/contrast checks for event and onboarding screens touched by this feature.

## Assumptions

- “Display name not set” means empty or whitespace-only value on the user profile returned after sign-in (including provider-supplied name if already synced).
- Users with a name but incomplete interests/city may still reach events first; any enforcement of remaining profile fields follows existing product rules outside this spec’s primary routing change.
- The welcome onboarding screen may remain in the app for optional/marketing use but is deprioritized as the post-sign-in entry.
- Brown background refers to the existing brand/dark surface used on event cards; white background refers to light surfaces on those same screens and onboarding steps.
- Scope is the Flutter client UI and navigation; backend profile fields already exist (`displayName` on user profile).

## Dependencies

- Existing authentication and profile APIs (LinkedIn BFF / session after `015`/`016` live-only policy).
- Existing onboarding routes: welcome, name, interests, city.
- Existing events list and event detail screens.
