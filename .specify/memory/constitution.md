<!--
Sync Impact Report
- Version change: 1.0.0 -> 1.1.0
- Modified principles:
  - I. Code Quality as a Release Gate -> I. Flutter Code Quality as a Release Gate
  - II. Test-Driven Delivery and Coverage Discipline
    -> II. Flutter Test Pyramid and Regression Discipline
  - III. User Experience Consistency by Default
    -> III. Cross-Platform UX Consistency by Default
  - IV. Performance Budgets Are Requirements
    -> IV. Mobile Performance Budgets Are Requirements
  - V. Quality Visibility and Documentation
    -> V. Delivery Evidence and Release Readiness
- Added sections:
  - None
- Removed sections:
  - None
- Templates requiring updates:
  - ✅ updated: .specify/templates/plan-template.md
  - ✅ updated: .specify/templates/spec-template.md
  - ✅ updated: .specify/templates/tasks-template.md
  - ⚠ pending (not present in repository): .specify/templates/commands/*.md
- Follow-up TODOs:
  - None
-->
# FelloWay Client Constitution

## Core Principles

### I. Flutter Code Quality as a Release Gate
All production Dart code MUST pass `dart format` and `flutter analyze` with no
unresolved errors. New logic MUST avoid dead code, TODO-only placeholders, and
implicit side effects across layers (UI, state, data). Pull requests MUST keep
changes scoped, readable, and null-safe, and MUST not merge with unresolved
critical findings. Rationale: strict Flutter quality gates prevent unstable app
behavior and preserve maintainability.

### II. Flutter Test Pyramid and Regression Discipline
Every feature and bug fix MUST include failing-first automated tests at the
appropriate level: unit tests for business logic, widget tests for UI behavior,
and integration tests for critical app journeys. Golden tests MUST be used for
stable visual components where layout consistency is required. Regression tests
are REQUIRED for production defects, and CI test failures block merge.
Rationale: a Flutter-specific test pyramid catches regressions early and
preserves confidence in release candidates.

### III. Cross-Platform UX Consistency by Default
User-visible behavior MUST follow shared navigation, loading, empty, error, and
accessibility patterns across Android and iOS. UI implementation MUST reuse the
project design system (theme, typography, spacing, and components) and MUST
respect platform conventions when intentionally diverging (Material/Cupertino).
Any UX deviation MUST be documented and approved. Rationale: consistent and
accessible cross-platform UX improves trust, usability, and retention.

### IV. Mobile Performance Budgets Are Requirements
Each feature specification MUST define measurable mobile performance targets,
including startup responsiveness, frame smoothness (jank-free interactions),
and memory impact where relevant. Feature changes that materially degrade agreed
budgets MUST be treated as release-blocking defects unless maintainers approve a
time-bound mitigation plan. Rationale: mobile performance directly determines
perceived quality and app adoption.

### V. Delivery Evidence and Release Readiness
Major technical decisions, architectural trade-offs, and known limitations MUST
be documented in spec/plan/task artifacts. Every release candidate MUST provide
traceable evidence for analyzer status, automated tests, UX acceptance, and
performance validation. Rationale: evidence-based readiness decisions reduce
release risk and shorten incident response.

## Delivery Standards

- Specifications MUST include explicit quality, testing, UX consistency, and
  performance requirements before implementation starts for Flutter delivery.
- Plans MUST pass a Constitution Check that confirms measurable success
  criteria, Flutter test strategy, UX consistency strategy, and performance
  budgets.
- Task breakdowns MUST include work items for test implementation, UX
  consistency validation, analyzer/lint compliance, and performance verification.

## Development Workflow & Quality Gates

- Feature flow is: `spec -> plan -> tasks -> implementation -> validation`.
- At least one reviewer MUST verify constitutional compliance before merge.
- Pre-release validation MUST include `flutter analyze`, `dart format` checks,
  required automated tests, UX acceptance confirmation, and performance
  verification against defined budgets.
- Exceptions MUST be time-bound, documented in the plan/spec, and approved by
  maintainers with a remediation task.

## Governance

This constitution supersedes conflicting local development habits or ad-hoc
processes for this repository.

Amendment policy:
- Any amendment MUST include rationale, impact assessment, and updates to
  affected templates.
- Amendment approval requires maintainer agreement in code review.

Versioning policy:
- MAJOR: Removes or redefines a principle in a backward-incompatible way.
- MINOR: Adds a principle/section or materially expands mandatory guidance.
- PATCH: Clarifications, wording improvements, and non-semantic refinements.

Compliance review expectations:
- Every plan and pull request MUST include a constitution compliance check.
- Non-compliant changes MUST not merge without an approved exception record.
- Periodic audits MAY be run; repeated violations require corrective actions.

**Version**: 1.1.0 | **Ratified**: 2026-04-01 | **Last Amended**: 2026-04-01
