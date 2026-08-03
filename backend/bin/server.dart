import 'dart:io';

import 'package:backend/composition_root.dart';
import 'package:backend/modules/catalog/presentation/item_router.dart';
import 'package:backend/modules/identity/presentation/identity_router.dart';
import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:backend/shared/db/migration_runner.dart';
import 'package:backend/shared/env_config.dart';
import 'package:backend/shared/http/auth_middleware.dart';
import 'package:backend/shared/http/cors_middleware.dart';
import 'package:backend/shared/http/docs_router.dart';
import 'package:backend/shared/http/error_mapping_middleware.dart';
import 'package:backend/modules/catalog/application/item_read_service.dart';
import 'package:backend/modules/catalog/application/item_write_service.dart';
import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/identity_write_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> main() async {
  final dbConfig = DatabaseConfig.fromEnvironment();
  final envConfig = EnvConfig.fromEnvironment();
  final pool = createConnectionPool(dbConfig);

  await MigrationRunner(pool, Directory('migrations')).run();

  configureDependencies(pool, envConfig);

  final identityRouter = buildIdentityRouter(getIt<IdentityWriteService>());
  final docsRouter = buildDocsRouter();
  final itemRouter = buildItemRouter(
    getIt<ItemReadService>(),
    getIt<ItemWriteService>(),
  );

  final protectedItems = const Pipeline()
      .addMiddleware(authMiddleware(getIt<AccessTokenIssuer>()))
      .addHandler(itemRouter.call);

  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addMiddleware(errorMappingMiddleware())
      .addHandler(
        Cascade()
            .add(identityRouter.call)
            .add(docsRouter.call)
            .add(protectedItems)
            .handler,
      );

  final server = await io.serve(handler, '0.0.0.0', envConfig.port);
  print('Listening on port ${server.port}');
}
