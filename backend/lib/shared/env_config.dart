import 'dart:io';

class EnvConfig {
  const EnvConfig({
    required this.jwtSecret,
    required this.accessTokenTtl,
    required this.refreshTokenTtl,
    required this.port,
  });

  factory EnvConfig.fromEnvironment() {
    final env = Platform.environment;
    return EnvConfig(
      jwtSecret: env['JWT_SECRET'] ?? 'dev-secret-change-me',
      accessTokenTtl: Duration(
        minutes: int.parse(env['ACCESS_TOKEN_TTL_MINUTES'] ?? '15'),
      ),
      refreshTokenTtl: Duration(
        days: int.parse(env['REFRESH_TOKEN_TTL_DAYS'] ?? '30'),
      ),
      port: int.parse(env['PORT'] ?? '8080'),
    );
  }

  final String jwtSecret;
  final Duration accessTokenTtl;
  final Duration refreshTokenTtl;
  final int port;
}
