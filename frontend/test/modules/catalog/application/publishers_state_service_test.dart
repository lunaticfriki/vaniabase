import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/publishers_state_service.dart';
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
        ItemReadModelMother.random(id: 'item-1', publisher: 'Chilton Books'),
        ItemReadModelMother.random(id: 'item-2', publisher: 'Chilton Books'),
        ItemReadModelMother.random(id: 'item-3', publisher: 'Penguin'),
        ItemReadModelMother.random(id: 'item-4', publisher: ''),
        ItemReadModelMother.random(id: 'item-5', publisher: 'City Lights'),
      ]),
    );
  });

  group('PublishersStateService', () {
    blocTest<PublishersStateService, PublishersState>(
      'loads distinct, sorted publishers across every item, ignoring empty ones',
      build: () => PublishersStateService(readService),
      expect: () => [isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.publishers, ['Chilton Books', 'City Lights', 'Penguin']);
        expect(state.selectedLetter, isNull);
        expect(state.selectedPublisher, isNull);
      },
    );

    blocTest<PublishersStateService, PublishersState>(
      'selectLetter auto-selects the first publisher for that letter',
      build: () => PublishersStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('C');
      },
      expect: () => [isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.selectedLetter, 'C');
        expect(state.selectedPublisher, 'Chilton Books');
        expect(state.selectedItems.map((i) => i.id), ['item-1', 'item-2']);
      },
    );

    blocTest<PublishersStateService, PublishersState>(
      'selecting the same letter again clears the selection',
      build: () => PublishersStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('C');
        service.selectLetter('C');
      },
      expect: () => [isA<PublishersLoaded>(), isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.selectedLetter, isNull);
        expect(state.selectedPublisher, isNull);
      },
    );

    blocTest<PublishersStateService, PublishersState>(
      'selectPublisher overrides the default publisher within the same letter',
      build: () => PublishersStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('C');
        service.selectPublisher('City Lights');
      },
      expect: () => [isA<PublishersLoaded>(), isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.selectedLetter, 'C');
        expect(state.selectedPublisher, 'City Lights');
        expect(state.selectedItems.map((i) => i.id), ['item-5']);
      },
    );

    blocTest<PublishersStateService, PublishersState>(
      'selecting the default publisher again clears the publisher but keeps the letter',
      build: () => PublishersStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('C');
        service.selectPublisher('Chilton Books');
      },
      expect: () => [isA<PublishersLoaded>(), isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.selectedPublisher, isNull);
        expect(state.selectedLetter, 'C');
      },
    );

    blocTest<PublishersStateService, PublishersState>(
      'an initial publisher pre-selects its letter and itself',
      build: () =>
          PublishersStateService(readService, initialPublisher: 'Penguin'),
      expect: () => [isA<PublishersLoaded>()],
      verify: (service) {
        final state = service.state as PublishersLoaded;
        expect(state.selectedLetter, 'P');
        expect(state.selectedPublisher, 'Penguin');
      },
    );
  });
}
