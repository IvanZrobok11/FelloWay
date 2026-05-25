import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:felloway_client/l10n/app_localizations.dart';
import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../domain/interest_catalog_item.dart';
import '../domain/onboarding_draft.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  OnboardingDraft? _draft;
  List<InterestCatalogItem> _catalog = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??=
        GoRouterState.of(context).extra as OnboardingDraft? ??
        OnboardingDraft();
    if (_loading && _catalog.isEmpty) {
      _loadCatalog();
    }
  }

  Future<void> _loadCatalog({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final repo = AppScope.interestsOf(context);
    final res = await repo.fetchCatalog(forceRefresh: forceRefresh);
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _catalog = value;
          _loading = false;
        });
      case Failure(:final error):
        setState(() {
          _loading = false;
          _errorMessage = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft!;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null) ...[
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _loadCatalog(forceRefresh: true),
                child: Text(l10n.commonRetry),
              ),
            ] else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _catalog.map((item) {
                  final selected = draft.interests.contains(item.id);
                  return FilterChip(
                    label: Text(item.name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          draft.interests = {
                            ...draft.interests.toSet(),
                            item.id,
                          }.toList();
                        } else {
                          draft.interests = draft.interests
                              .where((e) => e != item.id)
                              .toList();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading || _errorMessage != null
                  ? null
                  : () {
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
