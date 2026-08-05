import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/app_theme.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );
  await getIt<SessionStateService>().restore();
  runApp(VaniabaseApp(router: buildAppRouter(getIt<SessionStateService>())));
}

class VaniabaseApp extends StatelessWidget {
  const VaniabaseApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SessionStateService>()),
        BlocProvider.value(value: getIt<ThemeStateService>()),
      ],
      child: BlocBuilder<ThemeStateService, ThemeMode>(
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
