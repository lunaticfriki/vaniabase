import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/infrastructure/acl/item_mapper.dart';
import 'package:frontend/shared/http/api_client.dart';

class HttpItemRepository {
  HttpItemRepository(this._client);

  final ApiClient _client;

  Future<PageResult<ItemReadModel>> list(PageRequest pageRequest) async {
    final json = await _client.get(
      '/items',
      queryParameters: {
        'page': '${pageRequest.page}',
        'pageSize': '${pageRequest.pageSize}',
      },
    );
    return ItemMapper.toPageResult(json);
  }

  Future<String> create({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required String format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    String? language,
    String? imageUrl,
  }) async {
    final json = await _client.post(
      '/items',
      body: {
        'title': title,
        'creator': creator,
        'publisher': publisher,
        'category': category,
        'format': format,
        'tags': ?tags,
        'topic': ?topic,
        'year': ?year,
        'description': ?description,
        'language': ?language,
        'imageUrl': ?imageUrl,
      },
    );
    return json['id'] as String;
  }
}
