import 'dart:io';

import 'package:postgres/postgres.dart';

class MigrationRunner {
  MigrationRunner(this._pool, this._migrationsDir);

  final Pool _pool;
  final Directory _migrationsDir;

  Future<void> run() async {
    await _pool.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
      )
    ''');

    final applied = await _pool.execute(
      'SELECT version FROM schema_migrations',
    );
    final appliedVersions = applied
        .map((row) => row[0] as String)
        .toSet();

    final files =
        _migrationsDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.sql'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final version = file.uri.pathSegments.last;
      if (appliedVersions.contains(version)) {
        continue;
      }

      final sql = await file.readAsString();
      await _pool.runTx((session) async {
        await session.execute(sql, queryMode: QueryMode.simple);
        await session.execute(
          Sql.named(
            'INSERT INTO schema_migrations (version) VALUES (@version)',
          ),
          parameters: {'version': version},
        );
      });
    }
  }
}
