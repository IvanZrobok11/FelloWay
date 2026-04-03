import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';

class EventFeedbackPage extends StatefulWidget {
  const EventFeedbackPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventFeedbackPage> createState() => _EventFeedbackPageState();
}

class _EventFeedbackPageState extends State<EventFeedbackPage> {
  int _stars = 5;
  final _comment = TextEditingController();
  bool _submitting = false;
  String? _userId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final users = AppScope.usersOf(context);
    final config = AppScope.configOf(context);
    final res = await users.getMe();
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _userId = value.id;
          _loadingUser = false;
        });
      case Failure():
        if (config.isDemoBackend) {
          setState(() {
            _userId = 'demo';
            _loadingUser = false;
          });
        } else {
          setState(() => _loadingUser = false);
        }
    }
  }

  Future<void> _submit() async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    final repo = AppScope.eventsOf(context);
    final r = await repo.submitAttendeeReview(
      eventId: widget.eventId,
      attendeeUserId: uid,
      stars: _stars,
      comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (r) {
      case Success():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eventFeedbackThanks)));
        context.pop();
      case Failure(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingUser) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.eventFeedbackTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_userId == null || _userId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.eventFeedbackTitle)),
        body: Center(child: Text(l10n.commonErrorTitle)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventFeedbackTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.eventFeedbackSubtitle),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              final n = i + 1;
              return IconButton(
                icon: Icon(
                  n <= _stars ? Icons.star : Icons.star_border,
                  semanticLabel: l10n.eventFeedbackStarLabel(n),
                ),
                onPressed: () => setState(() => _stars = n),
              );
            }),
          ),
          TextField(
            controller: _comment,
            decoration: InputDecoration(
              labelText: l10n.eventFeedbackCommentLabel,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.eventFeedbackSubmit),
          ),
        ],
      ),
    );
  }
}
