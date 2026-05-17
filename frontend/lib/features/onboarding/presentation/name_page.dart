import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:felloway_client/l10n/app_localizations.dart';
import '../domain/onboarding_draft.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  TextEditingController? _controller;
  OnboardingDraft? _draft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final incoming =
        GoRouterState.of(context).extra as OnboardingDraft? ??
        OnboardingDraft();
    _draft ??= incoming;
    _controller ??= TextEditingController(text: incoming.displayName);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft!;
    final controller = _controller!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.onboardingNameTitle)),
      body: Semantics(
        container: true,
        label: '${l10n.onboardingNameTitle}. ${l10n.onboardingNameLabel}',
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.onboardingNameLabel,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (v) => draft.displayName = v,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  draft.displayName = controller.text.trim();
                  if (draft.displayName.isEmpty) return;
                  context.go('/onboarding/interests', extra: draft);
                },
                child: Text(l10n.onboardingContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
