# Implementation Plan: Mobile typography system (Ukrainian UI)

**Branch**: `014-mobile-typography` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/014-mobile-typography/spec.md`

## Summary

Adopt **Onest** as the single app-wide sans-serif with a centralized **type scale** and **text color tokens** for dark gradient/blur UI. Implement via Flutter `ThemeData` + `ThemeExtension` in `frontend/lib/app/theme/`, bundle font files (weights 400, 500, 600) for startup performance, and roll out starting with **Profile** + **bottom navigation**, then remaining tabs. Validate Ukrainian Cyrillic QA strings and WCAG contrast on gradient screenshots.

## Technical Context

**Languages/Versions**:

- **Frontend**: Dart 3.10+ / Flutter stable (`frontend/`, SDK `^3.10.4`)
- **Platforms**: iOS, Android (primary); web uses same theme (no separate web font CDN required if bundled)

**Primary Dependencies**:

- Flutter Material 3 (`ThemeData`, `TextTheme`, `ThemeExtension`)
- New: bundled **Onest** font files under `frontend/assets/fonts/onest/` (no runtime Google Fonts fetch in production)
- Existing: `app_theme.dart`, `felloway_colors.dart`, `go_router`, `MainShell` / `NavigationBar`

**Storage**: N/A (static font assets in repo)

**Testing**:

- `flutter analyze` + `dart format`
- Widget tests: Profile guest + signed-in list uses theme styles (no hardcoded `fontSize` on key labels)
- Golden tests (optional v1): Profile header + tab bar on gradient background fixture
- Manual: contrast checker on screenshots; 5-user Ukrainian readability (spec SC-001)

**Target Platform**: iOS + Android; web inherits bundled font

**Performance Goals**:

- Cold start font impact **≤150ms** vs baseline (measure on mid-range Android after bundling 3 weights)
- 60fps scrolling on Profile `ListView` (no per-frame text layout changes)

**Constraints**:

- Ukrainian Cyrillic complete in bundled cuts (verify glyphs і, ї, є, ґ)
- System text scale **1.0–1.3** without clipping tab labels (`NavigationDestinationLabelBehavior.alwaysShow`)
- Align with existing `FellowayColors` (yellow accent, dark scrim app bar/nav)

**Scale/Scope**:

- **P1**: `app_theme.dart`, new `felloway_typography.dart` / `felloway_text_colors.dart`, `profile_page.dart`, `main_shell.dart` (nav theme already partial)
- **P2**: Events, Chats, Map, onboarding screens — replace ad-hoc `TextStyle` with theme roles
- **Out of scope v1**: Second display font; per-screen custom fonts; Stream Chat SDK internal typography override (best-effort only)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Code quality | Pass | `flutter analyze` on theme + Profile; no magic numbers in touched widgets |
| Test strategy | Pass | Widget tests for Profile/nav; golden optional; regression for tab label weights |
| UX consistency | Pass | Single family + tokens; Material 3 `TextTheme` + extension for app-specific roles |
| Performance | Pass | Bundle 3 weights only; document startup measurement in quickstart |
| Flutter checks | Pass | CI existing frontend pipeline runs analyze/test |
| Evidence | Pass | quickstart contrast + Cyrillic checklist; golden artifacts if added |

**Post-design re-check**: Pass. Bundled fonts justified over `google_fonts` runtime fetch (see [research.md](./research.md)).

## Project Structure

### Documentation (this feature)

```text
specs/014-mobile-typography/
├── plan.md              # This file
├── research.md          # Font loading + M3 mapping decisions
├── data-model.md        # Type roles + color tokens
├── quickstart.md        # Implement + verify steps
├── contracts/
│   └── typography-tokens.md
└── tasks.md             # Phase 2 (/speckit.tasks)
```

### Source Code (repository root)

```text
frontend/
├── assets/fonts/onest/           # Onest-400/500/600 .ttf (SIL OFL)
├── lib/app/theme/
│   ├── app_theme.dart            # wire fontFamily + textTheme
│   ├── felloway_colors.dart      # existing brand palette
│   ├── felloway_typography.dart  # NEW: ThemeExtension + scale
│   └── felloway_text_colors.dart # NEW: semantic text opacities on white
├── lib/app/shell/main_shell.dart
├── lib/features/profile/presentation/profile_page.dart
└── test/
    ├── widget/profile_typography_test.dart  # NEW
    └── golden/                              # optional
```

**Structure Decision**: Flutter-only change under `frontend/lib/app/theme/`; features consume `Theme.of(context)` / `context.fellowayTypography` extension rather than importing font names directly.

## Implementation Phases

### Phase A — Foundation (blocking)

1. Download **Onest** static TTFs (400, 500, 600) from Google Fonts; add to `pubspec.yaml` `fonts:` section.
2. Create `FellowayTextColors` semantic tokens (`primary` 96%, `secondary` 74%, `tertiary` 58%, `accent` = `brandYellow`).
3. Create `FellowayTypography` `ThemeExtension` with roles: `screenTitle`, `sectionLabel`, `menuRow`, `bodySupporting`, `tabLabel`, `tabLabelSelected`.
4. Build `TextTheme` from Onest mapping to M3 (`titleLarge` ← sectionLabel, `bodyLarge` ← menuRow, etc.).
5. Update `AppTheme.light()` to set `fontFamily: 'Onest'`, merged `textTheme`, `appBarTheme.titleTextStyle` = `screenTitle` scaled for app bar (28sp spec → may use 22–28 in `AppBar` per platform density).

### Phase B — Profile + navigation (P1)

1. `profile_page.dart`: remove implicit defaults; use `ListTile` with theme `titleTextStyle` / `subtitleTextStyle` or explicit `style: theme.textTheme...`.
2. Section headers («Інтереси»): `sectionLabel` + `textPrimary`.
3. `navigationBarTheme.labelTextStyle`: apply `tabLabel` / `tabLabelSelected` with `FellowayTextColors` (replace raw `Colors.white70`).
4. App bar title: align with `screenTitle` (Profile «Профіль»).

### Phase C — App-wide rollout (P2)

1. Grep `fontSize` / `fontWeight` in `lib/features/`; migrate high-traffic screens (Events list, Chats, onboarding welcome).
2. Document exceptions in quickstart if Stream Chat UI cannot fully inherit.

### Phase D — Validation

1. Screenshot contrast on gradient (`AppBackground`) for menu + tab labels.
2. Cyrillic QA string list from spec.
3. Text scale 1.3 smoke on Profile + nav.

## Complexity Tracking

> No constitution violations requiring justification.

## Generated Artifacts (Phase 0–1)

| Artifact | Path |
|----------|------|
| Research | [research.md](./research.md) |
| Data model | [data-model.md](./data-model.md) |
| Contract | [contracts/typography-tokens.md](./contracts/typography-tokens.md) |
| Quickstart | [quickstart.md](./quickstart.md) |

**Next**: `/speckit.tasks` to break into implementation tasks.
