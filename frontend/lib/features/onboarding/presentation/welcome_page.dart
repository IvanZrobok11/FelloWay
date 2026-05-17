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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Semantics(
        container: true,
        label: l10n.onboardingWelcomeSemanticsLabel,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.35),
                scheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryContainer,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        size: 56,
                        color: scheme.onPrimaryContainer,
                        semanticLabel: l10n.onboardingWelcomeTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.onboardingWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingWelcomeBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(flex: 2),
                  FilledButton(
                    onPressed: () => context.go(
                      '/onboarding/name',
                      extra: draft ?? OnboardingDraft(),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.onboardingWelcomeGetStarted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/sign-in'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.onboardingWelcomeLogIn),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
