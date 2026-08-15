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
      format: _stringList(data['format']),
      tags: ((data['tags'] as List?) ?? const []).cast<String>(),
      topic: data['topic'] as String? ?? '',
      year: data['year'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      language: _stringList(data['language']),
      imageUrl: data['image_url'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
      reference: data['reference'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  /// Accepts both the legacy single-string shape and the current array
  /// shape, so items written before the multi-value migration keep reading
  /// correctly without a data migration.
  static List<String> _stringList(dynamic raw) {
    if (raw is List) return raw.cast<String>();
    if (raw is String && raw.isNotEmpty) return [raw];
    return const [];
  }
}
