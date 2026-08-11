import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/tags_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
    when(() => readService.watchAll()).thenAnswer(
      (_) => Stream.value([
        ItemReadModelMother.random(
          id: 'item-1',
          tags: const ['sci-fi', 'classic'],
        ),
        ItemReadModelMother.random(id: 'item-2', tags: const ['sci-fi']),
        ItemReadModelMother.random(id: 'item-3', tags: const ['drama']),
      ]),
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

    blocTest<TagsStateService, TagsState>(
      'a live update keeps the current selection when the tag still exists',
      setUp: () {
        when(() => readService.watchAll()).thenAnswer(
          (_) => Stream.fromIterable([
            [
              ItemReadModelMother.random(id: 'item-1', tags: const ['sci-fi']),
              ItemReadModelMother.random(id: 'item-2', tags: const ['sci-fi']),
            ],
            [
              ItemReadModelMother.random(id: 'item-1', tags: const ['sci-fi']),
              ItemReadModelMother.random(id: 'item-2', tags: const ['sci-fi']),
              ItemReadModelMother.random(id: 'item-3', tags: const ['sci-fi']),
            ],
          ]),
        );
      },
      build: () => TagsStateService(readService),
      expect: () => [
        isA<TagsLoaded>().having((s) => s.selectedTag, 'selectedTag', 'sci-fi'),
        isA<TagsLoaded>().having((s) => s.selectedTag, 'selectedTag', 'sci-fi'),
      ],
      verify: (service) {
        final state = service.state as TagsLoaded;
        expect(state.items, hasLength(3));
      },
    );

    blocTest<TagsStateService, TagsState>(
      'a live update clears the selection once that tag no longer exists',
      setUp: () {
        when(() => readService.watchAll()).thenAnswer(
          (_) => Stream.fromIterable([
            [
              ItemReadModelMother.random(id: 'item-1', tags: const ['sci-fi']),
            ],
            [
              ItemReadModelMother.random(id: 'item-1', tags: const ['drama']),
            ],
          ]),
        );
      },
      build: () => TagsStateService(readService),
      expect: () => [
        isA<TagsLoaded>().having((s) => s.selectedTag, 'selectedTag', 'sci-fi'),
        isA<TagsLoaded>().having((s) => s.selectedTag, 'selectedTag', isNull),
      ],
    );
  });
}
