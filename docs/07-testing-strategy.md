# Testing Strategy

Testing mirrors the layers: the domain is tested with no mocks at all, the
application layer is tested by mocking ports — including the state service,
tested by mocking the read/write services it depends on and asserting its
state transitions — infrastructure is tested with real or containerized
dependencies, and presentation (pages/views) is tested with plain widget
tests, no mocking needed since a view takes only constructor parameters.
Architecture rules are enforced by dedicated arch tests, not just
convention.

## Domain tests — no mocks

The domain has no outward dependencies, so its tests need none either. Build
fixtures with Object Mothers (see
[01-domain-layer.md](01-domain-layer.md)), exercise behavior, assert on
resulting state or thrown domain errors.

```dart
void main() {
  group('Order', () {
    test('cannot be modified once confirmed', () {
      final order = OrderMother.confirmed();

      expect(
        () => order.addLine(OrderLineMother.random()),
        throwsA(isA<CannotModifyConfirmedOrderError>()),
      );
    });
  });
}
```

If a domain test needs a mock, that's a signal the class has an outward
dependency it shouldn't — move that dependency to application/infrastructure
instead.

## Application tests — mock the ports

Application services depend only on ports (repository contracts, external
service contracts). Tests mock those ports with **mocktail** and assert
both the resulting domain state and the interactions with the port.

```dart
class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('ConfirmOrderCommandHandler', () {
    test('confirms an existing order and persists it', () async {
      final repository = MockOrderRepository();
      final order = OrderMother.random();
      when(() => repository.findById(order.id)).thenAnswer((_) async => order);
      when(() => repository.save(order)).thenAnswer((_) async {});

      final handler = ConfirmOrderCommandHandler(repository);
      await handler.handle(ConfirmOrderCommand(order.id.toString()));

      expect(order.status.isConfirmed, isTrue);
      verify(() => repository.save(order)).called(1);
    });

    test('throws when the order does not exist', () async {
      final repository = MockOrderRepository();
      when(() => repository.findById(any())).thenAnswer((_) async => null);

      final handler = ConfirmOrderCommandHandler(repository);

      expect(
        () => handler.handle(ConfirmOrderCommand('missing')),
        throwsA(isA<OrderNotFoundError>()),
      );
    });
  });
}
```

Never mock a domain object itself (`Order`, `Money`) — domain objects are
real, cheap to construct via Object Mothers, and mocking them would hide the
very invariants the test should verify. Only ports get mocked.

## Infrastructure tests

Repository implementations and mappers are tested against something as
close to the real dependency as practical (a test container, an in-memory
DB, a recorded HTTP fixture). These tests are fewer and slower by nature —
they exist to verify the adapter honors the port contract and the mapping is
correct in both directions, not to re-verify business rules already covered
by domain tests.

## State service tests (`frontend`'s `application/`)

The state service lives in application (see
[03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state)),
so its test sits in `test/modules/<feature>/application/`, right alongside
the read/write-service tests, not under `presentation/`. It's tested with
**bloc_test**, mocking the read/write services it depends on and asserting
the exact state sequence emitted (loading → loaded, or loading → error) —
mechanically the same shape as mocking a port for a command handler test,
just asserting a state sequence instead of a return value/repository call.

```dart
void main() {
  group('OrderDetailsStateService', () {
    final order = OrderMother.random();

    blocTest<OrderDetailsStateService, OrderDetailsState>(
      'emits loading then loaded',
      build: () {
        final readService = MockOrderReadService();
        when(() => readService.getById(any()))
            .thenAnswer((_) async => OrderReadModel.fromDomain(order));
        return OrderDetailsStateService(readService, MockOrderWriteService(), order.id.toString());
      },
      expect: () => [isA<OrderDetailsLoading>(), isA<OrderDetailsLoaded>()],
    );
  });
}
```

## Presentation tests

A View takes only constructor parameters, so it's tested in isolation with
`flutter_test`'s widget testing — no mocking needed since it has no
dependencies at all, not even the state service. Pump it with a handful of
representative prop combinations (loaded with data, empty state, error
message set) and assert on rendered widgets/text, plus that tapping a
control invokes the right callback. A Page is thin enough (wire
`BlocProvider`/`BlocBuilder`, pick a branch) that it's usually left to the
state service test plus a View test to cover, rather than tested separately.

## End-to-end tests — the whole system, for real

Everything above tests one layer in isolation. None of it proves navigation,
rendering, and a real build actually work together. That's a separate suite,
run against a real Flutter build rather than mocks — see
[11-e2e-testing.md](11-e2e-testing.md) for the full `flutter_gherkin` setup.
It's slower by nature and deliberately kept out of the fast `pre-push` suite
(see [09-git-workflow.md](09-git-workflow.md)) — run on demand and in CI, not
on every push.

## Arch tests — enforce the dependency rule in CI

Layer violations MUST fail the build, not rely on reviewers catching them.
Dart's tooling for import-boundary enforcement is less standardized than the
JS ecosystem's, so this is a small custom script rather than an off-the-shelf
package: walk each layer folder, parse its files' `import` directives, and
fail if any import crosses a forbidden edge.

```dart
// tool/arch_test.dart
const forbiddenEdges = {
  'domain': ['application', 'infrastructure', 'presentation'],
  'application': ['infrastructure', 'presentation'],
  'infrastructure': ['presentation'],
  'presentation': ['infrastructure'],
};

void main() {
  final violations = <String>[];

  for (final entry in forbiddenEdges.entries) {
    for (final file in dartFilesUnder('lib/modules/*/${entry.key}')) {
      for (final import in importsOf(file)) {
        if (entry.value.any((layer) => import.contains('/$layer/'))) {
          violations.add('$file imports $import (${entry.key} → forbidden)');
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln(violations.join('\n'));
    exit(1);
  }
}
```

Run it as its own CI/test step (`dart run tool/arch_test.dart`), alongside
`flutter analyze`, and treat any violation as a build failure, exactly like
a failing unit test.

## Tests live in a mirrored top-level `test/` tree

Test files sit in a top-level `test/` directory whose structure mirrors
`lib/` folder-for-folder, never inline as siblings inside `lib/` and never a
single flat test folder that loses the module/layer structure:

```
lib/
  modules/
    ordering/
      domain/
        entities/
          order.dart
      application/
        query/
          get_order_query_handler.dart
      infrastructure/
        http_order_repository.dart

test/
  modules/
    ordering/
      domain/
        entities/
          order_test.dart
          order_mother.dart
      application/
        query/
          get_order_query_handler_test.dart
      infrastructure/
        http_order_repository_test.dart
```

This is the one place these docs deliberately part ways with a co-located
`__tests__/`-next-to-source convention: anything placed under `lib/` is part
of what `flutter build`/`dart compile` ships, so test code and Object Mothers
genuinely cannot live there without shipping inside the app or backend
binary. `flutter test` / `dart test` already default to discovering
`*_test.dart` files under the top-level `test/` directory, so mirroring
`lib/`'s structure there needs no extra config — just discipline about
keeping the two trees in lockstep.

## Object Mothers, once more

Object Mothers are shared across domain, application, and presentation
tests. They live in `test/` alongside the entity/value object they build
(e.g. `test/modules/ordering/domain/entities/order_mother.dart`), are
imported only from tests, and are the only sanctioned way to construct a
domain fixture. It's normal for an application or presentation test to
import a domain module's Object Mother across the `lib/`/`test/` boundary —
this rule is about test code, not the production import-boundary rule from
[02-hexagonal-architecture.md](02-hexagonal-architecture.md). Ad-hoc
literals (`Order.create(...)` repeated with slightly different inline
values everywhere) scattered across test files are what Object Mothers
replace — if you find yourself typing one, extract or extend the Mother
instead.
