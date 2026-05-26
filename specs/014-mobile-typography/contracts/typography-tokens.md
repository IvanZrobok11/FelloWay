# Contract: FelloWay typography tokens

## Scope

All user-facing text in the Flutter client (`frontend/`) unless explicitly exempt (third-party SDK surfaces).

## Requirements

1. **Single family**: `Onest` only in production UI.
2. **Roles**: Widgets MUST use theme tokens from [data-model.md](../data-model.md), not inline `fontFamily` or ad-hoc sizes except in golden baselines.
3. **Colors**: Text on gradient/blur backgrounds MUST use `FellowayTextColors` semantic tokens, not raw `Colors.white70` / `Colors.grey`.
4. **Navigation bar**: Selected state = `tabLabelSelected` (weight 600 + `textAccent`); unselected = `tabLabel` (weight 500 + `textSecondary`). Same 12sp size for both.
5. **Profile reference**: `profile_page.dart` is the acceptance reference for menu row and section styles.

## Public API (implementation)

| Access | Contract |
|--------|----------|
| `Theme.of(context).textTheme.*` | M3-mapped styles (preferred for generic widgets) |
| `Theme.of(context).extension<FellowayTypography>()!` | App-specific roles |
| `Theme.of(context).extension<FellowayTextColors>()!` | Semantic text colors |

## Exemptions

| Area | Rule |
|------|------|
| `stream_chat_flutter` | Best-effort; not blocking merge |
| Debug overlays | May use monospace system font |

## Verification

| Check | Pass |
|-------|------|
| `rg "fontFamily:" lib/features` after rollout | Only theme or zero matches |
| Profile AppBar + ListTile + NavBar | Uses Onest visibly |
| Cyrillic QA strings | No clipping at 16sp menu |
| Contrast | Primary menu ≥4.5:1 on reference screenshot |
