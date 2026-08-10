import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockItemWriteService extends Mock implements ItemWriteService {}

Uint8List _csvBytes(String csv) => Uint8List.fromList(utf8.encode(csv));

const _validCsv =
    'title,creator,publisher,category,format\n'
    'Dune,Frank Herbert,Chilton Books,book,hardcover\n'
    'Foundation,Isaac Asimov,Gnome Press,book,hardcover\n';

void main() {
  late MockItemWriteService writeService;

  setUp(() {
    writeService = MockItemWriteService();
  });

  group('BulkImportStateService', () {
    blocTest<BulkImportStateService, BulkImportState>(
      'handlePickedFile parses the file and shows a preview',
      build: () => BulkImportStateService(writeService),
      act: (service) => service.handlePickedFile(_csvBytes(_validCsv), 'items.csv'),
      expect: () => [isA<BulkImportParsing>(), isA<BulkImportPreview>()],
      verify: (service) {
        final state = service.state as BulkImportPreview;
        expect(state.fileName, 'items.csv');
        expect(state.validCount, 2);
        expect(state.invalidCount, 0);
      },
    );

    blocTest<BulkImportStateService, BulkImportState>(
      'handlePickedFile surfaces a parse error for an unsupported file',
      build: () => BulkImportStateService(writeService),
      act: (service) => service.handlePickedFile(_csvBytes('title\nDune\n'), 'items.txt'),
      expect: () => [isA<BulkImportParsing>(), isA<BulkImportError>()],
    );

    blocTest<BulkImportStateService, BulkImportState>(
      'startImport creates every valid row and reports the result',
      setUp: () {
        when(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'hardcover',
          ),
        ).thenAnswer((_) async => 'item-1');
        when(
          () => writeService.create(
            title: 'Foundation',
            creator: ['Isaac Asimov'],
            publisher: 'Gnome Press',
            category: 'book',
            format: 'hardcover',
          ),
        ).thenAnswer((_) async => 'item-2');
      },
      build: () => BulkImportStateService(writeService),
      act: (service) async {
        service.handlePickedFile(_csvBytes(_validCsv), 'items.csv');
        await Future<void>.delayed(Duration.zero);
        await service.startImport();
      },
      verify: (service) {
        final state = service.state as BulkImportDone;
        expect(state.succeeded, 2);
        expect(state.failures, isEmpty);
        verify(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'hardcover',
          ),
        ).called(1);
      },
    );

    blocTest<BulkImportStateService, BulkImportState>(
      'startImport records a failure without aborting the remaining rows',
      setUp: () {
        when(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'hardcover',
          ),
        ).thenThrow(Exception('backend unavailable'));
        when(
          () => writeService.create(
            title: 'Foundation',
            creator: ['Isaac Asimov'],
            publisher: 'Gnome Press',
            category: 'book',
            format: 'hardcover',
          ),
        ).thenAnswer((_) async => 'item-2');
      },
      build: () => BulkImportStateService(writeService),
      act: (service) async {
        service.handlePickedFile(_csvBytes(_validCsv), 'items.csv');
        await Future<void>.delayed(Duration.zero);
        await service.startImport();
      },
      verify: (service) {
        final state = service.state as BulkImportDone;
        expect(state.succeeded, 1);
        expect(state.failures, hasLength(1));
        expect(state.failures.single.title, 'Dune');
      },
    );

    blocTest<BulkImportStateService, BulkImportState>(
      'reset returns to idle',
      build: () => BulkImportStateService(writeService),
      act: (service) async {
        service.handlePickedFile(_csvBytes(_validCsv), 'items.csv');
        await Future<void>.delayed(Duration.zero);
        service.reset();
      },
      expect: () => [isA<BulkImportParsing>(), isA<BulkImportPreview>(), isA<BulkImportIdle>()],
    );
  });
}
