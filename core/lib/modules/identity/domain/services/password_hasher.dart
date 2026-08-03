import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';

abstract class PasswordHasher {
  PasswordHash hash(Password password);

  bool verify(String candidate, PasswordHash hash);
}
