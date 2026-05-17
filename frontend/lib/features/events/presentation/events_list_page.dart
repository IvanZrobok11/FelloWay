import 'dart:async';

import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/widgets/error_display.dart';
import '../domain/event.dart';
import 'event_card.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  List<EventSummary> _items = [];
  String? _cursor;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _cursor == null) return;
    final pos = _scrollController.position;
    if (pos.pixels > pos.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
      _cursor = null;
    });
    await _fetch(reset: true);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    await _fetch(reset: false);
    if (!mounted) return;
    setState(() => _loadingMore = false);
  }

  Future<void> _fetch({required bool reset}) async {
    final repo = AppScope.eventsOf(context);
    final q = _searchController.text.trim();
    final result = await repo.listEvents(
      query: q.isEmpty ? null : q,
      cursor: reset ? null : _cursor,
    );

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          if (reset) {
            _items = value.items;
          } else {
            _items = [..._items, ...value.items];
          }
          _cursor = value.nextCursor;
          _error = null;
        });
      case Failure(:final error):
        setState(() {
          _error = error.message;
        });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadInitial);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context).isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsScreenTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Semantics(
              label: l10n.eventsSearchHint,
              textField: true,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.eventsSearchHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadInitial,
              child: _buildBody(l10n, auth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool auth) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [ErrorDisplay(message: _error!, onRetry: _loadInitial)],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.emptyStateTitle, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = _items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            summary: item,
            isGuest: !auth,
            onTap: () => context.push('/event/${item.id}'),
          ),
        );
      },
    );
  }
}
