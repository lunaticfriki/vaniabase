import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/infrastructure/http_item_repository.dart';

abstract class ItemReadService {
  Future<PageResult<ItemReadModel>> list({required PageRequest pageRequest});
}

class ItemReadServiceImpl implements ItemReadService {
  ItemReadServiceImpl(this._repository);

  final HttpItemRepository _repository;

  @override
  Future<PageResult<ItemReadModel>> list({required PageRequest pageRequest}) =>
      _repository.list(pageRequest);
}
