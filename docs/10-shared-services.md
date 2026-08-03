# Shared Cross-Cutting Services

Some concerns aren't owned by any one feature module — error reporting,
notifications, auth session, feature flags. They live in `shared/`, but
they follow the exact same architectural patterns a feature module does:
real domain modeling when the concern has actual data shape, a pure
application service, and — if the concern needs reactive state in the UI —
a Cubit in presentation, exactly as described in
[03-application-layer-cqrs.md](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-cubit-holds-the-reactive-state).
"Shared" describes *where* the code lives and *who* depends on it, not a
license to skip the rules.

This doc walks through the two shared services every project starts with —
`NotificationService`/`NotificationStateCubit` and `ErrorManager` — as the
canonical example to copy when building the next one. `NotificationService`
and its domain model live in `core` (framework-free, so `backend` can raise
notifications too); `NotificationStateCubit` lives in `frontend`, since it's
the Flutter-facing reactive holder.

## Folder structure

```
core/
  shared/
    errors/
      domain_error.dart
      domain_warning.dart
      error_manager.dart
    notifications/
      entities/
        notification.dart
      value_objects/
        notification_id.dart
        notification_message.dart
      notification_service.dart

frontend/
  shared/
    notifications/
      notification_state_cubit.dart
      notification_center.dart

test/
  shared/
    errors/
      error_manager_test.dart
    notifications/
      entities/
        notification_test.dart
        notification_mother.dart
```

## Notification Service

A notification is a real domain concept with identity (each one can be
individually dismissed) — it gets a proper entity, not a loose map/record.

```dart
// core/shared/notifications/entities/notification.dart
enum NotificationKind { info, success, warning, error }

class Notification {
  const Notification._(this.id, this.kind, this.message);

  factory Notification.create({
    required NotificationKind kind,
    required NotificationMessage message,
  }) {
    return Notification._(NotificationId.generate(), kind, message);
  }

  factory Notification.empty() {
    return Notification._(NotificationId.empty(), NotificationKind.info, NotificationMessage.empty());
  }

  final NotificationId id;
  final NotificationKind kind;
  final NotificationMessage message;
}
```

`NotificationKind` stays a plain `enum`, not a value object — it's a small,
closed, compiler-checked set with no validation logic to centralize, which
is what the no-primitives rule is actually protecting against (see
[01-domain-layer.md](01-domain-layer.md#no-primitives-in-the-domain)). The
`id` and `message` are real value objects (`NotificationId`,
`NotificationMessage`) because they carry actual validation and identity
semantics.

The application layer is a single pure service — no Flutter dependency, no
reactive state, just construction logic — living in `core`:

```dart
// core/shared/notifications/notification_service.dart — no Flutter dependency
abstract class NotificationService {
  Notification create(NotificationKind kind, String message);
}

class NotificationServiceImpl implements NotificationService {
  @override
  Notification create(NotificationKind kind, String message) {
    return Notification.create(kind: kind, message: NotificationMessage.create(message));
  }
}
```

The reactive list of currently-visible notifications is a Cubit, living in
`frontend/shared/` — the same "Cubit is presentation's one reactive-state
dependency" rule as any feature module (see
[05-presentation-layer.md](05-presentation-layer.md#state-service-the-cubit)):

```dart
// frontend/shared/notifications/notification_state_cubit.dart
class NotificationStateCubit extends Cubit<List<Notification>> {
  NotificationStateCubit(this._notificationService) : super(const []);

  final NotificationService _notificationService;

  void notify(NotificationKind kind, String message) {
    final notification = _notificationService.create(kind, message);
    emit([...state, notification]);
  }

  void dismiss(NotificationId id) {
    emit(state.where((n) => n.id != id).toList());
  }
}
```

A `NotificationCenter` widget wraps itself in a `BlocBuilder<
NotificationStateCubit, List<Notification>>` and renders a snackbar/banner
per entry, calling `dismiss(id)` on close — the same page-reads-a-Cubit
pattern as any feature module's state service.

## Error Manager

`ErrorManager` is the single place a thrown `DomainError`/`DomainWarning`
gets translated into something the user actually sees. It has no reactive
state of its own — it's a pure orchestrator that delegates to
`NotificationStateCubit` for the reactive part, so it lives in `core` next
to the error types it handles, taking the Cubit as a dependency rather than
being one itself.

```dart
// core/shared/errors/error_manager.dart
abstract class ErrorManager {
  void handle(Object error);
}

class ErrorManagerImpl implements ErrorManager {
  ErrorManagerImpl(this._notifications);

  final NotificationStateCubit _notifications;

  @override
  void handle(Object error) {
    if (error is DomainWarning) {
      _notifications.notify(NotificationKind.warning, error.message);
      return;
    }
    if (error is DomainError) {
      _notifications.notify(NotificationKind.error, error.message);
      return;
    }
    _notifications.notify(NotificationKind.error, error.toString());
  }
}
```

Any Cubit in the app that catches a genuine failure calls
`errorManager.handle(error)` in addition to emitting its own local error
state — the local state drives that one screen's UI (an inline error
message, a retry button), while `ErrorManager` drives the app-wide
notification. Don't route *every* caught error through it — an expected,
navigable outcome (a "not found" from a bad route parameter) is local state
only; see
[01-domain-layer.md](01-domain-layer.md#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer)
for that distinction.

## Wiring into the composition root

Same `get_it` pattern as any other binding, wired in dependency order —
`NotificationService` has no deps, `NotificationStateCubit` needs it,
`ErrorManager` needs `NotificationStateCubit`, and any feature Cubit that
reports errors needs `ErrorManager`:

```dart
getIt.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());

getIt.registerLazySingleton<NotificationStateCubit>(
  () => NotificationStateCubit(getIt<NotificationService>()),
);

getIt.registerLazySingleton<ErrorManager>(
  () => ErrorManagerImpl(getIt<NotificationStateCubit>()),
);
```

`NotificationStateCubit` is registered as a singleton (not a per-page
factory, unlike a feature Cubit) because it's genuinely app-wide state that
every screen's `ErrorManager` calls into and one `NotificationCenter` at the
app root renders from.

## When to build a new shared service this way

Build the full pattern (domain entities/VOs + pure service + Cubit) when the
concern has real data shape and/or needs reactive state — the next
candidates are typically auth session, feature flags, or a global
loading/offline indicator. If a cross-cutting concern is genuinely stateless
and trivial — a single pure formatting or validation function with no data
shape of its own — a plain top-level function in a `_util.dart` file is
enough. Don't force entities and a Cubit onto something that's really just a
function; don't skip them onto something that's genuinely stateful and
shared just because it's a small amount of code today.
