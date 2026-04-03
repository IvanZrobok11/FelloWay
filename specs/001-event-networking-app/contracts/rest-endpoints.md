# REST Endpoints — Mobile Consumer Summary

Derived from `TECH_PLAN.md` backend bullets. Paths and payloads are indicative; final shapes come from backend OpenAPI.

## User / Profile

| Method | Path | Use on client |
|--------|------|----------------|
| GET | `/users/me` | Current user profile |
| PUT | `/users/me` | Update name, bio, interests, city |
| POST | `/users/me/avatar` | Upload avatar (multipart) |
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
| POST | `/events/{id}/trips` | Create trip chat |
| POST | `/trips/{id}/join` | Request join |
| POST | `/trips/{id}/approve/{userId}` | Owner approves (client may only trigger if authorized) |

## Reviews & push prefs

| Method | Path | Use on client |
|--------|------|----------------|
| POST | `/events/{id}/attendees/{userId}/review` | Post-event feedback |
| *(TBD)* | push preferences | Align with backend `push_preferences` design |

## Reports

Reporting flows in PRD; exact paths TBD with backend (`reports` admin-facing; mobile likely POST report).

## GetStream

User creation/sync and channel provisioning are **server-side** with Stream; mobile uses Stream SDK token (from backend) to connect.
