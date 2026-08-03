import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/command/login_command.dart';
import 'package:backend/modules/identity/application/session_read_model.dart';
import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/errors/invalid_credentials_error.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';

class LoginCommandHandler {
  LoginCommandHandler(
    this._users,
    this._hasher,
    this._refreshTokens,
    this._accessTokens, {
    this.refreshTokenValidFor = const Duration(days: 30),
  });

  final UserRepository _users;
  final PasswordHasher _hasher;
  final RefreshTokenRepository _refreshTokens;
  final AccessTokenIssuer _accessTokens;
  final Duration refreshTokenValidFor;

  Future<SessionReadModel> handle(LoginCommand command) async {
    final user = await _users.findByEmail(Email.create(command.email));
    if (user == null || !_hasher.verify(command.password, user.passwordHash)) {
      throw InvalidCredentialsError();
    }

    final accessToken = _accessTokens.issue(user.id);
    final refreshToken = RefreshToken.issue(
      userId: user.id,
      validFor: refreshTokenValidFor,
    );
    await _refreshTokens.save(refreshToken);

    return SessionReadModel(
      accessToken: accessToken.token,
      accessTokenExpiresAt: accessToken.expiresAt,
      refreshToken: refreshToken.id.value,
    );
  }
}
