import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_state.dart';

class SessionStateService extends Cubit<SessionState> {
  SessionStateService(this._firebaseAuth) : super(const SessionUnauthenticated()) {
    _subscription = _firebaseAuth.authStateChanges().listen(_onUserChanged);
  }

  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _subscription;

  bool get isAuthenticated => state is SessionAuthenticated;

  /// Resolves once the initial (persisted) auth state has been reported by
  /// Firebase, so the router's first redirect decision reflects the real
  /// signed-in/out state instead of the Cubit's `SessionUnauthenticated`
  /// starting value.
  Future<void> get ready => _firebaseAuth.authStateChanges().first;

  void _onUserChanged(User? user) {
    emit(
      user == null
          ? const SessionUnauthenticated()
          : SessionAuthenticated(uid: user.uid, email: user.email),
    );
  }

  Future<void> clear() => _firebaseAuth.signOut();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
