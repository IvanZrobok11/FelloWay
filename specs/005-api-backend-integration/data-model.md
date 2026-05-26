# Data Model: Live API Integration (logical)

**Feature**: `005-api-backend-integration`  
**Date**: 2026-05-17

## Runtime configuration

| Field | Source | Values | Notes |
|-------|--------|--------|-------|
| `apiBaseUrl` | `--dart-define=API_BASE_URL` | HTTPS staging or `http://host:port` | Must match running backend |
| `apiMode` | `--dart-define=API_MODE` | `mock`, `live`, `auto` | `live` disables mock branches |
| OAuth defines | `OAUTH_*` | Optional | Production/staging OIDC |
| `streamApiKey` | `STREAM_API_KEY` | **Required** | Chat (GetStream public key) |

**Invariant (FR-006)**: When `apiMode == live`, `useMockApi` MUST be false regardless of hostname.

## Session

| Field | Storage | Lifecycle |
|-------|---------|-----------|
| `accessToken` | `TokenStorage` (secure) | Set after OAuth exchange or dev token POST |
| `refreshToken` | `TokenStorage` | Used by refresh interceptor |
| `userId` | Optional claim / from profile | Derived after `GET /users/me` |

```text
Sign-in → POST /auth/oauth/{provider}/token → TokenStorage
       → ApiClient attaches Bearer
       → GET /users/me → UserProfile (domain)
```

## Wired REST resources (MVP)

### TokenResponse (auth)

| Field | Type | Maps to |
|-------|------|---------|
| `accessToken` | string | `TokenStorage.access` |
| `refreshToken` | string | `TokenStorage.refresh` |
| `expiresIn` | int | Optional client expiry tracking |
| `userId` | uuid string | Debug / profile bootstrap |

### UserProfile (contract ↔ domain)

| Contract / backend | Domain (Flutter) | Mapping note |
|--------------------|------------------|--------------|
| `id` | `id` | uuid string |
| `displayName` | `displayName` | |
| `bio` | `bio` | |
| `homeCity` | `homeCityLabel` | Display label |
| `homeCityId` | (new optional) | Required for `PUT` updates per contract |
| `interestIds` | `interests` | MVP: store ids as strings OR resolve labels later |
| `avatarUrl` | `avatarUrl` | |
| `aggregateRating` | `ratingAverage` | |

**Update body (`PUT /users/me`)**: Use `UserProfileUpdate` shape — `displayName`, `bio`, `homeCityId`, `interestIds` (not legacy `homeCity` string in body).

### EventListPage

| Field | Type | Domain |
|-------|------|--------|
| `items` | `Event[]` | `List<EventSummary>` |
| `nextCursor` | string? | pagination |

### ErrorResponse (shared)

| Field | Type | UI use |
|-------|------|--------|
| `message` | string | Snackbar / error state |
| `code` | string? | Logging |
| `errors` | field errors[] | Form validation |

## Live vs mock feature matrix

| Feature | Live MVP | Notes |
|---------|----------|-------|
| Auth token | ✅ | Dev exchange + optional AppAuth |
| Profile GET/PUT | ✅ | Mapper fixes required |
| Events list GET | ✅ | Seeded backend events |
| Event detail GET | ✅ | |
| Event attend POST | ⚠️ Follow-up | Path exists; verify in smoke v2 |
| Trips | ❌ Mock | FR-010 |
| Stream chat | ❌ Mock/dev token | Unless Stream configured |

## State transitions

```text
[Unauthenticated] --sign-in--> [Authenticated]
[Authenticated] --401+refresh ok--> [Authenticated]
[Authenticated] --401+refresh fail--> [Unauthenticated]
[Authenticated] --GET /users/me fail (network)--> Error UI (no mock fallback in live)
```
