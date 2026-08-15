import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';

sealed class AddItemState {
  const AddItemState();
}

class AddItemIdle extends AddItemState {
  const AddItemIdle();
}

class AddItemInProgress extends AddItemState {
  const AddItemInProgress();
}

class AddItemSuccess extends AddItemState {
  const AddItemSuccess();
}

class AddItemFailure extends AddItemState {
  const AddItemFailure(this.message);

  final String message;
}

class AddItemStateService extends Cubit<AddItemState> {
  AddItemStateService(this._writeService) : super(const AddItemIdle());

  final ItemWriteService _writeService;

  Future<void> submit({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required List<String> format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    List<String>? language,
    Uint8List? imageBytes,
    bool completed = false,
    String? reference,
  }) async {
    emit(const AddItemInProgress());
    try {
      await _writeService.create(
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
        completed: completed,
        reference: reference,
      );
      emit(const AddItemSuccess());
    } catch (error) {
      emit(AddItemFailure(error.toString()));
    }
  }
}
