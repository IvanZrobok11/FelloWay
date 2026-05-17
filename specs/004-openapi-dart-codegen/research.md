# Research: OpenAPI Dart Codegen (004) — revised

**Date**: 2026-05-17 (revised)

## 1. Merge / bundle (YAML → openapi.json)

**Decision**: **`@redocly/cli join`** invoked via `npx` or global `redocly` from bash.

**Rationale**: User forbids custom `tools/` merge projects. Redocly is a standard npm CLI for combining OpenAPI files; supports multiple inputs and emits a single JSON/YAML artifact.

**Alternatives considered**:
- **Custom .NET `OpenApiContractMerge`** — rejected per user (incorrect first implementation).
- **`swagger-cli bundle`** — viable; Redocly chosen for clearer multi-file join UX.
- **Hand-maintained `openapi.json`** — rejected (drift from domain YAML).

**Join order** (matches backend domain order):

```text
common/openapi.yaml → auth/openapi.yaml → users/openapi.yaml → events/openapi.yaml
```

**Redocly flags**: `--without-x-tag-groups` (domain files share tag name `all`); generator uses `--skip-validate-spec` until YAML response descriptions are added.

## 2. Code generation CLI

**Decision**: **`@openapitools/openapi-generator-cli`** installed via npm:

```bash
npm install -g @openapitools/openapi-generator-cli
```

Script calls **`openapi-generator-cli generate`** when on PATH; fallback: `npx @openapitools/openapi-generator-cli` with `openapitools.json` version **7.10.0**.

**Rationale**: User explicitly requested global npm install pattern, not `dotnet run` or repo-owned JAR wrappers.

**Alternatives considered**:
- **npx only (no global)** — acceptable fallback; global install is primary doc path.
- **Docker `openapitools/openapi-generator-cli`** — heavier; optional doc only.

## 3. Dart generator template

**Decision**: **`dart-dio`** (unchanged).

**Rationale**: Frontend already uses `dio`; generated APIs accept shared `Dio` instance.

## 4. Output locations

**Decision**:

- `shared/api-contracts/openapi.json` (committed)
- `frontend/lib/generated/felloway_api/` (committed generated package)

## 5. Post-generation

**Decision**: `dart run build_runner build` inside generated package (built_value `.g.dart` files).

**Rationale**: `dart-dio` template requires serializer codegen; not part of openapi-generator-cli alone.

## 6. Backend Swashbuckle

**Decision**: Keep **`OpenApiContractMerger`** in `FelloWay.Api` for Development Swagger only; **not** invoked from bash script.

**Rationale**: FR-011 — mobile pipeline is npm-only; backend can retain C# merge for runtime docs independently.

## 7. Prerequisites (documented)

| Tool | Purpose |
|------|---------|
| Node.js 18+ | npx / global npm CLIs |
| `npm install -g @openapitools/openapi-generator-cli` | Dart codegen |
| `@redocly/cli` (global or npx) | YAML join |
| Java 11+ | OpenAPI Generator JVM |
| Dart / Flutter SDK | build_runner + app analyze |
| Bash | script runner (Git Bash on Windows) |

**Not required**: .NET SDK for this feature.
