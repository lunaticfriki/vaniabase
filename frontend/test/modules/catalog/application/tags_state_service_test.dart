import 'package:bloc_test/bloc_test.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/tags_state.dart';
import 'package:frontend/modules/catalog/application/tags_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
    when(
      () => readService.list(pageRequest: PageRequest.create(pageSize: PageRequest.maxPageSize)),
    ).thenAnswer(
      (_) async => PageResult(
        items: [
          ItemReadModelMother.random(id: 'item-1', tags: const ['sci-fi', 'classic']),
          ItemReadModelMother.random(id: 'item-2', tags: const ['sci-fi']),
          ItemReadModelMother.random(id: 'item-3', tags: const ['drama']),
        ],
        page: 1,
        pageSize: PageRequest.maxPageSize,
        totalItems: 3,
      ),
    );
  });

  group('TagsStateService', () {
    blocTest<TagsStateService, TagsState>(
      'loads tag counts across every item and selects the first tag by default',
      build: () => TagsStateService(readService),
      expect: () => [isA<TagsLoaded>()],
      verify: (service) {
        final state = service.state as TagsLoaded;
        final byTag = {for (final t in state.tagCounts) t.tag: t.count};
        expect(byTag, {'sci-fi': 2, 'classic': 1, 'drama': 1});
        expect(state.selectedTag, 'classic');
        expect(state.selectedItems.map((i) => i.id), ['item-1']);
      },
    );

    blocTest<TagsStateService, TagsState>(
      'selectTag shows only items carrying that tag',
      build: () => TagsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectTag('sci-fi');
      },
      expect: () => [isA<TagsLoaded>()],
      verify: (service) {
        final state = service.state as TagsLoaded;
        expect(state.selectedTag, 'sci-fi');
        expect(state.selectedItems.map((i) => i.id), ['item-1', 'item-2']);
      },
    );

    blocTest<TagsStateService, TagsState>(
      'selecting the same tag again clears the selection',
      build: () => TagsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectTag('sci-fi');
        service.selectTag('sci-fi');
      },
      expect: () => [isA<TagsLoaded>(), isA<TagsLoaded>()],
      verify: (service) {
        final state = service.state as TagsLoaded;
        expect(state.selectedTag, isNull);
      },
    );
  });
}
