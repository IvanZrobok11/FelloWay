# Quickstart: Flutter web + local API (CORS)

**Feature**: `007-api-cors-policy`

## Prerequisites

- PostgreSQL running; connection string in `backend/src/FelloWay.Api/appsettings.json`
- .NET 8 SDK, Flutter stable

## 1. Start the API (HTTPS)

```powershell
cd backend
dotnet run --project src/FelloWay.Api --launch-profile https
```

API base: `https://localhost:7086` (Swagger: `/swagger`).

## 2. Run Flutter web in live mode

```powershell
cd frontend
flutter run -d chrome `
  --dart-define=API_MODE=live `
  --dart-define=API_BASE_URL=https://localhost:7086
```

Note the web origin in the browser (e.g. `http://localhost:62178`). In **Development**, the API allows any `localhost` / `127.0.0.1` origin automatically.

## 3. Smoke checks

1. Sign in (local backend / dev OAuth path).
2. Open **Events** — network tab shows `GET https://localhost:7086/events` with **no CORS error**.
3. Optional: trigger a `POST` (e.g. attend) — preflight `OPTIONS` succeeds.

## 4. Verify CORS headers (curl)

```powershell
curl -i -H "Origin: http://localhost:9999" https://localhost:7086/health
```

Expect `Access-Control-Allow-Origin: http://localhost:9999` when API runs in Development.

## 5. Run backend tests

```powershell
cd backend
dotnet test FelloWay.slnx --filter "Category!=Integration"
```

Includes `CorsPolicyTests` after implementation.

## Troubleshooting

| Symptom | Check |
|---------|--------|
| CORS blocked, no `Access-Control-Allow-Origin` | API env is Development, or origin is in `Cors:AllowedOrigins` |
| `NET::ERR_CERT_AUTHORITY_INVALID` | Trust dev HTTPS cert: `dotnet dev-certs https --trust` |
| 401 on `/events` | Auth token / sign-in — not CORS |
| PostgreSQL 28P01 on startup | Fix `ConnectionStrings:Default` password |

## Staging / production

Set `Cors:AllowedOrigins` to deployed web app URLs only. Do not rely on localhost predicate outside Development.
