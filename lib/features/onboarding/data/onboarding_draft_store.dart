import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_draft.dart';

/// Persists a completed local registration draft until after OAuth succeeds.
///
/// Cleared after a successful `PUT /users/me` sync or on sign-out.
class OnboardingDraftStore {
  OnboardingDraftStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kPending = 'onboarding_pending_registration_v1';

  /// Returns a draft waiting to be pushed to `PUT /users/me`, or null.
  OnboardingDraft? loadPending() {
    final raw = _prefs.getString(_kPending);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OnboardingDraft.fromJson(map);
    } on Object {
      return null;
    }
  }

  Future<void> savePending(OnboardingDraft draft) async {
    await _prefs.setString(_kPending, jsonEncode(draft.toJson()));
  }

  Future<void> clearPending() async {
    await _prefs.remove(_kPending);
  }
}
