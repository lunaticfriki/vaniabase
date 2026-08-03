import 'dart:convert';

import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';
import 'package:crypto/crypto.dart';

class RefreshTokenMapper {
  static String hashOf(RefreshTokenId id) {
    return sha256.convert(utf8.encode(id.value)).toString();
  }

  static RefreshToken toDomain(RefreshTokenId id, Map<String, dynamic> row) {
    return RefreshToken.fromPersistence(
      id: id,
      userId: UserId.create(row['user_id'] as String),
      createdAt: Timestamp.create(row['created_at'] as DateTime),
      expiresAt: Timestamp.at(row['expires_at'] as DateTime),
      revoked: row['revoked'] as bool,
    );
  }

  static Map<String, dynamic> toPersistence(RefreshToken token) {
    return {
      'token_hash': hashOf(token.id),
      'user_id': token.userId.value,
      'expires_at': token.expiresAt.value,
      'revoked': token.isRevoked,
      'created_at': token.createdAt.value,
    };
  }
}
