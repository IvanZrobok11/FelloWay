# Research: Mobile typography (014)

**Date**: 2026-05-26

## 1. Primary typeface selection

**Decision**: **Onest** (Option A from spec) as the sole production family.

**Rationale**:

- Spec default for Ukrainian-first product; Cyrillic quality for і/ї/є/ґ.
- Warm geometric tone fits orange-brown / cosmic gradient brand (`FellowayColors`).
- Weights 400–600 cover menu, sections, and tab states without loading 700.

**Alternatives considered**:

- **Inter** — best small-size neutrality; rejected as default for weaker brand warmth on hero gradients.
- **Manrope** — strong UI grotesk; rejected as default in favor of Onest’s Ukrainian positioning.

## 2. Font delivery in Flutter

**Decision**: **Bundle static TTF** files in `frontend/assets/fonts/onest/` and declare in `pubspec.yaml` `fonts:` section. Set `ThemeData(fontFamily: 'Onest')`.

**Rationale**:

- Meets **NFR-PERF-001** (no runtime network fetch on cold start).
- Same binaries for iOS, Android, and web builds (no FOUT from CDN).
- Predictable CI/reproducible builds.

**Alternatives considered**:

- **`google_fonts` package** — fast to prototype; runtime fetch/cache unless disabled; adds dependency and network edge cases on web.
- **System font (Roboto/SF Pro)** — zero bundle cost; poor Ukrainian brand distinction and inconsistent cross-platform metrics.

## 3. Token architecture

**Decision**: `ThemeExtension<FellowayTypography>` for app-specific roles + `FellowayTextColors` for semantic white-opacity colors; map roles into Material 3 `TextTheme` for widgets that use `theme.textTheme` only.

**Rationale**:

- Constitution III: centralized design system.
- `ListTile`, `AppBar`, `NavigationBar` read from theme without per-widget font family strings.
- Extension accessible via `Theme.of(context).extension<FellowayTypography>()!`.

**Alternatives considered**:

- **Only TextTheme** without extension — forces awkward reuse of `headlineSmall` for tab labels.
- **Separate typography package** — over-engineering for single app.

## 4. Letter spacing in Flutter

**Decision**: Store letter spacing in **logical pixels** per role (`letterSpacing: -0.5` for −0.02em at 28sp ≈ -0.56). Use `TextStyle.letterSpacing` directly.

**Rationale**: Flutter has no `em` unit on `TextStyle`; convert at definition time from spec table.

## 5. Contrast on gradient backgrounds

**Decision**: Semantic colors on **white with alpha**; keep localized scrims (`brandDark` 55–82% alpha) on app bar and nav; add optional `ListTile` tile scrim only if contrast audit fails.

**Rationale**: Matches spec; existing `AppBar` / `NavigationBar` already use translucent dark fills.

**Alternatives considered**:

- **Flat `#FFFFFF` everywhere** — fails on bright gradient bands.
- **Full-screen dark overlay** — kills blur aesthetic.

## 6. Web platform

**Decision**: Same bundled Onest for `flutter build web`; verify font manifest in `FontManifest.json` after build.

**Rationale**: Spec assumes shared typography; bundled fonts work on web without `index.html` link tags.

## 7. Stream Chat UI

**Decision**: Do not fork `stream_chat_flutter` theme in v1; document as known limitation if message list uses SDK defaults.

**Rationale**: Out of spec scope; high cost to maintain across SDK upgrades.
