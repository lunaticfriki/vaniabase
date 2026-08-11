import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/languages_state_service.dart';
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
        ItemReadModelMother.random(id: 'item-1', language: 'English'),
        ItemReadModelMother.random(id: 'item-2', language: 'English'),
        ItemReadModelMother.random(id: 'item-3', language: 'Spanish'),
        ItemReadModelMother.random(id: 'item-4', language: ''),
        ItemReadModelMother.random(id: 'item-5', language: 'Esperanto'),
      ]),
    );
  });

  group('LanguagesStateService', () {
    blocTest<LanguagesStateService, LanguagesState>(
      'loads distinct, sorted languages across every item, ignoring empty ones',
      build: () => LanguagesStateService(readService),
      expect: () => [isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.languages, ['English', 'Esperanto', 'Spanish']);
        expect(state.selectedLetter, isNull);
        expect(state.selectedLanguage, isNull);
      },
    );

    blocTest<LanguagesStateService, LanguagesState>(
      'selectLetter auto-selects the first language for that letter',
      build: () => LanguagesStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('E');
      },
      expect: () => [isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.selectedLetter, 'E');
        expect(state.selectedLanguage, 'English');
        expect(state.selectedItems.map((i) => i.id), ['item-1', 'item-2']);
      },
    );

    blocTest<LanguagesStateService, LanguagesState>(
      'selecting the same letter again clears the selection',
      build: () => LanguagesStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('E');
        service.selectLetter('E');
      },
      expect: () => [isA<LanguagesLoaded>(), isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.selectedLetter, isNull);
        expect(state.selectedLanguage, isNull);
      },
    );

    blocTest<LanguagesStateService, LanguagesState>(
      'selectLanguage overrides the default language within the same letter',
      build: () => LanguagesStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('E');
        service.selectLanguage('Esperanto');
      },
      expect: () => [isA<LanguagesLoaded>(), isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.selectedLetter, 'E');
        expect(state.selectedLanguage, 'Esperanto');
        expect(state.selectedItems.map((i) => i.id), ['item-5']);
      },
    );

    blocTest<LanguagesStateService, LanguagesState>(
      'selecting the default language again clears the language but keeps the letter',
      build: () => LanguagesStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.selectLetter('E');
        service.selectLanguage('English');
      },
      expect: () => [isA<LanguagesLoaded>(), isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.selectedLanguage, isNull);
        expect(state.selectedLetter, 'E');
      },
    );

    blocTest<LanguagesStateService, LanguagesState>(
      'an initial language pre-selects its letter and itself',
      build: () =>
          LanguagesStateService(readService, initialLanguage: 'Spanish'),
      expect: () => [isA<LanguagesLoaded>()],
      verify: (service) {
        final state = service.state as LanguagesLoaded;
        expect(state.selectedLetter, 'S');
        expect(state.selectedLanguage, 'Spanish');
      },
    );
  });
}
