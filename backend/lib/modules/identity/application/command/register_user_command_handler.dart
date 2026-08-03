import 'package:backend/modules/identity/application/command/register_user_command.dart';
import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/errors/email_already_registered_error.dart';
import 'package:core/modules/identity/domain/errors/username_already_taken_error.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';

class RegisterUserCommandHandler {
  RegisterUserCommandHandler(this._users, this._hasher);

  final UserRepository _users;
  final PasswordHasher _hasher;

  Future<UserId> handle(RegisterUserCommand command) async {
    final email = Email.create(command.email);
    final username = Username.create(command.username);
    final password = Password.create(command.password);

    if (await _users.findByEmail(email) != null) {
      throw EmailAlreadyRegisteredError(email);
    }
    if (await _users.findByUsername(username) != null) {
      throw UsernameAlreadyTakenError(username);
    }

    final passwordHash = _hasher.hash(password);
    final user = User.register(
      email: email,
      username: username,
      passwordHash: passwordHash,
    );
    await _users.save(user);
    return user.id;
  }
}
