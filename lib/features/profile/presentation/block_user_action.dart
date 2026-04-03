import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';

Future<void> confirmAndBlockUser(
  BuildContext context, {
  required String userId,
  required String displayName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.chatBlockUserTitle),
      content: Text(l10n.chatBlockUserBody(displayName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.chatBlockUserConfirm),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final users = AppScope.usersOf(context);
  final result = await users.blockUser(userId);
  if (!context.mounted) return;
  switch (result) {
    case Success():
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatBlockUserSuccess)));
    case Failure(:final error):
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
  }
}
