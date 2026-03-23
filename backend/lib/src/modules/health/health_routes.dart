import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

Handler healthRoutes() {
  final router = Router();

  router.get('/health', (Request req) {
    return Response.ok(
      jsonEncode(<String, dynamic>{'status': 'ok'}),
      headers: <String, String>{'content-type': 'application/json'},
    );
  });

  return router.call;
}
