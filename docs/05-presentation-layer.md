# Presentation Layer

Presentation renders state and dispatches user intent. It depends on the
application layer: its read/write services indirectly, and its **state
service** directly, subscribed to via `BlocProvider`/`BlocBuilder`. It MUST
NOT import infrastructure directly, and MUST NOT define reactive state
itself — presentation holds no state of its own beyond throwaway widget-local
concerns (a `TextEditingController`, a `GlobalKey<FormState>`); anything
that outlives a single build (loading/error/loaded, form-submission
progress) is the state service's job, one layer in. See
[03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state)
for why it lives there.

## Page vs View

- **Page**: knows about the application layer's state service and
  subscribes to it. Owns the `BlocProvider`/`BlocBuilder`, reads emitted
  state, dispatches commands/queries by calling the state service's
  methods, and decides what to render based on state
  (loading/error/loaded). No markup beyond composing views and picking the
  loading/error/loaded branch. Never defines a Cubit/Bloc itself — only
  ever constructs and reads one that already exists in `application/`.
- **View**: pure, presentation-only widget. Receives constructor parameters,
  renders widgets, emits events upward via callbacks. Has no knowledge of
  the state service, application layer, or domain. Trivial to test in
  isolation and reuse.

```dart
// presentation/order/order_details_page.dart
class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailsStateService(
        context.read<OrderReadService>(),
        context.read<OrderWriteService>(),
        orderId,
      ),
      child: BlocBuilder<OrderDetailsStateService, OrderDetailsState>(
        builder: (context, state) => switch (state) {
          OrderDetailsLoading() => const OrderDetailsSkeleton(),
          OrderDetailsError(:final message) => OrderDetailsErrorView(message: message),
          OrderDetailsLoaded(:final order) => OrderDetailsView(
              order: order,
              onConfirm: () => context.read<OrderDetailsStateService>().confirm(),
            ),
        },
      ),
    );
  }
}
```

```dart
// presentation/order/order_details_view.dart
class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({required this.order, required this.onConfirm, super.key});

  final OrderReadModel order;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(order.customerName),
        OrderLineList(lines: order.lines),
        ElevatedButton(onPressed: onConfirm, child: const Text('Confirm order')),
      ],
    );
  }
}
```

`OrderDetailsView` never imports the state service or its state classes
directly — its constructor takes a plain read model shape, making it
layer-agnostic to test and reuse (e.g. in a widgetbook/style-guide app).

## Skeletons

Every page that loads data owns a skeleton widget shown while state is
loading. Skeletons mirror the real view's layout (same regions, placeholder
blocks instead of content) so the transition from loading to loaded doesn't
jump. Skeletons live next to the view they shadow:

```
presentation/order/
  order_details_page.dart
  order_details_view.dart
  order_details_skeleton.dart
```

## Consuming the state service

Presentation never defines a Cubit — it only ever subscribes to one that
already exists in the application layer. See
[03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state)
for why the state service lives in application, and
[08-tech-flutter-dart.md#application-the-state-service](08-tech-flutter-dart.md#application-the-state-service)
for the concrete `Cubit<State>` pattern (including when Bloc — event-sourced
— is a better fit than Cubit's direct method calls).

The Page's contract with it is narrow:

- Construct it in a `BlocProvider.create`, resolving its read/write-service
  dependencies from `getIt`/`context.read`.
- Read emitted state via `BlocBuilder`/`BlocConsumer` and pick the
  loading/error/loaded branch.
- Call its methods (`confirm()`, `submit()`, ...) in response to a callback
  a View fired upward — never reach into a read/write service or repository
  directly from presentation to bypass it.

A page imports `BlocProvider`/`BlocBuilder`/`BlocConsumer` from
`flutter_bloc` — the *consumer*-side API — but never `Cubit` itself and
never extends it. If a file under `presentation/` extends `Cubit<State>`,
that's the signal it belongs in `application/` instead.

## Read models are optional — presentation may render a domain entity directly

The default used to be: a query handler always maps its result to a read
model DTO before it leaves the application layer, so presentation never
sees a domain type. That's still the right call for an entity with
behavior or mutable state (see below) — but for a genuinely read-only
entity (every field public `final`, no methods that change anything),
mapping to a hand-written DTO is pure ceremony. It's fine to return the
entity itself from the read service/state service and let presentation
render its value-object fields with `.toString()` (or a small formatter,
for things like a date):

```dart
class PostPreview extends StatelessWidget {
  const PostPreview({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title.toString()),
        Text('${post.author} · ${formatPublishedAt(post.publishedAt)}'),
      ],
    );
  }
}
```

This is a deliberate, narrow trade: presentation now imports a domain type
(`Post`) directly, which is a real deviation from "presentation depends on
application only" — accept it specifically because `Post` here is
immutable and behavior-free, so there's nothing presentation could
accidentally trigger by holding a reference to it. Reach for a proper read
model DTO instead when any of these hold:

- The entity has behavior (`order.confirm()`) — handing presentation a live
  reference risks it calling a mutating method directly, bypassing the
  write service.
- The entity is mutable internally (private fields behind a `get`
  accessor) — same risk, plus the read model can safely be a frozen
  snapshot where the entity can't.
- The read shape genuinely diverges from the domain shape — aggregating
  fields from more than one entity, flattening nested value objects
  differently than the domain model does.

`Order` (the running example throughout these docs) is intentionally kept
as the "needs a read model" case for this reason — it has both behavior and
mutable state.

## What presentation MUST NOT do

- Import infrastructure directly (a concrete repository, an HTTP client).
- Contain business rules (e.g. "an order over $100 gets free shipping" is a
  domain rule, not a widget conditional).
- Construct domain entities directly — presentation only ever sees read
  models (DTOs) coming back from queries, or a read-only domain entity per
  the exception above.
- Define a Cubit/Bloc, or hold any state that outlives a single build beyond
  throwaway widget-local concerns (a `TextEditingController`, a
  `GlobalKey<FormState>`) — that's the state service's job in application;
  presentation only ever subscribes to one via `BlocProvider`/`BlocBuilder`.
