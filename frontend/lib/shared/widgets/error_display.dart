import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                semanticLabel: l10n?.commonErrorTitle,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(l10n?.commonRetry ?? 'Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
