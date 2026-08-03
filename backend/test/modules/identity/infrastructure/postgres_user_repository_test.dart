import 'package:backend/modules/identity/infrastructure/postgres_user_repository.dart';
import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

void main() {
  late Pool pool;
  late PostgresUserRepository repository;

  setUpAll(() {
    pool = createConnectionPool(DatabaseConfig.fromEnvironment());
    repository = PostgresUserRepository(pool);
  });

  tearDownAll(() async {
    await pool.close();
  });

  tearDown(() async {
    await pool.execute('DELETE FROM users');
  });

  group('PostgresUserRepository', () {
    test('save then findById round-trips a user', () async {
      final user = User.register(
        email: Email.create('jane.doe@example.com'),
        username: Username.create('jane_doe'),
        passwordHash: PasswordHash.create('hashed-value'),
      );

      await repository.save(user);
      final found = await repository.findById(user.id);

      expect(found, isNotNull);
      expect(found!.id, user.id);
      expect(found.email, user.email);
      expect(found.username, user.username);
      expect(found.passwordHash, user.passwordHash);
    });

    test('findById returns null when the user does not exist', () async {
      final found = await repository.findById(UserId.generate());

      expect(found, isNull);
    });

    test('findByEmail finds a saved user', () async {
      final user = User.register(
        email: Email.create('jane.doe@example.com'),
        username: Username.create('jane_doe'),
        passwordHash: PasswordHash.create('hashed-value'),
      );
      await repository.save(user);

      final found = await repository.findByEmail(user.email);

      expect(found?.id, user.id);
    });

    test('findByUsername finds a saved user', () async {
      final user = User.register(
        email: Email.create('jane.doe@example.com'),
        username: Username.create('jane_doe'),
        passwordHash: PasswordHash.create('hashed-value'),
      );
      await repository.save(user);

      final found = await repository.findByUsername(user.username);

      expect(found?.id, user.id);
    });

    test('save persists an update to an existing user', () async {
      final user = User.register(
        email: Email.create('jane.doe@example.com'),
        username: Username.create('jane_doe'),
        passwordHash: PasswordHash.create('hashed-value'),
      );
      await repository.save(user);

      user.update(email: Email.create('new.email@example.com'));
      await repository.save(user);

      final found = await repository.findById(user.id);
      expect(found?.email, Email.create('new.email@example.com'));
    });

    test('delete removes the user', () async {
      final user = User.register(
        email: Email.create('jane.doe@example.com'),
        username: Username.create('jane_doe'),
        passwordHash: PasswordHash.create('hashed-value'),
      );
      await repository.save(user);

      await repository.delete(user.id);

      expect(await repository.findById(user.id), isNull);
    });
  });
}
