# Feature Specification: Contract-Driven Dart API Client Generation

**Feature Branch**: `004-openapi-dart-codegen`  
**Created**: 2026-05-17  
**Updated**: 2026-05-17  
**Status**: Implemented  
**Input**: User description: "let's make logic to generate openapi.json file in shared contracts folder and generate dart client using openapi-generator-cli. Using bash script for it" → **Revised**: use **`@openapitools/openapi-generator-cli` from Node** (e.g. `npm install -g @openapitools/openapi-generator-cli`); **do not implement** custom merge tools under `tools/`.

## Summary

Provide a **repeatable, single-command bash workflow** that produces `shared/api-contracts/openapi.json` from domain YAML fragments and generates an **up-to-date Dart client**—using **only standard npm-installed CLIs**, not bespoke repository tooling.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Regenerate client after contract change (Priority: P1)

As a mobile developer, when REST contracts change, I run one documented bash command and get an updated Dart API client without hand-maintaining DTOs.

**Why this priority**: Contract drift blocks live API adoption.

**Independent Test**: Change a field in a domain YAML file, run the script, confirm generated Dart types update.

**Acceptance Scenarios**:

1. **Given** domain `openapi.yaml` files exist, **When** the developer runs the generation script, **Then** `shared/api-contracts/openapi.json` is produced.
2. **Given** valid merged JSON, **When** codegen completes, **Then** Dart sources appear under the documented `frontend/` path.
3. **Given** unchanged contracts, **When** the script runs again, **Then** output is stable (aside from documented generator metadata).

---

### User Story 2 — Standard tooling only (Priority: P1)

As a maintainer, I want codegen to rely on **well-known npm packages** so any developer can install prerequisites with npm/Java docs—without building or maintaining custom merge code in this repo.

**Why this priority**: User explicitly rejected custom `tools/` implementations.

**Independent Test**: Fresh machine with Node, Java, and global `openapi-generator-cli`; script succeeds with **no** `dotnet run` step.

**Acceptance Scenarios**:

1. **Given** prerequisites are installed per README, **When** the bash script runs, **Then** it invokes **`openapi-generator-cli`** (from `@openapitools/openapi-generator-cli`) for Dart generation.
2. **Given** the repository, **When** reviewing the feature, **Then** there is **no** `tools/OpenApiContractMerge` or similar custom merge project added for this feature.

---

### User Story 3 — Onboarding (Priority: P2)

As a new contributor, I follow README steps to install global or project-local generator CLI and run one script.

**Acceptance Scenarios**:

1. **Given** documented install (`npm install -g @openapitools/openapi-generator-cli` or equivalent), **When** I run the script from repo root, **Then** the pipeline completes in under 5 minutes.

---

### Edge Cases

- Missing domain YAML — script fails with clear message.
- Invalid OpenAPI / broken `$ref` — bundler or generator fails non-zero.
- Generator version drift — pin via `openapitools.json` in `shared/api-contracts/`.
- Windows — Git Bash or WSL for bash script.
- Stale generated files — script overwrites output directory deterministically.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Produce **`shared/api-contracts/openapi.json`** from domain fragments (`common`, `auth`, `users`, `events`).
- **FR-002**: Domain inclusion order MUST match established project order (`common` → `auth` → `users` → `events`).
- **FR-003**: Generate the Dart client from merged JSON using **`openapi-generator-cli`** from the npm package **`@openapitools/openapi-generator-cli`** (install globally e.g. `npm install -g @openapitools/openapi-generator-cli`, or use project `openapitools.json` + `npx`).
- **FR-004**: A **bash script** under `shared/api-contracts/scripts/` MUST be the single entry point (bundle/merge → generate → documented post-steps e.g. `build_runner`).
- **FR-005**: Script MUST exit non-zero on failure and indicate which step failed.
- **FR-006**: Generated Dart MUST live under a stable `frontend/` path (e.g. `frontend/lib/generated/felloway_api/`).
- **FR-007**: README MUST document: Node.js, Java 11+, bash, **npm install for openapi-generator-cli**, and when to re-run.
- **FR-008**: Merged `openapi.json` and generated Dart MAY be committed (default: yes, for PR review).
- **FR-009**: Hand-written `ApiClient` / interceptors remain; generated code is adopted incrementally.
- **FR-010**: PR checklist MUST remind contributors to regenerate when contracts change.
- **FR-011**: The feature MUST **NOT** add or require custom repository tooling (no `tools/OpenApiContractMerge`, no .NET console for merge). Bundling YAML → JSON MUST use a **standard npm CLI** (e.g. `@redocly/cli join` or `swagger-cli bundle`) or a documented `openapi-generator-cli` workflow—**not** bespoke C# merge projects.

### Non-Functional Requirements

- **NFR-001**: Full pipeline under **5 minutes** on a typical laptop.
- **NFR-002**: Deterministic output for pinned generator version and unchanged inputs.
- **NFR-003**: No secrets in committed spec or generated code.
- **NFR-004**: Generated files clearly marked; no manual edits in review.

### Validation Requirements

- Script succeeds with only Node/npm/Java/bash prerequisites (no .NET SDK required for this feature).
- `flutter analyze` passes on the main app after `flutter pub get`.
- Merged JSON includes paths from all four domains.

### Key Entities

- **Domain fragment**: `shared/api-contracts/{domain}/openapi.yaml`
- **Merged artifact**: `shared/api-contracts/openapi.json`
- **Generator CLI**: `@openapitools/openapi-generator-cli` (npm)
- **Bash orchestrator**: `generate-api-client.sh`

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: One bash command refreshes client in under 5 minutes.
- **SC-002**: All four domain folders appear in merged `openapi.json`.
- **SC-003**: Contract field rename flows through to regenerated Dart without hand edits.
- **SC-004**: **Zero** custom merge/codegen projects under `tools/` for this feature.
- **SC-005**: New contributors succeed using README + `npm install -g @openapitools/openapi-generator-cli` only.

## Assumptions

- **openapi-generator-cli** is the primary codegen tool (user-specified); install via npm global or `openapitools.json` + local `npx`.
- **Merge/bundle** step uses an off-the-shelf npm CLI (Redocly join or swagger-cli)—not a repo-owned .NET tool. Backend `OpenApiContractMerger` remains for Swashbuckle only.
- Bash on Git Bash/WSL/macOS/Linux.
- **dart-dio** generator template matches existing `dio` usage.
- Java required by OpenAPI Generator (documented).

## Out of Scope

- Custom C# / .NET merge consoles or `tools/*` projects for this pipeline.
- `dotnet run` in the generation script.
- Server stub generation for ASP.NET.
- Mandatory CI drift gate in MVP.
- Replacing mock catalog in the same release.
