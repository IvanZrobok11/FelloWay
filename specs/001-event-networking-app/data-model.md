# Client Data Model Notes: Event Networking MVP

**Feature**: `001-event-networking-app`  
**Date**: 2026-04-03  
**Purpose**: Define **client-side** entities the Flutter app holds or maps from JSON/API and Stream. This is not a database schema.

## Core Entities (Dart Layering)

| Concept | Client role | Typical fields (illustrative) |
|---------|-------------|-------------------------------|
| `Session` | Auth state | access token handle, refresh token presence, expiry hint, user id |
| `OnboardingDraft` | Pre-auth registration | display name, interests, hobbies, home city label — persisted locally until OAuth succeeds, then merged or discarded per `GET /users/me` |
| `UserProfile` | Me + others (visibility rules) | id, display name, home city, interests, hobbies, bio, avatar url, social links, aggregate rating |
| `Event` | List + detail | id, title, start/end, city, venue, cover images, optional capacity/price/official url, attendee preview flags |
| `EventAttendee` | List items | id, display name, city (policy: no avatars on cards per PRD for signed-in preview) |
| `AttendStatus` | Local + server | joined, pending, left |
| `TripChat` | Trip listing + detail | id, event id, route label, departure time, role type, member count cap (20), city for auto-approve |
| `TripJoinRequest` | UX for approvals | id, trip id, requester id, status (pending/approved/rejected/cancelled), requester city, requester rating snapshot |
| `ChatThreadRef` | Tab 3 list item | channel id, type (event/trip/dm), title, subtitle, unread, mute preference |
| `Review` | Profile | id, author id, stars, text, created at |
| `NotificationPrefs` | Profile settings | per-channel or global toggles matching product triggers |

## Visibility Rules (UI State)

- **Guest**: event cards visible; participant identities blurred on detail; join → auth prompt.
- **Signed-in, not joined**: per PRD for cards (preview names/cities); detail join available after auth.
- **Joined same event**: full participant profile for co-attendees; event chat + DM allowed; trip section visible.
- **After unjoin**: event + trip chats inaccessible; DM history read-only, no new sends.

## Stream Mapping (Conceptual)

- One channel type (or CID convention) for **event-wide** chat per event
- **Trip** channels per trip chat, membership after approve
- **DM** channels between two users who share event participation (server rules); client reflects read-only after unjoin

Exact channel naming and creation are **server/stream admin** concerns; client subscribes and renders per token and channel list API.
