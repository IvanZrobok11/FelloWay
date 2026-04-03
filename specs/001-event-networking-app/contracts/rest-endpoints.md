# REST Endpoints — Mobile Consumer Summary

Derived from `TECH_PLAN.md` backend bullets. Paths and payloads are indicative; final shapes come from backend OpenAPI.

## User / Profile

| Method | Path | Use on client |
|--------|------|----------------|
| GET | `/users/me` | Current user profile |
| PUT | `/users/me` | Update name, bio, interests, city. **Registration path:** not called during onboarding S2–S4; after OAuth, client may call `GET` first and **only** `PUT` when profile is incomplete (e.g. new user or missing name/city). Profile edit and settings flows use `PUT` anytime when signed in. |
| POST | `/users/me/avatar` | Upload avatar (multipart) |
| PUT | `/users/me/push-preferences` | Sync notification toggles (body: `globalEnabled`, `eventMessages`, `tripMessages`, `directMessages`) |
| GET | `/users/{id}/reviews` | Reviews list on profile |
| POST | `/users/{id}/block` | Block user |

## Events

| Method | Path | Use on client |
|--------|------|----------------|
| GET | `/events` | Paginated list; query: interests, geo sort, `q`, city, tag |
| GET | `/events/{id}` | Event detail |
| POST | `/events/{id}/attend` | Join event |
| DELETE | `/events/{id}/attend` | Leave event (revoke chat access) |
| GET | `/events/{id}/attendees` | Participant list (subscribers only) |

## Trips (local chats)

| Method | Path | Use on client |
|--------|------|----------------|
| GET | `/events/{id}/trips` | List trip chats for event (`items` array) |
| POST | `/events/{id}/trips` | Create trip chat |
| POST | `/trips/{id}/join` | Request join |
| DELETE | `/trips/{id}/join` | Cancel pending join request (FR-018) |
| GET | `/trips/{id}/join-requests` | Owner: pending requests (`items`) |
| POST | `/trips/{id}/approve/{userId}` | Owner approves (client may only trigger if authorized) |

## Reviews

| Method | Path | Use on client |
|--------|------|----------------|
| POST | `/events/{id}/attendees/{userId}/review` | Post-event feedback (`rating`, optional `comment`) |

## Reports

Reporting flows in PRD; exact paths TBD with backend (`reports` admin-facing; mobile likely POST report).

## GetStream

User creation/sync and channel provisioning are **server-side** with Stream; mobile uses Stream SDK token (from backend) to connect.

| Method | Path | Use on client |
|--------|------|----------------|
| GET | `/chat/stream-token` | JWT / token string for `StreamChatClient.connectUser` (response: `{ "token": "..." }` or `{ "streamToken": "..." }`) |
