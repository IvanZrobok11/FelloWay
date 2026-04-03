# Feature Specification: Event Networking Mobile MVP

**Feature Branch**: `001-event-networking-app`  
**Created**: 2026-04-01  
**Status**: Draft  
**Input**: User description: "Build flutter mobile application based on @PRD_Event_Networking.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Join and Discover Events (Priority: P1)

As an attendee, I want to sign in quickly, complete a profile, browse relevant
work conferences, and join an event so I can start networking before arrival.

**Why this priority**: This is the entry point for all value; without onboarding
and event participation, chat and networking features cannot be used.

**Independent Test**: A new user can complete onboarding, view event cards,
open event details, join an event, and see joined status in one session.

**Acceptance Scenarios**:

1. **Given** a first-time user opens the app, **When** they choose **Get started**
   on the welcome screen, complete mandatory onboarding fields **locally** (S2–S4),
   then sign in successfully on `/sign-in`, **Then** the client syncs profile to
   the backend when needed (`GET /users/me` then conditional `PUT /users/me`) and
   they reach the event list with personalized ordering.
2. **Given** a user is on the welcome screen, **When** they choose **Log in**,
   **Then** they are taken to the OAuth sign-in screen and, after successful
   authentication, routed according to session and onboarding completion state.
3. **Given** a signed-in user opens an event card, **When** they select "Join",
   **Then** their participation status updates immediately and they are added to
   the event participant set.
4. **Given** a guest user opens an event card, **When** they attempt to join,
   **Then** they are prompted to authenticate before participation is allowed.

---

### User Story 2 - Communicate with Event Participants (Priority: P2)

As an event participant, I want access to event chat spaces and direct messages
so I can coordinate with other attendees before and during the event.

**Why this priority**: Communication is the core product promise and depends on
the event participation established in User Story 1.

**Independent Test**: A joined participant can access event chat, send direct
messages to other participants, and observe access restrictions after unjoining.

**Acceptance Scenarios**:

1. **Given** a user has joined an event, **When** they open chats, **Then** they
   can access the event-wide chat and message other event participants directly.
2. **Given** a user cancels event participation, **When** they return to chats,
   **Then** event and trip chat access is removed while existing direct message
   history remains visible in read-only mode.
3. **Given** a user views an event participant, **When** they initiate direct
   messaging, **Then** a direct conversation is created or reopened.

---

### User Story 3 - Coordinate Travel in Local Trip Chats (Priority: P3)

As an event participant, I want to find or create travel-specific local chats so
I can coordinate rides with people from my city or route.

**Why this priority**: This delivers the differentiating value of travel-based
networking once baseline event participation and communication are available.

**Independent Test**: A joined participant can view trip chats, request entry,
receive auto/manual approval by city rule, and participate in multiple trip
chats for one event.

**Acceptance Scenarios**:

1. **Given** a participant opens the trip section, **When** they view available
   chats, **Then** route and departure details are visible while participant
   membership remains hidden until approval.
2. **Given** a participant requests to join a trip chat, **When** their home city
   matches the chat city, **Then** access is granted automatically.
3. **Given** a participant requests to join from another city, **When** the chat
   owner approves, **Then** the participant gains chat access and member profiles
   become visible within that chat.

### Edge Cases

- User starts onboarding but skips mandatory interests or home city selection.
- User loses session while submitting join/unjoin actions for an event.
- Event reaches participant or trip-chat capacity limits.
- User is blocked by another participant after a conversation starts.
- Multiple join requests exist for the same trip chat with delayed owner action.
- User has low rating and requests entry to a trip chat.
- Event is archived after users have active chat conversations.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow users to sign in through approved social
  identity providers only.
- **FR-002**: The system MUST require completion of onboarding fields (display
  name, interests/hobbies, and home city) before full app access.
- **FR-003**: The system MUST present event listings with pagination and allow
  search by event name, topic tag, and city.
- **FR-004**: The system MUST prioritize event ordering by interest relevance and
  then by geographic proximity to the user's home city.
- **FR-005**: Guest users MUST be able to browse event cards but MUST be required
  to authenticate before joining an event.
- **FR-006**: Signed-in users MUST be able to join or cancel participation in an
  event from event detail.
- **FR-007**: The system MUST display event details including required fields:
  title, schedule, location, at least one image, and participant list.
- **FR-008**: The system MUST support optional event metadata including capacity,
  participation price, and official event link when provided.
- **FR-009**: The system MUST grant event participants access to event-wide chat.
- **FR-010**: The system MUST allow direct messaging between any two users who
  are participants of the same event.
- **FR-011**: The system MUST preserve existing direct-message history after event
  cancellation but prevent sending new direct messages in that context.
- **FR-012**: The system MUST remove access to event-wide and trip chats after
  event participation is canceled.
- **FR-013**: The system MUST allow participants to view available trip chats for
  an event and see route/departure details prior to joining.
- **FR-014**: The system MUST allow participants to create a trip chat with route,
  departure time, and transport role.
- **FR-015**: The system MUST enforce a configurable participant limit per trip
  chat and reject joins beyond capacity.
- **FR-016**: The system MUST automatically approve trip-chat join requests when
  requester city matches the chat's target city.
- **FR-017**: The system MUST require creator approval for trip-chat join requests
  when requester city does not match the chat's target city.
- **FR-018**: The system MUST allow users to cancel pending trip-chat requests.
- **FR-019**: The system MUST support participant profile visibility rules based
  on shared event or trip-chat membership.
- **FR-020**: The system MUST provide per-chat notification preferences and send
  notifications for key triggers (new message, request approved, relevant event).
- **FR-021**: The system MUST provide a map-based discovery view with event points
  and nearby trip-chat indicators and allow navigation to event details.
- **FR-022**: The system MUST provide profile management for avatar, display name,
  interests, home city, social links, bio, rating, and reviews.
- **FR-023**: The system MUST support user reporting and participant blocking.
- **FR-024**: The system MUST maintain visibility of participant ratings/reviews
  and show rating warnings to trip-chat creators during join review.
- **FR-025**: The system MUST limit MVP event categories to work conferences and
  exclude entertainment events.

### Non-Functional Requirements *(mandatory)*

- **NFR-001**: Core user journeys (onboarding, join event, open chat, join trip
  chat) MUST be available 99.5% of the time measured monthly.
- **NFR-002**: 95% of primary screen loads MUST complete within 2 seconds under
  normal network conditions.
- **NFR-003**: 95% of chat message delivery events MUST appear to recipients
  within 3 seconds.
- **NFR-004**: The app MUST maintain consistent navigation, status messaging, and
  visual language across all tabs and major user flows.
- **NFR-005**: All critical user actions MUST have clear success/failure feedback
  and recoverable retry options.
- **NFR-006**: Accessibility requirements MUST include readable text contrast,
  scalable text support, and screen-reader-friendly labeling for key actions.
- **NFR-007**: User-visible text MUST support Ukrainian for MVP and be ready for
  English rollout without redesign of core flows.
- **NFR-008**: Privacy-sensitive profile and conversation access MUST follow role-
  and membership-based visibility rules at all times.

### Validation Requirements *(mandatory)*

- Acceptance scenarios for all user stories MUST be covered in test evidence.
- Functional requirements MUST map to at least one verification scenario each.
- Performance and reliability targets MUST be validated against measurable data.
- UX consistency and accessibility checks MUST be included in release validation.

### Key Entities *(include if feature involves data)*

- **User**: Person using the platform with profile attributes, preferences,
  social identity linkage, and participation status.
- **OnboardingProfile**: Mandatory initial profile inputs including display name,
  interests/hobbies, and home city. Before authentication, these live in a
  **local onboarding draft**; the first server write uses `PUT /users/me` only
  after OAuth succeeds and only when the server profile is not already complete
  (display name and home city both present).
- **Event**: Work conference listing with schedule, location, media, optional
  capacity/pricing/link metadata, and lifecycle state.
- **EventParticipation**: Relationship between a user and an event, including
  joined/canceled status and timestamps.
- **ParticipantProfileView**: Visibility-controlled profile representation shown
  to other users based on shared context.
- **ChatSpace**: Conversation container of type event-wide, trip-local, or direct
  message with membership and access rules.
- **TripChat**: Route-specific group chat with creator, departure info, role, and
  member limit.
- **TripJoinRequest**: Request to enter a trip chat with status, requester city,
  and approval mode (auto/manual).
- **NotificationPreference**: Per-user and per-chat notification settings.
- **RatingReview**: Post-interaction star score and optional text feedback tied
  to profile reputation.
- **ReportBlockRecord**: Complaint and blocking records for safety workflows.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 85% of new users who start onboarding complete it and view
  the event list in the same session.
- **SC-002**: At least 70% of signed-in users who open an event detail complete a
  join action within 2 minutes.
- **SC-003**: At least 60% of users who join an event send at least one message
  (event-wide, trip, or direct) within 24 hours.
- **SC-004**: At least 50% of users who open the trip section either request to
  join or create a trip chat for that event.
- **SC-005**: Fewer than 2% of join/chat actions fail due to authorization or
  visibility-rule mismatches in production monitoring.
- **SC-006**: User-reported confusion about chat access and participation status
  drops by at least 40% compared with pre-release pilot feedback.

## Assumptions

- MVP scope targets mobile attendee experience; organizer administration is
  handled outside this feature scope.
- The Flutter client shows **OAuth provider choice on a dedicated sign-in
  screen**; the **welcome** screen separates **profile onboarding (get started)**
  from **log in** rather than embedding LinkedIn/Facebook on S1.
- **S2–S4 do not call the profile API** until the user has a session; after OAuth,
  the app may **skip** `PUT /users/me` if `GET /users/me` already returns a
  complete profile (returning user on the same device).
- Users have a valid social account supported by the platform for sign-in.
- Event and location reference data are available from existing business sources.
- Push delivery infrastructure is available for notification triggers.
- Ratings and reviews are visible platform-wide to support trust signals.
- Entertainment event categories remain out of scope for MVP release.
