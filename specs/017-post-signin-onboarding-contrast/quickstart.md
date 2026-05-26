# Quickstart: Post-sign-in routing and text contrast (017)

## What changed (one sentence)

**After sign-in: no name → name onboarding; has name → events (never welcome first). Onboarding inputs and event cards use dark text on white, light text on brown.**

## Manual smoke (deployed dev)

### Routing (VR-001)

1. **New account** (or profile with empty display name): sign in via LinkedIn BFF → land on **name** onboarding (not welcome).
2. **Returning account** with display name: sign in → land on **events** tab.
3. Confirm URL/path is not `/onboarding/welcome` immediately after sign-in.

### Contrast (VR-002, VR-003)

1. On **name** step: type in field — characters must be **dark on white** input.
2. On **city** step: open dropdown — city names **dark on white**.
3. On **events** list: card title/metadata on white card area **dark**; text on brown app bar/nav **light**.

## Automated checks

```bash
cd frontend
dart format .
flutter analyze
flutter test
```

Key tests to add/update:

- `test/unit/resolve_post_sign_in_route_test.dart`
- `test/widget/onboarding_input_contrast_test.dart` (optional)
- `test/golden/event_card_golden_test.dart`

## Troubleshooting

```text
Still lands on welcome after sign-in?
├─ Check resolvePostSignInRoute used in oauth_sign_in_page + app_router redirect
└─ Check GET /users/me returns displayName

White text invisible in name field?
├─ TextField style should use onSurface / onLightSurface token
└─ Global theme stays onGradient for gradient shell

Event title unreadable on card?
└─ EventCard body text must not use gradient textTheme on light Card.color
```

## Related

- [post-sign-in-navigation.md](./contracts/post-sign-in-navigation.md)
- [spec.md](./spec.md)
