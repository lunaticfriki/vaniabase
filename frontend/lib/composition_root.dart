import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/infrastructure/http_item_repository.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/infrastructure/http_identity_repository.dart';
import 'package:frontend/shared/http/api_client.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:frontend/shared/session/session_storage.dart';
import 'package:frontend/shared/theme/theme_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({required String apiBaseUrl}) async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SessionStorage>(
    () => SharedPreferencesSessionStorage(prefs),
  );
  getIt.registerLazySingleton<SessionCubit>(
    () => SessionCubit(getIt<SessionStorage>()),
  );
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(apiBaseUrl, getIt<SessionCubit>()),
  );

  getIt.registerLazySingleton<HttpIdentityRepository>(
    () => HttpIdentityRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<IdentityWriteService>(
    () => IdentityWriteServiceImpl(getIt<HttpIdentityRepository>()),
  );

  getIt.registerLazySingleton<HttpItemRepository>(
    () => HttpItemRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<ItemReadService>(
    () => ItemReadServiceImpl(getIt<HttpItemRepository>()),
  );
  getIt.registerFactory<ItemWriteService>(
    () => ItemWriteServiceImpl(getIt<HttpItemRepository>()),
  );
}
