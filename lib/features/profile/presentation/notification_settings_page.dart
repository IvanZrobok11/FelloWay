import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_scope.dart';
import '../data/users_repository.dart';

const _kPushGlobal = 'push_global';
const _kPushEvents = 'push_events';
const _kPushTrips = 'push_trips';
const _kPushDm = 'push_dm';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  SharedPreferences? _prefs;
  bool _global = true;
  bool _events = true;
  bool _trips = true;
  bool _dm = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _global = p.getBool(_kPushGlobal) ?? true;
      _events = p.getBool(_kPushEvents) ?? true;
      _trips = p.getBool(_kPushTrips) ?? true;
      _dm = p.getBool(_kPushDm) ?? true;
      _loading = false;
    });
  }

  Future<void> _persistAndSync() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool(_kPushGlobal, _global);
    await p.setBool(_kPushEvents, _events);
    await p.setBool(_kPushTrips, _trips);
    await p.setBool(_kPushDm, _dm);
    if (!mounted) return;
    final repo = AppScope.usersOf(context);
    final draft = PushPreferenceDraft(
      globalEnabled: _global,
      eventMessages: _events,
      tripMessages: _trips,
      directMessages: _dm,
    );
    await repo.syncPushPreferences(draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.notificationSettingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.notificationGlobalTitle),
            subtitle: Text(l10n.notificationGlobalSubtitle),
            value: _global,
            onChanged: (v) {
              setState(() => _global = v);
              _persistAndSync();
            },
          ),
          SwitchListTile(
            title: Text(l10n.notificationEventsTitle),
            subtitle: Text(l10n.notificationEventsSubtitle),
            value: _events && _global,
            onChanged: _global
                ? (v) {
                    setState(() => _events = v);
                    _persistAndSync();
                  }
                : null,
          ),
          SwitchListTile(
            title: Text(l10n.notificationTripsTitle),
            subtitle: Text(l10n.notificationTripsSubtitle),
            value: _trips && _global,
            onChanged: _global
                ? (v) {
                    setState(() => _trips = v);
                    _persistAndSync();
                  }
                : null,
          ),
          SwitchListTile(
            title: Text(l10n.notificationDmTitle),
            subtitle: Text(l10n.notificationDmSubtitle),
            value: _dm && _global,
            onChanged: _global
                ? (v) {
                    setState(() => _dm = v);
                    _persistAndSync();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
