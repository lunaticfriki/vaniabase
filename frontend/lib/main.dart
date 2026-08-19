import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/accent_color_state_service.dart';
import 'package:frontend/shared/theme/app_theme.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await configureDependencies();
  await getIt<SessionStateService>().ready;
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
        BlocProvider.value(value: getIt<AccentColorStateService>()),
      ],
      child: BlocBuilder<ThemeStateService, ThemeMode>(
        builder: (context, themeMode) =>
            BlocBuilder<AccentColorStateService, AppAccentColor>(
              builder: (context, accentColor) => MaterialApp.router(
                title: 'vaniabase',
                theme: AppTheme.light(accentColor),
                darkTheme: AppTheme.dark(accentColor),
                themeMode: themeMode,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
              ),
            ),
      ),
    );
  }
}
