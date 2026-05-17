# Data Model: Codegen Pipeline (logical)

**Feature**: `004-openapi-dart-codegen` (revised)  
**Date**: 2026-05-17

## Pipeline flow

```text
common/openapi.yaml  ─┐
auth/openapi.yaml      ├── @redocly/cli join ──► openapi.json ──► openapi-generator-cli ──► felloway_api/
users/openapi.yaml     │                              (dart-dio)        └── build_runner
events/openapi.yaml  ─┘
```

**No** `tools/OpenApiContractMerge` or `dotnet run` in this path.

## Artifacts

| Artifact | Producer | Consumer |
|----------|----------|----------|
| Domain YAML | Human PR | Redocly join |
| `openapi.json` | Redocly join | openapi-generator-cli |
| `openapitools.json` | Human (version pin) | openapi-generator-cli |
| `openapi-generator-config.yaml` | Human | openapi-generator-cli |
| `felloway_api/**` | openapi-generator-cli + build_runner | Flutter app (`path` dep) |

## npm CLIs (no repo tools/)

| CLI | npm package | Role |
|-----|-------------|------|
| Redocly | `@redocly/cli` | Join domain YAML → `openapi.json` |
| Generator | `@openapitools/openapi-generator-cli` | `generate` dart-dio client |

## Validation rules

- Script MUST fail if `openapi-generator-cli` is missing (print `npm install -g` instructions).
- Join MUST include all four domains or exit non-zero.
- No files under `tools/` added for merge/codegen (SC-004).

## Remediation from v1 implementation

Delete if present:

- `tools/OpenApi.ContractMerge/`
- `tools/OpenApiContractMerge/`
- `FelloWay.Api` → `OpenApi.ContractMerge` project reference
