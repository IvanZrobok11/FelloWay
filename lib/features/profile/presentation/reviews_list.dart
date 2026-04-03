import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../domain/user_review.dart';

/// Full-screen page: loads current user id then shows [ReviewsListBody].
class ProfileReviewsPage extends StatefulWidget {
  const ProfileReviewsPage({super.key});

  @override
  State<ProfileReviewsPage> createState() => _ProfileReviewsPageState();
}

class _ProfileReviewsPageState extends State<ProfileReviewsPage> {
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final users = AppScope.usersOf(context);
    final config = AppScope.configOf(context);
    final res = await users.getMe();
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _userId = value.id;
          _loading = false;
        });
      case Failure():
        if (config.isDemoBackend) {
          setState(() {
            _userId = 'demo';
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviewsListTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final id = _userId;
    if (id == null || id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviewsListTitle)),
        body: Center(child: Text(l10n.commonErrorTitle)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewsListTitle)),
      body: ReviewsListBody(userId: id),
    );
  }
}

/// Fetches and displays reviews for [userId] (`GET /users/{id}/reviews`).
class ReviewsListBody extends StatefulWidget {
  const ReviewsListBody({super.key, required this.userId});

  final String userId;

  @override
  State<ReviewsListBody> createState() => _ReviewsListBodyState();
}

class _ReviewsListBodyState extends State<ReviewsListBody> {
  List<UserReview>? _items;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant ReviewsListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = AppScope.usersOf(context);
    final res = await repo.getUserReviews(widget.userId);
    if (!mounted) return;
    switch (res) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _fetch, child: Text(l10n.commonRetry)),
            ],
          ),
        ),
      );
    }
    final items = _items ?? const <UserReview>[];
    if (items.isEmpty) {
      return Center(child: Text(l10n.emptyStateTitle));
    }
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final r = items[i];
          return Semantics(
            label: l10n.reviewSemanticLabel(
              r.eventTitle ?? '',
              r.rating,
              r.comment ?? '',
            ),
            child: ListTile(
              title: Text(
                r.eventTitle ?? l10n.reviewsAnonymousEvent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (j) => Icon(
                        j < r.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (r.authorLabel != null) Text(r.authorLabel!),
                  if (r.comment != null && r.comment!.isNotEmpty)
                    Text(r.comment!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
