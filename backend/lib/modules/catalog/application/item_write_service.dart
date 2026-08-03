import 'package:backend/modules/catalog/application/command/create_item_command.dart';
import 'package:backend/modules/catalog/application/command/create_item_command_handler.dart';
import 'package:backend/modules/catalog/application/command/delete_item_command.dart';
import 'package:backend/modules/catalog/application/command/delete_item_command_handler.dart';
import 'package:backend/modules/catalog/application/command/update_item_command.dart';
import 'package:backend/modules/catalog/application/command/update_item_command_handler.dart';

abstract class ItemWriteService {
  Future<String> create(CreateItemCommand command);

  Future<void> update(UpdateItemCommand command);

  Future<void> delete(DeleteItemCommand command);
}

class ItemWriteServiceImpl implements ItemWriteService {
  ItemWriteServiceImpl(this._create, this._update, this._delete);

  final CreateItemCommandHandler _create;
  final UpdateItemCommandHandler _update;
  final DeleteItemCommandHandler _delete;

  @override
  Future<String> create(CreateItemCommand command) => _create.handle(command);

  @override
  Future<void> update(UpdateItemCommand command) => _update.handle(command);

  @override
  Future<void> delete(DeleteItemCommand command) => _delete.handle(command);
}
