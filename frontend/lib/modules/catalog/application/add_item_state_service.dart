import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/add_item_state.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';

class AddItemStateService extends Cubit<AddItemState> {
  AddItemStateService(this._writeService) : super(const AddItemIdle());

  final ItemWriteService _writeService;

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
    String? imageUrl,
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
        imageUrl: imageUrl,
      );
      emit(const AddItemSuccess());
    } catch (error) {
      emit(AddItemFailure(error.toString()));
    }
  }
}
