import 'package:bloc_test/bloc_test.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/topics_state.dart';
import 'package:frontend/modules/catalog/application/topics_state_service.dart';
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
          ItemReadModelMother.random(id: 'item-1', topic: 'Science Fiction'),
          ItemReadModelMother.random(id: 'item-2', topic: 'Science Fiction'),
          ItemReadModelMother.random(id: 'item-3', topic: 'History'),
          ItemReadModelMother.random(id: 'item-4', topic: ''),
          ItemReadModelMother.random(id: 'item-5', topic: 'Steampunk'),
        ],
        page: 1,
        pageSize: PageRequest.maxPageSize,
        totalItems: 5,
      ),
    );
  });

  group('TopicsStateService', () {
    blocTest<TopicsStateService, TopicsState>(
      'loads distinct, sorted topics across every item, ignoring empty ones',
      build: () => TopicsStateService(readService),
      expect: () => [isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.topics, ['History', 'Science Fiction', 'Steampunk']);
        expect(state.selectedLetter, isNull);
        expect(state.selectedTopic, isNull);
      },
    );

    blocTest<TopicsStateService, TopicsState>(
      'selectLetter auto-selects the first topic for that letter',
      build: () => TopicsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('S');
      },
      expect: () => [isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.selectedLetter, 'S');
        expect(state.selectedTopic, 'Science Fiction');
        expect(state.selectedItems.map((i) => i.id), ['item-1', 'item-2']);
      },
    );

    blocTest<TopicsStateService, TopicsState>(
      'selecting the same letter again clears the selection',
      build: () => TopicsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('S');
        service.selectLetter('S');
      },
      expect: () => [isA<TopicsLoaded>(), isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.selectedLetter, isNull);
        expect(state.selectedTopic, isNull);
      },
    );

    blocTest<TopicsStateService, TopicsState>(
      'selectTopic overrides the default topic within the same letter',
      build: () => TopicsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('S');
        service.selectTopic('Steampunk');
      },
      expect: () => [isA<TopicsLoaded>(), isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.selectedLetter, 'S');
        expect(state.selectedTopic, 'Steampunk');
        expect(state.selectedItems.map((i) => i.id), ['item-5']);
      },
    );

    blocTest<TopicsStateService, TopicsState>(
      'selecting the default topic again clears the topic but keeps the letter',
      build: () => TopicsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('S');
        service.selectTopic('Science Fiction');
      },
      expect: () => [isA<TopicsLoaded>(), isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.selectedTopic, isNull);
        expect(state.selectedLetter, 'S');
      },
    );

    blocTest<TopicsStateService, TopicsState>(
      'an initial topic pre-selects its letter and itself',
      build: () => TopicsStateService(readService, initialTopic: 'History'),
      expect: () => [isA<TopicsLoaded>()],
      verify: (service) {
        final state = service.state as TopicsLoaded;
        expect(state.selectedLetter, 'H');
        expect(state.selectedTopic, 'History');
      },
    );
  });
}
