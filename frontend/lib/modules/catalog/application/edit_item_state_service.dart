import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';

sealed class EditItemState {
  const EditItemState();
}

class EditItemLoading extends EditItemState {
  const EditItemLoading();
}

class EditItemLoadFailure extends EditItemState {
  const EditItemLoadFailure(this.message);

  final String message;
}

class EditItemReady extends EditItemState {
  const EditItemReady(this.item, {this.isSubmitting = false, this.submitError});

  final ItemReadModel item;
  final bool isSubmitting;
  final String? submitError;
}

class EditItemSuccess extends EditItemState {
  const EditItemSuccess(this.itemId);

  final String itemId;
}

class EditItemDeleting extends EditItemState {
  const EditItemDeleting(this.item);

  final ItemReadModel item;
}

class EditItemDeleted extends EditItemState {
  const EditItemDeleted();
}

class EditItemStateService extends Cubit<EditItemState> {
  EditItemStateService(this._readService, this._writeService, this._itemId)
    : super(const EditItemLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final ItemWriteService _writeService;
  final String _itemId;

  Future<void> _load() async {
    try {
      final item = await _readService.getById(id: _itemId);
      emit(EditItemReady(item));
    } catch (error) {
      emit(EditItemLoadFailure(error.toString()));
    }
  }

  Future<void> submit({
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
    bool removeImage = false,
    bool? completed,
    String? reference,
  }) async {
    final current = state;
    if (current is! EditItemReady) return;
    emit(EditItemReady(current.item, isSubmitting: true));
    try {
      await _writeService.update(
        id: _itemId,
        title: title,
        creator: creator,
        publisher: publisher,
        category: category,
        format: format,
        tags: tags,
        topic: topic,
        year: year,
        description: description,
        language: language,
        imageBytes: imageBytes,
        removeImage: removeImage,
        completed: completed,
        reference: reference,
      );
      emit(EditItemSuccess(_itemId));
    } catch (error) {
      emit(EditItemReady(current.item, submitError: error.toString()));
    }
  }

  Future<void> delete() async {
    final current = state;
    if (current is! EditItemReady) return;
    emit(EditItemDeleting(current.item));
    try {
      await _writeService.delete(id: _itemId);
      emit(const EditItemDeleted());
    } catch (error) {
      emit(EditItemReady(current.item, submitError: error.toString()));
    }
  }
}
