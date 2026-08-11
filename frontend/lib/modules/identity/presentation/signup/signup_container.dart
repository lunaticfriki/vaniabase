import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/signup_state_service.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_view.dart';
import 'package:go_router/go_router.dart';

class SignupContainer extends StatefulWidget {
  const SignupContainer({super.key});

  @override
  State<SignupContainer> createState() => _SignupContainerState();
}

class _SignupContainerState extends State<SignupContainer> {
  late final SignupStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = SignupStateService(getIt<IdentityWriteService>());
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
      child: BlocBuilder<SignupStateService, SignupState>(
        builder: (context, state) => SignupView(
          isSubmitting: state is SignupInProgress,
          errorMessage: state is SignupFailure ? state.message : null,
          onSubmit: ({required email, required username, required password}) =>
              context.read<SignupStateService>().submit(
                email: email,
                username: username,
                password: password,
              ),
          onNavigateToLogin: () => context.go('/login'),
        ),
      ),
    );
  }
}
