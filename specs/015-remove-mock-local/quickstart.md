# Quickstart: Live-only client (015)

## Policy (one sentence)

**Deployed dev / test / prod: live API only — no mock mode, no demo sign-in, no local-backend shortcuts in the app.**

## Operator: verify after merge

1. Wait for **Deploy (main → dev)** green (`build` + `deploy-dev`).
2. Open **dev web URL** (from `DEV_WEB_BASE_URL` or terraform output).
3. Hard refresh or private window.
4. **Sign-in screen**: LinkedIn (and configured OAuth only) — no “Demo sign-in” or “Sign in (local backend)”.
5. Complete LinkedIn BFF sign-in on dev.
6. **Events / Profile / Onboarding interests**: data from API or explicit error — not seeded demo events.
7. **Chats**: connecting or token error — not “Demo API” hint.
8. Eruda → Network: API calls to `dev.api.*` — no reliance on mock.

## Maintainer: static checks before PR

From repo root:

```powershell
cd frontend
flutter analyze
flutter test
```

Grep (expect zero hits in `lib/`):

```powershell
rg "useMockApi|MockApiCatalog|ApiMode\.mock" lib/
```

## Troubleshooting

```text
Empty or fake-looking data after deploy?
├─ Still seeing demo events or “Demo sign-in”?
│  └─ Old bundle → CloudFront invalidate; confirm latest deploy SHA (015 removes mock UI)
├─ API errors / empty lists?
│  └─ Fix ECS/API/auth — never “enable mock mode” or demo sign-in
└─ Sign-in missing LinkedIn?
   └─ OAuth secrets + Frontend__BaseUrl on API; use BFF flow only
```

Do **not** use obsolete docs that mention `API_MODE=mock` — see [live-only-client-policy.md](./contracts/live-only-client-policy.md).

## Test-only configuration

Widget tests may use:

```text
--dart-define=STREAM_API_KEY_OPTIONAL=true
```

and explicit `AppConfig(apiBaseUrl: 'https://test.example', ...)` in test code — not `API_MODE=mock` in product code.

## Related

- [live-only-client-policy.md](./contracts/live-only-client-policy.md)
- [013 deploy config quickstart](../013-clarify-env-json/quickstart.md)
