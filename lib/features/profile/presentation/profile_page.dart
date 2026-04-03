import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePlaceholderTitle)),
      body: Center(child: Text(l10n.profilePlaceholderTitle)),
    );
  }
}
