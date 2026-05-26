# Contract: Web deploy public configuration policy

## Scope

Flutter **web** artifacts deployed to **dev**, **test**, and **prod** (S3 + CloudFront).

## Policy

1. All **public** runtime values required at app startup (including GetStream public key) MUST be supplied at **`flutter build web`** via `--dart-define=...`.
2. CI MUST pass defines from GitHub repository variables and MUST fail the build if a required variable is empty.
3. Deployed hosts MUST NOT require `env.json` at the web origin.
4. Operators MUST NOT upload `env.json` to S3 as a deployment step.
5. Troubleshooting for missing chat config on deploy MUST start with **CI variables and redeploy**, not runtime files.

## CI inputs (per environment)

| Environment | Stream public key variable |
|-------------|---------------------------|
| dev | `DEV_STREAM_API_KEY` |
| test | `TEST_STREAM_API_KEY` |
| prod | `PROD_STREAM_API_KEY` |

Build command MUST include:

```text
--dart-define=STREAM_API_KEY=<value from variable>
--dart-define=API_BASE_URL=<env api url>
--dart-define=API_MODE=live
```

## Verification (acceptance)

| Check | Pass criteria |
|-------|----------------|
| Cold load network | No request to `/env.json` |
| App startup | Succeeds when CI variables set |
| Chats (authenticated) | `GET /chat/stream-token` observed |
| S3 bucket | No `env.json` required for above |

## Operator checklist (support)

1. Identify environment (dev / test / prod).
2. In GitHub → Settings → Variables, confirm `DEV_/TEST_/PROD_STREAM_API_KEY` is set.
3. Re-run the web deploy workflow; confirm build step fails if variable empty.
4. After deploy: Eruda network — no `/env.json`; Chats tab shows `/chat/stream-token` when signed in.
5. If hint persists after variable fix: invalidate CloudFront; do **not** upload `env.json`.
6. If token HTTP fails: check API JWT and Stream server secrets — not client runtime files.

## Non-goals

- Local `flutter run` configuration (team does not use for acceptance).
- Storing secrets in web-accessible files.
