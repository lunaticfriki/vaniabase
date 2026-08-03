import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/presentation/login/login_cubit.dart';
import 'package:frontend/modules/identity/presentation/login/login_state.dart';
import 'package:frontend/modules/identity/presentation/login/login_view.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        getIt<IdentityWriteService>(),
        context.read<SessionCubit>(),
      ),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) => LoginView(
          isSubmitting: state is LoginInProgress,
          errorMessage: state is LoginFailure ? state.message : null,
          onSubmit: ({required email, required password}) => context
              .read<LoginCubit>()
              .submit(email: email, password: password),
          onNavigateToSignup: () => context.go('/signup'),
        ),
      ),
    );
  }
}
