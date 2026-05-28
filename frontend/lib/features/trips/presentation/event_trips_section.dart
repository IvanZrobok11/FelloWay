import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/felloway_text_colors.dart';
import '../../../shared/errors/result.dart';
import '../domain/trip_chat.dart';
import 'trip_join_flow.dart';

/// Trip chats for an event (FR-013–FR-018). Shown on event detail when attending.
///
/// Network: one [TripsRepository.listTrips] call per refresh; [UsersRepository.getMe]
/// runs once in [_bootstrap] for join policy (not per trip row — no N+1 on the list).
class EventTripsSection extends StatefulWidget {
  const EventTripsSection({
    super.key,
    required this.eventId,
    required this.eventCity,
    required this.attending,
    required this.authenticated,
  });

  final String eventId;
  final String eventCity;
  final bool attending;
  final bool authenticated;

  @override
  State<EventTripsSection> createState() => _EventTripsSectionState();
}

class _EventTripsSectionState extends State<EventTripsSection> {
  List<TripChatSummary> _trips = [];
  bool _loading = true;
  String? _error;
  String _homeCity = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!widget.authenticated || !widget.attending) {
      setState(() => _loading = false);
      return;
    }
    final users = AppScope.usersOf(context);
    final me = await users.getMe();
    if (!mounted) return;
    switch (me) {
      case Success(:final value):
        _homeCity = value.homeCityLabel;
      case Failure():
        break;
    }
    await _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (!widget.attending) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = AppScope.tripsOf(context);
    final r = await repo.listTrips(widget.eventId);
    if (!mounted) return;
    switch (r) {
      case Success(:final value):
        setState(() {
          _trips = value;
          _loading = false;
        });
      case Failure(:final error):
        setState(() {
          _error = error.message;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streamReady = AppScope.streamChatOf(context).isReady;
    final onGradient = context.fellowayTextColors;

    if (!widget.authenticated) {
      return const SizedBox.shrink();
    }
    if (!widget.attending) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          l10n.tripsJoinEventHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: onGradient.primary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.tripsSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onGradient.primary,
                  ),
                ),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: onGradient.primary),
              onPressed: () async {
                final created = await context.push<bool>(
                  '/event/${widget.eventId}/trips/create?city=${Uri.encodeComponent(widget.eventCity)}',
                );
                if (created == true && mounted) await _loadTrips();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.tripCreateCta),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else if (_trips.isEmpty)
          Text(
            l10n.tripsEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onGradient.primary,
            ),
          )
        else
          ..._trips.map(
            (t) => _TripCard(
              trip: t,
              eventId: widget.eventId,
              userHomeCity: _homeCity,
              streamReady: streamReady,
              onUpdated: _loadTrips,
            ),
          ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
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
    final roleLabel = switch (trip.transportRole) {
      TripTransportRole.driver => l10n.tripRoleDriver,
      TripTransportRole.passenger => l10n.tripRolePassenger,
      TripTransportRole.either => l10n.tripRoleEither,
    };

    return Semantics(
      container: true,
      label:
          '${trip.routeLabel}. ${l10n.tripCardMeta(l10n.tripDepartureValue(_format(trip.departureAt)), trip.targetCityLabel, roleLabel, trip.memberCount, trip.capacity)}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.routeLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tripCardMeta(
                  l10n.tripDepartureValue(_format(trip.departureAt)),
                  trip.targetCityLabel,
                  roleLabel,
                  trip.memberCount,
                  trip.capacity,
                ),
              ),
              const SizedBox(height: 8),
              TripJoinBar(
                trip: trip,
                eventId: eventId,
                userHomeCity: userHomeCity,
                streamReady: streamReady,
                onUpdated: onUpdated,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
