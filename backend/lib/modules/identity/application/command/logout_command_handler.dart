import 'package:backend/modules/identity/application/command/logout_command.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';

class LogoutCommandHandler {
  LogoutCommandHandler(this._refreshTokens);

  final RefreshTokenRepository _refreshTokens;

  Future<void> handle(LogoutCommand command) async {
    final id = RefreshTokenId.create(command.refreshToken);
    final existing = await _refreshTokens.findById(id);
    if (existing == null) {
      return;
    }
    existing.revoke();
    await _refreshTokens.save(existing);
  }
}
