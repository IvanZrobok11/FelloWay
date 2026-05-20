# Feature Specification: Connectivity SnackBar

**Feature Branch**: `010-connectivity-snackbar`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User description: "Створи сервіс та кастомізований віджет SnackBar для Flutter, який делікатно сповіщає користувача про відсутність інтернету або недоступність бекенду при спробі виконати дію."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Understand why an action failed (Priority: P1)

A signed-in user taps a button that triggers a server request (save profile, join trip, send message, etc.). The device has no internet connection, or the server cannot be reached. Instead of silence or a cryptic technical error, a short floating notification appears explaining that the action is unavailable because of connectivity.

**Why this priority**: Without clear feedback, users assume the app is broken or their tap did nothing; this is the core value of the feature.

**Independent Test**: Turn off network (or block API host), trigger any action that calls the backend, and confirm the standardized connectivity notification appears with the agreed message and icon.

**Acceptance Scenarios**:

1. **Given** the user is on any screen with a scaffold and taps an action that fails due to no network, **When** the failure is handled by the connectivity notification entry point, **Then** a single floating notification appears with the offline/connectivity message and a connectivity-related icon.
2. **Given** the user is on any screen and taps an action while the backend is unreachable (timeout, connection refused, no response), **When** the failure is classified as connectivity-related and the entry point is invoked, **Then** the same standardized notification appears (same copy and treatment as offline).
3. **Given** a connectivity notification is visible, **When** the auto-dismiss timer elapses (3–4 seconds), **Then** the notification disappears without blocking further interaction.

---

### User Story 2 - Dismiss without waiting (Priority: P2)

The user sees the connectivity notification but wants to continue using the screen immediately without the banner covering content.

**Why this priority**: Reduces annoyance on repeated failures and respects user control; supports the “delicate” UX goal.

**Independent Test**: Show the notification, tap the close control, verify it hides before the timer ends.

**Acceptance Scenarios**:

1. **Given** a connectivity notification is shown, **When** the user taps the close control, **Then** the notification is dismissed immediately.
2. **Given** the user dismissed the notification, **When** they perform another failing action, **Then** a fresh notification can appear (not blocked by the previous dismiss).

---

### User Story 3 - Rapid repeated actions do not stack notifications (Priority: P2)

A user taps “Retry” or the same action several times while still offline. Only one notification should be visible at a time—no queue of identical banners.

**Why this priority**: Prevents visual clutter and matches existing patterns where duplicate snack bars degrade UX.

**Independent Test**: Invoke the show entry point five times within one second; assert at most one notification is visible and the latest message is shown.

**Acceptance Scenarios**:

1. **Given** a connectivity notification is already visible or queued, **When** the show entry point is called again, **Then** any prior connectivity notifications are cleared before the new one is shown.
2. **Given** the user triggers multiple failing API actions in quick succession, **When** each handler invokes the connectivity notification, **Then** the user never sees more than one connectivity banner at once.

---

### User Story 4 - Simple integration for action handlers (Priority: P3)

A developer handling errors from API calls can trigger the connectivity notification with one call from a `catch` or error branch when the failure is connectivity-related, without duplicating layout or timing logic.

**Why this priority**: Adoption across trips, profile, chats, and auth flows depends on a single reusable entry point.

**Independent Test**: From a sample button’s error handler, call the static show method with a valid context; widget test asserts snack bar content and behavior.

**Acceptance Scenarios**:

1. **Given** a `BuildContext` under a `Scaffold`, **When** the developer calls the connectivity notification show API once, **Then** the notification appears with the prescribed layout and duration without additional boilerplate.
2. **Given** a non-connectivity error (validation, 403, business rule), **When** the handler does not invoke the connectivity entry point, **Then** this feature does not alter existing error snack bars.

---

### Edge Cases

- **No scaffold in context**: Show API is only used where `ScaffoldMessenger` is available (same constraint as existing snack bars); callers must use a context from a routed page with scaffold—document in integration guidance, no crash.
- **Rapid taps**: Multiple invocations within milliseconds only produce one visible banner (clear-before-show).
- **Localization**: Message and semantics are available in Ukrainian and English to match the rest of the app.
- **Light and dark app theme**: Dark charcoal background maintains readable contrast for white icon and text on both theme modes.
- **Web vs mobile**: Behavior is identical wherever Material scaffold snack bars are used.
- **Concurrent with other snack bars**: Clearing applies to connectivity notifications only if implemented as “clear all snack bars” before show—user accepts replacing any current snack bar when connectivity fires (document as intentional to avoid stacking).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product MUST provide a reusable connectivity notification that can be triggered when a user-initiated action fails due to lack of network or unreachable backend.
- **FR-002**: The notification MUST use a floating style (not edge-locked to the bottom of the screen), with rounded corners (approximately 12 logical pixels radius), and a dark charcoal background that contrasts with typical app surfaces.
- **FR-003**: The notification content MUST display, left to right: a connectivity-related icon (offline/wifi or cloud-unavailable metaphor), spacing, then primary text stating that the action is unavailable due to no internet (localized; default copy in Ukrainian: «Дія недоступна. Немає інтернету.» and equivalent English for EN locale).
- **FR-004**: Icon and text MUST use light colors (white or light gray) for readability on the dark background.
- **FR-005**: The notification MUST include a manual dismiss control (close affordance) that hides it immediately without waiting for the timer.
- **FR-006**: The notification MUST auto-dismiss after a visible duration between 3 and 4 seconds (inclusive).
- **FR-007**: Before showing a new connectivity notification, the system MUST clear any existing snack bars on the same scaffold messenger so repeated failures do not queue multiple banners.
- **FR-008**: The product MUST expose a single static entry point (e.g. `show(BuildContext context)`) so feature code can invoke it from API error handlers with minimal code.
- **FR-009**: The feature MUST NOT replace or change generic error messages for non-connectivity failures; scope is limited to connectivity/backend-unreachable cases when explicitly invoked.
- **FR-010**: Strings MUST be externalized for localization (Ukrainian and English) consistent with existing app l10n.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Code changes MUST satisfy linting/formatting/static analysis requirements with no unresolved critical findings.
- **NFR-TEST-001**: Automated tests MUST cover core flows and regressions for bugs addressed by this feature.
- **NFR-UX-001**: The notification MUST feel unobtrusive (“delicate”): floating, short duration, dismissible, and visually aligned with the app’s existing floating snack bar theme where applicable.
- **NFR-PERF-001**: Showing the notification MUST not block the UI thread or delay navigation; display latency perceived as immediate (&lt; 100 ms after invoke under normal conditions).
- **NFR-FLUTTER-001**: Flutter changes MUST pass `flutter analyze` and formatting checks before merge.
- **NFR-FLUTTER-TEST-001**: Widget tests MUST verify layout elements (icon, message, close action), floating behavior, duration bounds, and clear-before-show when multiple invocations occur.
- **NFR-FLUTTER-UX-001**: Visual design MUST remain consistent with Material-style floating snack patterns already used in the app theme.
- **NFR-FLUTTER-PERF-001**: No measurable impact on frame rate during show/dismiss; no additional network or background work.

### Validation Requirements *(mandatory)*

- **Quality gates**: `flutter analyze`, `dart format --set-exit-if-changed`, and project CI Flutter job green.
- **Test evidence**: Unit/widget tests for `ConnectivitySnackBar` (or equivalent) show method; optional golden test for snack bar appearance if team adopts goldens for shared widgets.
- **UX acceptance**: Design review confirms floating shape, dark background, icon+text+close layout, and copy in both locales.
- **Performance**: Manual smoke on mid-tier device—tap failing action 10 times; no jank, single banner.
- **Flutter verification**: `flutter test` for new tests; manual offline smoke on one mobile and web target documented in feature quickstart after implementation.

### Key Entities

- **Connectivity notification**: Ephemeral UI feedback bound to a screen’s scaffold messenger; attributes: message copy, icon choice, duration, dismiss action, visual style.
- **Show invocation**: One-shot trigger from an action’s error path when failure is classified as connectivity-related (`NetworkFailure`, connection timeout, no host, etc.—exact mapping left to implementation plan).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In moderated usability checks, at least 90% of participants correctly identify that their action failed due to connectivity (not an app bug) after seeing the notification once.
- **SC-002**: When users trigger five consecutive failing actions within 10 seconds while offline, they never see more than one connectivity banner at a time.
- **SC-003**: Users can dismiss the notification via the close control in under 2 seconds from when it appears, without using system back or leaving the screen.
- **SC-004**: After feature adoption in at least three existing API-driven flows (e.g. profile save, trip action, chat-related action), support-style “button does nothing” reports for offline scenarios decrease or use consistent wording in internal QA notes within one release cycle.
- **SC-005**: Developers can add connectivity feedback to a new action handler with a single show call plus connectivity error detection, without copying UI layout code.

## Assumptions

- The FelloWay client is a Flutter application using Material scaffold snack bars; existing app theme already defines floating snack bar shape and dark brand background—this feature extends that pattern with dedicated connectivity content and service API.
- One unified message covers both “no internet” and “backend unreachable” unless product later splits copy; user-specified single string applies to both cases.
- Primary icon default is “wifi off” metaphor; “cloud off” is acceptable alternative if design prefers backend emphasis—no separate user-facing variants in v1.
- Callers are responsible for detecting connectivity-type failures (e.g. `NetworkFailure` without HTTP body, `DioExceptionType.connectionError`, timeouts) before invoking show; retrofitting all screens is follow-up work outside minimal v1 delivery (service + widget + l10n + tests + 1–2 reference integrations).
- English copy for EN locale will be along the lines of “Action unavailable. No internet connection.” (exact wording finalized during implementation/l10n review).
- Duration default is 4 seconds within the 3–4 second requirement unless UX review prefers 3 seconds.

## Dependencies

- Existing `ScaffoldMessenger` / scaffold structure on feature screens.
- Existing localization pipeline (`app_en.arb`, `app_uk.arb`).
- Existing `AppFailure` / `NetworkFailure` and API client error mapping for classification guidance in plan/tasks phase.
