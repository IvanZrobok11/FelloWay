import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../application/auth_completion_service.dart';
import '../mobile/linkedin_bff_auth.dart';
import '../web/bff_ticket_from_browser.dart';
import '../web/linkedin_bff_web_auth.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../onboarding/domain/onboarding_draft.dart';
import '../../profile/domain/user_profile.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import '../../../shared/errors/result.dart';

class OAuthSignInPage extends StatefulWidget {
  const OAuthSignInPage({super.key});

  @override
  State<OAuthSignInPage> createState() => _OAuthSignInPageState();
}

class _OAuthSignInPageState extends State<OAuthSignInPage> {
  bool _finishing = false;
  bool _shownSessionExpired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shownSessionExpired) return;
    String? reason;
    String? error;
    try {
      final state = GoRouterState.of(context);
      reason = state.uri.queryParameters['reason'];
      error = state.uri.queryParameters['error'];
    } on Object {
      return;
    }
    if (reason == 'session_expired' || (error != null && error.isNotEmpty)) {
      _shownSessionExpired = true;
      final l10n = AppLocalizations.of(context)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final message = reason == 'session_expired'
            ? l10n.oauthSessionExpired
            : l10n.oauthFailed(error ?? reason ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  Future<void> _signInWithLinkedIn() async {
    final l10n = AppLocalizations.of(context)!;
    final config = AppScope.configOf(context);
    final authCompletion = AppScope.authCompletionOf(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _finishing = true);
    try {
      if (kIsWeb) {
        linkedInBffSignInWeb(
          apiBaseUrl: config.apiBaseUrl,
          returnOrigin: Uri.base.origin,
        );
        return;
      }

      final result = await linkedInBffSignInMobile(apiBaseUrl: config.apiBaseUrl);
      switch (result) {
        case LinkedInBffMobileCancelled():
          return;
        case LinkedInBffMobileError(:final message):
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.oauthFailed(message))),
          );
          return;
        case LinkedInBffMobileTicket(:final ticket):
          final result = await authCompletion.completeFromTicket(ticket);
          if (result != AuthCompletionResult.success) {
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.oauthMissingTokens)),
            );
            return;
          }
          if (!mounted) return;
          await _afterAuthenticated();
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.oauthFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  Future<void> _afterAuthenticated() async {
    setState(() => _finishing = true);
    try {
      final store = AppScope.onboardingDraftStoreOf(context);
      final users = AppScope.usersOf(context);
      final onboarding = AppScope.onboardingOf(context);
      final l10n = AppLocalizations.of(context)!;
      final pending = store.loadPending();

      if (pending != null) {
        var pushDraft = true;
        final me = await users.getMe();
        if (!mounted) return;
        switch (me) {
          case Success(:final value):
            final hasServerProfile =
                value.displayName.trim().isNotEmpty &&
                value.homeCityLabel.trim().isNotEmpty;
            pushDraft = !hasServerProfile;
          case Failure():
            pushDraft = true;
        }

        if (pushDraft) {
          final profile = UserProfile(
            id: '',
            displayName: pending.displayName,
            interests: pending.interests,
            hobbies: pending.hobbies,
            homeCityLabel: pending.homeCityLabel,
            homeCityId: _devHomeCityIdFromDefine(),
          );
          final up = await users.updateMe(profile);
          if (!mounted) return;
          switch (up) {
            case Success():
              await store.clearPending();
              await onboarding.setComplete(true);
            case Failure(:final error):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.onboardingSaveFailed(error.message)),
                ),
              );
              context.go('/onboarding/welcome', extra: OnboardingDraft());
              return;
          }
        } else {
          await store.clearPending();
          await onboarding.setComplete(true);
        }
      }

      if (!mounted) return;
      if (onboarding.isComplete) {
        context.go('/events');
      } else {
        context.go('/onboarding/welcome', extra: OnboardingDraft());
      }
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  static String? _devHomeCityIdFromDefine() {
    const raw = String.fromEnvironment('DEV_HOME_CITY_ID', defaultValue: '');
    return raw.isEmpty ? null : raw;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = AppScope.configOf(context);
    final error = Uri.base.queryParameters['error'];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.signInSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (error != null && error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.oauthFailed(error),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (kIsWeb) ...[
                  Text(
                    'LinkedIn BFF login: ${config.apiBaseUrl}/auth/linkedin/login',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _finishing ? null : _signInWithLinkedIn,
                  icon: const Icon(Icons.business_center_outlined),
                  label: Text(l10n.oauthLinkedIn),
                ),
              ],
            ),
          ),
          if (_finishing)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// Web route after API redirects to `/auth/success?ticket=...` (JWT handoff).
class OAuthBffSuccessPage extends StatefulWidget {
  const OAuthBffSuccessPage({super.key});

  @override
  State<OAuthBffSuccessPage> createState() => _OAuthBffSuccessPageState();
}

class _OAuthBffSuccessPageState extends State<OAuthBffSuccessPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_complete());
    });
  }

  Future<void> _complete() async {
    final l10n = AppLocalizations.of(context)!;
    final session = AppScope.authSessionOf(context);
    final users = AppScope.usersOf(context);
    final onboarding = AppScope.onboardingOf(context);
    final store = AppScope.onboardingDraftStoreOf(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final ticket = readBffTicket(uri: GoRouterState.of(context).uri);
      final authCompletion = AppScope.authCompletionOf(context);
      if (!session.isAuthenticated) {
        if (ticket != null && ticket.isNotEmpty) {
          final result = await authCompletion.completeFromTicket(ticket);
          if (!mounted) return;
          if (result != AuthCompletionResult.success) {
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.oauthMissingTokens)),
            );
            context.go('/sign-in');
            return;
          }
        } else if (!authCompletion.shouldProbeCookieSession) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.oauthMissingTokens)),
          );
          context.go('/sign-in');
          return;
        } else {
          final me = await users.getMe();
          if (!mounted) return;
          switch (me) {
            case Success():
              session.setAuthenticatedFromCookie();
            case Failure(:final error):
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.oauthFailed(error.message))),
              );
              context.go('/sign-in');
              return;
          }
        }
      }

      final pending = store.loadPending();
      if (pending != null) {
        var pushDraft = true;
        final meAgain = await users.getMe();
        if (!mounted) return;
        if (meAgain case Success(:final value)) {
          pushDraft =
              value.displayName.trim().isEmpty ||
              value.homeCityLabel.trim().isEmpty;
        }
        if (pushDraft) {
          final profile = UserProfile(
            id: '',
            displayName: pending.displayName,
            interests: pending.interests,
            hobbies: pending.hobbies,
            homeCityLabel: pending.homeCityLabel,
            homeCityId: _OAuthSignInPageState._devHomeCityIdFromDefine(),
          );
          final up = await users.updateMe(profile);
          if (!mounted) return;
          if (up case Failure(:final error)) {
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.onboardingSaveFailed(error.message))),
            );
            context.go('/onboarding/welcome', extra: OnboardingDraft());
            return;
          }
          await store.clearPending();
          await onboarding.setComplete(true);
        }
      }

      if (!mounted) return;
      _navigateAfterAuth(context, onboarding);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.oauthFailed(e.toString()))),
      );
      context.go('/sign-in');
    }
  }

  void _navigateAfterAuth(
    BuildContext context,
    OnboardingPreferences onboarding,
  ) {
    if (onboarding.isComplete) {
      context.go('/events');
    } else {
      context.go('/onboarding/welcome', extra: OnboardingDraft());
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.authSessionOf(context);
    final onboarding = AppScope.onboardingOf(context);
    if (session.isAuthenticated &&
        onboarding.isComplete &&
        readBffTicket(uri: GoRouterState.of(context).uri) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateAfterAuth(context, onboarding);
      });
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
