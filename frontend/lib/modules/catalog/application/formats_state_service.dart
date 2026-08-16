import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

const formatPreviewCount = 8;

sealed class FormatsState {
  const FormatsState();
}

class FormatsLoading extends FormatsState {
  const FormatsLoading();
}

class FormatsLoaded extends FormatsState {
  const FormatsLoaded(this.previewImageUrls);

  final Map<String, List<String>> previewImageUrls;
}

class FormatsError extends FormatsState {
  const FormatsError(this.message);

  final String message;
}

class FormatsStateService extends Cubit<FormatsState> {
  FormatsStateService(this._readService, this._formats)
    : super(const FormatsLoading()) {
    _previewImageUrls = {
      for (final format in _formats) format: const <String>[],
    };
    _subscriptions = [
      for (final format in _formats)
        _readService
            .watchAll(format: format)
            .listen(
              (items) => _onFormatItems(format, items),
              onError: (Object error) => emit(FormatsError(error.toString())),
            ),
    ];
  }

  final ItemReadService _readService;
  final List<String> _formats;
  late Map<String, List<String>> _previewImageUrls;
  late final List<StreamSubscription<List<ItemReadModel>>> _subscriptions;

  void _onFormatItems(String format, List<ItemReadModel> items) {
    _previewImageUrls = Map.of(_previewImageUrls)
      ..[format] = items
          .take(formatPreviewCount)
          .map((item) => item.imageUrl)
          .toList();
    emit(FormatsLoaded(_previewImageUrls));
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
