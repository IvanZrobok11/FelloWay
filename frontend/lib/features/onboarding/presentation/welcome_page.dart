import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:felloway_client/l10n/app_localizations.dart';
import '../../../app/theme/felloway_text_colors.dart';
import '../../../app/theme/felloway_typography.dart';
import '../../../shared/widgets/app_assets.dart';
import '../domain/onboarding_draft.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = GoRouterState.of(context).extra as OnboardingDraft?;
    final typo = context.fellowayTypography;
    final onGradient = context.fellowayTextColors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Semantics(
        container: true,
        label: l10n.onboardingWelcomeSemanticsLabel,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: typo.sectionLabel.copyWith(letterSpacing: 0.5),
                ),
                const Spacer(flex: 1),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        AppAssets.fellowayLogo,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        semanticLabel: l10n.onboardingWelcomeTitle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.onboardingWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: typo.screenTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingWelcomeBody,
                  textAlign: TextAlign.center,
                  style: typo.menuRow.copyWith(color: onGradient.primary),
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
    );
  }
}
