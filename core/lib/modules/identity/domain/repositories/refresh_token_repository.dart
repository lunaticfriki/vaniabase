import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';

abstract class RefreshTokenRepository {
  Future<RefreshToken?> findById(RefreshTokenId id);

  Future<void> save(RefreshToken token);

  Future<void> revokeAllForUser(UserId userId);
}
