# Vertical Slicing

Folders are organized by feature/bounded context first, by layer second. A
developer working on "orders" should be able to find everything relevant to
orders in one place, rather than jumping between a global `domain/`,
`services/`, and `widgets/` tree hunting for order-related files.

## The `core`/`backend`/`frontend` split

Vertical slicing organizes folders by feature *within* a package, but a
module's four hexagonal layers don't all live in the same package. `core`
holds only `domain` — entities, value objects, repository ports, domain
services, errors. `application`, `infrastructure`, and `presentation` each
live in whichever package actually has a real implementation to provide:
`backend` has its own `application` (orchestrating a real Postgres
repository, a real password hasher) plus `infrastructure`/`presentation`;
`frontend` has its own `application`/`infrastructure`/`presentation`
talking to `backend` over HTTP.

This is a deliberate departure from the more common "share
domain+application, swap only infrastructure" hexagonal setup. It doesn't
fit here because `backend`'s application layer routinely depends on
infrastructure that has no meaningful equivalent on `frontend` — a command
handler that hashes a password or checks a database for a uniqueness
constraint can't be constructed on `frontend` at all, since `frontend`
never talks to the database or a real hasher directly; it only ever calls
`backend`'s HTTP API. Sharing that handler in `core` wouldn't let
`frontend` reuse it — `frontend`'s equivalent orchestration is just "call
this endpoint," which is a different, thinner thing worth writing directly
in `frontend` rather than forcing through a shared abstraction built for
`backend`'s shape. `domain` doesn't have this problem — an `Item` or a
`Title` value object means the same thing and enforces the same invariants
regardless of which package is holding it, which is exactly why it *is*
shared.

A narrow exception: a service with real behavior but **no infrastructure
dependency at all** (nothing that differs between `backend` and
`frontend`) — see [10-shared-services.md](10-shared-services.md)'s
`NotificationService` — can still live in `core`, because there's nothing
package-specific to force a split. The deciding question for any given
service: does it depend on something that's fundamentally different
between `backend` and `frontend` (a real DB vs. an HTTP client, a real
password hasher vs. nothing)? If yes, it belongs in the package that owns
that dependency. If it's genuinely infrastructure-free construction logic,
`core` is fine.

## Shape

```
core/
  lib/
    modules/
      ordering/
        domain/
          entities/
            order.dart
          value_objects/
            order_id.dart
            order_line.dart
            order_status.dart
          repositories/
            order_repository.dart
          errors/
            order_already_confirmed_error.dart
      catalog/
        domain/
    shared/
      errors/
        domain_error.dart
        domain_warning.dart
  test/
    modules/
      ordering/
        domain/
          entities/
            order_test.dart
            order_mother.dart

backend/
  lib/
    modules/
      ordering/
        application/
          command/
            confirm_order_command.dart
            confirm_order_command_handler.dart
          query/
            get_order_query.dart
            get_order_query_handler.dart
          order_read_model.dart
          order_read_service.dart
          order_write_service.dart
        infrastructure/
          postgres_order_repository.dart
          acl/
            order_mapper.dart
        presentation/
          order_router.dart
    composition_root.dart
  test/
    modules/
      ordering/
        application/
          command/
            confirm_order_command_handler_test.dart
        infrastructure/
          postgres_order_repository_test.dart

frontend/
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
    composition_root.dart
  test/
    modules/
      ordering/
        presentation/
          order_details_cubit_test.dart
```

`Order` would keep an `order_read_model.dart` (in whichever package's
`application` maps it) specifically because it has behavior and mutable
state (see
[05-presentation-layer.md](05-presentation-layer.md#read-models-are-optional--presentation-may-render-a-domain-entity-directly))
— a simpler, read-only entity would skip that file and have its read
service/Cubit work with the domain entity directly. `frontend`'s
`application` here is thinner than `backend`'s — often just a read/write
service wrapping HTTP calls, with no command/query handler split needed,
since there's no local business orchestration happening, only a network
call. `core/shared/` and a package-local `shared/notifications/` are
covered in [10-shared-services.md](10-shared-services.md).

## `lib/` vs `test/`: mirrored trees, not co-located folders

Unlike a JS/TS-style `__tests__/` folder sitting inside the source tree,
Dart/Flutter tests live in a **separate top-level `test/` directory that
mirrors `lib/`'s module/layer structure**. This is a deliberate difference
from a co-located-tests convention, not an oversight — see
[07-testing-strategy.md](07-testing-strategy.md#tests-live-in-a-mirrored-top-level-test-tree)
for why: anything under `lib/` compiles into the shipped Flutter app, so
test code (and Object Mothers) genuinely cannot live there without bloating
the release binary.

## File naming convention

Every file is `snake_case.dart`, named for the concept it's about plus a
descriptive suffix identifying what kind of thing it is. The kind suffix is
fixed vocabulary; skimming a directory listing tells you what everything is
without opening a file.

| Kind | Suffix | Example |
|---|---|---|
| Entity | plain concept name | `order.dart` |
| Value object | plain concept name | `order_id.dart` |
| Object Mother | `_mother.dart` | `order_mother.dart` |
| Repository (port or adapter) | `_repository.dart` | `order_repository.dart` (port), `fake_order_repository.dart` (adapter) |
| Domain/application error | `_error.dart` | `order_not_found_error.dart` |
| Read model / DTO | `_read_model.dart` | `order_read_model.dart` |
| Read service | `_read_service.dart` | `order_read_service.dart` |
| Write service | `_write_service.dart` | `order_write_service.dart` |
| Query | `_query.dart` | `get_order_by_slug_query.dart` |
| Query handler | `_query_handler.dart` | `get_order_by_slug_query_handler.dart` |
| Command | `_command.dart` | `confirm_order_command.dart` |
| Command handler | `_command_handler.dart` | `confirm_order_command_handler.dart` |
| Mapper (ACL) | `_mapper.dart` | `order_mapper.dart` |
| Utility/helper function | `_util.dart` | `format_published_at_util.dart` |
| Page (container) | `_page.dart` | `order_details_page.dart` |
| View (component) | `_view.dart` | `order_details_view.dart` |
| Skeleton | `_skeleton.dart` | `order_details_skeleton.dart` |
| Cubit / Bloc (state service) | `_cubit.dart` / `_bloc.dart` | `order_details_cubit.dart` |
| Cubit/Bloc state | `_state.dart` | `order_details_state.dart` |
| Test | append `_test` before the extension | `order_test.dart` |

Rules:

- The concept name is whatever the file is fundamentally about — usually,
  but not always, matching the exported class. A repository port file
  `order_repository.dart` exports `OrderRepository`; a concrete adapter is
  named for what makes it distinct — `fake_order_repository.dart`,
  `http_order_repository.dart` — not a second copy of "repository" in the
  concept name.
- Entities and value objects skip a redundant suffix (`order.dart`, not
  `order_entity.dart`) because their own folder (`entities/`,
  `value_objects/`) already says what kind of thing they are; every other
  kind keeps an explicit suffix since files of different kinds otherwise sit
  side by side in the same folder (`application/`, `presentation/`).
- A port and its adapter both get `_repository.dart` — they're
  distinguished by folder (`domain/repositories/` vs `infrastructure/`) and
  by the adapter's distinguishing prefix, not by a different suffix.
- Test files keep the production file's full name and insert `_test` before
  `.dart`: `order.dart` → `order_test.dart`.
- **Exempt**: entry-point/scaffold files that don't represent one of the
  kinds above — `main.dart`, `composition_root.dart`, a shared prop-type
  contract. These keep plain descriptive names.

## Rules

- A module (`ordering`, `catalog`, ...) corresponds to a bounded
  context/feature area, not a technical concern. If you can't name it with a
  business noun, it's probably not a module boundary.
- Within a module, the four hexagonal layers still apply, and the dependency
  rule from [02-hexagonal-architecture.md](02-hexagonal-architecture.md)
  still holds — vertical slicing organizes folders, it does not relax the
  layering.
- `shared/` holds truly cross-cutting, stable primitives (generic value
  objects like `Money`, the base `DomainError`, arch-test rule
  configuration). It is not a dumping ground — if something is only used by
  one module, it stays in that module.
- Cross-module communication goes through a module's application layer
  (its commands/queries), never by one module reaching into another
  module's domain or infrastructure internals.
- A new feature means a new module folder with its own four layers, not new
  branches inside an existing module's files.
- `core` (the domain layer shared between `backend` and `frontend`)
  applies this same module structure — a module's `domain/` folder lives
  in `core`; `application/`, `infrastructure/`, and `presentation/` each
  live in whichever of `backend`/`frontend` needs them, importing the
  module's domain types from `core` — see
  [above](#the-corebackendfrontend-split) for why application isn't
  shared too.

## Why

- Deleting a feature is deleting a folder.
- Arch tests can enforce both the horizontal rule (layer dependencies) and,
  optionally, the vertical rule (no module importing another module's
  internals) in one pass.
- Cognitive load per task drops: the files you need for "confirm an order"
  are co-located, not scattered across a layer-first tree.
