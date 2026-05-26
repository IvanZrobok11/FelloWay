# Contract: Live-only Flutter client runtime policy

## Scope

Flutter client (`frontend/lib/`) builds deployed to **dev**, **test**, and **prod** via GitHub Actions (S3 + CloudFront). Automated tests (`test/`, `integration_test/`) are exempt but MUST NOT reintroduce mock runtime mode into `lib/`.

## Policy

1. Product code MUST use the **deployed backend API** for all user-facing data and auth (no in-app demo catalogs, fake tokens, or mock mode switches).
2. Configuration MUST come from **build-time** `--dart-define` values set in CI per environment (`API_BASE_URL`, `STREAM_API_KEY`, OAuth defines as needed).
3. Operators MUST NOT document or rely on `API_MODE=mock`, `API_MODE=auto`, or `flutter run` with localhost as a **supported product workflow**.
4. On API failure, the client MUST show **error or retry** — MUST NOT substitute embedded demo data.
5. Sign-in UI on shipped builds MUST expose only **production auth flows** (e.g. LinkedIn BFF on web, configured OAuth) — no demo sign-in or local-backend dev sign-in.

## CI build (unchanged intent)

Deploy workflows MUST continue to pass at minimum:

```text
--dart-define=API_BASE_URL=<env api url>
--dart-define=STREAM_API_KEY=<env public key>
--dart-define=API_MODE=live
```

(`API_MODE` may be removed from workflows once client no longer reads it.)

## Verification (acceptance)

| Check | Pass criteria |
|-------|----------------|
| Static | `rg useMockApi lib/` → no matches |
| Static | `rg shared/mocks lib/` → no matches |
| Static | `rg ApiMode\.mock lib/` → no matches |
| Deployed dev smoke | Sign-in (BFF) → events/profile load from API or show error |
| Deployed dev smoke | No demo sign-in control visible |
| Chats | No `demoSkipped` / demo hint path; token request when key set |
| Tests | `flutter test` green |
| Docs | `frontend/README.md` lists deployed verification only |

## Out of scope

- Backend unit/integration tests (InMemory DB, Testcontainers)
- OpenAPI codegen output under `lib/generated/`
- Server engineer local `dotnet run` workflows

## Related policies

- [013 web deploy config](../013-clarify-env-json/contracts/web-deploy-config-policy.md) — no `env.json` on host
- [011 interests catalog](../011-backend-interests-catalog/spec.md) — server-owned catalog only
