# Tasks: Post-sign-in routing and readable onboarding/event text

**Input**: [plan.md](./plan.md), [spec.md](./spec.md)

## Phase 1: Routing (US1)

- [x] T001 Add `frontend/lib/app/router/resolve_post_sign_in_route.dart`
- [x] T002 Add `frontend/lib/app/router/post_sign_in_navigation.dart`
- [x] T003 Update `oauth_sign_in_page.dart` post-auth navigation
- [x] T004 Update `app_router.dart` redirect (name not welcome)
- [x] T005 Update `resolve_initial_location.dart` (name not welcome)

## Phase 2: Contrast (US2–US4)

- [x] T006 Add `FellowayTextColors.onLightSurface` in `felloway_text_colors.dart`
- [x] T007 Fix `name_page.dart` input text color
- [x] T008 Fix `city_page.dart` dropdown text color
- [x] T009 Fix `event_card.dart` light-surface text colors

## Phase 3: Tests & validation

- [x] T010 Add `test/unit/resolve_post_sign_in_route_test.dart`
- [x] T011 `flutter test --dart-define=STREAM_API_KEY_OPTIONAL=true` green
- [x] T012 `flutter analyze` green
- [ ] T013 Manual deployed dev smoke (VR-001–VR-003)

**Coordination**: Ship with live-only auth (015/016).
