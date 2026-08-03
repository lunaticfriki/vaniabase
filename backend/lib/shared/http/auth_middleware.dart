import 'package:backend/shared/http/json_response_util.dart';
import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:shelf/shelf.dart';

Middleware authMiddleware(AccessTokenIssuer accessTokens) {
  return (Handler innerHandler) {
    return (Request request) async {
      final header = request.headers['authorization'];
      if (header == null || !header.startsWith('Bearer ')) {
        return jsonResponse(401, {'error': 'missing bearer token'});
      }

      final userId = accessTokens.verify(header.substring('Bearer '.length));
      if (userId == null) {
        return jsonResponse(401, {'error': 'invalid or expired access token'});
      }

      return innerHandler(request.change(context: {'userId': userId}));
    };
  };
}
