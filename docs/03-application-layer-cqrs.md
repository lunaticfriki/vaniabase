# Application Layer & CQRS

The application layer orchestrates domain objects to satisfy a request. It
holds no business rules of its own — it fetches via a repository port, calls
domain methods, persists via a repository port. If a piece of logic in an
application service looks like a business decision (a conditional based on
business state, a calculation, a validation of a business invariant), it
belongs in the domain instead.

## Where this layer lives: `backend`, not `core`

Unlike domain, the application layer is **not** shared verbatim in `core`.
It lives in `backend` (and, once `frontend` has its own real orchestration
needs, in `frontend` too) — each consuming package gets its own copy. See
[06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split)
for the full reasoning; in short, a command handler like
`RegisterUserCommandHandler` depends on a real `PasswordHasher` and a
`UserRepository` backed by an actual database, neither of which `frontend`
can ever construct — `frontend` only ever talks to `backend`'s HTTP API, so
sharing the handler that orchestrates that API's own implementation buys it
nothing. `core` stays domain-only: entities, value objects, domain
services, repository ports, errors.

## Commands and queries, not use cases

We do not have a generic "use case" class per action. Instead, application
services are split by CQRS:

- **Write services** (commands): change state. One command, one handler.
  Returns nothing meaningful beyond success/failure (and maybe the new
  identity) — never a read model.
- **Read services** (queries): read state, return a DTO/read model shaped for
  the caller. Never mutate anything.

This split is enforced at the class level: a given application service is
either a command handler or a query handler, never both.

```dart
// application/order/command/confirm_order_command.dart
class ConfirmOrderCommand {
  const ConfirmOrderCommand(this.orderId);
  final String orderId;
}

// application/order/command/confirm_order_command_handler.dart
class ConfirmOrderCommandHandler {
  ConfirmOrderCommandHandler(this._orders);

  final OrderRepository _orders;

  Future<void> handle(ConfirmOrderCommand command) async {
    final id = OrderId.create(command.orderId);
    final order = await _orders.findById(id);
    if (order == null) {
      throw OrderNotFoundError(id);
    }
    order.confirm();
    await _orders.save(order);
  }
}
```

```dart
// application/order/query/get_order_query.dart
class GetOrderQuery {
  const GetOrderQuery(this.orderId);
  final String orderId;
}

// application/order/query/get_order_query_handler.dart
class GetOrderQueryHandler {
  GetOrderQueryHandler(this._orders);

  final OrderRepository _orders;

  Future<OrderReadModel> handle(GetOrderQuery query) async {
    final id = OrderId.create(query.orderId);
    final order = await _orders.findById(id);
    if (order == null) {
      throw OrderNotFoundError(id);
    }
    return OrderReadModel.fromDomain(order);
  }
}
```

`order.confirm()` — the invariant check (can this order be confirmed given
its current status?) — lives on `Order`, not in the handler. The handler's
job is purely: load, delegate, persist.

## Why no use cases, and no data sources

**No use cases.** "Use case" as a generic pattern tends to become a bag where
business logic quietly accumulates because there's no CQRS discipline forcing
read/write separation, and no clear signal about whether a given class
mutates state. Naming things `XCommandHandler` / `XQueryHandler` makes the
read/write split explicit in the type itself, and keeps each handler doing
exactly one thing.

**No data sources.** Some layered-architecture templates insert a "data
source" abstraction between the repository interface and the actual
API/DB/cache call (`Repository → DataSource → API client`). We intentionally
flatten this: the repository implementation in infrastructure talks to the
API/DB/cache directly. The extra indirection rarely earns its keep — it
tends to exist only to satisfy a template, not because two different data
sources are genuinely swapped at runtime. If a repository truly needs to
combine multiple sources (cache + network), that composition lives inside
the repository implementation itself, still behind the one port the domain
declared.

## Read and write services are separated

Beyond command/query handlers per operation, group them so read access and
write access are two distinct dependency surfaces:

```dart
abstract class OrderWriteService {
  Future<void> confirm(ConfirmOrderCommand command);
  Future<void> cancel(CancelOrderCommand command);
}

abstract class OrderReadService {
  Future<OrderReadModel> getById(GetOrderQuery query);
  Future<List<OrderReadModel>> list(ListOrdersQuery query);
}
```

(`abstract class`, not an implicit interface on one concrete class — see
[01-domain-layer.md](01-domain-layer.md#dart-abstract-classes-for-ports-and-application-service-contracts).)

A state service that only ever reads an order's status should only depend
on `OrderReadService`. This makes the blast radius of a widget obvious from
its constructor, and makes mocking in tests trivial (see
[07-testing-strategy.md](07-testing-strategy.md)).

## Read/write services stay pure; the state service holds the reactive state

`OrderReadService`/`OrderWriteService` MUST have **zero Flutter
dependency** — no `flutter/material.dart`, no `bloc`/`cubit` import, nothing
widget-related. They are plain Dart classes wrapping query/command handlers,
returning `Future`s, fully portable to any consumer (a script, a test, the
backend process itself, or a Flutter widget).

Reactive state lives beside them in the **same** layer, application, as a
**state service** — a class named `XStateService` (not `XCubit`; see the
naming convention in
[06-vertical-slicing.md](06-vertical-slicing.md#file-naming-convention)) that
happens to be implemented by extending flutter_bloc's `Cubit<State>`. See
[08-tech-flutter-dart.md](08-tech-flutter-dart.md#application-the-state-service)
for the concrete pattern and
[05-presentation-layer.md](05-presentation-layer.md#consuming-the-state-service)
for how a page subscribes to it. The state service depends on the read
(and/or write) service, holds the current state, and exposes methods that
update it. This is a deliberate difference from a web/signals-based stack:
Dart's `Stream`/`ChangeNotifier`/`Cubit` reactivity primitives are inherently
tied to the widget tree's lifecycle (`BlocProvider`, `context.watch`), so
there is no framework-agnostic "reactive primitive" worth inventing —
`flutter_bloc`'s `Cubit` already is that primitive, so the state service is
just application-layer code built on it, the same way a command handler is
application-layer code built on a repository port.

The state service is a deliberate, narrow exception to application's
zero-Flutter-dependency rule — it's the **only** file per feature allowed to
import `flutter_bloc`. `XReadService`/`XWriteService` next to it stay exactly
as Flutter-free as `backend`'s application layer; only the state service
file bridges application state to the widget tree.

```dart
// application/order/order_read_service.dart — no Flutter dependency
abstract class OrderReadService {
  Future<OrderReadModel> getById(GetOrderQuery query);
}

class OrderReadServiceImpl implements OrderReadService {
  OrderReadServiceImpl(this._handler);

  final GetOrderQueryHandler _handler;

  @override
  Future<OrderReadModel> getById(GetOrderQuery query) {
    return _handler.handle(query);
  }
}
```

`ErrorManager` (see
[10-shared-services.md](10-shared-services.md#error-manager)) is how a
genuine failure gets surfaced app-wide (a snackbar/toast, a log entry) in
addition to the local error state a state service emits for one screen. Only
route through it for conditions that represent something actually going
wrong — an expected, navigable outcome (a 404-style "not found" from a bad
slug/id) is still just local state, not an `ErrorManager` report; see
[the domain errors rule](01-domain-layer.md#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer)
for why "not found" is itself a domain error even though it's not reported
to `ErrorManager`.

Why keep the read/write services free of any reactivity concern at all: it
keeps them trivially reusable and testable with zero setup — anything that
needs `Future<OrderReadModel>` can use `OrderReadService` directly, in a
script, a backend handler, or a unit test, without dragging in Flutter or a
state service it doesn't need. The state service is the one place that
concern is allowed to live, and it's easy to spot in a file listing
precisely because it's the only `*_state_service.dart` file for the feature.

## Read models are optional for simple, read-only entities

A query handler CAN return a read model (DTO) — flattened,
presentation-friendly, no behavior, mapped from the domain object inside
the handler or a dedicated mapper — and this remains the right call for any
entity with behavior or mutable state, to keep the domain model's shape
free to evolve without breaking every screen that reads it and to avoid
handing presentation a live reference it could mutate through.

For an entity that's genuinely read-only (every field public `final`, no
behavior methods), a query handler MAY return the domain entity directly
instead — skip writing a DTO type and a mapper that would just copy every
field across unchanged. See
[05-presentation-layer.md](05-presentation-layer.md#read-models-are-optional--presentation-may-render-a-domain-entity-directly)
for the full trade-off and exactly which conditions tip it back toward a
proper read model.

## What an application service MUST NOT do

- Contain a business rule that isn't already, or shouldn't be, expressed on
  a domain object.
- Import an infrastructure class directly (only the port/interface).
- Import anything from presentation.
- Reach into another aggregate's internals instead of going through its own
  repository/root.
- Import a widget or anything from `flutter/material.dart`. Read/write
  services have **zero Flutter dependency** at all — that includes the state
  service, which may depend on `flutter_bloc` (for `Cubit`) but never on
  `material.dart` or any widget type.
