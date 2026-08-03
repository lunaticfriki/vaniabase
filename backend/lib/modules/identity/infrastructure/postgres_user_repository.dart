import 'package:backend/modules/identity/infrastructure/acl/user_mapper.dart';
import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:postgres/postgres.dart';

class PostgresUserRepository implements UserRepository {
  PostgresUserRepository(this._pool);

  final Pool _pool;

  @override
  Future<User?> findById(UserId id) async {
    final result = await _pool.execute(
      Sql.named('SELECT * FROM users WHERE id = @id::uuid'),
      parameters: {'id': id.value},
    );
    if (result.isEmpty) return null;
    return UserMapper.toDomain(result.first.toColumnMap());
  }

  @override
  Future<User?> findByEmail(Email email) async {
    final result = await _pool.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email.value},
    );
    if (result.isEmpty) return null;
    return UserMapper.toDomain(result.first.toColumnMap());
  }

  @override
  Future<User?> findByUsername(Username username) async {
    final result = await _pool.execute(
      Sql.named('SELECT * FROM users WHERE username = @username'),
      parameters: {'username': username.value},
    );
    if (result.isEmpty) return null;
    return UserMapper.toDomain(result.first.toColumnMap());
  }

  @override
  Future<void> save(User user) async {
    await _pool.execute(
      Sql.named('''
        INSERT INTO users (id, email, username, password_hash, created_at, updated_at)
        VALUES (@id::uuid, @email, @username, @password_hash, @created_at, @updated_at)
        ON CONFLICT (id) DO UPDATE SET
          email = EXCLUDED.email,
          username = EXCLUDED.username,
          password_hash = EXCLUDED.password_hash,
          updated_at = EXCLUDED.updated_at
      '''),
      parameters: UserMapper.toPersistence(user),
    );
  }

  @override
  Future<void> delete(UserId id) async {
    await _pool.execute(
      Sql.named('DELETE FROM users WHERE id = @id::uuid'),
      parameters: {'id': id.value},
    );
  }
}
