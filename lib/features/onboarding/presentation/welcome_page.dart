import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:felloway_client/l10n/app_localizations.dart';
import '../domain/onboarding_draft.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = GoRouterState.of(context).extra as OnboardingDraft?;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingWelcomeTitle)),
      body: Semantics(
        container: true,
        label: l10n.onboardingWelcomeSemanticsLabel,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onboardingWelcomeBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(
                  '/onboarding/name',
                  extra: draft ?? OnboardingDraft(),
                ),
                child: Text(l10n.onboardingContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
