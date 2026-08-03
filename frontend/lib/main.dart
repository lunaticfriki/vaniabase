import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:frontend/shared/theme/app_theme.dart';
import 'package:frontend/shared/theme/theme_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SessionCubit>()),
        BlocProvider.value(value: getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          title: 'vaniabase',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
