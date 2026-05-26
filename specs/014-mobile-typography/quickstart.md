# Quickstart: Onest typography rollout (014)

## Prerequisites

- Flutter stable, `frontend/` as cwd
- Download [Onest](https://fonts.google.com/specimen/Onest) static TTF: Regular (400), Medium (500), SemiBold (600)

## 1. Add fonts

```text
frontend/assets/fonts/onest/
  Onest-wght.ttf   # variable font (weights 400–600)
  OFL.txt
```

`pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Onest
      fonts:
        - asset: assets/fonts/onest/Onest-wght.ttf
```

## 2. Theme files (see plan)

- `felloway_text_colors.dart` — white @ 96% / 74% / 58%, accent yellow
- `felloway_typography.dart` — `ThemeExtension` + `buildTextTheme()`
- `app_theme.dart` — `fontFamily: 'Onest'`, extensions, nav + app bar

## 3. Verify locally

```powershell
cd frontend
flutter pub get
flutter analyze
flutter test test/widget/profile_typography_test.dart
flutter run -d <device> --dart-define=STREAM_API_KEY=<key> --dart-define=API_MODE=live ...
```

**Profile smoke**:

1. Sign in → **Profile** tab
2. Confirm «Профіль» title, menu rows, «Інтереси» / «Хобі» readable
3. Tab bar: selected = yellow + semibold; unselected = muted white

## 4. Cyrillic QA (30 sec)

Render: `Їжак`, `Європа`, `Ґрунт`, `Налаштування сповіщень` — no broken glyphs.

## 5. Contrast

Capture screenshot on gradient background → check menu title (`textPrimary`) and unselected tab (`textSecondary`) with any WCAG contrast tool (≥4.5:1 primary, ≥3:1 large/bold where applicable).

Profile header uses a light localized scrim (`Colors.black` @ 10%) behind the avatar row for readability on busy gradients.

## 6. Text scale

System settings → largest text (~1.3×) → Profile + nav still usable.

## 7. Performance (optional)

Compare cold start before/after fonts on one Android device; target ≤150ms delta per spec.

## Rollout order

1. Theme foundation  
2. Profile + `MainShell` / `NavigationBar`  
3. Events, Chats, Map, onboarding (grep `fontSize`)

## Related

- Spec: [spec.md](../spec.md)  
- Tokens: [contracts/typography-tokens.md](./typography-tokens.md)
