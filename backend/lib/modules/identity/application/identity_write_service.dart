import 'package:backend/modules/identity/application/command/login_command.dart';
import 'package:backend/modules/identity/application/command/login_command_handler.dart';
import 'package:backend/modules/identity/application/command/logout_command.dart';
import 'package:backend/modules/identity/application/command/logout_command_handler.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command_handler.dart';
import 'package:backend/modules/identity/application/command/register_user_command.dart';
import 'package:backend/modules/identity/application/command/register_user_command_handler.dart';
import 'package:backend/modules/identity/application/session_read_model.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';

abstract class IdentityWriteService {
  Future<UserId> register(RegisterUserCommand command);

  Future<SessionReadModel> login(LoginCommand command);

  Future<SessionReadModel> refresh(RefreshSessionCommand command);

  Future<void> logout(LogoutCommand command);
}

class IdentityWriteServiceImpl implements IdentityWriteService {
  IdentityWriteServiceImpl(
    this._registerUser,
    this._login,
    this._refreshSession,
    this._logout,
  );

  final RegisterUserCommandHandler _registerUser;
  final LoginCommandHandler _login;
  final RefreshSessionCommandHandler _refreshSession;
  final LogoutCommandHandler _logout;

  @override
  Future<UserId> register(RegisterUserCommand command) =>
      _registerUser.handle(command);

  @override
  Future<SessionReadModel> login(LoginCommand command) =>
      _login.handle(command);

  @override
  Future<SessionReadModel> refresh(RefreshSessionCommand command) =>
      _refreshSession.handle(command);

  @override
  Future<void> logout(LogoutCommand command) => _logout.handle(command);
}
