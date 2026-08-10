import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/categories_state.dart';
import 'package:frontend/modules/catalog/application/categories_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
  });

  group('CategoriesStateService', () {
    blocTest<CategoriesStateService, CategoriesState>(
      'loads preview image URLs for every category, capped at categoryPreviewCount',
      setUp: () {
        when(() => readService.watchAll(category: 'book')).thenAnswer(
          (_) => Stream.value(
            List.generate(
              10,
              (i) => ItemReadModelMother.random(id: 'book-$i'),
            ),
          ),
        );
        when(
          () => readService.watchAll(category: 'movie'),
        ).thenAnswer((_) => Stream.value([ItemReadModelMother.random(id: 'movie-1')]));
      },
      build: () => CategoriesStateService(readService, ['book', 'movie']),
      expect: () => [isA<CategoriesLoaded>(), isA<CategoriesLoaded>()],
      verify: (service) {
        final state = service.state as CategoriesLoaded;
        expect(state.previewImageUrls['book'], hasLength(categoryPreviewCount));
        expect(state.previewImageUrls['movie'], hasLength(1));
      },
    );

    blocTest<CategoriesStateService, CategoriesState>(
      'a live update refreshes only the affected category',
      setUp: () {
        final controller = StreamController<List<ItemReadModel>>();
        addTearDown(controller.close);
        when(() => readService.watchAll(category: 'book')).thenAnswer((_) => controller.stream);
        when(() => readService.watchAll(category: 'movie')).thenAnswer(
          (_) => Stream.value([ItemReadModelMother.random(id: 'movie-1')]),
        );
        controller.add([ItemReadModelMother.random(id: 'book-1')]);
        scheduleMicrotask(() => controller.add([
          ItemReadModelMother.random(id: 'book-1'),
          ItemReadModelMother.random(id: 'book-2'),
        ]));
      },
      build: () => CategoriesStateService(readService, ['book', 'movie']),
      expect: () => [
        isA<CategoriesLoaded>(),
        isA<CategoriesLoaded>(),
        isA<CategoriesLoaded>().having(
          (s) => s.previewImageUrls['book'],
          'book previews',
          hasLength(2),
        ),
      ],
    );

    blocTest<CategoriesStateService, CategoriesState>(
      'emits CategoriesError when a watch stream errors',
      setUp: () {
        when(
          () => readService.watchAll(category: 'book'),
        ).thenAnswer((_) => Stream.error(Exception('network error')));
      },
      build: () => CategoriesStateService(readService, ['book']),
      expect: () => [isA<CategoriesError>()],
    );
  });
}
