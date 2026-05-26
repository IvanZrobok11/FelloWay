# Data model: Web public config policy (013)

## Configuration sources (web)

| Source | Used on dev/test/prod deploy? | Used local dev? (out of acceptance scope) |
|--------|------------------------------|-------------------------------------------|
| CI `--dart-define=STREAM_API_KEY` | **Yes (authoritative)** | Optional |
| Runtime `/env.json` on web host | **No** | Was optional fallback |
| `web/env.json` in repo (gitignored) | **No** | Optional for local only |

## Build-time public values (current)

| Key | CI variable (per env) | Required for |
|-----|----------------------|--------------|
| `STREAM_API_KEY` | `DEV_` / `TEST_` / `PROD_STREAM_API_KEY` | Chat SDK init |
| `API_BASE_URL` | `DEV_API_BASE_URL` or domain-derived | API client |
| `API_MODE` | `live` in workflows | Live HTTP |

Secrets (Stream API secret, DB, JWT signing) remain on **API** only (Secrets Manager / ECS), never in web bundle or `env.json`.

## Client load sequence (target)

```text
App start
  → AppConfig.fromEnvironment()  // includes STREAM_API_KEY from dart-define
  → if streamApiKey empty && !optional → StateError (fail fast)
  → else continue (no HTTP fetch for env.json)
```

## Deploy artifact (S3 / CloudFront)

Expected files after `flutter build web` + sync:

- `index.html`, `flutter_bootstrap.js`, `main.dart.js`, assets, `deploy_env.js` (Eruda env label)
- **No** `env.json` required or produced by CI

## Policy entity

**WebDeployConfigPolicy**

- **environments**: dev, test, prod
- **primarySource**: build-time dart-define from GitHub Actions
- **runtimeFileAllowed**: false
- **verification**: CI fail on missing vars; smoke: no `/env.json` request; Chats calls `/chat/stream-token` when authenticated
