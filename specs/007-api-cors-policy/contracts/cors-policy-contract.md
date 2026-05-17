# Contract: API CORS policy

**Feature**: `007-api-cors-policy`  
**Date**: 2026-05-17

## Configuration

| Key | Type | Environments | Description |
|-----|------|--------------|-------------|
| `Cors:AllowedOrigins` | `string[]` | All | Explicit allowlist. Empty in base `appsettings.json`. |

**Development behavior** (code): origins with host `localhost` or `127.0.0.1` are permitted regardless of port.

**Example** (`appsettings.Production.json` or App Service settings):

```json
{
  "Cors": {
    "AllowedOrigins": [
      "https://app.felloway.com",
      "https://staging-app.felloway.com"
    ]
  }
}
```

## Allowed request headers (preflight)

| Header | Required for |
|--------|----------------|
| `Authorization` | JWT Bearer (`ApiClient`) |
| `Content-Type` | JSON bodies |
| `Accept` | JSON responses |
| `X-Correlation-ID` | Optional client correlation |

## Allowed methods

`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`

## Middleware pipeline position

```text
ApplyDatabaseAsync
UseStaticFiles
UseCors                    ← this feature
CorrelationIdMiddleware
ExceptionHandlingMiddleware
UseAuthentication
UseAuthorization
MapFelloWayHealthChecks
MapControllers
```

## Browser request contract

### Simple GET (e.g. events list)

```http
GET /events HTTP/1.1
Host: localhost:7086
Origin: http://localhost:62178
Accept: application/json
```

**Response MUST include** (when origin permitted):

```http
Access-Control-Allow-Origin: http://localhost:62178
```

### Preflight (e.g. POST with Authorization)

```http
OPTIONS /events/{id}/attend HTTP/1.1
Origin: http://localhost:62178
Access-Control-Request-Method: POST
Access-Control-Request-Headers: authorization,content-type
```

**Response MUST** be `204` or `200` with:

```http
Access-Control-Allow-Origin: http://localhost:62178
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type, Accept, X-Correlation-ID
```

### Denied origin (production-like)

```http
GET /health HTTP/1.1
Origin: https://evil.example
```

**Response MUST NOT** include `Access-Control-Allow-Origin: https://evil.example`.

## Automated test contract

| Test | Factory | Assertion |
|------|---------|-----------|
| Allowed origin GET | `FelloWayWebApplicationFactory` + `Cors:AllowedOrigins` or Testing env | `Access-Control-Allow-Origin` matches `Origin` |
| Preflight OPTIONS | Same | 2xx + allow headers present |
| Denied origin | Factory with `Environment=Production` + fixed allowlist | No matching `Access-Control-Allow-Origin` for evil origin |

## Out of scope

- `Access-Control-Allow-Credentials`
- Wildcard `Access-Control-Allow-Origin: *` with authenticated requests
- CDN / Azure Front Door CORS rules
