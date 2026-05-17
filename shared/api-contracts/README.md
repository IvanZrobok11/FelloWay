# API contracts

Canonical REST contract definitions shared by **frontend** and **backend**. Add OpenAPI fragments, request/response schemas, and examples per domain folder.

```
shared/api-contracts/
├── auth/       # OAuth, sessions, Stream chat tokens
├── users/      # Profile, avatar, preferences, blocks, reviews
├── common/     # Shared types, errors, pagination, versioning
└── events/     # Events, attendance, trips, join requests
```

## Domain scope

| Folder | Typical paths / topics |
|--------|-------------------------|
| [auth/](auth/) | OAuth callbacks, token refresh, `GET /chat/stream-token` |
| [users/](users/) | `GET/PUT /users/me`, avatar upload, push preferences, `GET /users/{id}/reviews`, block |
| [common/](common/) | Error envelope, list pagination, shared enums/DTOs |
| [events/](events/) | `GET/POST /events`, attend, attendees, trips, join/approve, event reviews |

## OpenAPI files (v0.1.0 draft)

| File | Scope |
|------|--------|
| [common/openapi.yaml](common/openapi.yaml) | Errors, pagination meta, security scheme |
| [auth/openapi.yaml](auth/openapi.yaml) | OAuth token exchange, refresh, Stream token |
| [users/openapi.yaml](users/openapi.yaml) | Profile, avatar, push prefs, reviews, block |
| [events/openapi.yaml](events/openapi.yaml) | Events, attendance, trips, join/approve, reviews |

Backend plan: [specs/002-backend-api/plan.md](../../specs/002-backend-api/plan.md).

## Conventions

- Prefer **OpenAPI 3** YAML per domain (`openapi.yaml`); merge in Swashbuckle for local dev.
- Keep breaking changes versioned or noted in PR descriptions.
- Mobile mock catalog: `frontend/lib/shared/mocks/mock_api_catalog.dart` should stay aligned with these contracts.

## Legacy summary

The feature-level endpoint index lives in [specs/001-event-networking-app/contracts/rest-endpoints.md](../../specs/001-event-networking-app/contracts/rest-endpoints.md). Migrate sections into the domain folders above as specs are formalized.
