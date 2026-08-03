import 'dart:convert';

import 'package:backend/shared/http/json_response_util.dart';
import 'package:backend/modules/catalog/application/command/create_item_command.dart';
import 'package:backend/modules/catalog/application/command/delete_item_command.dart';
import 'package:backend/modules/catalog/application/command/update_item_command.dart';
import 'package:backend/modules/catalog/application/item_read_model.dart';
import 'package:backend/modules/catalog/application/item_read_service.dart';
import 'package:backend/modules/catalog/application/item_write_service.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query.dart';
import 'package:backend/modules/catalog/application/query/list_items_query.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router buildItemRouter(ItemReadService reads, ItemWriteService writes) {
  final router = Router();

  router.post('/items', (Request request) async {
    final ownerId = request.context['userId'] as UserId;
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final id = await writes.create(
      CreateItemCommand(
        ownerId: ownerId.value,
        title: body['title'] as String,
        creator: (body['creator'] as List).cast<String>(),
        publisher: body['publisher'] as String,
        category: body['category'] as String,
        format: body['format'] as String,
        tags: (body['tags'] as List?)?.cast<String>(),
        topic: body['topic'] as String?,
        year: body['year'] as int?,
        description: body['description'] as String?,
        language: body['language'] as String?,
        imageUrl: body['imageUrl'] as String?,
      ),
    );
    return jsonResponse(201, {'id': id});
  });

  router.get('/items/<id>', (Request request, String id) async {
    final requestingUserId = request.context['userId'] as UserId;
    final item = await reads.getById(
      GetItemByIdQuery(itemId: id, requestingUserId: requestingUserId.value),
    );
    return jsonResponse(200, _itemJson(item));
  });

  router.patch('/items/<id>', (Request request, String id) async {
    final requestingUserId = request.context['userId'] as UserId;
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    await writes.update(
      UpdateItemCommand(
        itemId: id,
        requestingUserId: requestingUserId.value,
        title: body['title'] as String?,
        creator: (body['creator'] as List?)?.cast<String>(),
        publisher: body['publisher'] as String?,
        category: body['category'] as String?,
        format: body['format'] as String?,
        tags: (body['tags'] as List?)?.cast<String>(),
        topic: body['topic'] as String?,
        year: body['year'] as int?,
        description: body['description'] as String?,
        language: body['language'] as String?,
        imageUrl: body['imageUrl'] as String?,
      ),
    );
    return Response(204);
  });

  router.delete('/items/<id>', (Request request, String id) async {
    final requestingUserId = request.context['userId'] as UserId;
    await writes.delete(
      DeleteItemCommand(itemId: id, requestingUserId: requestingUserId.value),
    );
    return Response(204);
  });

  router.get('/items', (Request request) async {
    final requestingUserId = request.context['userId'] as UserId;
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final pageSize =
        int.tryParse(request.url.queryParameters['pageSize'] ?? '') ?? 10;
    final result = await reads.list(
      ListItemsQuery(
        ownerId: requestingUserId.value,
        page: page,
        pageSize: pageSize,
      ),
    );
    return jsonResponse(200, _pageJson(result));
  });

  return router;
}

Map<String, dynamic> _pageJson(PageResult<ItemReadModel> result) {
  return {
    'items': result.items.map(_itemJson).toList(),
    'page': result.page,
    'pageSize': result.pageSize,
    'totalItems': result.totalItems,
    'totalPages': result.totalPages,
  };
}

Map<String, dynamic> _itemJson(ItemReadModel item) {
  return {
    'id': item.id,
    'ownerId': item.ownerId,
    'title': item.title,
    'creator': item.creator,
    'publisher': item.publisher,
    'category': item.category,
    'format': item.format,
    'tags': item.tags,
    'topic': item.topic,
    'year': item.year,
    'description': item.description,
    'language': item.language,
    'imageUrl': item.imageUrl,
    'createdAt': item.createdAt.toIso8601String(),
    'updatedAt': item.updatedAt.toIso8601String(),
  };
}
