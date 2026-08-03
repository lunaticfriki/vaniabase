import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command.dart';
import 'package:backend/modules/identity/application/session_read_model.dart';
import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/errors/invalid_refresh_token_error.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';

class RefreshSessionCommandHandler {
  RefreshSessionCommandHandler(
    this._refreshTokens,
    this._accessTokens, {
    this.refreshTokenValidFor = const Duration(days: 30),
  });

  final RefreshTokenRepository _refreshTokens;
  final AccessTokenIssuer _accessTokens;
  final Duration refreshTokenValidFor;

  Future<SessionReadModel> handle(RefreshSessionCommand command) async {
    final id = RefreshTokenId.create(command.refreshToken);
    final existing = await _refreshTokens.findById(id);
    if (existing == null || !existing.isValid) {
      throw InvalidRefreshTokenError();
    }

    existing.revoke();
    await _refreshTokens.save(existing);

    final rotated = RefreshToken.issue(
      userId: existing.userId,
      validFor: refreshTokenValidFor,
    );
    await _refreshTokens.save(rotated);

    final accessToken = _accessTokens.issue(existing.userId);

    return SessionReadModel(
      accessToken: accessToken.token,
      accessTokenExpiresAt: accessToken.expiresAt,
      refreshToken: rotated.id.value,
    );
  }
}
