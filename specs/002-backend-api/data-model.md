# Data Model: Backend API (PostgreSQL)

**Feature**: `002-backend-api`  
**Date**: 2026-05-17  
**Purpose**: Persistent schema for ASP.NET Core + EF Core. Aligns with client concepts in [001 data-model](../001-event-networking-app/data-model.md).

## Entity Relationship (overview)

```text
User ──┬── UserInterest ── Interest
       ├── RefreshToken
       ├── PushPreferences
       ├── EventAttendee ── Event ──┬── EventInterest
       ├── Trip (creator)            └── (optional geo on City)
       ├── TripMember
       ├── TripJoinRequest
       ├── Review (author / subject)
       ├── BlockedUser (blocker → blocked)
       └── OAuthIdentity (provider, subject id)

Report ── (reporter, target user/channel, status) — admin workflow
```

## Tables

### `users`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | Internal user id (= Stream user id) |
| display_name | varchar(120) | Required after onboarding merge |
| bio | text | Optional |
| home_city_id | uuid FK → cities | Required for “complete” profile |
| avatar_url | varchar(512) | Blob HTTPS URL |
| aggregate_rating | decimal(3,2) | Denormalized; updated on review insert |
| role | varchar(20) | `user`, `admin` |
| created_at, updated_at | timestamptz | |

### `oauth_identities`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| user_id | uuid FK | |
| provider | varchar(32) | `linkedin`, `facebook` |
| provider_subject | varchar(256) | Unique per provider |
| created_at | timestamptz | Unique (provider, provider_subject) |

### `refresh_tokens`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| user_id | uuid FK | |
| token_hash | varchar(128) | Store hash only |
| expires_at | timestamptz | |
| revoked_at | timestamptz? | |

### `cities`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| name | varchar(120) | Localized label stored as entered |
| country_code | char(2) | |
| latitude, longitude | double | For Haversine sort/filter |

### `interests` / `user_interests`

Standard many-to-many; seed interests for IT tags.

### `events`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| title | varchar(200) | |
| description | text | |
| starts_at, ends_at | timestamptz | |
| city_id | uuid FK | |
| venue | varchar(200)? | |
| cover_image_url | varchar(512)? | |
| status | varchar(20) | `pending`, `active`, `rejected`, `archived` |
| created_by_user_id | uuid FK | |
| capacity | int? | |
| official_url | varchar(512)? | |
| latitude, longitude | double? | Venue coords for map |

### `event_attendees`

| Column | Type | Notes |
|--------|------|-------|
| event_id, user_id | PK composite | |
| status | varchar(20) | `joined`, `left` |
| joined_at, left_at | timestamptz? | |

### `event_interests`

Many-to-many tags on events for filtering.

### `trips`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| event_id | uuid FK | |
| creator_user_id | uuid FK | |
| route_label | varchar(200) | |
| departure_at | timestamptz | |
| role_type | varchar(32) | Driver / Passenger / Train / Custom |
| origin_city_id | uuid FK | Used for auto-approve |
| stream_channel_id | varchar(64) | GetStream CID |
| max_members | int | Default 20 |

### `trip_members`

| trip_id, user_id | PK | status `active` / `left` |

### `trip_join_requests`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| trip_id | uuid FK | |
| requester_user_id | uuid FK | |
| status | varchar(20) | `pending`, `approved`, `rejected`, `cancelled` |
| requester_city_id | uuid FK | Snapshot for auto-approve |
| created_at | timestamptz | |

### `reviews`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| subject_user_id | uuid FK | |
| author_user_id | uuid FK | |
| event_id | uuid FK | Context |
| rating | smallint | 1–5 |
| comment | text? | |
| created_at | timestamptz | |

### `blocked_users`

| blocker_user_id, blocked_user_id | PK | created_at |

### `push_preferences`

| user_id | PK | global_enabled, event_messages, trip_messages, direct_messages (booleans) |

### `reports` (admin)

| id | uuid | reporter_id, target_type, target_id, reason, status, resolved_at |

## State transitions

### Event attendance

`none` → `joined` (POST attend) → `left` (DELETE attend). Re-join allowed unless blocked.

### Trip join request

`pending` → `approved` | `rejected` | `cancelled` (DELETE by requester). Auto-approve when `requester.city_id == trip.origin_city_id`.

### Event (moderation)

`pending` → `active` | `rejected` (admin). User-submitted events start `pending`.

## Indexes (MVP)

- `events(status, starts_at)` for list
- `event_attendees(user_id)`, `event_attendees(event_id)`
- `trip_join_requests(trip_id, status)`
- `oauth_identities(provider, provider_subject)` unique

## API DTO mapping notes

- List endpoints return **cursor pagination** wrapper from `common` contract.
- Profile “complete” = `display_name` set + `home_city_id` set (matches Flutter onboarding completion).
- Never expose refresh token hash or OAuth provider tokens in responses.
