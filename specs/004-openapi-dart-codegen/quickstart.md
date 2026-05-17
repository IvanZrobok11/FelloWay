# Quickstart: Generate Dart API client (npm only)

**Feature**: `004-openapi-dart-codegen`  
**Date**: 2026-05-17 (revised)

## Install prerequisites

```bash
npm install -g @openapitools/openapi-generator-cli
java -version   # 11+
node --version  # 18+
```

Optional (faster join without npx download each run):

```bash
npm install -g @redocly/cli
```

Verify:

```bash
openapi-generator-cli version
```

## Generate

From repository root (Git Bash / WSL / macOS / Linux):

```bash
./shared/api-contracts/scripts/generate-api-client.sh
```

## After generation

```bash
cd frontend
flutter pub get
flutter analyze
```

Commit when you changed contracts:

- `shared/api-contracts/openapi.json`
- `frontend/lib/generated/felloway_api/`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `openapi-generator-cli: command not found` | `npm install -g @openapitools/openapi-generator-cli` (script falls back to npx) |
| Java not found | Install JDK 11+ |
| Redocly join fails | Fix YAML/`$ref` in domain files |
| `build_runner` fails | Run from `frontend/lib/generated/felloway_api` |

## What this feature does NOT use

- No `tools/OpenApiContractMerge` or custom .NET merge consoles
- No `dotnet run` in the generation script

Backend Swagger still uses `FelloWay.Api/OpenApi/OpenApiContractMerger.cs` at runtime only.

## Related

- [spec.md](./spec.md)
- [plan.md](./plan.md)
- [shared/api-contracts/README.md](../../shared/api-contracts/README.md)
