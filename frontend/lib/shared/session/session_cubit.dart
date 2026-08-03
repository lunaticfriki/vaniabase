import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionUnauthenticated());

  bool get isAuthenticated => state is SessionAuthenticated;

  String? get accessToken => switch (state) {
    SessionAuthenticated(:final accessToken) => accessToken,
    SessionUnauthenticated() => null,
  };

  void authenticate({
    required String accessToken,
    required String refreshToken,
  }) {
    emit(
      SessionAuthenticated(accessToken: accessToken, refreshToken: refreshToken),
    );
  }

  void clear() => emit(const SessionUnauthenticated());
}
