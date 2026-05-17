import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_completion.dart';

const _cities = [
  'Kyiv',
  'Lviv',
  'Odesa',
  'Kharkiv',
  'Dnipro',
  'Vinnytsia',
  'Ivano-Frankivsk',
];

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  OnboardingDraft? _draft;
  String? _city;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??=
        GoRouterState.of(context).extra as OnboardingDraft? ??
        OnboardingDraft();
    _city ??= _draft!.homeCityLabel.isNotEmpty ? _draft!.homeCityLabel : null;
  }

  Future<void> _finish(BuildContext context) async {
    final draft = _draft!;
    final city = _city?.trim() ?? '';
    if (city.isEmpty) return;
    draft.homeCityLabel = city;

    if (!OnboardingCompletion.isSatisfied(
      displayName: draft.displayName,
      interests: draft.interests,
      homeCityLabel: draft.homeCityLabel,
    )) {
      return;
    }

    setState(() => _saving = true);
    final store = AppScope.onboardingDraftStoreOf(context);
    final onboarding = AppScope.onboardingOf(context);
    await store.savePending(draft);
    await onboarding.setComplete(true);
    if (!context.mounted) return;
    setState(() => _saving = false);
    context.go('/events');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.onboardingCityTitle)),
      body: Semantics(
        container: true,
        label: '${l10n.onboardingCityTitle}. ${l10n.onboardingCityLabel}',
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.onboardingCityLabel,
                  border: const OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _cities.contains(_city) ? _city : null,
                    hint: Text(l10n.onboardingCityLabel),
                    items: _cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _city = v;
                      if (v != null) {
                        draft.homeCityLabel = v;
                      }
                    }),
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : () => _finish(context),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.onboardingWelcomeGetStarted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
