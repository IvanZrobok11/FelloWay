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
  final _hobbiesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??=
        GoRouterState.of(context).extra as OnboardingDraft? ??
        OnboardingDraft();
    final d = _draft!;
    if (_hobbiesController.text.isEmpty) {
      _hobbiesController.text = d.hobbies;
    }
  }

  @override
  void dispose() {
    _hobbiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingInterestsTitle)),
      body: ListView(
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
          Text(
            l10n.onboardingHobbiesSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hobbiesController,
            decoration: InputDecoration(
              labelText: l10n.onboardingHobbiesLabel,
              border: const OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
            onChanged: (v) => draft.hobbies = v,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              draft.hobbies = _hobbiesController.text.trim();
              if (draft.interests.isEmpty || draft.hobbies.isEmpty) return;
              context.go('/onboarding/city', extra: draft);
            },
            child: Text(l10n.onboardingContinue),
          ),
        ],
      ),
    );
  }
}
