# Data model: Post-sign-in routing and text contrast

## Navigation entities

| Entity | Fields | Rules |
|--------|--------|-------|
| **PostSignInRoute** | `path`, `extra?` | Derived from profile display name only for this feature |
| **Display name** | `string` | Empty/whitespace → name onboarding; else events |
| **OnboardingPreferences.isComplete** | `bool` | Local install flag; no longer sole driver of post-sign-in landing |

## Route resolution (client)

```
after auth success + GET /users/me
├─ displayName empty  → /onboarding/name
└─ displayName set    → /events
```

**Not used** for post-sign-in default: `/onboarding/welcome`

## Router redirect (authenticated, incomplete local onboarding)

| Condition | Old | New |
|-----------|-----|-----|
| No display name, leaves protected route | → welcome | → `/onboarding/name` |
| Has display name | → welcome or block | → allow `/events` (no forced welcome) |

## Text surface classification

| Surface type | Examples | Text token |
|--------------|----------|------------|
| **Dark / brand** | App bar, nav bar, gradient scaffold, brown hero | `FellowayTextColors.onGradient` (light text) |
| **Light / white** | TextField fill, dropdown panel, event card body, chips on card | `ColorScheme.onSurface` or `FellowayTextColors.onLightSurface` |

## Onboarding draft (unchanged)

- `OnboardingDraft.displayName` may pre-fill name page when routing from sign-in
- City/interests flow unchanged after name step

## State transitions

| Event | From | To (route) |
|-------|------|------------|
| Sign-in success, no name | `/sign-in` | `/onboarding/name` |
| Sign-in success, has name | `/sign-in` or `/auth/success` | `/events` |
| Name saved (continue) | `/onboarding/name` | `/onboarding/interests` (existing) |
| Onboarding finished | `/onboarding/city` | `/events` (existing) |

## Validation rules

- `displayName.trim().isEmpty` ≡ name not set
- Contrast: light-surface text must use dark color; dark-surface text must use light color (WCAG ≥ 4.5:1 target)
