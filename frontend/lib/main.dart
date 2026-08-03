import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:go_router/go_router.dart';

void main() {
  configureDependencies(
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );
  runApp(VaniabaseApp(router: buildAppRouter(getIt<SessionCubit>())));
}

class VaniabaseApp extends StatelessWidget {
  const VaniabaseApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SessionCubit>(),
      child: MaterialApp.router(
        title: 'vaniabase',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
