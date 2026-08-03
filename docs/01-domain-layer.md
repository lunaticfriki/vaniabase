# Domain Layer

The domain layer is the core. It has zero dependencies on application,
infrastructure, presentation, or any framework/library beyond a minimal
standard runtime (no `flutter`, no `dio`/`http`, no `bloc`). Everything else
in the system depends on it; it depends on nothing. Because it's plain Dart
with no Flutter dependency, this is exactly the layer the `core` package
shares between `backend` and `frontend` in this monorepo.

## What belongs here

- Entities and aggregates
- Value objects
- Domain services (logic that doesn't naturally belong to a single entity)
- Repository interfaces (ports) — the domain declares what it needs
  persisted/fetched, infrastructure decides how
- Domain events (when relevant)
- Domain errors (typed exceptions representing broken invariants)

## What does NOT belong here

- Framework types (HTTP request/response, DB rows, widget/UI types)
- Serialization/formatting concerns
- Orchestration of multiple aggregates/repositories (that's application layer)
- Anything that changes because a library changed, not because the business
  rules changed

## Folder structure within the domain layer

The domain folder is itself split by concept, not left as a flat file
listing:

```
domain/
  entities/
    order.dart
    order_test.dart        (in the mirrored test/ tree, see 07-testing-strategy.md)
    order_mother.dart
  value_objects/
    order_id.dart
    order_line.dart
    order_status.dart
  repositories/
    order_repository.dart
  errors/
    order_not_found_error.dart
```

- `entities/` — entities and aggregate roots.
- `value_objects/` — value objects.
- `repositories/` — repository ports (abstract classes, see below).
- `errors/` — condition/outcome errors and warnings not tied to one value
  object (see
  [below](#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer)).
  A value object's own validation error stays in the VO's file, not here.
- More categories are added as they're needed (`services/` for domain
  services, `events/` for domain events) — the point is every concept gets
  its own folder instead of accumulating as same-level files.
- Tests and Object Mothers live in the mirrored `test/` tree, never inside
  `lib/` — see [07-testing-strategy.md](07-testing-strategy.md) for why this
  differs from a co-located test folder.

## No primitives in the domain

A raw `String`, `int`, `double`, or `bool` in a domain model is a missed
invariant. If a concept has meaning in the ubiquitous language — an email, a
price, a user id, a date range — it MUST be a value object, not a primitive
passed around and validated in five different places.

Rule of thumb: if you'd validate the same string format/range in more than
one place, it's a value object you haven't extracted yet.

## Private constructors + factory constructors

Entities and value objects MUST NOT expose a public unnamed constructor that
callers can invoke directly with unvalidated data. Construction goes through
static factory constructors so that invariants are enforced at the single
point of creation and invalid states are unrepresentable. Dart's private
named constructor (`ClassName._(...)`) plus public `factory` constructors is
the idiomatic shape for this.

Two factory constructors are standard:

- `create(...)` — validates input, throws a domain error for invalid data,
  returns a valid instance otherwise.
- `empty()` — returns a neutral/default instance used as an initial or
  null-object value (e.g. initial state before data loads, a "no selection"
  placeholder). It is a legitimate domain concept, not a workaround — only add
  it when the domain genuinely has a meaningful empty/unset state.

### Dart: final fields, not private fields with a getter method

A field that is set once at construction and never reassigned MUST be
declared `final` and public, not `private` with a `getXxx()` wrapper method.
The getter-method pattern is boilerplate left over from languages without a
`final`/`readonly` modifier — Dart already gives callers compile-time
immutability on a public `final` field, so a method that does nothing but
`return _x` adds a call site (`order.getId()`) with no benefit over a
property (`order.id`).

This does NOT apply to fields a class mutates internally after construction
to protect an invariant (e.g. an aggregate's `status` changing through a
`confirm()` method). Those must stay `private` (a leading underscore) — a
mutable field can never be public without letting external code bypass the
method that guards the invariant. Expose read access to those with a Dart
`get` accessor (`String get status => _status;`), not a `getStatus()` method,
so the call site still reads as a plain property (`order.status`) regardless
of whether a field is fixed at construction or internally computed/mutated.

```dart
class Email {
  const Email._(this.value);

  factory Email.create(String value) {
    if (!_isValid(value)) {
      throw InvalidEmailError(value);
    }
    return Email._(value);
  }

  factory Email.empty() => const Email._('');

  final String value;

  static bool _isValid(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
```

```dart
class Order {
  Order._(this.id, this.customerId, this._lines, this._status);

  factory Order.create(CustomerId customerId) {
    return Order._(OrderId.generate(), customerId, const [], OrderStatus.draft());
  }

  factory Order.empty() {
    return Order._(OrderId.empty(), CustomerId.empty(), const [], OrderStatus.draft());
  }

  final OrderId id;
  final CustomerId customerId;
  List<OrderLine> _lines;
  OrderStatus _status;

  List<OrderLine> get lines => _lines;

  OrderStatus get status => _status;

  void addLine(OrderLine line) {
    if (_status.isConfirmed) {
      throw CannotModifyConfirmedOrderError(id);
    }
    _lines = [..._lines, line];
  }

  void confirm() {
    _status = _status.confirm();
  }
}
```

`id`/`customerId` are fixed at construction, so they're plain public `final`
fields. `lines`/`status` change through `addLine`/`confirm()`, so the backing
fields are private (`_lines`/`_status`) with a `get` accessor exposing them —
callers still read `order.lines`/`order.status` like a property either way.

## Entities vs value objects

- **Entity**: has identity that persists across state changes (`OrderId`
  stays the same as an order's lines change). Equality is by identity.
- **Value object**: has no identity, defined entirely by its attributes.
  Equality is structural (`operator ==`/`hashCode` overridden accordingly).
  Immutable — mutation methods return a new instance rather than mutating in
  place.
- **Aggregate**: a cluster of entities/value objects with one designated
  aggregate root, which is the only object referenced from outside the
  aggregate and the only one exposing behavior that touches the whole
  cluster's invariants.

## Domain services

When behavior involves more than one aggregate, or doesn't naturally belong
to any single entity, it becomes a domain service — still pure domain logic,
still zero infrastructure dependencies, just not a method on one entity.

```dart
class PricingPolicy {
  Money applyDiscount(Order order, Customer customer) {
    if (customer.isLoyalCustomer && order.total().isAbove(Money.create(100))) {
      return order.total().percentageOff(10);
    }
    return order.total();
  }
}
```

## Repository ports live in the domain

The domain declares the contract for persistence as a port. It knows
nothing about SQL, HTTP, or the filesystem — only the shape of what it
needs.

Ports are declared as `abstract class`, not left as an implicit interface on
a concrete class — see
[the Dart-specific rule below](#dart-abstract-classes-for-ports-and-application-service-contracts)
for why.

```dart
abstract class OrderRepository {
  Future<Order?> findById(OrderId id);
  Future<void> save(Order order);
}
```

Infrastructure extends this class. See
[02-hexagonal-architecture.md](02-hexagonal-architecture.md).

## Dart: abstract classes for ports and application-service contracts

Any Dart type that represents a behavioral contract — a port (repository,
external-service interface) or an application service exposed to
presentation — MUST be declared as `abstract class`, not defined only
implicitly by a single concrete class. Concrete implementations `extends`
(or, when the abstract class has no shared implementation/constructor logic
to inherit, `implements`) it.

Why: Dart already gives every class an implicit interface, so it's tempting
to skip a dedicated abstract type and just depend directly on one concrete
class — but that concrete class is now simultaneously "the contract" and
"the real implementation," with nothing signaling that a fake/in-memory/test
implementation is expected to exist alongside it. A dedicated `abstract
class` makes the contract a first-class, nameable thing: it's what shows up
in a constructor parameter, what `mocktail` mocks in tests, and what a
composition-root binding (see
[08-tech-flutter-dart.md](08-tech-flutter-dart.md)) maps to a concrete
adapter. Reach for `abstract class` specifically when multiple classes could
plausibly satisfy the same contract (a fake repository today, a real one
tomorrow) or when the type needs a stable name that outlives any one
implementation.

This rule does NOT apply to plain data shapes — read models, command/query
payloads, prop bags. Those aren't contracts meant to be implemented or
extended; they're flat records, and a plain immutable `class` (or a Dart
`record` type for something truly transient) remains the right tool.

```dart
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

## Object Mothers

Test data construction goes through Object Mother classes, not inline
literals repeated across test files. An Object Mother knows how to build a
valid, representative instance with sensible defaults, and offers named
variants for specific scenarios.

```dart
class OrderMother {
  static Order random() {
    final order = Order.create(CustomerMother.random().id);
    order.addLine(OrderLineMother.random());
    return order;
  }

  static Order empty() => Order.empty();

  static Order confirmed() {
    final order = OrderMother.random();
    order.confirm();
    return order;
  }
}
```

Rules:

- One Object Mother per aggregate/entity/value object that's meaningfully
  used across tests.
- Methods return fully valid instances by default (`random()`), plus named
  variants for edge cases (`confirmed()`, `withoutLines()`, `expired()`).
- Object Mothers live in the mirrored `test/` tree (e.g.
  `test/modules/ordering/domain/order_mother.dart`) and are never imported by
  production code under `lib/`.
- Prefer composing Object Mothers over duplicating construction logic
  (`OrderMother` uses `CustomerMother`, not a hand-rolled customer).

## Domain errors and warnings live in the domain, not the application layer

Broken invariants throw typed domain errors, not a bare `Exception`. This
keeps error handling in the application layer explicit and testable.

```dart
class InvalidEmailError extends DomainError {
  InvalidEmailError(String value) : super('"$value" is not a valid email');
}
```

Two base types, both in `shared/errors/domain/`:

```dart
// shared/errors/domain/domain_error.dart
abstract class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => message;
}

// shared/errors/domain/domain_warning.dart
abstract class DomainWarning implements Exception {
  const DomainWarning(this.message);
  final String message;

  @override
  String toString() => message;
}
```

`DomainError` is for conditions that stop the current operation (an invalid
value object, a "not found" outcome, an invariant violation). `DomainWarning`
is for conditions worth surfacing to the user but that don't stop anything —
a degraded-but-working state (falling back to cached data, an optional
field left unset). Both carry a `message` and work with `is`;
[`ErrorManager`](10-shared-services.md#error-manager) uses `error is
DomainWarning` to decide whether something is reported as a warning or an
error.

**Errors and warnings belong in the domain layer, not application** — even
when the application layer is what actually detects the condition. A "post
not found" error is thrown from a query handler after a repository call
returns `null`, but the *type* still lives in domain, because "no post
exists at this slug" is a statement about the domain, not an artifact of
how the application layer happens to be wired:

```dart
// domain/errors/post_not_found_error.dart
class PostNotFoundError extends DomainError {
  PostNotFoundError(String slug) : super('Post with slug "$slug" not found');
}
```

```dart
// application/query/get_post_by_slug_query_handler.dart
class GetPostBySlugQueryHandler {
  GetPostBySlugQueryHandler(this._posts);

  final PostRepository _posts;

  Future<PostReadModel> handle(GetPostBySlugQuery query) async {
    final post = await _posts.findBySlug(Slug.create(query.slug));
    if (post == null) {
      throw PostNotFoundError(query.slug);
    }
    return PostReadModel.fromDomain(post);
  }
}
```

Two different kinds of error live in two different places, and both are
domain, not application:

- **Value object validation errors** (`InvalidSlugError`,
  `InvalidEmailError`) stay co-located in the same file as the value object
  that throws them — no separate folder, they're small and 1:1 with their
  VO.
- **Condition/outcome errors** that aren't tied to one value object
  (`PostNotFoundError`, `OrderAlreadyConfirmedError`) get their own
  `domain/errors/` folder, alongside `entities/`, `value_objects/`,
  `repositories/` (see
  [06-vertical-slicing.md](06-vertical-slicing.md#file-naming-convention)).

Not every failure needs to reach the user through
[`ErrorManager`](10-shared-services.md) — an expected, navigable outcome
like "not found" is typically just local state a screen renders directly
(a "Post not found" view), not something that pops a toast. Route through
`ErrorManager` for conditions that represent something actually going
wrong, not for expected branches of normal navigation.
