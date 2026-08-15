import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/errors/domain_error.dart';

class UsernameAlreadyTakenError extends DomainError {
  UsernameAlreadyTakenError(Username username)
      : super('"${username.value}" is already taken');
}
