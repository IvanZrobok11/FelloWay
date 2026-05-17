import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../domain/trip_chat.dart';
import '../domain/trip_join_policy.dart';

/// One pending join request with optional low-rating banner (FR-024).
class TripRequestRow extends StatelessWidget {
  const TripRequestRow({
    super.key,
    required this.request,
    required this.onApprove,
  });

  final TripJoinRequest request;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final low = TripJoinPolicy.isLowRatingWarning(request.ratingAverage);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (low)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      l10n.tripLowRatingWarning,
                      key: const Key('trip_low_rating_banner'),
                    ),
                  ),
                ),
              ),
            ListTile(
              title: Text(request.displayName),
              subtitle: Text(l10n.tripRequesterCity(request.homeCityLabel)),
              trailing: request.ratingAverage != null
                  ? Text(
                      l10n.profileRating(
                        request.ratingAverage!.toStringAsFixed(1),
                      ),
                    )
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: ValueKey('approve_${request.userId}'),
                onPressed: onApprove,
                child: Text(l10n.tripApprove),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
