# Contract: Post-sign-in navigation (Flutter client)

## Scope

FelloWay Flutter client (`frontend/lib`) after successful authentication (LinkedIn BFF mobile ticket, web cookie session, or `/auth/success` ticket exchange).

## Routing policy

1. After authentication succeeds and user profile is loaded (`GET /users/me` or equivalent cached result from sign-in flow), the client MUST navigate using **display name presence**, not the welcome onboarding screen.
2. If `displayName` is empty or whitespace-only → navigate to **`/onboarding/name`**.
3. If `displayName` is non-empty → navigate to **`/events`**.
4. **`/onboarding/welcome`** MUST NOT be the automatic destination immediately after sign-in.
5. OAuth return URLs (`/auth/success`) and sign-in page completion MUST apply the same policy (FR-008).

## Text contrast policy (onboarding + events)

| UI region | Background | Text color |
|-----------|------------|------------|
| Name input (typed text) | Light / white fill | Dark (readable on white) |
| City list / dropdown labels | Light / white | Dark |
| Event card body (title, meta, attendees) | Light card surface | Dark |
| App chrome on brown/gradient (existing) | Dark brand | Light |

## Observable acceptance

| Scenario | Expected first screen after sign-in |
|----------|--------------------------------------|
| New user, empty profile name | Name onboarding |
| Returning user with name | Events list |
| Any user | Not welcome (unless user navigates there manually) |

## Verification

- Unit tests on route resolver (name empty vs set)
- Widget/golden tests on name, city, event card text colors
- Manual deployed dev smoke (VR-001–VR-003 in spec)

## Related

- Profile API: `displayName` on `UserProfile` / `GET /users/me`
- Onboarding routes: `/onboarding/name`, `/onboarding/interests`, `/onboarding/city`
