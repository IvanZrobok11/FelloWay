# Data model: Typography tokens (014)

Logical design tokens (not database entities). Implemented as Dart constants + `ThemeExtension`.

## Type roles (`FellowayTypography`)

| Role | Field | Size (sp) | Weight | Line height (sp) | Letter spacing (px) | Color token |
|------|-------|-----------|--------|------------------|----------------------|-------------|
| Screen title | `screenTitle` | 28 | 600 | 32 (1.15) | −0.56 | `textPrimary` |
| Section label | `sectionLabel` | 17 | 600 | 22 (1.25) | −0.17 | `textPrimary` |
| Menu row | `menuRow` | 16 | 500 | 22 (1.35) | 0 | `textPrimary` |
| Supporting | `bodySupporting` | 14 | 400 | 20 (1.4) | 0.14 | `textSecondary` |
| Tab label (unselected) | `tabLabel` | 12 | 500 | 14 (1.2) | 0.24 | `textSecondary` |
| Tab label (selected) | `tabLabelSelected` | 12 | 600 | 14 (1.2) | 0.24 | `textAccent` |

### Material 3 `TextTheme` mapping (reference)

| M3 role | Maps from |
|---------|-----------|
| `headlineMedium` | `screenTitle` |
| `titleMedium` | `sectionLabel` |
| `bodyLarge` | `menuRow` |
| `bodyMedium` | `bodySupporting` |
| `labelSmall` | `tabLabel` |

## Text color tokens (`FellowayTextColors`)

| Token | Definition | Typical use |
|-------|------------|-------------|
| `textPrimary` | `Colors.white` @ 96% alpha | Titles, menu titles, profile name |
| `textSecondary` | `Colors.white` @ 74% alpha | Subtitles, unselected tab labels, section hints |
| `textTertiary` | `Colors.white` @ 58% alpha | Disabled, placeholders, timestamps |
| `textAccent` | `FellowayColors.brandYellow` @ 100% | Selected tab, rating highlight |

## App bar adjustment

| Element | Style |
|---------|--------|
| App bar title | `screenTitle` at 22–24sp OR full 28sp if no large header below — implementer chooses one; document in quickstart |

## State / accessibility

| Concern | Rule |
|---------|------|
| Text scale factor | All roles use `sp` via `Theme` (Flutter scales automatically) |
| Max scale smoke | 1.3× — tab labels may wrap to 2 lines if `alwaysShow` |
| Long menu strings | `ListTile.title` `maxLines: 2`, `overflow: TextOverflow.ellipsis` |

## Validation strings (Cyrillic QA)

`Профіль`, `Редагувати профіль`, `Налаштування сповіщень`, `Відгуки про вас`, `Інтереси`, `Хобі`, `Їжак`, `Європа`, `Ґрунт`

## Relationships

```text
AppTheme.light()
  ├── fontFamily: Onest
  ├── textTheme (M3, derived from FellowayTypography)
  ├── extensions: [FellowayTypography, FellowayTextColors]
  ├── appBarTheme.titleTextStyle → screenTitle (adjusted)
  └── navigationBarTheme.labelTextStyle → tabLabel / tabLabelSelected
```
