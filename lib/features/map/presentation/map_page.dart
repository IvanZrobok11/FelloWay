import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../../events/domain/event.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<EventSummary> _events = [];
  bool _loading = true;
  String? _interestFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = AppScope.eventsOf(context);
    final res = await repo.listEvents(interest: _interestFilter);
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _events = value.items;
          _loading = false;
        });
      case Failure():
        setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const tags = ['IT', 'Marketing', 'HR', 'Design'];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapScreenTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.mapDiscoveryHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.mapFilterAll),
                  selected: _interestFilter == null,
                  onSelected: (_) {
                    setState(() => _interestFilter = null);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ...tags.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: _interestFilter == t,
                      onSelected: (v) {
                        setState(() => _interestFilter = v ? t : null);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, i) {
                      final e = _events[i];
                      return Card(
                        child: ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            '${e.city} · ${e.tags.join(", ")}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/event/${e.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
