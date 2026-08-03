import 'dart:io';

import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:backend/shared/db/migration_runner.dart';

Future<void> main() async {
  final config = DatabaseConfig.fromEnvironment();
  final pool = createConnectionPool(config);
  final runner = MigrationRunner(pool, Directory('migrations'));
  await runner.run();
  await pool.close();
  print('migrations applied');
}
