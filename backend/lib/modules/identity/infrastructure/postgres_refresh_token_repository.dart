import 'package:backend/modules/identity/infrastructure/acl/refresh_token_mapper.dart';
import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:postgres/postgres.dart';

class PostgresRefreshTokenRepository implements RefreshTokenRepository {
  PostgresRefreshTokenRepository(this._pool);

  final Pool _pool;

  @override
  Future<RefreshToken?> findById(RefreshTokenId id) async {
    final result = await _pool.execute(
      Sql.named('SELECT * FROM refresh_tokens WHERE token_hash = @tokenHash'),
      parameters: {'tokenHash': RefreshTokenMapper.hashOf(id)},
    );
    if (result.isEmpty) return null;
    return RefreshTokenMapper.toDomain(id, result.first.toColumnMap());
  }

  @override
  Future<void> save(RefreshToken token) async {
    await _pool.execute(
      Sql.named('''
        INSERT INTO refresh_tokens (token_hash, user_id, expires_at, revoked, created_at)
        VALUES (@token_hash, @user_id::uuid, @expires_at, @revoked, @created_at)
        ON CONFLICT (token_hash) DO UPDATE SET
          revoked = EXCLUDED.revoked
      '''),
      parameters: RefreshTokenMapper.toPersistence(token),
    );
  }

  @override
  Future<void> revokeAllForUser(UserId userId) async {
    await _pool.execute(
      Sql.named(
        'UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = @userId::uuid',
      ),
      parameters: {'userId': userId.value},
    );
  }
}
