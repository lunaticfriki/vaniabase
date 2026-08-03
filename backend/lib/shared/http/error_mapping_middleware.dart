import 'package:backend/shared/http/json_response_util.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/identity/domain/errors/email_already_registered_error.dart';
import 'package:core/modules/identity/domain/errors/invalid_credentials_error.dart';
import 'package:core/modules/identity/domain/errors/invalid_refresh_token_error.dart';
import 'package:core/modules/identity/domain/errors/username_already_taken_error.dart';
import 'package:core/shared/errors/domain_error.dart';
import 'package:shelf/shelf.dart';

Middleware errorMappingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } on ItemNotFoundError catch (error) {
        return jsonResponse(404, {'error': error.message});
      } on InvalidCredentialsError catch (error) {
        return jsonResponse(401, {'error': error.message});
      } on InvalidRefreshTokenError catch (error) {
        return jsonResponse(401, {'error': error.message});
      } on EmailAlreadyRegisteredError catch (error) {
        return jsonResponse(409, {'error': error.message});
      } on UsernameAlreadyTakenError catch (error) {
        return jsonResponse(409, {'error': error.message});
      } on DomainError catch (error) {
        return jsonResponse(400, {'error': error.message});
      } catch (error) {
        return jsonResponse(500, {'error': 'internal server error'});
      }
    };
  };
}
