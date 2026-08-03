import 'package:core/shared/errors/domain_error.dart';

class InvalidCredentialsError extends DomainError {
  InvalidCredentialsError() : super('email or password is incorrect');
}
