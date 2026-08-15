import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/infrastructure/firestore_item_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/remembered_accounts_repository.dart';
import 'package:frontend/modules/identity/infrastructure/firebase_identity_repository.dart';
import 'package:frontend/modules/identity/infrastructure/local_remembered_accounts_repository.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  getIt.registerLazySingleton<SessionStateService>(
    () => SessionStateService(getIt<FirebaseAuth>()),
  );
  getIt.registerLazySingleton<ThemeStateService>(
    () => ThemeStateService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<FirebaseIdentityRepository>(
    () => FirebaseIdentityRepository(getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<IdentityWriteService>(
    () => getIt<FirebaseIdentityRepository>(),
  );

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<LocalRememberedAccountsRepository>(
    () => LocalRememberedAccountsRepository(
      getIt<SharedPreferences>(),
      getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerFactory<RememberedAccountsRepository>(
    () => getIt<LocalRememberedAccountsRepository>(),
  );

  getIt.registerLazySingleton<FirestoreItemRepository>(
    () => FirestoreItemRepository(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
      getIt<FirebaseStorage>(),
    ),
  );
  getIt.registerFactory<ItemReadService>(
    () => getIt<FirestoreItemRepository>(),
  );
  getIt.registerFactory<ItemWriteService>(
    () => getIt<FirestoreItemRepository>(),
  );
}
