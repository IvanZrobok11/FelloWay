import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../shared/errors/result.dart';
import '../domain/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  Future<void> _load() async {
    final auth = AppScope.authSessionOf(context);
    if (!auth.isAuthenticated) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final users = AppScope.usersOf(context);
    final res = await users.getMe();
    if (!mounted) return;
    switch (res) {
      case Success(:final value):
        setState(() {
          _profile = value;
          _loading = false;
          _error = null;
        });
      case Failure(:final error):
        setState(() {
          _loading = false;
          _error = error.message;
        });
    }
  }

  Future<void> _signOut() async {
    final onboarding = AppScope.onboardingOf(context);
    final draftStore = AppScope.onboardingDraftStoreOf(context);
    final session = AppScope.authSessionOf(context);
    await onboarding.clear();
    await draftStore.clearPending();
    await session.signOut();
    if (!mounted) return;
    context.go('/events');
  }

  Future<void> _ensureWebSession() async {
    final config = AppScope.configOf(context);
    if (!kIsWeb || config.useMockApi) return;
    final session = AppScope.authSessionOf(context);
    if (session.isAuthenticated) return;
    await session.syncWebCookieSession(AppScope.authApiOf(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AppScope.authSessionOf(context);
    if (!auth.isAuthenticated && kIsWeb && !AppScope.configOf(context).useMockApi) {
      unawaited(_ensureWebSession().then((_) {
        if (!mounted) return;
        if (AppScope.authSessionOf(context).isAuthenticated &&
            _profile == null &&
            !_loading) {
          _load();
        }
      }));
      return;
    }
    if (auth.isAuthenticated && _profile == null && !_loading) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AppScope.authSessionOf(context).isAuthenticated;

    if (!auth) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileScreenTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.profileGuestMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/sign-in'),
                  child: Text(l10n.signInTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileScreenTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileScreenTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileScreenTitle)),
        body: Center(child: Text(l10n.emptyStateTitle)),
      );
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.profileSignOut,
            onPressed: _signOut,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: p.avatarUrl != null
                  ? NetworkImage(p.avatarUrl!)
                  : null,
              child: p.avatarUrl == null
                  ? Text(
                      p.displayName.isNotEmpty
                          ? p.displayName[0].toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            title: Text(p.displayName),
            subtitle: Text(p.homeCityLabel),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.profileMenuEdit),
            onTap: () => context.push('/profile/edit'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.profileMenuNotifications),
            onTap: () => context.push('/profile/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: Text(l10n.profileMenuReviews),
            onTap: () => context.push('/profile/reviews'),
          ),
          if (p.ratingAverage != null)
            ListTile(
              title: Text(
                l10n.profileRating(p.ratingAverage!.toStringAsFixed(1)),
              ),
            ),
          if (p.linkedinUrl != null)
            ListTile(
              title: Text(l10n.profileLinkedIn),
              subtitle: Text(p.linkedinUrl!),
            ),
          if (p.facebookUrl != null)
            ListTile(
              title: Text(l10n.profileFacebook),
              subtitle: Text(p.facebookUrl!),
            ),
          ListTile(
            title: Text(l10n.profileInterests),
            subtitle: Text(p.interests.join(', ')),
          ),
          ListTile(title: Text(l10n.profileHobbies), subtitle: Text(p.hobbies)),
        ],
      ),
    );
  }
}
