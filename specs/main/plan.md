# Implementation Plan: LinkedIn BFF auth fix + auth refactor

**Branch**: `main` | **Date**: 2026-05-26 | **Spec**: `specs/main/spec.md`  
**Input**: `specs/main/spec.md` (includes clarifications 2026-05-26)

## Summary

Fix production **LinkedIn BFF** sign-in for **split-host Flutter web** (frontend CloudFront host differs from API CloudFront host):

- Web success route `/auth/success?ticket=...` must complete **ticket → JWT** (`POST /auth/linkedin/mobile/complete`) and then use **Bearer JWT** for `/users/me` and protected API calls.
- Stop treating `GET /auth/session` (cookie session probe) as required in split-host web; it returns 401 by design when cookies are not available cross-origin.
- Infrastructure: ensure **HTTPS-only** LinkedIn callback (no CloudFront downgrade to `http://`) and ensure each env’s web origin is present in API `Cors:AllowedOrigins`.

Also perform a **refactor of the authorization system** (frontend + backend integration points) so classes and functions are simpler, responsibilities are explicit, and conditions are justified (no “try everything” auth heuristics).

## Technical Context

**Languages/Versions**:
- **Backend**: C# 12 / .NET 8 (ASP.NET Core)
- **Frontend**: Dart 3.x / Flutter stable (Flutter Web + iOS/Android app)

**Primary dependencies (auth-related)**:
- **Frontend**: `dio`, `go_router`, secure token storage (existing `TokenStorage`)
- **Backend**: `AspNet.Security.OAuth.LinkedIn`, ASP.NET Core auth (`Cookie`, `JwtBearer`, `PolicyScheme`), forwarded headers (`X-Forwarded-Proto`, `X-Forwarded-Host`)

**Storage**:
- JWT tokens stored client-side (mobile + split-host web) via existing `TokenStorage`
- Cookie sessions supported on backend (`felloway.session`) for same-origin / local dev cases, but not relied upon for split-host prod
- One-time auth tickets stored server-side (memory cache / store) for `/auth/linkedin/mobile/complete`

**Testing**:
- Frontend: `flutter test` (unit/widget)
- Backend: `dotnet test` (xUnit)

**Target platforms**: Web, iOS, Android

**Performance goals**:
- Web BFF completion (ticket redeem + first `/users/me`) completes within **30s** on deployed dev/test under normal network.

**Constraints**:
- Environments are **dev + test + prod** (no staging).
- Deployed auth callback must be **HTTPS-only** (CloudFront must not expose an `http://` OAuth callback to browsers/LinkedIn).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Code quality gate defined**: `flutter analyze`, `dart format`, backend build + tests; no dead code or ambiguous cross-layer side effects.
- **Test strategy defined**: add regression tests for split-host web login completion and for “do not call `/auth/session` in split-host mode”.
- **UX consistency strategy defined**: consistent sign-in success/error handling; avoid loops where user lands on `/auth/success` then gets bounced to `/sign-in`.
- **Performance budgets defined**: ticket redeem + `/users/me` within 30s (dev/test), no repeated retries or infinite redirects.
- **Evidence plan defined**: capture browser Network trace (dev/test/prod) showing `POST /auth/linkedin/mobile/complete` 2xx and `/users/me` 200; keep analyzer/test outputs in CI logs.

## Project Structure

### Documentation (this feature)

```text
specs/main/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
backend/
├── src/FelloWay.Api/
└── tests/

frontend/
├── lib/
│   ├── app/
│   ├── features/
│   └── shared/
└── test/
```

**Structure Decision**: Mobile + Web Flutter client in `frontend/` talking to ASP.NET Core API in `backend/`.

## Phase 0: Outline & Research (output: `research.md`)

Research goals (resolve “why it redirects to /sign-in after success”):
- Confirm the intended split-host **web auth strategy** (ticket→JWT) and why cookies are not viable across CloudFront hosts.
- Confirm infra requirements for HTTPS-only callback behind CloudFront/ALB (forwarded headers + CloudFront viewer policy).
- Confirm CORS requirements for browser calling `POST /auth/linkedin/mobile/complete` from the web origin.

## Phase 1: Design & Contracts

### Design decisions

- **Primary flow (split-host web)**:
  - `GET /auth/linkedin/login?platform=web&returnUrl=<web-origin>` redirects to LinkedIn.
  - Callback completes server-side and redirects to `<web-origin>/auth/success?ticket=...`.
  - Flutter web reads `ticket` and calls `POST /auth/linkedin/mobile/complete`.
  - Client stores `accessToken` + `refreshToken` and uses Bearer on subsequent requests (`/users/me`).
  - **Do not require** `GET /auth/session` in split-host mode.

- **Secondary flow (same-origin / local dev)**:
  - Cookie session can remain supported for local or same-origin deployments, but must be clearly separated in code paths (no ambiguity).

- **Refactor direction (auth simplicity)**:
  - Frontend: introduce a single “post-login completion” orchestrator that chooses between:
    - ticket→JWT completion (split-host web, and mobile)
    - cookie session probe (only when same-origin cookie session is expected)
  - Backend: keep `PolicyScheme` routing (Bearer vs cookie), but ensure controller endpoints used by split-host web do not assume cookie.
  - Remove/avoid “try cookie then JWT then cookie” patterns; conditions must be based on environment/config and URL context.

### Contracts (output: `contracts/`)

Document:
- Web BFF sequence (login → callback → success ticket)
- Ticket completion contract (`POST /auth/linkedin/mobile/complete`)
- CORS and HTTPS invariants per environment

### Data model (output: `data-model.md`)

Capture the minimal entities involved:
- `OAuthIdentity`, `User`, refresh tokens (existing)
- `MobileAuthTicket` (one-time ticket) lifecycle: create → redeem → consumed/expired

### Quickstart (output: `quickstart.md`)

Provide operator steps for dev/test/prod:
- Required LinkedIn redirect URIs: `https://<api-host>/auth/linkedin/callback`
- Required web return URLs/origins: `https://<web-host>`
- CORS: `Cors:AllowedOrigins` must include each env’s **web origin**
- CloudFront: enforce HTTPS-only viewer policy and forward proto/host headers (or equivalent)

## Phase 2: Implementation Plan (high level)

### Frontend (Flutter web)
- Make split-host detection explicit and use it to:
  - Always redeem `ticket` via `POST /auth/linkedin/mobile/complete`
  - Never call `GET /auth/session` as a completion step in split-host mode
- Ensure auth errors are surfaced once (snackbar) and navigation does not loop.
- Add regression tests for the “auth success ticket is present” path.

### Backend (.NET)
- Ensure `/auth/linkedin/callback` builds correct **https://** redirect URIs when behind CloudFront/ALB (forwarded headers already present; verify in infra).
- Ensure `Cors:AllowedOrigins` is correctly configured for dev/test/prod web origins.
- Add backend tests for `/auth/linkedin/mobile/complete` (invalid/expired ticket).

### Infrastructure (Terraform / CloudFront)
- Ensure CloudFront viewer policy always redirects HTTP → HTTPS.
- Ensure forwarding of `X-Forwarded-Proto` and `Host` to the API origin (ALB/ECS), so ASP.NET can generate HTTPS links.

