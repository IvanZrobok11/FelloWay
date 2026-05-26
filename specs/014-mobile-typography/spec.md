# Feature Specification: Mobile typography system (Ukrainian UI)

**Feature Branch**: `014-mobile-typography`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: Select a modern sans-serif type system for FelloWay (iOS/Android) with perfect Ukrainian Cyrillic, readable on dark blur/gradient UI (Profile screen and app-wide). Provide three candidate families with size/weight/spacing guidance and text color contrast rules.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read Profile and settings comfortably (Priority: P1)

A signed-in user opens **Profile** on a phone and scans the screen title, section labels (e.g. «Інтереси», «Хобі»), menu rows («Редагувати профіль», «Налаштування сповіщень»), and bottom navigation labels without squinting or misreading Ukrainian letters (і, ї, є, ґ).

**Why this priority**: Profile is the reference screen; poor typography here affects trust and usability across the app.

**Independent Test**: Show Profile to 5+ Ukrainian-speaking testers on iOS and Android in normal indoor lighting; ≥80% rate all text as «easy to read» without zooming.

**Acceptance Scenarios**:

1. **Given** the Profile screen with gradient/blur background, **When** the user reads the screen title and menu items at arm’s length, **Then** all Ukrainian text is legible without system font scaling above default.
2. **Given** body and caption text at 12–16 logical px equivalent, **When** the user reads labels on the bottom navigation bar, **Then** selected and unselected states are distinguishable by weight and/or opacity, not size alone.
3. **Given** strings containing «ї», «є», «ґ», **When** displayed in the chosen typeface, **Then** no distorted or clipped glyphs appear compared to Latin letters at the same size.

---

### User Story 2 - Consistent typography across the app (Priority: P2)

A user moves between Events, Map, Chats, and Profile and perceives one coherent typographic voice (same family, predictable hierarchy).

**Why this priority**: Fragmented fonts undermine the modern, premium brand on gradient backgrounds.

**Independent Test**: Audit four main tabs side-by-side; a design reviewer confirms one primary family and a documented type scale applied to headings, labels, and captions.

**Acceptance Scenarios**:

1. **Given** any primary tab screen, **When** compared to Profile, **Then** screen titles use the same role (size/weight) as Profile’s «Профіль».
2. **Given** list rows with icon + label, **When** shown on dark translucent surfaces, **Then** menu text uses the same role as Profile action rows.

---

### User Story 3 - Accessible contrast on dark gradients (Priority: P2)

A user with mild vision impairment or in bright sunlight still distinguishes primary text, secondary text, and disabled/hint text on orange-brown and cosmic gradient backgrounds.

**Why this priority**: Low contrast on blur UI is a reported failure mode; typography and color must work together.

**Independent Test**: Verify text/background pairs meet at least WCAG 2.1 Level AA for normal text (4.5:1) for primary body on representative gradient samples; secondary labels may use large-text AA (3:1) only where size ≥18px bold or ≥24px regular.

**Acceptance Scenarios**:

1. **Given** primary menu labels on the darkest area of the gradient, **When** measured with a contrast checker on captured screenshots, **Then** contrast ratio ≥4.5:1 against the effective background.
2. **Given** tab bar unselected labels, **When** displayed, **Then** they remain readable (≥3:1 if treated as large/bold per guidelines, otherwise ≥4.5:1).

---

### Edge Cases

- **System font scaling**: UI remains usable at 1.3× text scale without clipping titles or tab labels (wrap or ellipsize rules documented).
- **Long Ukrainian words** in menu rows: single-line ellipsis or two-line wrap policy defined so «Налаштування сповіщень» does not collide with icons.
- **Mixed Latin + Cyrillic** (e.g. email, URLs): same family covers both scripts without switching font mid-line.
- **Web build** (if shared): chosen family is available for web without FOUT breaking layout (assumption: same family licensed for all platforms).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product MUST adopt **one primary sans-serif family** (with multiple weights) for the mobile app; an optional second family for marketing/display is out of scope unless explicitly approved later.
- **FR-002**: The chosen family MUST include complete **Ukrainian Cyrillic** (including і, ї, є, ґ) in regular use weights (400–700).
- **FR-003**: A documented **type scale** MUST define at least these roles: screen title, section heading, list/menu row, supporting caption, bottom navigation label.
- **FR-004**: Sizes for small UI text (12–16px equivalent) MUST be validated on real devices against the Profile reference layout.
- **FR-005**: **Line height** and **letter spacing** rules MUST be documented per role for dark gradient backgrounds.
- **FR-006**: **Text color tokens** MUST be defined (primary, secondary, disabled, accent/selected) using opacity on white or near-white, not arbitrary grays per screen.
- **FR-007**: Three **candidate families** MUST be evaluated and one **recommended default** selected with rationale (see Design Deliverable below).
- **FR-008**: Typography rules MUST apply app-wide, starting with Profile and bottom navigation, then roll out to other tabs.

### Non-Functional Requirements *(mandatory)*

- **NFR-QUALITY-001**: Typography tokens MUST be centralized so future screens do not hardcode one-off sizes.
- **NFR-TEST-001**: Visual regression or golden tests SHOULD cover Profile title, one menu row, and tab bar labels after implementation.
- **NFR-UX-001**: Typography MUST align with existing warm dark brand (orange-brown, cosmic gradient, yellow accent for selected nav).
- **NFR-PERF-001**: Font files bundled for mobile MUST not increase cold start by more than 150ms on mid-range devices (measure after implementation).
- **NFR-FLUTTER-001**: *(Implementation phase)* Analyze and format checks pass before merge.
- **NFR-FLUTTER-TEST-001**: Widget/golden tests for Profile typography when tokens are applied.
- **NFR-FLUTTER-UX-001**: Material 3 text roles map to the documented scale.
- **NFR-FLUTTER-PERF-001**: Limit loaded font weights to those in the scale (typically 400, 500, 600, 700).

### Validation Requirements *(mandatory)*

- **Design review**: Stakeholder signs off one candidate from §Design Deliverable using Profile mock on iOS + Android.
- **Contrast**: Screenshot-based contrast check on gradient background for primary and tab labels.
- **Cyrillic QA**: Native Ukrainian speaker approves glyph quality for test strings: «Профіль», «Редагувати», «Відгуки», «Їжак», «Європа», «Ґрунт».
- **Readability**: 5-user informal read test on Profile (Story 1 metric).

### Key Entities

- **Type role**: Named level (e.g. `screenTitle`, `sectionLabel`, `menuRow`, `tabLabel`) with size, weight, line height, letter spacing, color token.
- **Color token**: Semantic text color (e.g. `textPrimary`, `textSecondary`, `textOnAccent`) tied to opacity levels on white.
- **Candidate typeface**: A font family under evaluation with source URL and supported weights.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥80% of Ukrainian testers rate Profile text «easy to read» at default system text size (Story 1).
- **SC-002**: 100% of primary text samples on Profile meet WCAG AA contrast (4.5:1) on documented gradient snapshots.
- **SC-003**: One primary font family is selected and documented within 3 candidates; no production screen uses ad-hoc font families outside the system.
- **SC-004**: Tab bar labels at 12–13px equivalent remain readable; unselected vs selected states identified correctly by ≥90% of testers in a 5-second recognition task.

## Assumptions

- **Scope**: iOS and Android native shells; Flutter app shares one typography system. Web may follow in a later pass.
- **Language**: Ukrainian UI first; Latin characters appear only in user-generated or technical strings.
- **Style**: Existing blur/gradient aesthetic is retained; typography adapts to it rather than replacing backgrounds with flat panels.
- **Licensing**: All candidates are free for commercial app use (e.g. SIL Open Font License via Google Fonts).
- **No serif pair**: A display serif is not required for v1; one grotesk family with weight contrast is sufficient.
- **Default recommendation**: **Onest** is the preferred default for Ukrainian product tone unless brand mandates a more neutral global face (see candidates).

## Design Deliverable: Three recommended sans-serif candidates

Each option uses a **single family** with weight hierarchy (no mandatory second font). Sizes are **logical pixels** (sp) for mobile; line height as multiplier; letter spacing in em unless noted.

### Option A — Onest (recommended for Ukrainian product)

| Attribute | Value |
|-----------|--------|
| **Source** | [Google Fonts — Onest](https://fonts.google.com/specimen/Onest) |
| **Why** | Designed with Cyrillic/Ukrainian readability in mind; modern, slightly warm; fits orange/cosmic brand without feeling corporate-cold. |

| Role | Weight | Size | Line height | Letter spacing |
|------|--------|------|-------------|----------------|
| Screen title («Профіль») | 600 (SemiBold) | 28 | 1.15 (32) | −0.02em |
| Section label («Інтереси», «Хобі») | 600 | 17 | 1.25 (22) | −0.01em |
| Menu row / button | 500 (Medium) | 16 | 1.35 (22) | 0 |
| Supporting / metadata | 400 (Regular) | 14 | 1.4 (20) | 0.01em |
| Tab bar label | 500 unselected / 600 selected | 12 | 1.2 (14) | 0.02em |

---

### Option B — Manrope

| Attribute | Value |
|-----------|--------|
| **Source** | [Google Fonts — Manrope](https://fonts.google.com/specimen/Manrope) |
| **Why** | Geometric grotesk, excellent at small sizes, neutral-modern; strong for dense lists and Chats. |

| Role | Weight | Size | Line height | Letter spacing |
|------|--------|------|-------------|----------------|
| Screen title | 700 (Bold) | 26 | 1.2 (31) | −0.03em |
| Section label | 600 | 16 | 1.3 (21) | −0.01em |
| Menu row / button | 500 | 16 | 1.35 (22) | 0 |
| Supporting | 400 | 14 | 1.45 (20) | 0.01em |
| Tab bar label | 500 / 600 | 12 | 1.25 (15) | 0.03em |

---

### Option C — Inter

| Attribute | Value |
|-----------|--------|
| **Source** | [Google Fonts — Inter](https://fonts.google.com/specimen/Inter) |
| **Why** | Maximum legibility at 12–14px; ubiquitous, neutral; safest for long reading and small captions. Slightly less «character» on gradient hero UI. |

| Role | Weight | Size | Line height | Letter spacing |
|------|--------|------|-------------|----------------|
| Screen title | 600 | 27 | 1.2 (32) | −0.025em |
| Section label | 600 | 16 | 1.35 (22) | −0.015em |
| Menu row / button | 500 | 16 | 1.4 (22) | 0 |
| Supporting | 400 | 14 | 1.45 (20) | 0 |
| Tab bar label | 500 / 600 | 12 | 1.33 (16) | 0.025em |

### Text color on dark gradient (all options)

Use **white with opacity** on top of blur/dark scrim—not pure gray hex—so text picks up warmth from the background:

| Token | Suggested treatment | Use |
|-------|---------------------|-----|
| **textPrimary** | `#FFFFFF` at **92–100%** opacity | Screen titles, menu rows, primary actions |
| **textSecondary** | `#FFFFFF` at **70–78%** | Section hints, subtitles, unselected tab labels |
| **textTertiary** | `#FFFFFF` at **55–62%** | Placeholders, disabled rows, timestamps |
| **textAccent** | Brand yellow (existing) at **100%** | Selected tab label/icon, key metrics («Рейтинг» value) |
| **Scrim assist** | Optional **8–12% black** overlay behind text blocks on busiest gradient areas | Improves contrast without flattening the whole screen |

**Practical rule**: If a label fails contrast on the gradient, add localized scrim behind the text block (profile header, list card) rather than jumping to pure white only on that string—keeps visual unity.

**Selected tab bar**: Keep label at **600 weight** + accent yellow; unselected at **500** + `textSecondary` opacity—size stays 12sp so the state difference is color + weight, not smaller text.

## Decision

| Item | Recommendation |
|------|----------------|
| **Primary choice** | **Onest** (Option A) for Ukrainian-first brand and Profile reference screen |
| **Fallback** | Inter (Option C) if team prioritizes maximum small-size neutrality over brand warmth |
| **Next step** | `/speckit.plan` → token implementation in app theme, Profile + `NavigationBar` first |
