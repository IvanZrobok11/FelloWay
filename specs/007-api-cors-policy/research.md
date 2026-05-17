# Research: Cross-Origin Access for Web Clients

**Feature**: `007-api-cors-policy` | **Date**: 2026-05-17

## R1: CORS implementation mechanism

**Decision**: Use ASP.NET Core built-in CORS (`AddCors` / `UseCors`) in `FelloWay.Api`; no gateway-only or third-party package.

**Rationale**: Native middleware integrates with the existing pipeline, supports preflight, and is well-documented for JWT + API controllers. Matches prior staging checklist item in `specs/002-backend-api/quickstart.md`.

**Alternatives considered**:
- **API gateway / reverse proxy only** — Rejected for v1; operators may add later; app-layer fix unblocks local dev immediately.
- **YARP / custom middleware** — Unnecessary complexity for allowlist + preflight.

## R2: Localhost with ephemeral ports (FR-005)

**Decision**: In **Development**, use `SetIsOriginAllowed` with a predicate: host is `localhost` or `127.0.0.1` (any port, `http` or `https`). In **non-Development**, use explicit `Cors:AllowedOrigins` array only (no wildcard).

**Rationale**: Browsers send full origins (`http://localhost:62178`); static lists cannot cover every Flutter web dev port. Predicate is dev-only and satisfies NFR-SEC-001 for production.

**Alternatives considered**:
- **Fixed port list in appsettings** — Rejected; breaks on every `flutter run -d chrome` port change.
- **`*` wildcard** — Rejected; violates production security requirement.

## R3: Credentials and auth model

**Decision**: `AllowCredentials = false`; expose `Authorization` via `WithHeaders`. Client continues Bearer-in-header (Dio `ApiClient`).

**Rationale**: Spec assumes cookie-based CORS credentials are out of scope; JWT does not require `Access-Control-Allow-Credentials`.

**Alternatives considered**:
- **AllowCredentials + cookies** — Out of scope; would require CSRF and cookie auth design.

## R4: Headers and methods for preflight (FR-004)

**Decision**: Allow methods `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`. Allow headers `Authorization`, `Content-Type`, `Accept`, `X-Correlation-ID`.

**Rationale**: Matches `ApiClient` and `CorrelationIdMiddleware` in the backend.

## R5: Middleware order

**Decision**: Register CORS after `UseStaticFiles`, before `UseAuthentication` / `UseAuthorization` / `MapControllers`.

**Rationale**: Microsoft guidance: CORS before auth for preflight; error responses still get CORS headers when middleware runs before endpoint execution.

## R6: Configuration shape

**Decision**: `Cors:AllowedOrigins` — string array in `appsettings.json` (empty default) and environment-specific overrides; Development uses predicate in code plus optional extra origins from config.

**Rationale**: FR-006 operator configurability; Azure App Service can set `Cors__AllowedOrigins__0` etc.

## R7: Testing approach

**Decision**: Add `CorsPolicyTests` in `FelloWay.Api.Tests` using `FelloWayWebApplicationFactory` with `UseSetting` for origins; send `Origin` header; assert `Access-Control-Allow-Origin` on GET and OPTIONS preflight. Separate test with production-like env (no localhost predicate) and unlisted origin → no allow header.

**Rationale**: NFR-TEST-001 without browser automation; fast in-memory suite compatible.

**Alternatives considered**:
- **Playwright / Flutter integration only** — Slower; keep as manual quickstart smoke.

## R8: Flutter web base URL alignment

**Decision**: Document `API_BASE_URL=https://localhost:7086` with backend `https` launch profile; note scheme mismatch if web is `http` and API is `https` (CORS still works; mixed content is separate browser concern for some setups).

**Rationale**: User error used `https://localhost:7086` API and `http://localhost:62178` web — CORS fix addresses origin allowlist, not TLS.
