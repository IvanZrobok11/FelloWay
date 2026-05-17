# Contract: API client generation pipeline (npm only)

**Feature**: `004-openapi-dart-codegen` (revised)  
**Date**: 2026-05-17

## Prerequisites

```bash
npm install -g @openapitools/openapi-generator-cli
# Optional if not using npx for join:
npm install -g @redocly/cli
```

Also required: **Java 11+**, **Node.js 18+**, **Dart/Flutter SDK**, **bash** (Git Bash / WSL on Windows).

## Entry point

```bash
./shared/api-contracts/scripts/generate-api-client.sh
```

## Steps

| Step | Command | Output |
|------|---------|--------|
| 1 — Join | `redocly join` or `npx @redocly/cli join` on `common`, `auth`, `users`, `events` `openapi.yaml` → `openapi.json` | `shared/api-contracts/openapi.json` |
| 2 — Generate | `openapi-generator-cli generate` (global) or `npx @openapitools/openapi-generator-cli generate` with `openapitools.json`; add `--skip-validate-spec` until YAML has response descriptions | Dart package tree |
| 3 — Serializers | `dart run build_runner build` (in generated dir) | `*.g.dart` files |

Redocly join uses `--without-x-tag-groups` (shared `all` tag across domain files).

Version pin: `shared/api-contracts/openapitools.json` → generator **7.10.0**.

## Failure behavior

- Missing global CLI → stderr message with install command; exit **1**.
- Join or generate error → non-zero exit; do not partially commit broken output.
- **MUST NOT** invoke `dotnet run` or repo `tools/*` merge projects.

## Outputs (committed)

- `shared/api-contracts/openapi.json`
- `frontend/lib/generated/felloway_api/**`

## Flutter integration

```yaml
# frontend/pubspec.yaml
dependencies:
  felloway_api:
    path: lib/generated/felloway_api
```

Hand-written `ApiClient` keeps auth interceptors; pass its `Dio` into generated `DefaultApi` when adopting endpoints.
