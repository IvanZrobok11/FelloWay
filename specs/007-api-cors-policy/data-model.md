# Data Model: CORS configuration

**Feature**: `007-api-cors-policy` | **Date**: 2026-05-17

Configuration-only feature; no database entities.

## CorsOptions (application configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `AllowedOrigins` | `string[]` | No (default `[]`) | Full origins allowed in non-Development (`https://app.example.com`). |

**Binding**: `Cors` section → `CorsOptions` class in `FelloWay.Api` (or `Infrastructure` if shared).

**Validation**:
- Each entry MUST be a valid absolute origin (scheme + host + optional port); no path suffix.
- Production/staging MUST NOT register `*` as an origin.
- Invalid entries SHOULD be logged at startup and ignored (fail-safe: deny unknown).

## Effective policy (runtime, derived)

| Environment | Origin evaluation |
|---------------|-------------------|
| Development | `localhost` / `127.0.0.1` (any port, http/https) **OR** listed in `AllowedOrigins` |
| Testing | Explicit `AllowedOrigins` only (tests set via `UseSetting`) |
| Staging / Production | Explicit `AllowedOrigins` only |

## Cross-origin response headers (browser contract)

When origin is permitted, responses include (via middleware):

| Header | Purpose |
|--------|---------|
| `Access-Control-Allow-Origin` | Echo permitted request `Origin` (not `*` when using auth headers) |
| `Access-Control-Allow-Methods` | Preflight: allowed HTTP methods |
| `Access-Control-Allow-Headers` | Preflight: allowed request headers |
| `Vary: Origin` | Cache correctness for per-origin responses |

**Not used**: `Access-Control-Allow-Credentials` (false).

## Relationships

- **Allowed origin** (spec entity) ↔ one element of `AllowedOrigins` or dev predicate match.
- **Cross-origin policy** ↔ combined Development predicate + configured list + middleware defaults.
