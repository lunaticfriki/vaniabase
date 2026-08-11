import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/authors_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
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
          creator: const ['Frank Herbert', 'Brian Herbert'],
        ),
        ItemReadModelMother.random(
          id: 'item-2',
          creator: const ['Frank Herbert'],
        ),
        ItemReadModelMother.random(
          id: 'item-3',
          creator: const ['Ursula K. Le Guin'],
        ),
        ItemReadModelMother.random(
          id: 'item-4',
          creator: const ['Fyodor Dostoevsky'],
        ),
      ]),
    );
  });

  group('AuthorsStateService', () {
    blocTest<AuthorsStateService, AuthorsState>(
      'loads distinct, sorted authors across every item',
      build: () => AuthorsStateService(readService),
      expect: () => [isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.authors, [
          'Brian Herbert',
          'Frank Herbert',
          'Fyodor Dostoevsky',
          'Ursula K. Le Guin',
        ]);
        expect(state.selectedLetter, isNull);
        expect(state.selectedAuthor, isNull);
      },
    );

    blocTest<AuthorsStateService, AuthorsState>(
      'selectLetter auto-selects the first author for that letter',
      build: () => AuthorsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('F');
      },
      expect: () => [isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.selectedLetter, 'F');
        expect(state.selectedAuthor, 'Frank Herbert');
        expect(state.selectedItems.map((i) => i.id), ['item-1', 'item-2']);
      },
    );

    blocTest<AuthorsStateService, AuthorsState>(
      'selecting the same letter again clears the selection',
      build: () => AuthorsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('F');
        service.selectLetter('F');
      },
      expect: () => [isA<AuthorsLoaded>(), isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.selectedLetter, isNull);
        expect(state.selectedAuthor, isNull);
      },
    );

    blocTest<AuthorsStateService, AuthorsState>(
      'selectAuthor overrides the default author within the same letter',
      build: () => AuthorsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('F');
        service.selectAuthor('Fyodor Dostoevsky');
      },
      expect: () => [isA<AuthorsLoaded>(), isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.selectedLetter, 'F');
        expect(state.selectedAuthor, 'Fyodor Dostoevsky');
        expect(state.selectedItems.map((i) => i.id), ['item-4']);
      },
    );

    blocTest<AuthorsStateService, AuthorsState>(
      'selecting the default author again clears the author but keeps the letter',
      build: () => AuthorsStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('F');
        service.selectAuthor('Frank Herbert');
      },
      expect: () => [isA<AuthorsLoaded>(), isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.selectedAuthor, isNull);
        expect(state.selectedLetter, 'F');
      },
    );

    blocTest<AuthorsStateService, AuthorsState>(
      'an initial author pre-selects its letter and itself',
      build: () =>
          AuthorsStateService(readService, initialAuthor: 'Ursula K. Le Guin'),
      expect: () => [isA<AuthorsLoaded>()],
      verify: (service) {
        final state = service.state as AuthorsLoaded;
        expect(state.selectedLetter, 'U');
        expect(state.selectedAuthor, 'Ursula K. Le Guin');
      },
    );
  });
}
