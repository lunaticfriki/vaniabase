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
