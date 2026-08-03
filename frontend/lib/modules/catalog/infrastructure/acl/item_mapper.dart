import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

class ItemMapper {
  static ItemReadModel toReadModel(Map<String, dynamic> json) {
    return ItemReadModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      creator: (json['creator'] as List).cast<String>(),
      publisher: json['publisher'] as String,
      category: json['category'] as String,
      format: json['format'] as String,
      tags: (json['tags'] as List).cast<String>(),
      topic: json['topic'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      language: json['language'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static PageResult<ItemReadModel> toPageResult(Map<String, dynamic> json) {
    return PageResult<ItemReadModel>(
      items: (json['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(toReadModel)
          .toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
    );
  }
}
