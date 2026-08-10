import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/infrastructure/acl/item_mapper.dart';

class FirestoreItemRepository implements ItemReadService, ItemWriteService {
  FirestoreItemRepository(this._firestore, this._firebaseAuth, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _storage;

  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw StateError('no authenticated user');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _items => _firestore.collection('items');

  Reference _imageRef(String itemId) => _storage.ref('items/$itemId/image');

  Future<String> _uploadImage(String itemId, Uint8List bytes) async {
    final ref = _imageRef(itemId);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> _deleteImage(String itemId) async {
    try {
      await _imageRef(itemId).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  @override
  Future<PageResult<ItemReadModel>> list({
    required PageRequest pageRequest,
    String? category,
  }) async {
    Query<Map<String, dynamic>> query = _items.where('owner_id', isEqualTo: _uid);
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.orderBy('created_at', descending: true).get();
    final allItems = snapshot.docs.map((doc) => ItemMapper.toReadModel(doc.id, doc.data())).toList();

    final start = pageRequest.offset;
    final end = (start + pageRequest.limit).clamp(0, allItems.length);
    final pageItems = start >= allItems.length ? const <ItemReadModel>[] : allItems.sublist(start, end);

    return PageResult<ItemReadModel>(
      items: pageItems,
      page: pageRequest.page,
      pageSize: pageRequest.pageSize,
      totalItems: allItems.length,
    );
  }

  @override
  Future<ItemReadModel> getById({required String id}) async {
    final doc = await _items.doc(id).get();
    return ItemMapper.toReadModel(doc.id, doc.data()!);
  }

  @override
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
    String? imageUrl,
    bool completed = false,
    String? reference,
  }) async {
    final doc = _items.doc();
    final resolvedImageUrl = imageBytes != null
        ? await _uploadImage(doc.id, imageBytes)
        : (imageUrl ?? '');
    await doc.set({
      'owner_id': _uid,
      'title': title,
      'creator': creator,
      'publisher': publisher,
      'category': category,
      'format': format,
      'tags': tags ?? const <String>[],
      'topic': topic ?? '',
      'year': year ?? 0,
      'description': description ?? '',
      'language': language ?? '',
      'image_url': resolvedImageUrl,
      'completed': completed,
      'reference': reference ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
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
    bool? completed,
    String? reference,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await _uploadImage(id, imageBytes);
    } else if (removeImage) {
      await _deleteImage(id);
      imageUrl = '';
    }
    await _items.doc(id).update({
      'title': ?title,
      'creator': ?creator,
      'publisher': ?publisher,
      'category': ?category,
      'format': ?format,
      'tags': ?tags,
      'topic': ?topic,
      'year': ?year,
      'description': ?description,
      'language': ?language,
      'image_url': ?imageUrl,
      'completed': ?completed,
      'reference': ?reference,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete({required String id}) async {
    await _items.doc(id).delete();
    await _deleteImage(id);
  }
}
