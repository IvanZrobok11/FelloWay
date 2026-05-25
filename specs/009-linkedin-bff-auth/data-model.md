# Data Model: LinkedIn BFF OAuth (009-linkedin-bff-auth)

**Feature**: `009-linkedin-bff-auth`  
**Date**: 2026-05-20 (plan refresh)

**LinkedIn claims source**: `AspNet.Security.OAuth.LinkedIn` middleware (`AddLinkedIn`) after callback — not client-posted codes.

## Overview

No new aggregate roots. Reuses `User`, `OAuthIdentity`, `RefreshToken`. Adds ephemeral **`MobileAuthTicket`** (in-memory or distributed cache) for native JWT handoff—not a persisted domain entity.

## Entities (existing)

### User

Unchanged from `main` LinkedIn work (`Email` optional, `DisplayName` from LinkedIn).

| Field | Notes |
|-------|-------|
| Email | Optional; from LinkedIn claims when present |
| DisplayName | Set from LinkedIn `name` when empty |

### OAuthIdentity

| Field | Notes |
|-------|-------|
| Provider | `linkedin` |
| ProviderSubject | LinkedIn OIDC `sub` from middleware claims |
| UserId | FK |

**Uniqueness**: `(Provider, ProviderSubject)`.

### RefreshToken

Issued by `AuthService` on successful login (mobile JWT path and any future cookie+JWT bridge).

## Ephemeral: MobileAuthTicket

| Field | Type | Notes |
|-------|------|-------|
| Id | guid/string | Single-use ticket in redirect URL |
| UserId | uuid | User to issue tokens for |
| ExpiresAt | datetime | ≤ 60s from creation |
| Consumed | bool | Set true on complete |

**Storage**: `IMemoryCache` or `IDistributedCache` (staging/prod); not EF table for v1.

## External identifiers

| LinkedIn claim | Maps to |
|----------------|---------|
| `sub` | `OAuthIdentity.ProviderSubject` |
| `name` | `User.DisplayName` |
| `email` | `User.Email` (optional) |

## State transitions

### Web (cookie)

```text
[Signed out]
  → navigate to GET /auth/linkedin/login?returnUrl=...
  → LinkedIn consent
  → GET /auth/linkedin/callback (middleware)
  → AuthService upsert user
  → Set HttpOnly session cookie
  → Redirect returnUrl/auth/success
  → GET /users/me (cookie) → [Authenticated]
```

### Mobile (JWT + flutter_web_auth_2)

```text
[Signed out]
  → FlutterWebAuth2.authenticate(api/login?platform=mobile&...)
  → LinkedIn consent (in system browser)
  → middleware callback
  → Create MobileAuthTicket
  → Redirect com.felloway.app://auth/callback?ticket=...
  → POST /auth/linkedin/mobile/complete { ticket }
  → TokenResponse → secure storage → [Authenticated]
```

### Dev (unchanged)

`POST /auth/oauth/linkedin/token` with `dev-{subject}` when LinkedIn secrets absent.
