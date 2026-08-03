# Infrastructure Layer

Infrastructure implements the ports declared by the domain (and
occasionally the application layer). It is the only layer allowed to know
about HTTP clients, SQL, the filesystem, third-party SDKs, or platform
channels.

## What belongs here

- Repository implementations (`HttpOrderRepository`,
  `SqliteOrderRepository`, `InMemoryOrderRepository` for tests)
- The Anti-Corruption Layer (ACL) — mappers/translators between domain
  objects and external wire/persistence shapes (see below)
- Wrappers around third-party SDKs/packages, so the rest of the app depends
  on our own port, not the package's API surface
- Configuration for the above (base URLs, connection strings) — read from
  environment/config, never hardcoded

## Folder structure

```
infrastructure/
  http_order_repository.dart
  acl/
    order_mapper.dart
```

(Tests for these live in the mirrored `test/infrastructure/` tree — see
[07-testing-strategy.md](07-testing-strategy.md).)

## The Anti-Corruption Layer (ACL)

An Anti-Corruption Layer is the translation code that converts an external
system's model — a raw API response, a database row, a JSON file — into
domain objects, and back. It's what keeps an external system's vocabulary
and shape from leaking past infrastructure and contaminating the domain
model. It lives in its own `acl/` folder within infrastructure, separate
from the repository implementation that uses it — the repository
orchestrates fetching/persisting; the ACL mapper owns the translation.

Domain objects are constructed through their `create`/`empty` factory
constructors from the ACL mapper — it never bypasses domain construction
rules to build an entity "cheaply."

```dart
// infrastructure/acl/order_mapper.dart
class OrderMapper {
  static Order toDomain(Map<String, dynamic> json) {
    final order = Order.create(CustomerId.create(json['customerId'] as String));
    for (final line in json['lines'] as List<dynamic>) {
      order.addLine(OrderLineMapper.toDomain(line as Map<String, dynamic>));
    }
    if (json['status'] == 'confirmed') {
      order.confirm();
    }
    return order;
  }

  static Map<String, dynamic> toPersistence(Order order) {
    return {
      'customerId': order.customerId.toString(),
      'lines': order.lines.map(OrderLineMapper.toPersistence).toList(),
      'status': order.status.toString(),
    };
  }
}
```

If a repository combines multiple external sources (a cache plus a network
call), that composition still lives in the repository — the ACL mapper only
ever translates one external shape to/from one domain shape, so it stays
reusable and easy to test in isolation.

## One implementation per port, swappable

Because application/domain depend on the port, infrastructure can offer
multiple implementations behind the same port — a real HTTP-backed
repository for production, an in-memory one for tests, a local-storage-backed
one for offline mode — without either inner layer changing. The port is an
`abstract class` (see
[01-domain-layer.md](01-domain-layer.md#dart-abstract-classes-for-ports-and-application-service-contracts)),
so implementations `implements` (or `extends`) it.

```dart
class InMemoryOrderRepository implements OrderRepository {
  final Map<String, Order> _orders = {};

  @override
  Future<Order?> findById(OrderId id) async => _orders[id.toString()];

  @override
  Future<void> save(Order order) async {
    _orders[order.id.toString()] = order;
  }
}
```

## What infrastructure MUST NOT do

- Contain business rules (a discount calculation, a status transition
  check) — that belongs in domain.
- Be imported directly by presentation. Presentation depends on application;
  application depends on the port; infrastructure is wired in at the
  composition root (`get_it` registration, app bootstrap).
- Construct domain entities by reaching past their factories (no
  `Order._(...)` from outside the domain, no setting private fields via
  reflection).

## Composition root

Somewhere in the app (bootstrap file, `get_it` registration module) the
concrete infrastructure adapters are instantiated and handed to the
application services that need them. This is the one place allowed to
import both infrastructure and application/domain together. See
[08-tech-flutter-dart.md](08-tech-flutter-dart.md#composition-root-get_it)
for the full `get_it` wiring pattern; sketched here:

```dart
final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<OrderRepository>(
    () => HttpOrderRepository(getIt<HttpClient>()),
  );

  getIt.registerFactory<OrderReadService>(
    () => OrderReadServiceImpl(GetOrderQueryHandler(getIt<OrderRepository>())),
  );

  getIt.registerFactory<OrderWriteService>(
    () => OrderWriteServiceImpl(ConfirmOrderCommandHandler(getIt<OrderRepository>())),
  );
}
```
