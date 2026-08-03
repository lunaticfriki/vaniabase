import 'package:backend/modules/catalog/infrastructure/postgres_item_repository.dart';
import 'package:backend/modules/identity/infrastructure/bcrypt_password_hasher.dart';
import 'package:backend/modules/identity/infrastructure/jwt_access_token_issuer.dart';
import 'package:backend/modules/identity/infrastructure/postgres_refresh_token_repository.dart';
import 'package:backend/modules/identity/infrastructure/postgres_user_repository.dart';
import 'package:backend/shared/env_config.dart';
import 'package:backend/modules/catalog/application/command/create_item_command_handler.dart';
import 'package:backend/modules/catalog/application/command/delete_item_command_handler.dart';
import 'package:backend/modules/catalog/application/command/update_item_command_handler.dart';
import 'package:backend/modules/catalog/application/item_read_service.dart';
import 'package:backend/modules/catalog/application/item_write_service.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query_handler.dart';
import 'package:backend/modules/catalog/application/query/list_items_query_handler.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/command/login_command_handler.dart';
import 'package:backend/modules/identity/application/command/logout_command_handler.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command_handler.dart';
import 'package:backend/modules/identity/application/command/register_user_command_handler.dart';
import 'package:backend/modules/identity/application/identity_write_service.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';

final getIt = GetIt.instance;

void configureDependencies(Pool pool, EnvConfig config) {
  getIt.registerLazySingleton<Pool>(() => pool);

  getIt.registerLazySingleton<UserRepository>(
    () => PostgresUserRepository(getIt<Pool>()),
  );
  getIt.registerLazySingleton<RefreshTokenRepository>(
    () => PostgresRefreshTokenRepository(getIt<Pool>()),
  );
  getIt.registerLazySingleton<ItemRepository>(
    () => PostgresItemRepository(getIt<Pool>()),
  );

  getIt.registerLazySingleton<PasswordHasher>(() => BcryptPasswordHasher());
  getIt.registerLazySingleton<AccessTokenIssuer>(
    () => JwtAccessTokenIssuer(config.jwtSecret, ttl: config.accessTokenTtl),
  );

  getIt.registerFactory(
    () => RegisterUserCommandHandler(
      getIt<UserRepository>(),
      getIt<PasswordHasher>(),
    ),
  );
  getIt.registerFactory(
    () => LoginCommandHandler(
      getIt<UserRepository>(),
      getIt<PasswordHasher>(),
      getIt<RefreshTokenRepository>(),
      getIt<AccessTokenIssuer>(),
      refreshTokenValidFor: config.refreshTokenTtl,
    ),
  );
  getIt.registerFactory(
    () => RefreshSessionCommandHandler(
      getIt<RefreshTokenRepository>(),
      getIt<AccessTokenIssuer>(),
      refreshTokenValidFor: config.refreshTokenTtl,
    ),
  );
  getIt.registerFactory(
    () => LogoutCommandHandler(getIt<RefreshTokenRepository>()),
  );

  getIt.registerFactory<IdentityWriteService>(
    () => IdentityWriteServiceImpl(
      getIt<RegisterUserCommandHandler>(),
      getIt<LoginCommandHandler>(),
      getIt<RefreshSessionCommandHandler>(),
      getIt<LogoutCommandHandler>(),
    ),
  );

  getIt.registerFactory(
    () => CreateItemCommandHandler(getIt<ItemRepository>()),
  );
  getIt.registerFactory(
    () => UpdateItemCommandHandler(getIt<ItemRepository>()),
  );
  getIt.registerFactory(
    () => DeleteItemCommandHandler(getIt<ItemRepository>()),
  );
  getIt.registerFactory(
    () => GetItemByIdQueryHandler(getIt<ItemRepository>()),
  );
  getIt.registerFactory(() => ListItemsQueryHandler(getIt<ItemRepository>()));

  getIt.registerFactory<ItemReadService>(
    () => ItemReadServiceImpl(
      getIt<GetItemByIdQueryHandler>(),
      getIt<ListItemsQueryHandler>(),
    ),
  );
  getIt.registerFactory<ItemWriteService>(
    () => ItemWriteServiceImpl(
      getIt<CreateItemCommandHandler>(),
      getIt<UpdateItemCommandHandler>(),
      getIt<DeleteItemCommandHandler>(),
    ),
  );
}
