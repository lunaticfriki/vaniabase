import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SessionState {
  const SessionState();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;
}

class SessionStateService extends Cubit<SessionState> {
  SessionStateService(this._firebaseAuth)
    : super(const SessionUnauthenticated()) {
    _subscription = _firebaseAuth.authStateChanges().listen(_onUserChanged);
  }

  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _subscription;

  bool get isAuthenticated => state is SessionAuthenticated;

  Future<void> get ready => _firebaseAuth.authStateChanges().first;

  void _onUserChanged(User? user) {
    emit(
      user == null
          ? const SessionUnauthenticated()
          : SessionAuthenticated(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
            ),
    );
  }

  Future<void> clear() => _firebaseAuth.signOut();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
