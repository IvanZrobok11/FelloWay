# Data model: Split-host LinkedIn BFF auth (main)

## Entities

### `OAuthIdentity` (existing)

- **provider**: `linkedin`
- **providerSubject**: string (LinkedIn subject)
- **userId**: GUID (FK to `User`)

### `User` (existing)

- **id**: GUID
- **email**: nullable string
- **displayName**: nullable string

### `RefreshToken` (existing)

- **userId**: GUID
- **token**: string
- **expiresAt**: timestamp

### `MobileAuthTicket` / BFF ticket (existing concept)

Represents a short-lived one-time token used to exchange a completed server-side OAuth login for FelloWay JWTs.

- **ticket**: string (opaque; passed as query string from `/auth/success?ticket=...`)
- **userId**: GUID
- **expiresAt**: timestamp (TTL)
- **consumedAt**: timestamp? (single-use)

## Lifecycle

1. Server completes LinkedIn OAuth and maps/creates user.
2. Server creates `ticket` for the user.
3. Web frontend opens `/auth/success?ticket=...`.
4. Frontend calls `POST /auth/linkedin/mobile/complete` with the `ticket`.
5. Server consumes the ticket (single-use) and issues JWT access + refresh.

# Data Model: Production LinkedIn OAuth Sign-In

**Feature**: `main`  
**Date**: 2026-05-19

## Overview

No new aggregate roots. Extends existing auth linkage and optionally adds email on `User`. External LinkedIn identity is keyed by OIDC `sub` (stored as `OAuthIdentity.ProviderSubject`).

## Entities (existing + changes)

### User

| Field | Type | Change | Notes |
|-------|------|--------|-------|
| Id | uuid | — | Primary key |
| DisplayName | string? | — | Set from LinkedIn `name` when empty |
| **Email** | string? | **ADD** | Nullable; set from LinkedIn userinfo when present; never required for token issue |
| Bio, HomeCityId, AvatarUrl, … | — | — | Unchanged |
| Role, BannedAt | — | — | Unchanged |

**Validation**: Email, if present, SHOULD be normalized (trim, lower-case) before persist; max length 320.

### OAuthIdentity

| Field | Type | Notes |
|-------|------|-------|
| Provider | string(32) | `linkedin` for this feature |
| ProviderSubject | string | LinkedIn OIDC `sub` |
| UserId | uuid | FK to User |

**Uniqueness**: `(Provider, ProviderSubject)` — one LinkedIn account → one FelloWay user.

**Lifecycle**: Created on first successful LinkedIn exchange; subsequent logins match existing row and issue new refresh tokens.

### RefreshToken

Unchanged — issued per successful `ExchangeOAuthCodeAsync`.

## External identifiers (not persisted as entities)

| Source | Maps to |
|--------|---------|
| LinkedIn OIDC `sub` | `OAuthIdentity.ProviderSubject` |
| LinkedIn `name` | `User.DisplayName` (if empty on existing user) |
| LinkedIn `email` | `User.Email` (optional) |

## State transitions

```text
[Signed out]
    → user taps LinkedIn
    → AppAuth authorize (PKCE)
    → POST /auth/oauth/linkedin/token
        → success: [Authenticated] (API JWT in secure storage)
        → 4xx: [Signed out] + error UI
```

Dev path (secrets absent):

```text
[Signed out]
    → "Sign in (local backend)" OR test client
    → POST with code dev-{subject}
    → [Authenticated]
```

## Identity rules

| Rule | Description |
|------|-------------|
| IR-001 | `dev-{subject}` identities MUST NOT merge with real LinkedIn `sub` values |
| IR-002 | Same LinkedIn `sub` MUST return same `UserId` on repeat login |
| IR-003 | When LinkedIn secrets configured, `dev-*` codes MUST NOT create sessions |

## EF migration

- **Migration name (suggested)**: `AddUserEmail`
- **Change**: `users.email` nullable `varchar(320)` + optional unique index deferred (email optional, duplicates possible across providers later)

## AuthService mapping (application layer)

On `ExchangeOAuthCodeAsync` after `OAuthUserInfo`:

1. Resolve identity by `(provider, ProviderSubject)`.
2. **Create**: `User { DisplayName, Email }` + `OAuthIdentity`.
3. **Update**: fill `DisplayName` if blank; set `Email` if user email null and userinfo has email.
4. `EnsureUserAsync` Stream; issue JWT.

No schema change to `OAuthIdentity` for this feature.
