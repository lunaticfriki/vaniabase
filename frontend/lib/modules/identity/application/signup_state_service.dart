import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';

sealed class SignupState {
  const SignupState();
}

class SignupIdle extends SignupState {
  const SignupIdle();
}

class SignupInProgress extends SignupState {
  const SignupInProgress();
}

class SignupFailure extends SignupState {
  const SignupFailure(this.message);

  final String message;
}

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
      await _identity.register(
        email: email,
        username: username,
        password: password,
      );
      emit(const SignupIdle());
    } catch (error) {
      emit(SignupFailure(error.toString()));
    }
  }
}
