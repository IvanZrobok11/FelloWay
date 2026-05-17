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

## API versioning (MVP)

- **URL prefix**: Routes are **not** prefixed with `/v1` in the MVP (e.g. `GET /events`, not `GET /v1/events`).
- **Optional header**: Clients may send `X-Api-Version: 1` for forward compatibility; the server does not reject requests without it today.
- **OpenAPI `info.version`**: `0.1.0` on domain fragments; Swashbuckle exposes a merged `v1` document in Development.
- Breaking changes: bump domain YAML version notes in PRs; plan `/v1` path prefix before public beta if required.

## Generate merged spec + Dart client

From repository root (Git Bash / WSL / macOS / Linux):

```bash
./shared/api-contracts/scripts/generate-api-client.sh
```

**Outputs**

- `shared/api-contracts/openapi.json` — merged contract (committed)
- `frontend/lib/generated/felloway_api/` — `dart-dio` client via [openapi-generator-cli](https://openapi-generator.tech)

**Prerequisites** (npm only — no .NET SDK for this script):

```bash
npm install -g @openapitools/openapi-generator-cli
# Optional: npm install -g @redocly/cli  (otherwise script uses npx @redocly/cli)
```

Also: **Node.js 18+**, **Java 11+**, **Dart/Flutter SDK**, **bash** (Git Bash / WSL on Windows). See [specs/004-openapi-dart-codegen/quickstart.md](../../specs/004-openapi-dart-codegen/quickstart.md).

After generation: `cd frontend && flutter pub get`.

## Conventions

- Prefer **OpenAPI 3** YAML per domain (`openapi.yaml`); merged in Swashbuckle via `OpenApiContractMerger` (see `backend/src/FelloWay.Api/OpenApi/`) and for mobile via `scripts/generate-api-client.sh` (`@redocly/cli join` + `openapi-generator-cli`).
- Keep breaking changes versioned or noted in PR descriptions.
- Mobile mock catalog: `frontend/lib/shared/mocks/mock_api_catalog.dart` should stay aligned with these contracts.

## Legacy summary

The feature-level endpoint index lives in [specs/001-event-networking-app/contracts/rest-endpoints.md](../../specs/001-event-networking-app/contracts/rest-endpoints.md). Migrate sections into the domain folders above as specs are formalized.
