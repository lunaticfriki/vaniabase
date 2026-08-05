import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/session/session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesSessionStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns null when nothing was ever saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesSessionStorage(prefs);

      expect(await storage.load(), isNull);
    });

    test('save then load (simulating a fresh instance after a page reload) round-trips exactly', () async {
      final writePrefs = await SharedPreferences.getInstance();
      final writeStorage = SharedPreferencesSessionStorage(writePrefs);
      final expiresAt = DateTime.parse('2026-08-05T12:34:56.000Z');

      await writeStorage.save(
        StoredSession(
          accessToken: 'access-token',
          accessTokenExpiresAt: expiresAt,
          refreshToken: 'refresh-token',
        ),
      );

      // A page reload constructs a brand new SharedPreferences instance
      // backed by the same underlying store — re-fetching it here is what
      // actually exercises the persistence, rather than reusing writePrefs.
      final readPrefs = await SharedPreferences.getInstance();
      final readStorage = SharedPreferencesSessionStorage(readPrefs);
      final loaded = await readStorage.load();

      expect(loaded, isNotNull);
      expect(loaded!.accessToken, 'access-token');
      expect(loaded.refreshToken, 'refresh-token');
      expect(loaded.accessTokenExpiresAt, expiresAt);
    });

    test('clear removes a previously-saved session', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesSessionStorage(prefs);
      await storage.save(
        StoredSession(
          accessToken: 'access-token',
          accessTokenExpiresAt: DateTime.now(),
          refreshToken: 'refresh-token',
        ),
      );

      await storage.clear();

      expect(await storage.load(), isNull);
    });
  });
}
