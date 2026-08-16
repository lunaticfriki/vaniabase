import 'package:frontend/modules/catalog/application/item_read_model.dart';

abstract class ItemReadService {
  Stream<List<ItemReadModel>> watchAll({
    String? category,
    String? format,
    bool? completed,
  });

  Future<ItemReadModel> getById({required String id});
}
