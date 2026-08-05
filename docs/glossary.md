# Glossary

**Aggregate** — a cluster of entities/value objects treated as one
consistency boundary, accessed only through its aggregate root.

**Anti-Corruption Layer (ACL)** — infrastructure code that translates an
external system's shape (API response, DB row, JSON file) into domain
objects and back, so external concepts never leak into the domain. Lives in
its own `infrastructure/acl/` folder — see
[04-infrastructure-layer.md](04-infrastructure-layer.md).

**Aggregate root** — the single entity through which the rest of an
aggregate is reached and modified.

**Arch test** — an automated test that enforces the dependency rule between
layers/modules (e.g. domain never imports infrastructure), run in CI.

**Command** — a request to change state. Handled by a write service/command
handler. Returns no read model.

**Composition root** — the single place in an app where concrete
infrastructure adapters are instantiated and wired into the application
services that need them.

**DI container / service locator** — a registry mapping types to concrete
implementations, resolved at the composition root. `get_it` is the standard
choice for Dart/Flutter projects here; bindings use explicit
`registerLazySingleton`/`registerFactory` factory functions rather than
annotation-based auto-wiring — see
[08-tech-flutter-dart.md](08-tech-flutter-dart.md#composition-root-get_it).

**Page** — a presentation-layer unit that subscribes to an application-layer
state service via `BlocProvider`/`BlocBuilder`, reads its emitted state, and
dispatches commands/queries by calling the state service's methods,
choosing which view to render based on status. The Flutter/Dart equivalent
of what other stacks call a "container."

**View** — a pure, presentation-only unit that receives constructor
parameters and renders widgets, with no knowledge of application/domain/
infrastructure. The Flutter/Dart equivalent of what other stacks call a
"component."

**Domain error** — a typed exception (`extends DomainError`) representing a
broken invariant or a notable outcome (e.g. "not found") that stops the
current operation. Declared in the domain layer even when an application
handler is what detects it — see
[01-domain-layer.md](01-domain-layer.md#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer).

**Domain warning** — a typed exception (`extends DomainWarning`) for a
notable-but-non-fatal condition (a degraded-but-working state). Same rules
as a domain error otherwise; `ErrorManager` checks `error is DomainWarning`
to show it as a warning rather than an error.

**Error Manager** — the shared service that turns a caught
`DomainError`/`DomainWarning` into a user-facing notification. Stateless
itself; delegates to `NotificationStateService` — see
[10-shared-services.md](10-shared-services.md#error-manager).

**Domain service** — domain logic that spans more than one aggregate or
doesn't naturally belong to a single entity.

**Entity** — a domain object with identity that persists across state
changes; equality is by identity, not attributes.

**Feature file** — a `.feature` file written in Gherkin (Given/When/Then),
describing user-facing behavior for an end-to-end test — see
[11-e2e-testing.md](11-e2e-testing.md).

**Step definition** — the Dart code implementing one Given/When/Then line
from a feature file, matched by `flutter_gherkin` at runtime; small and
reused across scenarios rather than written one-per-scenario.

**Hexagonal architecture (Ports & Adapters)** — an architecture where the
domain/application core defines contracts (ports) for what it needs, and
outer layers (infrastructure, presentation) provide/consume implementations
(adapters), with dependencies pointing inward only.

**Notification Service** — the shared service (living in `core`) that
constructs `Notification` entities; paired with `NotificationStateService`
(living in `frontend`), which holds the reactive list a `NotificationCenter`
widget renders — see
[10-shared-services.md](10-shared-services.md#notification-service).

**Object Mother** — a test-only factory class that builds valid, named
fixture instances of a domain object (`random()`, `empty()`,
`confirmed()`, ...), replacing ad-hoc literals in tests. Lives in the
mirrored `test/` tree, never inside `lib/`.

**Port** — a contract declared by an inner layer (usually domain, sometimes
application) describing a capability it needs, implemented by an outer
layer. Declared as an `abstract class` — see
[01-domain-layer.md](01-domain-layer.md#dart-abstract-classes-for-ports-and-application-service-contracts).

**Query** — a request to read state. Handled by a read service/query
handler. Returns a read model, never mutates.

**Read model** — a DTO shaped for a specific read use, returned by a query
handler; not a domain object and has no behavior. Optional for a read-only
entity (no behavior, no mutable state) — the query can return the domain
entity directly instead; see
[05-presentation-layer.md](05-presentation-layer.md#read-models-are-optional--presentation-may-render-a-domain-entity-directly).

**Read/write service** — the CQRS grouping of an aggregate's query handlers
(`XReadService`) versus its command handlers (`XWriteService`), exposed as
two distinct contracts.

**Skeleton** — a loading-state placeholder widget mirroring the layout of
the view it stands in for.

**State service** — the reactive state holder a page subscribes to.
Implemented by extending flutter_bloc's `Cubit<State>` (or `Bloc`), but
lives in the **application** layer, named `XStateService` rather than
`XCubit` — the one file per feature allowed a Flutter dependency in an
otherwise Flutter-free application layer. Presentation only ever subscribes
to it via `BlocProvider`/`BlocBuilder`; it never defines one itself — see
[03-application-layer-cqrs.md](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state)
and
[05-presentation-layer.md](05-presentation-layer.md#consuming-the-state-service).

**Value object** — a domain object with no identity, defined entirely by its
attributes, immutable, compared structurally.

**Vertical slicing** — organizing folders by feature/bounded context first,
by architectural layer second.
