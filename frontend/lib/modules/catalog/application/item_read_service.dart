import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

abstract class ItemReadService {
  Future<PageResult<ItemReadModel>> list({required PageRequest pageRequest, String? category});

  Future<ItemReadModel> getById({required String id});
}
