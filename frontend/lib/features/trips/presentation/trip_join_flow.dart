import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../domain/trip_chat.dart';
import '../domain/trip_join_policy.dart';
import 'trip_channel_opener.dart';

/// Join / pending / open chat actions for one trip row.
class TripJoinBar extends StatelessWidget {
  const TripJoinBar({
    super.key,
    required this.trip,
    required this.eventId,
    required this.userHomeCity,
    required this.streamReady,
    required this.onUpdated,
  });

  final TripChatSummary trip;
  final String eventId;
  final String userHomeCity;
  final bool streamReady;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.tripsOf(context);

    switch (trip.myMembership) {
      case TripMyMembership.owner:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => context.push(
                '/trips/${trip.id}/requests?eventId=${Uri.encodeComponent(eventId)}',
              ),
              child: Text(l10n.tripManageRequests),
            ),
            if (streamReady)
              FilledButton.tonal(
                onPressed: () =>
                    openTripChannel(context, tripId: trip.id, eventId: eventId),
                child: Text(l10n.tripOpenChat),
              ),
          ],
        );
      case TripMyMembership.member:
        return streamReady
            ? FilledButton(
                onPressed: () =>
                    openTripChannel(context, tripId: trip.id, eventId: eventId),
                child: Text(l10n.tripOpenChat),
              )
            : const SizedBox.shrink();
      case TripMyMembership.pending:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tripPendingHint),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final r = await repo.cancelJoinRequest(trip.id);
                if (!context.mounted) return;
                switch (r) {
                  case Success():
                    onUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tripCancelRequestDone)),
                    );
                  case Failure(:final error):
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              child: Text(l10n.tripCancelRequest),
            ),
          ],
        );
      case TripMyMembership.none:
        final auto = TripJoinPolicy.expectAutoApprove(
          requesterHomeCity: userHomeCity,
          tripTargetCity: trip.targetCityLabel,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auto)
              Text(
                l10n.tripJoinAutoHint,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Text(
                l10n.tripJoinManualHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final r = await repo.requestJoin(trip.id);
                if (!context.mounted) return;
                switch (r) {
                  case Success():
                    onUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tripJoinRequested)),
                    );
                  case Failure(:final error):
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              child: Text(l10n.tripRequestJoin),
            ),
          ],
        );
    }
  }
}
