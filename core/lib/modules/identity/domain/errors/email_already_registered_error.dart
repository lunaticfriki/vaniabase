import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/shared/errors/domain_error.dart';

class EmailAlreadyRegisteredError extends DomainError {
  EmailAlreadyRegisteredError(Email email)
    : super('"${email.value}" is already registered');
}
