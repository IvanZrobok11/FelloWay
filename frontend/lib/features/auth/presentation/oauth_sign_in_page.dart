import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../app/config/app_config.dart';
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

  bool _oauthConfigured(AppConfig config) {
    final clientId = config.oauthClientId;
    final discovery = config.oauthDiscoveryUrl;
    return clientId != null &&
        clientId.isNotEmpty &&
        discovery != null &&
        discovery.isNotEmpty;
  }

  Future<void> _exchangeOAuth() async {
    final l10n = AppLocalizations.of(context)!;
    final config = AppScope.configOf(context);
    final session = AppScope.authSessionOf(context);
    final messenger = ScaffoldMessenger.of(context);

    final clientId = config.oauthClientId;
    final discovery = config.oauthDiscoveryUrl;
    final redirect =
        config.oauthRedirectUrl ?? 'com.felloway.app:/oauthredirect';

    if (clientId == null || discovery == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.oauthNotConfigured)));
      return;
    }

    try {
      const appAuth = FlutterAppAuth();
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirect,
          discoveryUrl: discovery,
          scopes: const ['openid', 'profile', 'email'],
        ),
      );
      final access = result.accessToken;
      final refresh = result.refreshToken ?? '';
      if (access == null || access.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.oauthMissingTokens)),
        );
        return;
      }
      await session.setAuthenticated(
        accessToken: access,
        refreshToken: refresh,
      );
      if (!mounted) return;
      await _afterAuthenticated();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.oauthFailed(e.toString()))),
      );
    }
  }

  Future<void> _devBackendSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    final session = AppScope.authSessionOf(context);
    final authApi = AppScope.authApiOf(context);
    try {
      final tokens = await authApi.exchangeLinkedIn(code: 'dev-smoke-user');
      if (tokens.accessToken.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Backend returned no access token')),
        );
        return;
      }
      await session.setAuthenticated(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      if (!mounted) return;
      await _afterAuthenticated();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Dev backend sign-in failed: $e')),
      );
    }
  }

  Future<void> _demoSignIn() async {
    final session = AppScope.authSessionOf(context);
    await session.setAuthenticated(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
    if (!mounted) return;
    await _afterAuthenticated();
  }

  /// Pushes locally collected registration to the server when appropriate, then
  /// navigates to `/events` or welcome.
  Future<void> _afterAuthenticated() async {
    setState(() => _finishing = true);
    try {
      final store = AppScope.onboardingDraftStoreOf(context);
      final users = AppScope.usersOf(context);
      final onboarding = AppScope.onboardingOf(context);
      final config = AppScope.configOf(context);
      final l10n = AppLocalizations.of(context)!;
      final pending = store.loadPending();

      if (pending != null) {
        var pushDraft = config.useMockApi;
        if (!config.useMockApi) {
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
        }

        if (pushDraft) {
          final profile = UserProfile(
            id: '',
            displayName: pending.displayName,
            interests: pending.interests,
            hobbies: pending.hobbies,
            homeCityLabel: pending.homeCityLabel,
            homeCityId: config.useMockApi ? null : _devHomeCityIdFromDefine(),
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
    final useMock = config.useMockApi;
    final oauthReady = _oauthConfigured(config);

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
                const SizedBox(height: 24),
                if (oauthReady) ...[
                  FilledButton.icon(
                    onPressed: _finishing ? null : _exchangeOAuth,
                    icon: const Icon(Icons.business_center_outlined),
                    label: Text(l10n.oauthLinkedIn),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _finishing ? null : _exchangeOAuth,
                    icon: const Icon(Icons.facebook_outlined),
                    label: Text(l10n.oauthFacebook),
                  ),
                ],
                if (!useMock && !oauthReady) ...[
                  FilledButton.icon(
                    onPressed: _finishing ? null : _devBackendSignIn,
                    icon: const Icon(Icons.developer_mode_outlined),
                    label: const Text('Sign in (local backend)'),
                  ),
                ],
                if (useMock && kDebugMode) ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _finishing ? null : _demoSignIn,
                    child: Text(l10n.demoSignIn),
                  ),
                ],
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
