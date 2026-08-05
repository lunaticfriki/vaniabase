import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/signup_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';

class SignupStateService extends Cubit<SignupState> {
  SignupStateService(this._identity, this._session) : super(const SignupIdle());

  final IdentityWriteService _identity;
  final SessionStateService _session;

  Future<void> submit({
    required String email,
    required String username,
    required String password,
  }) async {
    emit(const SignupInProgress());
    try {
      await _identity.register(
        email: email,
        username: username,
        password: password,
      );
      final session = await _identity.login(email: email, password: password);
      await _session.authenticate(
        accessToken: session.accessToken,
        accessTokenExpiresAt: session.accessTokenExpiresAt,
        refreshToken: session.refreshToken,
      );
      emit(const SignupIdle());
    } catch (error) {
      emit(SignupFailure(error.toString()));
    }
  }
}
