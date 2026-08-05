import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_storage.dart';

class SessionStateService extends Cubit<SessionState> {
  SessionStateService(this._storage) : super(const SessionUnauthenticated());

  final SessionStorage _storage;

  bool get isAuthenticated => state is SessionAuthenticated;

  String? get accessToken => switch (state) {
    SessionAuthenticated(:final accessToken) => accessToken,
    SessionUnauthenticated() => null,
  };

  /// Rehydrates a previously-persisted session (survives a page reload).
  /// A stored access token past its expiry is discarded rather than
  /// restored, so the UI doesn't come up "authenticated" only to have the
  /// first API call fail with a 401.
  Future<void> restore() async {
    final stored = await _storage.load();
    if (stored == null) return;
    if (stored.accessTokenExpiresAt.isBefore(DateTime.now())) {
      await _storage.clear();
      return;
    }
    emit(
      SessionAuthenticated(
        accessToken: stored.accessToken,
        accessTokenExpiresAt: stored.accessTokenExpiresAt,
        refreshToken: stored.refreshToken,
      ),
    );
  }

  Future<void> authenticate({
    required String accessToken,
    required DateTime accessTokenExpiresAt,
    required String refreshToken,
  }) async {
    emit(
      SessionAuthenticated(
        accessToken: accessToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
        refreshToken: refreshToken,
      ),
    );
    await _storage.save(
      StoredSession(
        accessToken: accessToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<void> clear() async {
    emit(const SessionUnauthenticated());
    await _storage.clear();
  }
}
