import 'package:core/shared/errors/domain_error.dart';

class InvalidRefreshTokenError extends DomainError {
  InvalidRefreshTokenError() : super('refresh token is invalid or expired');
}
