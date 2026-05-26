# felloway_client

Flutter client for FelloWay.

## How we validate the product

The team validates on **deployed** dev / test / prod (S3 + CloudFront), not via mock API mode. See:

- [specs/015-remove-mock-local/quickstart.md](../specs/015-remove-mock-local/quickstart.md) — live-only client policy and smoke steps
- [specs/013-clarify-env-json/quickstart.md](../specs/013-clarify-env-json/quickstart.md) — CI `--dart-define` for Stream key (no `env.json` on S3)

After merge to `main`, verify the **Deploy (main → dev)** workflow, then open the dev web URL (hard refresh).

## Mobile web debugging (Eruda)

Eruda loads from `web/index.html` when **`deploy_env.js`** says the build is not production:

| Environment | `deploy_env.js` (CI writes before `flutter build web`) | Eruda |
|-------------|--------------------------------------------------------|-------|
| **dev** | `dev` | on |
| **test** | `test` | on |
| **prod** | `prod` | off |

| Override | Action |
|----------|--------|
| Force on prod | `?eruda=1` |
| Force off | `?eruda=0` |

## Build-time configuration (all shipped builds)

CI passes at minimum:

| Define | Source |
|--------|--------|
| `API_BASE_URL` | `DEV_/TEST_/PROD` API URL or domain-derived |
| `STREAM_API_KEY` | `DEV_/TEST_/PROD_STREAM_API_KEY` |
| `API_MODE=live` | workflow (harmless if client ignores) |

OAuth defines (`OAUTH_*`) are optional per environment.

LinkedIn BFF callback is always `{API_BASE_URL}/auth/linkedin/callback` (register in LinkedIn Developer Portal). See [specs/009-linkedin-bff-auth/quickstart.md](../specs/009-linkedin-bff-auth/quickstart.md).

## Typography

**Onest** (bundled under `assets/fonts/onest/`) with tokens in `lib/app/theme/`. See [specs/014-mobile-typography/quickstart.md](../specs/014-mobile-typography/quickstart.md).

## Maintainer: automated tests only

From `frontend/`:

```bash
flutter pub get
flutter test --dart-define=STREAM_API_KEY_OPTIONAL=true
```

Widget tests use explicit `AppConfig(apiBaseUrl: 'https://…', streamApiKey: '')` — there is **no** `API_MODE=mock` or in-app demo catalog.

Optional local `flutter run` (not product acceptance):

```bash
flutter run -d chrome --web-port=7357 \
  --dart-define=API_BASE_URL=https://dev.api.your-domain \
  --dart-define=STREAM_API_KEY=your_stream_key
```

## Development Standards

`../.specify/memory/constitution.md` — quality gates for analyze, tests, UX, and performance.
