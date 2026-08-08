# `frontend` — the app

A Flutter web app: the visual front door to the catalog described in
[core-domain.md](core-domain.md), talking directly to Firebase Auth and
Cloud Firestore — there is no custom backend in between. It owns its own
application/infrastructure/presentation layers on top of the shared
`core` domain.

## Pages and navigation

Routing is `go_router` (`app_router.dart`), gated by one rule: signed
out and not already on `/login` or `/signup` → redirected to `/login`;
signed in and on one of those two → redirected to `/`. That check runs
on every navigation (it's wired to `SessionStateService`'s stream via
`GoRouterRefreshStream`), so logging out mid-session immediately kicks
the user back to `/login` rather than leaving a stale authenticated
screen on-screen.

| Route | Page | Requires auth |
|---|---|---|
| `/login` | Sign in with email + password | no |
| `/signup` | Register (email, username, password) | no |
| `/` | Home — a preview of recently added items | yes |
| `/items` | The full catalog, paginated | yes |
| `/items/new` | Add an item | yes |
| `/items/:id` | Item detail | yes |

`/` and `/items` share a persistent shell (`AppShellView`): a header
with **Home** / **All items** links, a light/dark theme toggle, and a
logout button when signed in; a footer with a GitHub link and the
current year. `/login` and `/signup` render standalone, outside the
shell.

### Signing in and up

Both `LoginStateService` and `SignupStateService` follow the same shape:
idle → in-progress → either back to idle (success) or a failure state
carrying the message from the `FirebaseAuthException` Firebase Auth
throws (translated in `FirebaseIdentityRepository`), so "email already
in use" or "wrong password" reaches the user close to verbatim rather
than a generic "something went wrong." Neither state service touches
`SessionStateService` directly — on success, Firebase Auth's own
`authStateChanges` stream fires, `SessionStateService` (which subscribes
to it) updates itself, and that's what flips the router's redirect logic
and reveals the authenticated shell.

### Home vs. "All items"

Home shows the 10 most-recently-added items as a taste of the catalog,
with a "See all items" link — it is deliberately not paginated, so it
reads as a preview, not a second copy of the list page. `/items` is the
real browse experience: every item, `PaginationControlView` stepping
one page at a time via
`ItemListStateService.nextPage`/`previousPage`, each page sliced fresh
from Firestore (no client-side caching of pages you've already seen —
see the pagination note in `FirestoreItemRepository`, which fetches the
full matching result set and slices it in memory since the Firestore
client SDK has no server-side `offset()`).
An "Add item" button on `/items` opens `/items/new`.

Both pages lay out items with the same `ResponsiveItemGrid`
(`shared/layout/responsive_item_grid.dart`): centered, targeting 5
columns so a 10-item page reads as two clean rows on a wide screen,
narrowing to fewer, wider columns (and more rows) on small screens.
Home additionally centers that grid vertically in the available space
when there are only a few items, rather than pinning it to the top of
an otherwise empty page. Tapping a card on either page opens
`/items/:id`.

### Adding and viewing an item

`/items/new` is a form (`AddItemStateService`) covering every field an
item has — title, creator(s), publisher, category, format, and the
optional tags/topic/year/description/language/image URL — client-
validated against the same constraints the domain value objects enforce
(so a bad category/format combination still surfaces the domain's exact
`InvalidFormatForCategoryError` message rather than being silently
prevented). The image is a plain URL text field for now; there is no
upload flow yet — Firebase Storage would be the natural place to plug
one in.

`/items/:id` (`ItemDetailStateService`) shows the image beside the rest
of the item's fields on a wide screen, and stacks title/creator → image →
the rest of the fields on a narrow one, with a back button that pops the
navigation stack (falling back to `/items` if the page was opened
directly, e.g. from a shared link).

### What isn't here yet

Deleting an item — `ItemWriteService` has no `delete` method yet, and
there's no page for it; doing so today means deleting the document
directly in the Firebase console.

### Session persistence

`SessionStateService` doesn't manage tokens itself — it wraps
`FirebaseAuth.instance.authStateChanges()`, so it just reflects whatever
Firebase Auth's own (browser-persisted, auto-refreshing) session state
is. `main.dart` awaits `SessionStateService.ready`
(`FirebaseAuth.authStateReady()`) before `runApp`, so a page reload
resolves the real signed-in/out state before the router makes its first
redirect decision, rather than flashing `/login` first.

## Look and feel

- **Typography** — Inconsolata everywhere (`AppTheme`, via
  `google_fonts`), a deliberate monospace choice rather than the
  Material default.
- **Color** — primary is a light purple, seeded through Material 3's
  `ColorScheme.fromSeed` so every derived shade (containers, borders,
  disabled states, ...) stays in family automatically rather than being
  hand-picked. Links use the *secondary* color, which differs by theme
  on purpose: a deeper purple on light backgrounds where a pale one
  wouldn't have enough contrast, and a lighter, higher-luminance purple
  on the app's dark background (`AppTheme._darkBackground`, a dark
  near-black rather than pure `#000000`) so it stays legible there.
- **Theme switching** — `ThemeStateService` toggles `ThemeMode` app-wide
  from the header button; both `ThemeData`s are pre-built in `AppTheme`
  rather than computed per-toggle.
- **Icons** — `pixelarticons` (`Pixel.*`) throughout instead of Material
  icons, matching the pixel-art aesthetic.

## Under the hood

- **State management** — one state service per page/concern, living in
  that feature's `application/` layer, not presentation (`LoginStateService`,
  `SignupStateService`, `HomeStateService`, `ItemListStateService`,
  `AddItemStateService`, `ItemDetailStateService`), plus two app-wide ones
  outside any single page, in `shared/`: `SessionStateService` (who's
  signed in) and `ThemeStateService` (light/dark). Each is implemented as
  a `Cubit<State>`, but named/placed to say what it *is* (application's
  reactive state holder) rather than which library implements it — see
  [03-application-layer-cqrs.md](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state).
  Pages subscribe to state via `BlocProvider`/`BlocBuilder` and choose
  which view to render; views are pure/props-only — see
  [05-presentation-layer.md](05-presentation-layer.md).
- **Wiring** — `get_it` as the composition root (`composition_root.dart`),
  explicit `registerLazySingleton`/`registerFactory` calls, no codegen —
  see [08-tech-flutter-dart.md](08-tech-flutter-dart.md). Only the two
  app-wide state services are registered in `getIt`; a per-page one is
  constructed directly in its Page's `BlocProvider.create`.
- **Firebase** — `firebase_auth` and `cloud_firestore` are called
  directly from infrastructure (`FirebaseIdentityRepository`,
  `FirestoreItemRepository`); nothing above the infrastructure layer
  imports either package, so the application/presentation layers stay
  ignorant of Firebase the same way they were previously ignorant of
  `package:http`.
- **Firebase configuration** — `firebase_options.dart` builds the
  project's `FirebaseOptions` from environment variables (`FIREBASE_API_KEY`,
  ...) rather than hardcoding them, read via `flutter_dotenv` from
  `frontend/.env` (gitignored; `main.dart` calls `dotenv.load()` before
  `Firebase.initializeApp`, which runs before anything else). Copy
  `frontend/.env.example` to `frontend/.env` and fill in your project's
  web config to run locally. Per-user data isolation is enforced
  server-side by `firestore.rules` at the repo root, not by anything in
  the Flutter app.
