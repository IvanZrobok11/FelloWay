# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Dart 3.x, Flutter stable channel or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., flutter_bloc, freezed, dio, go_router or NEEDS CLARIFICATION]  
**Storage**: [e.g., shared_preferences, hive, sqflite, secure storage, remote API, or N/A]  
**Testing**: [e.g., flutter test (unit/widget), integration_test, golden tests or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Android 8+, iOS 14+, Web or NEEDS CLARIFICATION]
**Project Type**: [Flutter mobile app/module/package or NEEDS CLARIFICATION]  
**Performance Goals**: [e.g., startup <2s on reference device, 60fps interactions, low jank]  
**Constraints**: [e.g., offline-capable, low-memory devices, battery-sensitive flows]  
**Scale/Scope**: [e.g., screens affected, expected DAU, localization scope]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Code quality gate defined: lint/format/static analysis + review expectations
  are explicit and measurable.
- Test strategy defined: failing-first tests, coverage for critical flows, and
  regression tests for defect-prone paths are planned.
- UX consistency strategy defined: shared components/tokens/states and
  accessibility behavior are identified for this feature.
- Performance budgets defined: measurable targets, validation method, and
  fallback/mitigation plan are documented.
- Flutter quality checks identified: `flutter analyze`, formatting checks, and
  required test suites (`unit/widget/integration`, plus golden where needed).
- Evidence plan defined: where analyzer, test, and performance results are
  recorded (CI logs, benchmark notes, screenshots/video captures if applicable).

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Flutter app (DEFAULT)
lib/
├── app/
├── features/
├── shared/
└── main.dart

test/
├── unit/
├── widget/
└── golden/

integration_test/
└── app_test.dart

# [REMOVE IF UNUSED] Option 2: Multi-package Flutter workspace
packages/
├── design_system/
├── data_layer/
└── feature_[name]/

apps/
└── mobile_app/

# [REMOVE IF UNUSED] Option 3: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 4: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
