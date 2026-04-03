import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../onboarding/domain/onboarding_draft.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

class OAuthSignInPage extends StatelessWidget {
  const OAuthSignInPage({super.key});

  Future<void> _exchangeOAuth(BuildContext context) async {
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
      if (!context.mounted) return;
      context.go('/onboarding/welcome', extra: OnboardingDraft());
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.oauthFailed(e.toString()))),
      );
    }
  }

  Future<void> _demoSignIn(BuildContext context) async {
    final session = AppScope.authSessionOf(context);
    await session.setAuthenticated(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
    if (!context.mounted) return;
    context.go('/onboarding/welcome', extra: OnboardingDraft());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.signInSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _exchangeOAuth(context),
              icon: const Icon(Icons.business_center_outlined),
              label: Text(l10n.oauthLinkedIn),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _exchangeOAuth(context),
              icon: const Icon(Icons.facebook_outlined),
              label: Text(l10n.oauthFacebook),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => _demoSignIn(context),
                child: Text(l10n.demoSignIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
