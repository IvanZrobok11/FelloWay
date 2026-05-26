# Quickstart: Web deploy config (no `env.json` on server environments)

## Policy (one sentence)

**Dev / test / prod web: only CI `--dart-define`; never `env.json` on S3.**

## Required GitHub variables

| Variable | Environment |
|----------|-------------|
| `DEV_STREAM_API_KEY` | dev |
| `TEST_STREAM_API_KEY` | test |
| `PROD_STREAM_API_KEY` | prod |

Also ensure API URL vars / domain config per existing `008` deploy docs.

## Verify after deploy

1. Open web URL (e.g. dev CloudFront).
2. Eruda → **Network** → reload: confirm **no** `GET .../env.json`.
3. Sign in → **Chats** → confirm `GET .../chat/stream-token` (not deploy-config hint only).

## Troubleshooting decision tree

```text
Chats broken on deployed web?
│
├─ Network: GET /env.json on cold load?
│  └─ YES → Old bundle or custom host file → remove env.json from S3; redeploy CI artifact only
│
├─ UI: "Chat is not enabled on this deploy" (or similar)?
│  ├─ No GET /chat/stream-token
│  │  └─ Missing compile-time key → fix DEV_/TEST_/PROD_STREAM_API_KEY → re-run web build → invalidate CloudFront
│  └─ Do NOT upload env.json (will not fix dart-define omission)
│
├─ GET /chat/stream-token returns 401/403?
│  └─ API auth / JWT session → sign in again; check API CORS and Bearer path (not env.json)
│
├─ GET /chat/stream-token returns 5xx?
│  └─ ECS Stream secrets (ApiKey/ApiSecret) in Secrets Manager; API logs
│
└─ Fixed CI variable but UI unchanged?
   └─ CloudFront cache → invalidate distribution after S3 sync
```

## If Chats shows deploy-config hint

| Step | Action |
|------|--------|
| 1 | Check GitHub variable for that env is set |
| 2 | Re-run deploy workflow (web build must pass `--dart-define=STREAM_API_KEY`) |
| 3 | Invalidate CloudFront cache after S3 sync |
| 4 | **Do not** upload `env.json` to S3 |

## If token request fails (401/5xx)

- Fix API auth / `Stream:ApiKey` + `Stream:ApiSecret` on ECS (Secrets Manager).
- Not a client `env.json` issue.

## CI dry-run (maintainers)

Unset `DEV_STREAM_API_KEY` in a test branch workflow run → build MUST fail before S3 sync.

## Operator checklist (5 min)

1. Confirm GitHub variable for env (`DEV_/TEST_/PROD_STREAM_API_KEY`).
2. Open latest successful **Build web** workflow log — `STREAM_API_KEY` must not be empty; length check must pass.
3. Deploy smoke: no `/env.json` on reload; after sign-in, `/chat/stream-token` on Chats tab.
4. If token fails, switch to API/Stream secrets — not S3 files.

## Related features

- Chat connect UX/tests: `specs/012-chats-stream-connect` (dart-define only; see also this quickstart).
- Eruda: `deploy_env.js` only (unrelated to Stream key).
