# Contract: Live mobile ↔ backend integration (MVP)

**Feature**: `005-api-backend-integration`  
**Date**: 2026-05-17

## Authority

- Request/response shapes: `shared/api-contracts/{auth,users,events}/openapi.yaml` (bundled in `openapi.json`).
- Server behavior: `backend/` implements same paths (feature `002-backend-api`).

## Endpoints in scope

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| POST | `/auth/oauth/linkedin/token` | No | Obtain JWT (dev: `code: dev-{subject}`) |
| POST | `/auth/oauth/facebook/token` | No | Alternate provider |
| POST | `/auth/refresh` | No (body: refresh token) | Renew access token |
| GET | `/users/me` | Bearer | Smoke: load profile |
| PUT | `/users/me` | Bearer | Onboarding completion / profile update |
| GET | `/events` | Bearer | Smoke: list events |
| GET | `/events/{id}` | Bearer | Optional smoke: detail |

Out of MVP smoke: trips, chat, avatar upload, admin.

## Request rules

- `Authorization: Bearer <accessToken>` on protected routes.
- `Content-Type: application/json` on POST/PUT bodies.
- OAuth exchange body: `{ "code", "redirectUri", "codeVerifier" }` per auth contract.

## Response rules

- Success: JSON matching OpenAPI schemas for each operation.
- Error: `ErrorResponse` envelope where implemented (4xx/5xx).
- Empty events list: HTTP 200 with `{ "items": [], "nextCursor": null }` — not an error.

## Client obligations

1. `API_MODE=live` MUST NOT use `MockApiCatalog` for wired endpoints.
2. Access token MUST come from backend auth endpoints before calling protected routes (except deliberate dev UI).
3. Field mapping MUST use contract property names on the wire; domain models may alias for UI.

## Verification

Manual checklist in [quickstart.md](../quickstart.md) — each step records expected status code and observable UI outcome.

Automated (recommended): unit tests with JSON fixtures copied from backend test snapshots or OpenAPI examples.
