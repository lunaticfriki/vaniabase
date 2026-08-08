import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state.dart';
import 'package:frontend/modules/identity/application/login_state_service.dart';
import 'package:frontend/modules/identity/presentation/login/login_view.dart';
import 'package:go_router/go_router.dart';

class LoginContainer extends StatefulWidget {
  const LoginContainer({super.key});

  @override
  State<LoginContainer> createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  late final LoginStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = LoginStateService(getIt<IdentityWriteService>());
  }

  @override
  void dispose() {
    _stateService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<LoginStateService, LoginState>(
        builder: (context, state) => LoginView(
          isSubmitting: state is LoginInProgress,
          errorMessage: state is LoginFailure ? state.message : null,
          onSubmit: ({required email, required password}) => context
              .read<LoginStateService>()
              .submit(email: email, password: password),
          onNavigateToSignup: () => context.go('/signup'),
        ),
      ),
    );
  }
}
