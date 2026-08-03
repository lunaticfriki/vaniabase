import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

const _swaggerUiHtml = '''
<!DOCTYPE html>
<html>
  <head>
    <title>vaniabase API docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      window.onload = () => {
        window.ui = SwaggerUIBundle({
          url: '/openapi.yaml',
          dom_id: '#swagger-ui',
        });
      };
    </script>
  </body>
</html>
''';

Router buildDocsRouter() {
  final router = Router();

  router.get('/docs', (Request request) async {
    return Response.ok(_swaggerUiHtml, headers: {'content-type': 'text/html'});
  });

  router.get('/openapi.yaml', (Request request) async {
    final file = File('openapi.yaml');
    return Response.ok(
      await file.readAsString(),
      headers: {'content-type': 'application/yaml'},
    );
  });

  return router;
}
