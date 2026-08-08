import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/signup_state.dart';

class SignupStateService extends Cubit<SignupState> {
  SignupStateService(this._identity) : super(const SignupIdle());

  final IdentityWriteService _identity;

  Future<void> submit({
    required String email,
    required String username,
    required String password,
  }) async {
    emit(const SignupInProgress());
    try {
      await _identity.register(email: email, username: username, password: password);
      emit(const SignupIdle());
    } catch (error) {
      emit(SignupFailure(error.toString()));
    }
  }
}
