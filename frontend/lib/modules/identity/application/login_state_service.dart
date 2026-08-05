import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';

class LoginStateService extends Cubit<LoginState> {
  LoginStateService(this._identity, this._session) : super(const LoginIdle());

  final IdentityWriteService _identity;
  final SessionStateService _session;

  Future<void> submit({required String email, required String password}) async {
    emit(const LoginInProgress());
    try {
      final session = await _identity.login(email: email, password: password);
      await _session.authenticate(
        accessToken: session.accessToken,
        accessTokenExpiresAt: session.accessTokenExpiresAt,
        refreshToken: session.refreshToken,
      );
      emit(const LoginIdle());
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }
}
