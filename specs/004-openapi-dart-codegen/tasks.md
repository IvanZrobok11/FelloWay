# Tasks: Contract-Driven Dart API Client Generation

**Input**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md), [contracts/codegen-pipeline.md](./contracts/codegen-pipeline.md)  
**Branch**: `004-openapi-dart-codegen`  
**Prerequisites**: Node.js 18+, Java 11+, Dart/Flutter SDK, bash (Git Bash / WSL on Windows)

**Organization**: Tasks grouped by user story. Phase 1–2 revert incorrect .NET tooling and lay npm foundation before US1 codegen.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (revert incorrect implementation)

**Purpose**: Remove custom `tools/` merge projects from the first (incorrect) pass; restore backend Swagger merge to self-contained C#.

- [x] T001 Delete directory `tools/OpenApi.ContractMerge/` (source + project files only; do not commit `bin/`/`obj/` if gitignored)
- [x] T002 Delete directory `tools/OpenApiContractMerge/`
- [x] T003 Remove `/tools/` folder projects from `backend/FelloWay.slnx`
- [x] T004 Remove `OpenApi.ContractMerge` project reference from `backend/src/FelloWay.Api/FelloWay.Api.csproj`
- [x] T005 Restore self-contained merge logic in `backend/src/FelloWay.Api/OpenApi/OpenApiContractMerger.cs` (no `OpenApi.ContractMerge` import)
- [x] T006 Run `dotnet build backend/FelloWay.slnx` to verify API still compiles after revert

**Checkpoint**: No `tools/OpenApi*` projects remain; backend builds.

---

## Phase 2: Foundational (npm config — blocking)

**Purpose**: Config files and optional npm manifest required before rewriting the bash script.

**⚠️ CRITICAL**: Complete Phase 2 before User Story implementation.

- [x] T007 [P] Ensure `shared/api-contracts/openapitools.json` pins generator-cli version `7.10.0`
- [x] T008 [P] Ensure `shared/api-contracts/openapi-generator-config.yaml` targets `dart-dio` with `pubName: felloway_api`
- [x] T009 Add `shared/api-contracts/package.json` with devDependency `@redocly/cli` (or document global install in README only)
- [x] T010 Add `shared/api-contracts/.gitignore` entry for `node_modules/` if using local `package.json`

**Checkpoint**: Contract folder has generator pin + Redocly option documented.

---

## Phase 3: User Story 1 — Regenerate client after contract change (P1) 🎯 MVP

**Goal**: One bash command produces `openapi.json` and an updated Dart client under `frontend/lib/generated/felloway_api/`.

**Independent Test**: Edit a field in `shared/api-contracts/users/openapi.yaml`, run `./shared/api-contracts/scripts/generate-api-client.sh`, confirm generated Dart model changes.

### Implementation

- [x] T011 [US1] Rewrite `shared/api-contracts/scripts/generate-api-client.sh` with `set -euo pipefail` — **no** `dotnet run`
- [x] T012 [US1] In `generate-api-client.sh` step 1: join domain YAML via `npx @redocly/cli join` (order: `common`, `auth`, `users`, `events`) → `shared/api-contracts/openapi.json`
- [x] T013 [US1] In `generate-api-client.sh` step 2: call `openapi-generator-cli generate` (global) with fallback `npx @openapitools/openapi-generator-cli` per `openapitools.json`; fail with install hint if missing
- [x] T014 [US1] In `generate-api-client.sh` step 3: `dart run build_runner build` in `frontend/lib/generated/felloway_api/`
- [x] T015 [US1] Run `generate-api-client.sh` and commit regenerated `shared/api-contracts/openapi.json`
- [x] T016 [US1] Run script output commit for `frontend/lib/generated/felloway_api/` (include `*.g.dart` from build_runner)
- [x] T017 [US1] Add `felloway_api` path dependency in `frontend/pubspec.yaml` → `lib/generated/felloway_api`
- [x] T018 [US1] Exclude `lib/generated/felloway_api/**` from app analyzer noise in `frontend/analysis_options.yaml` if needed
- [x] T019 [US1] Run `flutter pub get` and `flutter analyze` in `frontend/`

**Checkpoint**: US1 complete — contract edit → script → Dart types update without hand-editing generated files.

---

## Phase 4: User Story 2 — Standard tooling only (P1)

**Goal**: Pipeline uses only npm CLIs; repository has zero custom merge/codegen tools for this feature.

**Independent Test**: `grep -r dotnet shared/api-contracts/scripts/` returns nothing; `tools/OpenApiContractMerge` does not exist; script invokes `openapi-generator-cli`.

### Implementation

- [x] T020 [US2] Verify `shared/api-contracts/scripts/generate-api-client.sh` contains no `dotnet` / `OpenApiContractMerge` references
- [x] T021 [US2] Verify repository has no `tools/OpenApi.ContractMerge/` or `tools/OpenApiContractMerge/` after Phase 1
- [x] T022 [US2] Document global install in `shared/api-contracts/README.md`: `npm install -g @openapitools/openapi-generator-cli`
- [x] T023 [US2] Align `specs/004-openapi-dart-codegen/contracts/codegen-pipeline.md` with final script commands

**Checkpoint**: SC-004 satisfied — zero custom `tools/` projects for codegen.

---

## Phase 5: User Story 3 — Onboarding (P2)

**Goal**: New contributors install prerequisites and run one script from README.

**Independent Test**: Follow `quickstart.md` on a clean machine (Node + Java + global generator); script completes in &lt; 5 minutes.

### Implementation

- [x] T024 [P] [US3] Update `specs/004-openapi-dart-codegen/quickstart.md` with final prerequisite and troubleshooting steps
- [x] T025 [US3] Update root `README.md` codegen pointer (npm global install, no .NET for codegen)
- [x] T026 [US3] Update `.github/pull_request_template.md` checklist: run `generate-api-client.sh` when contracts change

**Checkpoint**: US3 complete — onboarding docs match npm-only pipeline.

---

## Phase 6: Polish & cross-cutting

- [x] T027 Run `dotnet test backend/FelloWay.slnx` after `OpenApiContractMerger` restore
- [x] T028 [P] Mark `specs/004-openapi-dart-codegen/spec.md` status **Implemented** when all tasks pass
- [x] T029 [P] Mark all tasks `[x]` in this file after verification

---

## Dependencies & execution order

```text
Phase 1 (revert) → Phase 2 (config) → Phase 3 US1 (script + artifacts)
                                      ↘ Phase 4 US2 (verify tooling)
                                      ↘ Phase 5 US3 (docs)
                                      → Phase 6 (polish)
```

| Story | Depends on |
|-------|------------|
| US1 | Phase 1 + Phase 2 |
| US2 | Phase 1 + US1 script |
| US3 | US1 script stable |

## Parallel execution examples

```text
# After Phase 1 completes:
T007 + T008 + T009 in parallel (different files)

# During US3 (after US1):
T024 + T025 + T026 in parallel

# Polish:
T027 parallel with T028 + T029
```

## Implementation strategy

### MVP (User Story 1 only)

1. Complete Phase 1–2 (revert + config).
2. Complete Phase 3 (bash script + regenerate + `flutter analyze`).
3. **STOP and validate**: change one YAML field → re-run script → Dart updates.

### Full delivery

4. Phase 4 — confirm no `tools/` / no `dotnet` in script.
5. Phase 5 — README / PR template / quickstart.
6. Phase 6 — backend tests + spec status.

## Task summary

| Phase | Tasks | Story |
|-------|-------|-------|
| 1 Setup (revert) | T001–T006 | — |
| 2 Foundational | T007–T010 | — |
| 3 US1 Regenerate client | T011–T019 | US1 |
| 4 US2 npm only | T020–T023 | US2 |
| 5 US3 Onboarding | T024–T026 | US3 |
| 6 Polish | T027–T029 | — |
| **Total** | **29** | |

**Suggested MVP scope**: Phase 1 + Phase 2 + Phase 3 (T001–T019).

**Parallel opportunities**: 6 tasks marked `[P]` (T007–T010, T024, T028–T029).
