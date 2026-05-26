import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists OAuth access/refresh tokens (see TECH_PLAN.md).
///
/// On web, [SharedPreferences] is used instead of [FlutterSecureStorage] because
/// mobile Safari often blocks or fails secure storage in the browser.
class TokenStorage {
  TokenStorage({
    FlutterSecureStorage? storage,
    SharedPreferences? webPreferences,
  })  : _nativeStorage = storage ?? const FlutterSecureStorage(),
        _webPrefs = kIsWeb ? webPreferences : null;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  final FlutterSecureStorage _nativeStorage;
  final SharedPreferences? _webPrefs;

  Future<String?> readAccessToken() async {
    final web = _webPrefs;
    if (web != null) {
      return web.getString(_kAccess);
    }
    return _nativeStorage.read(key: _kAccess);
  }

  Future<String?> readRefreshToken() async {
    final web = _webPrefs;
    if (web != null) {
      return web.getString(_kRefresh);
    }
    return _nativeStorage.read(key: _kRefresh);
  }

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final web = _webPrefs;
    if (web != null) {
      await web.setString(_kAccess, accessToken);
      await web.setString(_kRefresh, refreshToken);
      return;
    }
    await _nativeStorage.write(key: _kAccess, value: accessToken);
    await _nativeStorage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> clear() async {
    final web = _webPrefs;
    if (web != null) {
      await web.remove(_kAccess);
      await web.remove(_kRefresh);
      return;
    }
    await _nativeStorage.delete(key: _kAccess);
    await _nativeStorage.delete(key: _kRefresh);
  }
}
