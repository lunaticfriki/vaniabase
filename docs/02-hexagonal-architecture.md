# Hexagonal Architecture (Ports & Adapters)

Four layers, one dependency rule: **dependencies point inward, always.**
Nothing inward-facing knows that anything outward-facing exists.

```
presentation  ──depends on──▶  application  ──depends on──▶  domain
                                     ▲
infrastructure ──implements ports declared in── domain / application
```

## The four layers

### Domain (the core)
Zero outward dependencies. See [01-domain-layer.md](01-domain-layer.md).
Declares ports (repository contracts, external-service contracts) as
abstract classes — it defines *what* it needs, never *how* it's provided.
This is the **only** layer that lives in the `core` package, shared
verbatim between `backend` and `frontend` — see
[06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split)
for why application does not live here too.

### Application
Orchestrates domain objects to fulfill a command or answer a query. Depends
only on domain. Talks to the outside world exclusively through ports (the
contracts domain declared) — never imports a concrete infrastructure class
directly. Lives in whichever package actually has a real implementation to
orchestrate against (`backend` today) — not in `core`. See
[03-application-layer-cqrs.md](03-application-layer-cqrs.md).

### Infrastructure
Adapters. Implements the ports declared by domain/application: repository
implementations, HTTP clients, storage, third-party SDK wrappers, platform
channels. Also owns the **Anti-Corruption Layer (ACL)** — the translation
code that converts an external system's shape (a raw API response, a
database row, a JSON file) into domain objects, so external concepts never
leak past infrastructure. Depends on domain (to extend its ports) and may
depend on application only for wiring/DI registration — never the other way
around. See [04-infrastructure-layer.md](04-infrastructure-layer.md).

### Presentation
UI and its glue code: pages, views, Cubits/Blocs. Depends on application
(dispatches commands, runs queries) — MUST NOT import infrastructure
directly. If presentation needs a concrete adapter, it's wired through
dependency injection at the composition root, not imported inline. See
[05-presentation-layer.md](05-presentation-layer.md).

## Ports and adapters, concretely

A **port** is a contract owned by the inner layer that needs the capability
(usually domain, sometimes application for things like a notification
sender). An **adapter** is the concrete implementation, owned by
infrastructure, injected wherever the port is required. Ports are `abstract
class` — see
[01-domain-layer.md](01-domain-layer.md#dart-abstract-classes-for-ports-and-application-service-contracts)
for why.

```dart
// domain/repositories/order_repository.dart — port
abstract class OrderRepository {
  Future<Order?> findById(OrderId id);
  Future<void> save(Order order);
}

// infrastructure/http_order_repository.dart — adapter
class HttpOrderRepository implements OrderRepository {
  HttpOrderRepository(this._httpClient);

  final HttpClient _httpClient;

  @override
  Future<Order?> findById(OrderId id) async {
    final response = await _httpClient.get('/orders/${id.toString()}');
    return response == null ? null : OrderMapper.toDomain(response);
  }

  @override
  Future<void> save(Order order) async {
    await _httpClient.put('/orders/${order.id.toString()}', OrderMapper.toPersistence(order));
  }
}
```

Presentation never sees `HttpOrderRepository`. It only ever depends on
`OrderRepository` through an application service, wired at the composition
root (app bootstrap / `get_it` registration).

## Why this shape

- The domain is testable with zero mocks (see
  [07-testing-strategy.md](07-testing-strategy.md)) — pure functions and
  objects, no I/O.
- Swapping infrastructure (REST to GraphQL, SQL to a document store, a
  third-party SDK migration) never touches domain or application code.
- Swapping the presentation shell (a new Flutter platform target, a
  different widget-tree structure for the same screen) never touches
  domain, application, or infrastructure.
- Because domain has zero Flutter/backend-framework dependencies, `core`
  can be a plain Dart package imported unchanged by both `backend` (server
  Dart) and `frontend` (Flutter) — the same entities, value objects, and
  ports on both sides of the wire.

## Enforcing the rule

Documentation and code review are not enough on their own — layer
violations creep in under deadline pressure. Import-boundary rules MUST be
enforced by arch tests running in CI. See
[07-testing-strategy.md](07-testing-strategy.md) for the concrete setup.

The rule set, precisely:

- `domain` imports nothing from `application`, `infrastructure`, or
  `presentation`.
- `application` imports only from `domain`.
- `infrastructure` imports only from `domain` (to implement its interfaces);
  it MAY depend on `application`'s port definitions if a port is declared
  there instead of domain, but never on `presentation`.
- `presentation` imports only from `application` (commands, queries, their
  results/DTOs) — never `infrastructure` directly.
- Wiring (constructing concrete adapters and injecting them into application
  services) happens at a single composition root, not scattered through the
  codebase.
