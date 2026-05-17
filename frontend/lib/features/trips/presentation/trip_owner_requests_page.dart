import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../domain/trip_chat.dart';
import 'trip_channel_opener.dart';
import 'trip_request_row.dart';

class TripOwnerRequestsPage extends StatefulWidget {
  const TripOwnerRequestsPage({
    super.key,
    required this.tripId,
    required this.eventId,
  });

  final String tripId;
  final String eventId;

  @override
  State<TripOwnerRequestsPage> createState() => _TripOwnerRequestsPageState();
}

class _TripOwnerRequestsPageState extends State<TripOwnerRequestsPage> {
  List<TripJoinRequest> _items = [];
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
    final repo = AppScope.tripsOf(context);
    final r = await repo.listJoinRequests(widget.tripId);
    if (!mounted) return;
    switch (r) {
      case Success(:final value):
        setState(() {
          _items = value;
          _loading = false;
        });
      case Failure(:final error):
        setState(() {
          _error = error.message;
          _loading = false;
        });
    }
  }

  Future<void> _approve(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.tripsOf(context);
    final r = await repo.approveJoin(widget.tripId, userId);
    if (!mounted) return;
    switch (r) {
      case Success():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tripApproved)));
        await _load();
      case Failure(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streamReady = AppScope.streamChatOf(context).isReady;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripRequestsTitle),
        actions: [
          if (streamReady)
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => openTripChannel(
                context,
                tripId: widget.tripId,
                eventId: widget.eventId,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _items.isEmpty
          ? Center(child: Text(l10n.emptyStateTitle))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final req = _items[i];
                return TripRequestRow(
                  request: req,
                  onApprove: () => _approve(req.userId),
                );
              },
            ),
    );
  }
}
