import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/domain/onboarding_draft.dart';
import '../../features/profile/data/users_repository.dart';
import '../../shared/errors/result.dart';
import 'resolve_post_sign_in_route.dart';

/// Navigates after sign-in using [GET /users/me] display name (not welcome).
Future<void> navigateAfterSignIn(
  BuildContext context, {
  required UsersRepository users,
}) async {
  final me = await users.getMe();
  if (!context.mounted) return;
  final displayName = switch (me) {
    Success(:final value) => value.displayName,
    Failure() => '',
  };
  goPostSignInRoute(context, displayName);
}

void goPostSignInRoute(BuildContext context, String displayName) {
  final path = resolvePostSignInRoute(displayName);
  if (path == '/onboarding/name') {
    context.go(path, extra: OnboardingDraft());
  } else {
    context.go(path);
  }
}
