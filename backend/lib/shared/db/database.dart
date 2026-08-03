import 'package:backend/shared/db/database_config.dart';
import 'package:postgres/postgres.dart';

Pool createConnectionPool(DatabaseConfig config) {
  return Pool.withEndpoints(
    [
      Endpoint(
        host: config.host,
        port: config.port,
        database: config.database,
        username: config.username,
        password: config.password,
      ),
    ],
    settings: const PoolSettings(sslMode: SslMode.disable, maxConnectionCount: 10),
  );
}
