import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../data/demo_events.dart';
import '../domain/event.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Event? _event;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = AppScope.eventsOf(context);
    final config = AppScope.configOf(context);
    final res = await repo.getEvent(widget.eventId);
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _event = value;
          _loading = false;
        });
      case Failure(:final error):
        if (config.isDemoBackend) {
          setState(() {
            _event = demoEventDetail(widget.eventId);
            _loading = false;
            _error = null;
          });
        } else {
          setState(() {
            _error = error.message;
            _loading = false;
          });
        }
    }
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context);
    if (!auth.isAuthenticated) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.guestSignInPrompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/sign-in');
              },
              child: Text(l10n.signInTitle),
            ),
          ],
        ),
      );
      return;
    }
    final repo = AppScope.eventsOf(context);
    final r = await repo.attend(widget.eventId);
    if (!mounted) return;
    final config = AppScope.configOf(context);
    switch (r) {
      case Success():
        await _load();
      case Failure(:final error):
        if (config.isDemoBackend && _event != null) {
          setState(() => _event = _withAttend(_event!, AttendStatus.attending));
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
        }
    }
  }

  Future<void> _leave() async {
    final repo = AppScope.eventsOf(context);
    final config = AppScope.configOf(context);
    final r = await repo.leave(widget.eventId);
    if (!mounted) return;
    switch (r) {
      case Success():
        await _load();
      case Failure(:final error):
        if (config.isDemoBackend && _event != null) {
          setState(
            () => _event = _withAttend(_event!, AttendStatus.notAttending),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
        }
    }
  }

  Event _withAttend(Event e, AttendStatus status) {
    return Event(
      id: e.id,
      title: e.title,
      startsAt: e.startsAt,
      endsAt: e.endsAt,
      city: e.city,
      venueName: e.venueName,
      imageUrls: e.imageUrls,
      tags: e.tags,
      capacity: e.capacity,
      priceLabel: e.priceLabel,
      officialUrl: e.officialUrl,
      attendStatus: status,
      attendeePreview: e.attendeePreview,
      latitude: e.latitude,
      longitude: e.longitude,
      attendees: e.attendees,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context).isAuthenticated;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? l10n.commonErrorTitle)),
      );
    }

    final e = _event!;
    final attending = e.attendStatus == AttendStatus.attending;

    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (e.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  e.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${e.city} · ${e.venueName}'),
          const SizedBox(height: 8),
          Text(l10n.eventSchedule(_format(e.startsAt), _format(e.endsAt))),
          if (e.capacity != null) Text(l10n.eventCapacity(e.capacity!)),
          if (e.priceLabel != null) Text(l10n.eventPrice(e.priceLabel!)),
          if (e.officialUrl != null) Text(l10n.eventOfficialLink),
          const SizedBox(height: 16),
          Text(
            l10n.eventParticipantsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (!auth)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: _AttendeeList(attendees: e.attendees),
            )
          else
            _AttendeeList(attendees: e.attendees),
          if (!auth)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.eventGuestBlurHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 24),
          if (auth)
            attending
                ? OutlinedButton(
                    onPressed: _leave,
                    child: Text(l10n.eventLeave),
                  )
                : FilledButton(onPressed: _join, child: Text(l10n.eventJoin))
          else
            FilledButton(onPressed: _join, child: Text(l10n.eventJoinSignIn)),
        ],
      ),
    );
  }

  static String _format(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _AttendeeList extends StatelessWidget {
  const _AttendeeList({required this.attendees});

  final List<EventAttendeePreview> attendees;

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) {
      return Text(AppLocalizations.of(context)!.emptyStateTitle);
    }
    return Column(
      children: attendees
          .map(
            (a) => ListTile(
              dense: true,
              title: Text(a.displayName),
              subtitle: Text(a.city),
            ),
          )
          .toList(),
    );
  }
}
