# Presentation Layer

Presentation renders state and dispatches user intent. It depends on the
application layer (commands/queries and their read models) and MUST NOT
import infrastructure directly. It holds UI state and rendering logic —
never business rules.

## Page vs View

- **Page**: knows about the Cubit/Bloc and application layer. Owns the
  `BlocProvider`/`BlocBuilder`, reads emitted state, dispatches
  commands/queries, and decides what to render based on state
  (loading/error/loaded). No markup beyond composing views and picking the
  loading/error/loaded branch.
- **View**: pure, presentation-only widget. Receives constructor parameters,
  renders widgets, emits events upward via callbacks. Has no knowledge of
  the Cubit, application layer, or domain. Trivial to test in isolation and
  reuse.

```dart
// presentation/order/order_details_page.dart
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

`OrderDetailsView` never imports the Cubit or any application type
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

## State service: the Cubit

The Cubit is the reactive holder of "what should the UI currently show,"
built on top of application queries/commands, that a page subscribes to via
`BlocBuilder`/`BlocProvider`.

Responsibilities:

- Expose a sealed state hierarchy (`Loading`/`Loaded`/`Error`, or richer as
  the screen needs).
- Update after a command runs (re-run the query, or apply an optimistic
  update).
- Hold no business logic — it only decides *when* to call application
  services and *how* to shape loading/error state for the UI, never *whether*
  a business rule is satisfied.

```dart
// presentation/order/order_details_cubit.dart
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

The Cubit lives squarely in presentation — it is the layer's one allowed
dependency on a reactive-state library (`bloc`/`flutter_bloc`). See
[08-tech-flutter-dart.md](08-tech-flutter-dart.md#presentation-cubit-as-the-state-service)
for the full pattern, including when Bloc (event-sourced) is a better fit
than Cubit (direct method calls).

## Read models are optional — presentation may render a domain entity directly

The default used to be: a query handler always maps its result to a read
model DTO before it leaves the application layer, so presentation never
sees a domain type. That's still the right call for an entity with
behavior or mutable state (see below) — but for a genuinely read-only
entity (every field public `final`, no methods that change anything),
mapping to a hand-written DTO is pure ceremony. It's fine to return the
entity itself from the read service/Cubit and let presentation render its
value-object fields with `.toString()` (or a small formatter, for things
like a date):

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
