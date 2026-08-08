import 'dart:typed_data';

abstract class ItemWriteService {
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
    Uint8List? imageBytes,
  });

  Future<void> update({
    required String id,
    String? title,
    List<String>? creator,
    String? publisher,
    String? category,
    String? format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    String? language,
    Uint8List? imageBytes,
    bool removeImage = false,
  });

  Future<void> delete({required String id});
}
