import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state.dart';

class LoginStateService extends Cubit<LoginState> {
  LoginStateService(this._identity) : super(const LoginIdle());

  final IdentityWriteService _identity;

  Future<void> submit({required String email, required String password}) async {
    emit(const LoginInProgress());
    try {
      await _identity.login(email: email, password: password);
      emit(const LoginIdle());
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }
}
