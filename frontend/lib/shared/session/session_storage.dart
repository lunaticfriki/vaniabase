import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  const StoredSession({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
}

abstract class SessionStorage {
  Future<StoredSession?> load();

  Future<void> save(StoredSession session);

  Future<void> clear();
}

class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _accessTokenKey = 'session.accessToken';
  static const _accessTokenExpiresAtKey = 'session.accessTokenExpiresAt';
  static const _refreshTokenKey = 'session.refreshToken';

  @override
  Future<StoredSession?> load() async {
    final accessToken = _prefs.getString(_accessTokenKey);
    final accessTokenExpiresAt = _prefs.getString(_accessTokenExpiresAtKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    if (accessToken == null || accessTokenExpiresAt == null || refreshToken == null) {
      return null;
    }
    return StoredSession(
      accessToken: accessToken,
      accessTokenExpiresAt: DateTime.parse(accessTokenExpiresAt),
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> save(StoredSession session) async {
    await _prefs.setString(_accessTokenKey, session.accessToken);
    await _prefs.setString(
      _accessTokenExpiresAtKey,
      session.accessTokenExpiresAt.toIso8601String(),
    );
    await _prefs.setString(_refreshTokenKey, session.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_accessTokenExpiresAtKey);
    await _prefs.remove(_refreshTokenKey);
  }
}
