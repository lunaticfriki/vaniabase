import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/remembered_account.dart';
import 'package:frontend/modules/identity/application/remembered_accounts_repository.dart';

sealed class LoginState {
  const LoginState({required this.rememberedAccounts});

  final List<RememberedAccount> rememberedAccounts;
}

class LoginIdle extends LoginState {
  const LoginIdle({super.rememberedAccounts = const []});
}

class LoginInProgress extends LoginState {
  const LoginInProgress({required super.rememberedAccounts});
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message, {required super.rememberedAccounts});

  final String message;
}

class LoginStateService extends Cubit<LoginState> {
  LoginStateService(this._identity, this._rememberedAccounts)
    : super(const LoginIdle()) {
    _initialLoad = _loadRememberedAccounts();
  }

  final IdentityWriteService _identity;
  final RememberedAccountsRepository _rememberedAccounts;
  late final Future<void> _initialLoad;

  Future<void> _loadRememberedAccounts() async {
    final accounts = await _rememberedAccounts.getAll();
    if (!isClosed) emit(LoginIdle(rememberedAccounts: accounts));
  }

  Future<void> submit({
    required String email,
    required String password,
    bool rememberPassword = false,
  }) async {
    await _initialLoad;
    emit(LoginInProgress(rememberedAccounts: state.rememberedAccounts));
    try {
      await _identity.login(email: email, password: password);
      await _rememberedAccounts.remember(
        email: email,
        password: rememberPassword ? password : null,
      );
      final accounts = await _rememberedAccounts.getAll();
      emit(LoginIdle(rememberedAccounts: accounts));
    } catch (error) {
      emit(
        LoginFailure(error.toString(), rememberedAccounts: state.rememberedAccounts),
      );
    }
  }

  Future<void> forgetAccount(String email) async {
    await _initialLoad;
    await _rememberedAccounts.forget(email);
    final accounts = await _rememberedAccounts.getAll();
    emit(LoginIdle(rememberedAccounts: accounts));
  }
}
