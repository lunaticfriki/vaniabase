import 'package:backend/modules/catalog/infrastructure/acl/item_mapper.dart';
import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:postgres/postgres.dart';

class PostgresItemRepository implements ItemRepository {
  PostgresItemRepository(this._pool);

  final Pool _pool;

  @override
  Future<Item?> findById(ItemId id) async {
    final result = await _pool.execute(
      Sql.named('SELECT * FROM items WHERE id = @id::uuid'),
      parameters: {'id': id.value},
    );
    if (result.isEmpty) return null;
    return ItemMapper.toDomain(result.first.toColumnMap());
  }

  @override
  Future<PageResult<Item>> list(ItemCriteria criteria) async {
    final countResult = await _pool.execute(
      Sql.named('SELECT COUNT(*) AS total FROM items WHERE owner_id = @ownerId::uuid'),
      parameters: {'ownerId': criteria.ownerId.value},
    );
    final totalItems = (countResult.first.toColumnMap()['total'] as num).toInt();

    final rowsResult = await _pool.execute(
      Sql.named('''
        SELECT * FROM items
        WHERE owner_id = @ownerId::uuid
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {
        'ownerId': criteria.ownerId.value,
        'limit': criteria.pageRequest.limit,
        'offset': criteria.pageRequest.offset,
      },
    );

    return PageResult<Item>(
      items: rowsResult
          .map((row) => ItemMapper.toDomain(row.toColumnMap()))
          .toList(),
      page: criteria.pageRequest.page,
      pageSize: criteria.pageRequest.pageSize,
      totalItems: totalItems,
    );
  }

  @override
  Future<void> save(Item item) async {
    await _pool.execute(
      Sql.named('''
        INSERT INTO items (
          id, owner_id, title, creator, publisher, category, format,
          tags, topic, year, description, language, image_url,
          created_at, updated_at
        )
        VALUES (
          @id::uuid, @owner_id::uuid, @title, @creator::text[], @publisher,
          @category, @format, @tags::text[], @topic, @year, @description,
          @language, @image_url, @created_at, @updated_at
        )
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          creator = EXCLUDED.creator,
          publisher = EXCLUDED.publisher,
          category = EXCLUDED.category,
          format = EXCLUDED.format,
          tags = EXCLUDED.tags,
          topic = EXCLUDED.topic,
          year = EXCLUDED.year,
          description = EXCLUDED.description,
          language = EXCLUDED.language,
          image_url = EXCLUDED.image_url,
          updated_at = EXCLUDED.updated_at
      '''),
      parameters: ItemMapper.toPersistence(item),
    );
  }

  @override
  Future<void> delete(ItemId id) async {
    await _pool.execute(
      Sql.named('DELETE FROM items WHERE id = @id::uuid'),
      parameters: {'id': id.value},
    );
  }
}
