# Architecture Standards

Shared reference for how `vaniabase` is built: Domain-Driven Design,
Hexagonal Architecture (Ports & Adapters), CQRS at the application layer,
and Vertical Slicing across features — all in Dart, split across three
packages: `core` (domain only, shared), `backend` (Dart server — owns its
own application + infrastructure + presentation layers), and `frontend`
(Flutter app — same, its own application + infrastructure + presentation).

These documents are written for both human developers and AI coding
assistants. Rules are stated as MUST / MUST NOT / SHOULD so they can be
applied mechanically and checked in review or by arch tests.

## The one rule that outranks all others

**Domain logic lives in the domain layer, and nowhere else.** Application,
infrastructure, and presentation code MUST NOT contain business rules,
validation of business invariants, or decisions that belong to the domain.
Those layers orchestrate, adapt, and render — they do not decide. When in
doubt about where a piece of logic belongs, it belongs in the domain unless
it is strictly technical (I/O, framework wiring, rendering).

## Reading order

1. [01-domain-layer.md](01-domain-layer.md) — entities, value objects, private
   constructors, factories, object mothers, no primitives.
2. [02-hexagonal-architecture.md](02-hexagonal-architecture.md) — layers,
   ports/adapters, the dependency rule.
3. [03-application-layer-cqrs.md](03-application-layer-cqrs.md) — commands,
   queries, read/write services, why no use cases or data sources.
4. [04-infrastructure-layer.md](04-infrastructure-layer.md) — adapters,
   repository implementations, mapping.
5. [05-presentation-layer.md](05-presentation-layer.md) — pages, views,
   skeletons, consuming the application layer's state service.
6. [06-vertical-slicing.md](06-vertical-slicing.md) — organizing by feature
   instead of by layer, the `core`/`backend`/`frontend` split, and the file
   naming convention.
7. [07-testing-strategy.md](07-testing-strategy.md) — arch tests, mocking
   ports, object mothers, and why tests live in a mirrored `test/` tree
   instead of co-located with `lib/`.
8. [08-tech-flutter-dart.md](08-tech-flutter-dart.md) — the composition
   root, `get_it` wiring, and the state service's Cubit/Bloc implementation.
9. [09-git-workflow.md](09-git-workflow.md) — commit script, pre-push test
   guard, stashing uncommitted work before testing.
10. [10-shared-services.md](10-shared-services.md) — ErrorManager and
    NotificationService as the canonical shared cross-cutting services.
11. [11-e2e-testing.md](11-e2e-testing.md) — `flutter_gherkin` end-to-end
    testing.
12. [glossary.md](glossary.md) — terms used across these docs.

## How to use this in a new project

Copy this folder as-is into the new repository (e.g. `docs/architecture/`),
then follow [09-git-workflow.md](09-git-workflow.md) to wire up the git
hooks using the templates in `templates/`.

## vaniabase project documentation

The numbered files above are the portable architecture standard — no
vaniabase-specific content. What vaniabase actually *does*, feature by
feature and package by package, lives in three separate documents
instead, so they can be dropped or replaced without touching the
standard:

- [core-domain.md](core-domain.md) — the catalog and identity domain
  model: what an item and an account are, the business rules that
  govern them (category/format compatibility, password/username
  policy, token lifecycle).
- [backend-api.md](backend-api.md) — the API: the register → log in →
  browse → refresh → log out flow, how the catalog stays private per
  user, how domain errors become HTTP responses.
- [frontend-app.md](frontend-app.md) — the app: pages and navigation,
  the sign-in/sign-up/browse user journey, theming, and what's
  deliberately not built yet.

## Non-negotiables (summary)

- DDD tactical patterns in the domain layer: entities, value objects,
  aggregates, domain services, private constructors with `create`/`empty`
  factory constructors.
- No primitives in the domain — every meaningful concept is a value object.
- Fields fixed at construction are public `final`, not `private` + a
  `getXxx()` method. Fields mutated internally to protect an invariant stay
  `private` with a `get` accessor instead of a method, so every field still
  reads as a plain property at the call site.
- Ports and application-service contracts are `abstract class`, not left as
  an implicit interface on a single concrete class — implementations
  `extend`/`implement` them. Plain data shapes (read models, command/query
  payloads) stay plain classes.
- Domain folder split by concept: `entities/`, `value_objects/`,
  `repositories/`, not a flat file listing.
- Infrastructure owns an Anti-Corruption Layer (`infrastructure/acl/`) that
  translates external shapes into domain objects, separate from the
  repository implementation that uses it.
- Tests live in a top-level `test/` tree mirroring `lib/` folder-for-folder,
  never co-located inside `lib/` — anything under `lib/` ships in the
  compiled app/binary. Object Mothers live there too.
- File names are `snake_case.dart`, concept name plus a fixed kind suffix
  (`order_repository.dart`, `order_details_page.dart`,
  `order_details_state_service.dart`, ...) — see
  [06-vertical-slicing.md](06-vertical-slicing.md#file-naming-convention)
  for the full suffix table.
- Object Mothers for building test fixtures, never ad-hoc literals scattered
  across tests.
- Read/write services (`OrderReadService`/`OrderWriteService`) have **zero
  Flutter dependency** — plain Dart classes, fully usable from `core` and
  `backend` too. The state service in `frontend`'s **application** layer
  (not presentation) is the only place reactive UI state lives, and the one
  file per feature allowed to depend on `flutter_bloc` — see
  [03-application-layer-cqrs.md](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state).
- Read models are optional: a query MAY return the domain entity directly
  instead of a hand-written DTO when the entity is read-only (no behavior,
  no mutable state) — see
  [05-presentation-layer.md](05-presentation-layer.md#read-models-are-optional--presentation-may-render-a-domain-entity-directly).
  Keep the DTO for anything with behavior or mutable state.
- Errors and warnings are domain types (`DomainError`/`DomainWarning` in
  `shared/errors/`), declared in the domain layer even when an application
  handler is what detects the condition — see
  [01-domain-layer.md](01-domain-layer.md#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer).
- `ErrorManager` and `NotificationService` in `shared/` are the canonical
  cross-cutting services, following the exact same domain/pure-service/
  state-service pattern as a feature module — see
  [10-shared-services.md](10-shared-services.md). `SessionStateService` and
  `ThemeStateService` are built the same way; build future shared services
  (feature flags, ...) the same way too.
- Hexagonal architecture: `domain / application / infrastructure /
  presentation`, dependencies point inward only. Only `domain` lives in
  `core`, shared unchanged between `backend` and `frontend`; each of those
  two owns its own `application`/`infrastructure`/`presentation` — see
  [06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split)
  for why application isn't shared too.
- CQRS in the application layer: separate read services (queries) and write
  services (commands). No "use case" classes, no "data source" abstraction.
- Vertical slicing: folders organized by feature/bounded context first, by
  layer second.
- Presentation: pages (subscribe to the state service, pick a branch) vs
  views (pure/props-only), skeletons for loading states. Presentation never
  defines a Cubit/Bloc itself — that's the state service's job, in
  application.
- Arch tests enforce the dependency rule in CI — layer violations fail the
  build, not just code review.
- `mocktail` to mock ports when testing application services; `bloc_test`
  to assert a state service's state sequences.
- `get_it` as the composition-root service locator — bind ports to
  concretes with explicit factory functions (`registerLazySingleton`/
  `registerFactory`), not annotation-based/codegen auto-wiring (see
  [08-tech-flutter-dart.md](08-tech-flutter-dart.md) for why).
- No comments in code. Names and structure carry the meaning.
- Git hooks wired via `git config core.hooksPath .husky`, no Node required:
  a `prepare-commit-msg` hook prompts for a conventional-commit type on
  every `git commit`, a `commit-msg` hook validates the format regardless of
  how the message was produced, and a `pre-push` hook stashes uncommitted
  changes, runs the test suite against exactly what's committed, then
  restores the stash regardless of outcome.
- End-to-end tests are written in Gherkin and run through `flutter_gherkin`
  against a real app build — see [11-e2e-testing.md](11-e2e-testing.md).
  Kept out of the `pre-push` hook on purpose; run on demand and in CI.
