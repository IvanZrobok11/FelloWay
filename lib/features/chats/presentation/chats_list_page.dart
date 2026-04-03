import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context).isAuthenticated;

    if (!auth) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.chatsGuestMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/sign-in'),
                  child: Text(l10n.signInTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatsPlaceholderTitle)),
      body: Center(child: Text(l10n.chatsPlaceholderTitle)),
    );
  }
}
