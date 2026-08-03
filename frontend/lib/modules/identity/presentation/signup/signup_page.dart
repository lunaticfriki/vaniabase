import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_cubit.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_state.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_view.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(
        getIt<IdentityWriteService>(),
        context.read<SessionCubit>(),
      ),
      child: BlocBuilder<SignupCubit, SignupState>(
        builder: (context, state) => SignupView(
          isSubmitting: state is SignupInProgress,
          errorMessage: state is SignupFailure ? state.message : null,
          onSubmit: ({required email, required username, required password}) =>
              context.read<SignupCubit>().submit(
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
