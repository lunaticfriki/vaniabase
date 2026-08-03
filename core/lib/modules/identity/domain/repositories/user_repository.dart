import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';

abstract class UserRepository {
  Future<User?> findById(UserId id);

  Future<User?> findByEmail(Email email);

  Future<User?> findByUsername(Username username);

  Future<void> save(User user);

  Future<void> delete(UserId id);
}
