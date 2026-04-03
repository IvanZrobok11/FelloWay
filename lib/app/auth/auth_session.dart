import 'package:flutter/foundation.dart';

import '../../features/auth/data/token_storage.dart';

/// Tracks whether the user has stored credentials (hydrate in [restore]).
class AuthSession extends ChangeNotifier {
  AuthSession({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  bool _hydrated = false;
  bool _hasSession = false;

  bool get isHydrated => _hydrated;
  bool get isAuthenticated => _hasSession;

  Future<void> restore() async {
    final access = await _tokenStorage.readAccessToken();
    _hasSession = access != null && access.isNotEmpty;
    _hydrated = true;
    notifyListeners();
  }

  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    _hasSession = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _tokenStorage.clear();
    _hasSession = false;
    notifyListeners();
  }
}
