import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:felloway_client/l10n/app_localizations.dart';
import '../domain/onboarding_draft.dart';

const _interestOptions = ['IT', 'Marketing', 'HR', 'Design'];

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  OnboardingDraft? _draft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??=
        GoRouterState.of(context).extra as OnboardingDraft? ??
        OnboardingDraft();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingInterestsTitle)),
      body: Semantics(
        container: true,
        label:
            '${l10n.onboardingInterestsTitle}. ${l10n.onboardingInterestsSection}',
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.onboardingInterestsSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((label) {
                final selected = draft.interests.contains(label);
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        draft.interests = {
                          ...draft.interests.toSet(),
                          label,
                        }.toList();
                      } else {
                        draft.interests = draft.interests
                            .where((e) => e != label)
                            .toList();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                draft.hobbies = '';
                if (draft.interests.isEmpty) return;
                context.go('/onboarding/city', extra: draft);
              },
              child: Text(l10n.onboardingContinue),
            ),
          ],
        ),
      ),
    );
  }
}
