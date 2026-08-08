import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

class ItemMapper {
  static ItemReadModel toReadModel(String id, Map<String, dynamic> data) {
    return ItemReadModel(
      id: id,
      ownerId: data['owner_id'] as String,
      title: data['title'] as String,
      creator: ((data['creator'] as List?) ?? const []).cast<String>(),
      publisher: data['publisher'] as String,
      category: data['category'] as String,
      format: data['format'] as String,
      tags: ((data['tags'] as List?) ?? const []).cast<String>(),
      topic: data['topic'] as String? ?? '',
      year: data['year'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      language: data['language'] as String? ?? '',
      imageUrl: data['image_url'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }
}
