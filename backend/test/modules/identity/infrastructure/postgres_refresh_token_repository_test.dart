import 'package:backend/modules/identity/infrastructure/postgres_refresh_token_repository.dart';
import 'package:backend/modules/identity/infrastructure/postgres_user_repository.dart';
import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

Future<User> _persistedUser(PostgresUserRepository users) async {
  final user = User.register(
    email: Email.create('jane.doe@example.com'),
    username: Username.create('jane_doe'),
    passwordHash: PasswordHash.create('hashed-value'),
  );
  await users.save(user);
  return user;
}

void main() {
  late Pool pool;
  late PostgresRefreshTokenRepository repository;
  late PostgresUserRepository userRepository;

  setUpAll(() {
    pool = createConnectionPool(DatabaseConfig.fromEnvironment());
    repository = PostgresRefreshTokenRepository(pool);
    userRepository = PostgresUserRepository(pool);
  });

  tearDownAll(() async {
    await pool.close();
  });

  tearDown(() async {
    await pool.execute('DELETE FROM refresh_tokens');
    await pool.execute('DELETE FROM users');
  });

  group('PostgresRefreshTokenRepository', () {
    test('save then findById round-trips a token', () async {
      final user = await _persistedUser(userRepository);
      final token = RefreshToken.issue(
        userId: user.id,
        validFor: const Duration(days: 30),
      );

      await repository.save(token);
      final found = await repository.findById(token.id);

      expect(found, isNotNull);
      expect(found!.id, token.id);
      expect(found.userId, user.id);
      expect(found.isRevoked, isFalse);
    });

    test('findById returns null for an unknown token', () async {
      final found = await repository.findById(RefreshTokenId.generate());

      expect(found, isNull);
    });

    test('save persists a revoked status', () async {
      final user = await _persistedUser(userRepository);
      final token = RefreshToken.issue(
        userId: user.id,
        validFor: const Duration(days: 30),
      );
      await repository.save(token);

      token.revoke();
      await repository.save(token);

      final found = await repository.findById(token.id);
      expect(found?.isRevoked, isTrue);
    });

    test('revokeAllForUser revokes every token for that user', () async {
      final user = await _persistedUser(userRepository);
      final first = RefreshToken.issue(
        userId: user.id,
        validFor: const Duration(days: 30),
      );
      final second = RefreshToken.issue(
        userId: user.id,
        validFor: const Duration(days: 30),
      );
      await repository.save(first);
      await repository.save(second);

      await repository.revokeAllForUser(user.id);

      expect((await repository.findById(first.id))?.isRevoked, isTrue);
      expect((await repository.findById(second.id))?.isRevoked, isTrue);
    });
  });
}
