import 'package:core/shared/pagination/page_request.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

Future<List<ItemReadModel>> fetchAllItems(ItemReadService readService) async {
  final items = <ItemReadModel>[];
  var pageRequest = PageRequest.create(pageSize: PageRequest.maxPageSize);
  while (true) {
    final result = await readService.list(pageRequest: pageRequest);
    items.addAll(result.items);
    if (items.length >= result.totalItems) break;
    pageRequest = pageRequest.next();
  }
  return items;
}
