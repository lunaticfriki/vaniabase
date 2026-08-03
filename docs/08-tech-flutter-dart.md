# Flutter + Dart Specifics

The rest of these docs already use Dart throughout — this file covers the
handful of concerns that are specific to how the pieces get wired together
at runtime in this monorepo: the `core`/`backend`/`frontend` package split,
the composition root, and the Flutter-only presentation details (Cubit/Bloc,
widgets).

## The three packages

- **`core`** — domain layer only. Pure Dart, zero Flutter dependency, zero
  server-framework dependency. Consumed as a path dependency by both
  `backend` and `frontend`.
- **`backend`** — a Dart server. Owns its own `application` layer
  (command/query handlers orchestrating real infrastructure), the
  infrastructure adapters and composition root for the server process
  (DB/HTTP repositories, etc.), plus its own presentation layer in the
  loose sense of "how a request becomes a response" (HTTP handlers),
  depending on `core`.
- **`frontend`** — a Flutter app. Owns its own `application` layer (usually
  thin read/write services wrapping HTTP calls to `backend`), its own
  infrastructure adapters (an HTTP client talking to `backend`, local
  storage, platform channels) and its own composition root, plus the
  actual Flutter presentation layer (pages, views, Cubits), depending on
  `core`.

`backend` implements the repository ports `core`'s domain declares
(`PostgresItemRepository`, etc.) and its `application` layer's command/query
handlers depend on them directly — the classic hexagonal shape, all within
one package. `frontend` does **not** implement those same repository
ports: it has no database to back them, so it wouldn't gain anything from
running the same command handlers locally. Instead `frontend`'s
`application` layer talks to `backend`'s HTTP API directly, while still
importing `core`'s domain value objects for local input validation (e.g.
`Title.create(input)` to show an inline form error before ever hitting the
network). See
[06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split)
for the full reasoning.

## Folder tree (one vertical slice, `frontend`)

```
lib/
  modules/
    ordering/
      application/
        order_read_service.dart
        order_write_service.dart
      infrastructure/
        http_order_repository.dart
        acl/
          order_mapper.dart
      presentation/
        order_details_page.dart
        order_details_view.dart
        order_details_skeleton.dart
        order_details_cubit.dart
        order_details_state.dart
  shared/
    di/
      injection.dart
  composition_root.dart

test/
  modules/
    ordering/
      infrastructure/
        http_order_repository_test.dart
      presentation/
        order_details_cubit_test.dart
```

`ordering`'s `domain/` folder physically lives in `core` (see
[06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split))
— `frontend` and `backend` each add their own
`application/`/`infrastructure/`/`presentation/` (or HTTP-handler
equivalent) for that same module, importing the shared domain types from
`core`.

## No use cases, no data sources

`backend`'s application services are `XCommandHandler` / `XQueryHandler`
pairs, grouped behind `OrderWriteService`/`OrderReadService` abstract
classes. Repositories talk directly to the network/DB adapter — no
intermediate `OrderDataSource` class. See
[03-application-layer-cqrs.md](03-application-layer-cqrs.md) for the full
reasoning. `frontend`'s equivalent read/write services are typically
thinner — a network call, not a command/query handler pair — since the
orchestration already happened in `backend`.

## Presentation: Cubit as the state service

The Cubit sits in the presentation layer, inside `frontend`. It depends on
`OrderReadService`/`OrderWriteService` (`frontend`'s own `application`
layer), emits states that the widget tree consumes, and contains zero
business logic — only orchestration of loading/error/loaded states.

```dart
sealed class OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  OrderDetailsLoaded(this.order);
  final OrderReadModel order;
}

class OrderDetailsError extends OrderDetailsState {
  OrderDetailsError(this.message);
  final String message;
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._readService, this._writeService, this._orderId)
      : super(OrderDetailsLoading()) {
    _load();
  }

  final OrderReadService _readService;
  final OrderWriteService _writeService;
  final String _orderId;

  Future<void> _load() async {
    try {
      final order = await _readService.getById(GetOrderQuery(_orderId));
      emit(OrderDetailsLoaded(order));
    } catch (error) {
      emit(OrderDetailsError(error.toString()));
    }
  }

  Future<void> confirm() async {
    await _writeService.confirm(ConfirmOrderCommand(_orderId));
    await _load();
  }
}
```

Cubit is the default because most screens just need "call a method, react
to the result." Reach for Bloc instead only when a screen genuinely needs to
react to a stream of discrete events (e.g. debounced search-as-you-type,
combining multiple input streams) rather than direct method invocation —
the layering and CQRS rules are identical either way.

## Widgets: page (container) vs view (component)

`OrderDetailsPage` is the container — it owns the
`BlocProvider`/`BlocBuilder` and picks the loading/error/loaded branch.
`OrderDetailsView` is the pure component — plain constructor parameters, no
Cubit/Bloc awareness. See
[05-presentation-layer.md](05-presentation-layer.md#page-vs-view) for the
full pattern.

```dart
class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailsCubit(
        context.read<OrderReadService>(),
        context.read<OrderWriteService>(),
        orderId,
      ),
      child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) => switch (state) {
          OrderDetailsLoading() => const OrderDetailsSkeleton(),
          OrderDetailsError(:final message) => OrderDetailsErrorView(message: message),
          OrderDetailsLoaded(:final order) => OrderDetailsView(
              order: order,
              onConfirm: () => context.read<OrderDetailsCubit>().confirm(),
            ),
        },
      ),
    );
  }
}
```

## Composition root: get_it

`get_it` is the standard service locator for both `backend` and `frontend`
in this stack — a plain registry, no code generation, no annotations to
process. One `GetIt` instance is configured at each package's composition
root; every port (repository contract, application service contract — both
`abstract class`, see
[01-domain-layer.md](01-domain-layer.md#dart-abstract-classes-for-ports-and-application-service-contracts))
is bound to its concrete implementation there, and presentation code
resolves what it needs from `getIt<T>()` instead of constructing or
importing concretes directly.

```dart
// composition_root.dart (frontend)
final getIt = GetIt.instance;

void configureDependencies({required String apiBaseUrl}) {
  getIt.registerLazySingleton<HttpClient>(() => HttpClient(baseUrl: apiBaseUrl));

  getIt.registerFactory<OrderReadService>(
    () => HttpOrderReadService(getIt<HttpClient>()),
  );

  getIt.registerFactory<OrderWriteService>(
    () => HttpOrderWriteService(getIt<HttpClient>()),
  );

  // ErrorManager, NotificationService — see 10-shared-services.md for that wiring.
}
```

`HttpOrderReadService`/`HttpOrderWriteService` implement `frontend`'s own
`OrderReadService`/`OrderWriteService` abstract classes directly against
`HttpClient` — there's no `OrderRepository`/command-handler indirection
here the way there is in `backend`, because there's no local domain
orchestration to do; the request just needs to reach the API. Compare with
`backend`'s composition root (see
[04-infrastructure-layer.md](04-infrastructure-layer.md#composition-root)),
which does wire a real repository behind its command/query handlers.

`registerLazySingleton` for adapters that should be built once and reused
(an HTTP client, a repository); `registerFactory` for application services
that are cheap to construct and hold no state worth sharing across call
sites. Widgets pull dependencies via `context.read<T>()` (through a
`RepositoryProvider`/`BlocProvider` bridging `get_it` into the widget tree)
or directly via `getIt<T>()` — pick one style per project and stay
consistent; `context.read<T>()` is preferred inside the widget tree because
it plays well with widget tests overriding a provider.

### Why an explicit factory function per binding, not annotation-based auto-wiring

Packages like `injectable` generate the `get_it` registration code from
`@injectable`/`@LazySingleton` annotations via `build_runner`. That's a
legitimate option, but it adds a code-generation step (and its build-time
cost) to every package in the monorepo for a problem an explicit factory
function already solves in a few lines, with no generated file to keep in
sync. Prefer plain `registerLazySingleton(() => ...)`/`registerFactory(()
=> ...)` calls unless a project's binding count grows large enough that the
boilerplate genuinely outweighs the build step.

## Tooling

- Test runner: `flutter_test` (frontend) / `test` (core, backend).
- Mocking ports: `mocktail` — avoid `mockito`'s code-generation step unless
  the project already relies on `build_runner` elsewhere.
- Cubit/Bloc testing: `bloc_test`, asserting the exact state sequence
  emitted.
- Dependency injection: `get_it` (see above).
- Arch tests: a small custom script (`tool/arch_test.dart`) enforcing the
  forbidden-edges rule set from
  [07-testing-strategy.md](07-testing-strategy.md#arch-tests--enforce-the-dependency-rule-in-ci),
  run via `flutter analyze` + `dart run tool/arch_test.dart` as its own CI
  step.
- No comments in source — types and names carry meaning; dartdoc (`///`) is
  only used where a published package's public API needs it.
