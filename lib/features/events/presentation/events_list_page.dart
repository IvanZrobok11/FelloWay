import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsPlaceholderTitle)),
      body: Center(child: Text(l10n.eventsPlaceholderTitle)),
    );
  }
}
