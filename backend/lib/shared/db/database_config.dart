import 'dart:io';

class DatabaseConfig {
  const DatabaseConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });

  factory DatabaseConfig.fromEnvironment() {
    final env = Platform.environment;
    return DatabaseConfig(
      host: env['DB_HOST'] ?? 'localhost',
      port: int.parse(env['DB_PORT'] ?? '5432'),
      database: env['DB_NAME'] ?? 'vaniabase',
      username: env['DB_USER'] ?? 'vaniabase',
      password: env['DB_PASSWORD'] ?? 'vaniabase',
    );
  }

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
}
