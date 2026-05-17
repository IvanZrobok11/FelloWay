# Implementation Plan: Contract-Driven Dart API Client Generation

**Branch**: `004-openapi-dart-codegen` | **Date**: 2026-05-17 (revised) | **Spec**: [spec.md](./spec.md)

**Input**: Bash pipeline using **npm CLIs only** — bundle domain YAML → `openapi.json` → Dart client via **`openapi-generator-cli`** (`npm install -g @openapitools/openapi-generator-cli`). **No** custom `tools/` projects.

## Summary

Provide `shared/api-contracts/scripts/generate-api-client.sh` that (1) **bundles** four domain `openapi.yaml` files into `openapi.json` using **`@redocly/cli join`** (npm), (2) **generates** a `dart-dio` client with **`openapi-generator-cli`** (global or `openapitools.json`-pinned), and (3) runs **`dart run build_runner build`** in the generated package. **Remove** any `tools/OpenApiContractMerge` / `tools/OpenApi.ContractMerge` added in the incorrect first pass and restore `FelloWay.Api` merge to its original in-process C# (Swashbuckle only).

## Technical Context

**Language/Version**: Bash 5+; Node.js 18+; Dart 3.10+ / Flutter  
**Primary Dependencies**: `@redocly/cli` (bundle/join); `@openapitools/openapi-generator-cli` 7.10.x (global or npx); Java 11+ (JVM for generator)  
**Storage**: Committed `openapi.json` + `frontend/lib/generated/felloway_api/`  
**Testing**: Manual script run; `flutter pub get` + `flutter analyze` on `frontend/`  
**Target Platform**: Developer machines (Git Bash / WSL / macOS / Linux)  
**Project Type**: Monorepo scripts (`shared/api-contracts/`, `frontend/`) — **no** new repo `tools/` projects  
**Performance Goals**: Pipeline &lt; 5 minutes (NFR-001)  
**Constraints**: No `dotnet run` in script; no bespoke merge code; pin generator in `openapitools.json`  
**Scale/Scope**: 4 YAML domains → 1 JSON + generated Dart package

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | ✅ Pass | `flutter analyze` after codegen; no .NET tooling for this feature |
| Test strategy | ✅ Pass | Manual + PR diff on generated artifacts |
| UX consistency | N/A | Tooling only |
| Performance budgets | ✅ Pass | &lt; 5 min pipeline |
| Flutter quality checks | ✅ Pass | Exclude `lib/generated/felloway_api` from app analyzer or analyze package separately |
| Evidence plan | ✅ Pass | Script exit 0; committed artifacts in PR |

**Post-design re-check**: No violations.

## Project Structure

### Documentation (this feature)

```text
specs/004-openapi-dart-codegen/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/codegen-pipeline.md
└── tasks.md
```

### Source Code (repository root)

```text
shared/api-contracts/
├── openapi.json                          # generated (committed)
├── openapitools.json                     # pin openapi-generator-cli 7.10.0
├── openapi-generator-config.yaml         # dart-dio options
├── package.json                          # optional: local npm deps (@redocly/cli)
├── scripts/generate-api-client.sh          # bash entry (npm only)
├── common|auth|users|events/openapi.yaml

frontend/
├── lib/generated/felloway_api/             # generated dart-dio package
└── pubspec.yaml                            # path: lib/generated/felloway_api

backend/src/FelloWay.Api/OpenApi/
└── OpenApiContractMerger.cs                # unchanged for Swashbuckle (NOT used by bash script)

# REMOVE (incorrect first implementation):
# tools/OpenApi.ContractMerge/
# tools/OpenApiContractMerge/
```

**Structure Decision**: All automation lives under `shared/api-contracts/` + `frontend/`; backend merge stays runtime-only for Swagger.

## Implementation Phases (for `/speckit.tasks`)

### Phase 0 — Revert incorrect tooling

1. Delete `tools/OpenApi.ContractMerge/` and `tools/OpenApiContractMerge/`.
2. Remove `tools/` entries from `backend/FelloWay.slnx`.
3. Remove `OpenApi.ContractMerge` project reference from `FelloWay.Api.csproj`.
4. Restore `OpenApiContractMerger.cs` to self-contained merge (pre-shared-library).

### Phase 1 — npm bundle + config

1. Add `shared/api-contracts/package.json` (optional devDeps: `@redocly/cli`) OR document global `npm install -g @redocly/cli`.
2. Keep `openapitools.json` + `openapi-generator-config.yaml`.
3. Rewrite `generate-api-client.sh`:
   - `set -euo pipefail`
   - Step 1: `npx @redocly/cli join` (or `redocly join`) on four YAML paths → `openapi.json`
   - Step 2: `openapi-generator-cli generate` (global) **or** `npx @openapitools/openapi-generator-cli generate` with `openapitools.json`
   - Step 3: `dart run build_runner build` in generated dir
   - Fail if `openapi-generator-cli` not found (print install hint)

### Phase 2 — Regenerate artifacts

1. Run script; commit `openapi.json` + `frontend/lib/generated/felloway_api/`.
2. `frontend/pubspec.yaml` path dependency on `felloway_api`.
3. `flutter pub get` + `flutter analyze`.

### Phase 3 — Docs

1. Update `shared/api-contracts/README.md`, root `README.md`, PR template.
2. Document: `npm install -g @openapitools/openapi-generator-cli` and Java 11+.

## Complexity Tracking

> No violations.

## Generated Artifacts

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Pipeline contract | [contracts/codegen-pipeline.md](./contracts/codegen-pipeline.md) |
| Quickstart | [quickstart.md](./quickstart.md) |
