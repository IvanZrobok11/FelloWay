---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks by default. Every user story requires automated
test coverage for its independently testable behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter app (default)**: `lib/`, `test/`, `integration_test/` at repository root
- **Flutter package**: `lib/`, `test/` at package root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume Flutter app structure - adjust based on plan.md structure

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create Flutter feature structure per implementation plan
- [ ] T002 Configure dependencies in pubspec and environment setup
- [ ] T003 [P] Configure linting/formatting and analyzer rules

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Setup app routing and navigation shell
- [ ] T005 [P] Implement authentication/session foundation (if required)
- [ ] T006 [P] Setup state-management scaffolding for features
- [ ] T007 Create core models/entities and mappers shared by stories
- [ ] T008 Configure error handling, user feedback states, and logging hooks
- [ ] T009 Setup environment/config management and flavor handling

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (REQUIRED) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T010 [P] [US1] Unit test for [logic] in test/unit/[name]_test.dart
- [ ] T011 [P] [US1] Widget test for [screen/component] in test/widget/[name]_test.dart
- [ ] T012 [US1] Integration test for [journey] in integration_test/[name]_test.dart

### Implementation for User Story 1

- [ ] T013 [P] [US1] Create [Entity1] model in lib/features/[feature]/domain/[entity1].dart
- [ ] T014 [P] [US1] Create [Entity2] model in lib/features/[feature]/domain/[entity2].dart
- [ ] T015 [US1] Implement [Repository/Service] in lib/features/[feature]/data/[service].dart (depends on T013, T014)
- [ ] T016 [US1] Implement [screen/flow] in lib/features/[feature]/presentation/[file].dart
- [ ] T017 [US1] Add validation, loading, and error states in UI/state layer
- [ ] T018 [US1] Add logging/analytics events for user story 1 flow
- [ ] T019 [US1] Verify UX consistency (theme, shared components, accessibility)
- [ ] T020 [US1] Verify performance budget (startup/frame/memory as applicable)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (REQUIRED) ⚠️

- [ ] T021 [P] [US2] Unit test for [logic] in test/unit/[name]_test.dart
- [ ] T022 [P] [US2] Widget test for [screen/component] in test/widget/[name]_test.dart
- [ ] T023 [US2] Integration test for [journey] in integration_test/[name]_test.dart

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create [Entity] model in lib/features/[feature]/domain/[entity].dart
- [ ] T025 [US2] Implement [Repository/Service] in lib/features/[feature]/data/[service].dart
- [ ] T026 [US2] Implement [screen/flow] in lib/features/[feature]/presentation/[file].dart
- [ ] T027 [US2] Integrate with User Story 1 components (if needed)
- [ ] T028 [US2] Verify UX consistency (theme, shared components, accessibility)
- [ ] T029 [US2] Verify performance budget (startup/frame/memory as applicable)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (REQUIRED) ⚠️

- [ ] T030 [P] [US3] Unit test for [logic] in test/unit/[name]_test.dart
- [ ] T031 [P] [US3] Widget test for [screen/component] in test/widget/[name]_test.dart
- [ ] T032 [US3] Integration test for [journey] in integration_test/[name]_test.dart

### Implementation for User Story 3

- [ ] T033 [P] [US3] Create [Entity] model in lib/features/[feature]/domain/[entity].dart
- [ ] T034 [US3] Implement [Repository/Service] in lib/features/[feature]/data/[service].dart
- [ ] T035 [US3] Implement [screen/flow] in lib/features/[feature]/presentation/[file].dart
- [ ] T036 [US3] Verify UX consistency (theme, shared components, accessibility)
- [ ] T037 [US3] Verify performance budget (startup/frame/memory as applicable)

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/ and feature quickstart
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional Flutter tests in test/unit/, test/widget/, integration_test/
- [ ] TXXX Cross-story UX consistency and accessibility audit
- [ ] TXXX Security hardening
- [ ] TXXX Run `flutter analyze` and full test matrix validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Domain/data models before repositories/services
- Repositories/services before UI screens/flows
- Core implementation before integration test stabilization
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test for [logic] in test/unit/[name]_test.dart"
Task: "Widget test for [screen] in test/widget/[name]_test.dart"
Task: "Integration test for [journey] in integration_test/[name]_test.dart"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in lib/features/[feature]/domain/[entity1].dart"
Task: "Create [Entity2] model in lib/features/[feature]/domain/[entity2].dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
