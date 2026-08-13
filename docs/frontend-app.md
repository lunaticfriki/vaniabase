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
| `/items` | The full catalog, paginated, sortable | yes |
| `/completed` | Items marked completed (reuses `/items`'s list view) | yes |
| `/items/new` | Add an item | yes |
| `/items/import` | Bulk import items from a spreadsheet | yes |
| `/items/:id` | Item detail | yes |
| `/items/:id/edit` | Edit an item | yes |
| `/categories` | Categories, each with a preview of its items | yes |
| `/categories/:category` | Items in one category, paginated (reuses `/items`'s list view) | yes |
| `/tags` | Tag cloud; click a tag to filter items below | yes |
| `/topics` | Topics, browsable by first letter | yes |
| `/authors` | Authors/creators, browsable by first letter | yes |
| `/languages` | Languages, browsable by first letter | yes |
| `/publishers` | Publishers, browsable by first letter | yes |
| `/search` | Debounced text search across the catalog | yes |

All of the above except `/login` and `/signup` share a persistent shell
(`AppShellView`): a header with links to each page plus a light/dark
theme toggle and a logout button when signed in; a floating **Add item**
button bottom-right on every shell page except the add/import/detail/edit
ones (where it would either be redundant or overlap the page's own
controls — see `_addItemFabHiddenRoutes` in `app_shell_view.dart`); a
footer with a GitHub link and the current year. On screens narrower than
`navWideBreakpoint` (640px) the nav collapses from icon buttons into a
single hamburger menu (`_showResponsiveMenu` in `app_header_view.dart`)
that opens as a full-width dropdown listing every page by icon and label,
so adding a page never requires shrinking the wide-screen icon row.
`/login` and `/signup` render standalone, outside the shell.

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

### Live data: `watchAll` over one-shot fetches

`ItemReadService.watchAll({category, completed})` returns a
`Stream<List<ItemReadModel>>`, not a `Future` — `FirestoreItemRepository`
backs it with a Firestore `snapshots()` listener, so every page/state
service that subscribes to it (`HomeStateService`, `ItemListStateService`,
`CategoriesStateService`, `TagsStateService`, `SearchStateService`, and
the authors/languages/publishers/topics state services) re-emits
automatically when the underlying data changes, with no manual refresh
or refetch-after-write step anywhere in the app. `category`/`completed`
are pushed down as Firestore `where` clauses so the server does that
filtering; anything beyond that (sorting, paging, letter/tag grouping)
happens client-side over whatever the stream last delivered, since the
client SDK has no server-side `offset()`, sort-by-derived-field, or
grouping support.

### Home vs. "All items" vs. "Completed"

Home shows the 10 most-recently-added items (`homeItemCount` in
`HomeStateService`) as a taste of the catalog, with a "See all items"
link — it is deliberately not paginated, so it reads as a preview, not a
second copy of the list page. `/items` is the real browse experience:
every item, sortable (see below), `PaginationControlView` stepping one
page at a time via `ItemListStateService.nextPage`/`previousPage` over
the sorted list held in memory. `/completed` reuses the exact same
`ItemListContainer`/`ItemListView` with `completed: true` passed through
to `watchAll`, just without the sort control
(`ItemListContainer(completed: true)`, `enableSort` left at its default
`false` — see "Sorting" below for why sort and the completed filter don't
combine).

Both pages, plus `/categories/:category`, lay out items with the same
`ResponsiveItemGrid` (`shared/layout/responsive_item_grid.dart`):
centered, targeting 5 columns so a 10-item page reads as two clean rows
on a wide screen, narrowing to fewer, wider columns (and more rows) on
small screens. Home additionally centers that grid vertically in the
available space when there are only a few items, rather than pinning it
to the top of an otherwise empty page. Tapping a card on any of these
pages opens `/items/:id`. A floating **Add item** button (see "Pages and
navigation" above) is the primary way to reach `/items/new` from any of
them.

### Sorting

`/items` is the only list with a sort control (`ItemListContainer
(enableSort: true)` → a `Pixel.sort` popup menu in `ItemListView`, wired
to `ItemListStateService.setSortOption`). `ItemSortOption`
(`application/item_sort_option.dart`) is one of `createdAtDesc` (default),
`createdAtAsc`, `title`, or `author`; changing it re-sorts the in-memory
item list and resets to page 1 (`ItemListStateService._emitPage`).
`/completed` and `/categories/:category` reuse the same container without
`enableSort`, so they stay in `watchAll`'s default newest-first order —
sorting was scoped to the one page people actually reorder rather than
threaded through every `ItemListContainer` use.

### Browsing: categories, tags, topics, authors, languages, publishers, and search

Seven more ways into the same catalog, all reachable from the header nav:

- **`/categories`** (`CategoryListContainer`/`CategoriesStateService`) —
  one tile per category, each showing up to a handful of that
  category's most recent item covers as small thumbnails next to the
  name, so a tile reads as a preview rather than just a label. The
  thumbnail count is computed from the tile's actual width
  (`LayoutBuilder` in `category_list_view.dart`), so a wider window
  shows more covers instead of a fixed number. Tapping a tile opens
  `/categories/:category`, which reuses the same `ItemListView` as
  `/items` with a category filter.
- **`/tags`** (`TagsContainer`/`TagsStateService`) — every tag used
  across the catalog, laid out as a tag cloud where font size scales
  with how often that tag appears (a `Map<String, int>` frequency count
  over whatever `watchAll` last delivered drives a linear min↔max
  font-size mapping). Tapping a tag filters a `PaginatedItemGridView`
  shown below the cloud, without navigating away; tapping the same tag
  again clears the filter, and selecting a new one auto-scrolls the
  results heading into view (`Scrollable.ensureVisible` off a `GlobalKey`
  in `_TagsBodyState.didUpdateWidget`). The item detail page's tag chips
  link here too, via `/tags?tag=<tag>`, which pre-selects that tag on
  load (`TagsContainer.initialTag` → `TagsStateService`'s constructor).
- **`/topics`, `/authors`, `/languages`, `/publishers`** (their matching
  `*Container`/`*StateService` pairs) — four instances of the same
  shape: collect the distinct values of one `ItemReadModel` field
  (`topic`, `creator` — flattened, since it's a list — `language`, and
  `publisher` respectively) from the live item stream, then browse them
  through the shared `AlphabetIndexView`
  (`presentation/alphabet_index_view.dart`) — an A–Z strip
  (`letterForEntry` in `application/alphabet_util.dart` buckets anything
  not starting with A–Z under `#`) that narrows to the matching entries
  on tap, then to that entry's items in a `PaginatedItemGridView` below,
  auto-scrolled into view the same way `/tags` does. Each page also
  accepts a query param to preselect an entry on load
  (`?topic=`, `?author=`, `?language=`, `?publisher=`), the same pattern
  `/tags?tag=` uses.
- **`/search`** (`SearchContainer`/`SearchStateService`) — a single text
  field, debounced 300ms (`Timer`-based cancel-and-restart in
  `SearchStateService.onQueryChanged`) before it searches, so it doesn't
  re-query on every keystroke. Firestore has no server-side text search,
  so this filters the live item stream in memory using `core`'s
  `SearchTerm.matchesAny` against each item's title, creator, publisher,
  topic, reference, and tags — see
  [core-domain.md](core-domain.md#search) for why that matching logic
  lives in `core` rather than being reimplemented here.

`PaginatedItemGridView` (`presentation/paginated_item_grid_view.dart`) is
the client-side-paginated grid `/tags`, `/topics`, `/authors`,
`/languages`, and `/publishers` all share for their filtered results —
distinct from `ItemListView`'s pagination in that it paginates a list
that's already fully in memory (a filtered subset) rather than driving
`ItemListStateService`'s page-fetching, and resets to page 1 whenever its
`Key` changes (each page passes `ValueKey(selectedEntry)`, so switching
which tag/author/etc. is selected starts back at page 1).

### Bulk import

`/items/import` (`BulkImportContainer`/`BulkImportStateService`) accepts
a `.xlsx`, `.ods`, or `.csv` file (picked via `file_picker`, decoded with
`spreadsheet_decoder` for the spreadsheet formats or the `csv` package
for `.csv`) with a header row and one item per row; `parseBulkImportFile`
(`application/bulk_import_parser.dart`) normalizes header names against
a fixed set of aliases (`author`/`authors`/`creator`/`creators` all map
to the `creator` column, `isbn`/`reference` both map to `reference`,
etc.), then validates each row against the same constraints the domain
value objects enforce — an invalid or missing required field doesn't
abort the import, it's collected as a per-row error and surfaces in a
preview table (`BulkImportPreview.validRows`/`invalidCount`) before
anything is written. Confirming the import calls
`ItemWriteService.create` once per valid row sequentially, emitting
`BulkImportImporting(total, completed)` after each one so the view can
show live progress, and finishes on `BulkImportDone(succeeded, failures)`
— a per-row try/catch means one row failing (e.g. a transient write
error) doesn't stop the rest of the batch.

### Adding and viewing an item

`/items/new` and editing an existing item both use the same
`ItemFormView` (`initial: null` means "add" mode) covering every field
an item has — title, creator(s), publisher, category, format, a
completed checkbox, and the optional tags/topic/year/description/
language/reference/image — client-validated against the same
constraints the domain value objects enforce (so a bad category/format
combination still surfaces the domain's exact
`InvalidFormatForCategoryError` message rather than being silently
prevented). The image is picked from the gallery (`image_picker`) and
uploaded to Firebase Storage (`FirestoreItemRepository._uploadImage`);
removing it clears the `image_url` field and deletes the stored object.

`/items/:id` (`ItemDetailStateService`) lays out differently either side
of `itemDetailWideBreakpoint` (700px, `item_detail_view.dart`). Wide: the
image sits beside a scrollable column of the rest of the fields, with
text **Back**/**Edit** buttons above them. Narrow: the image becomes a
full-bleed hero behind the title/creator (`_ItemHeroImage`, a dark
gradient over the bottom of the image keeps that text legible over any
photo), and Back/Edit become translucent `OverlayIconButton`s
(`shared/layout/overlay_icon_button.dart` — a pill-shaped semi-transparent
button meant to sit on top of image content) that fade in as the page
scrolls (`_headerOpacity` tracks `ScrollController.offset` over a
120px fade distance in `_NarrowItemDetailState`), so they're legible
against both the image and the plain background beneath it. On narrow
screens `AppShellView` also hides the app's own header entirely on this
route (`_isItemDetailPage` check), letting the hero image use the full
viewport height instead of losing space to two stacked toolbars. Either
layout's back button pops the navigation stack (falling back to `/items`
if the page was opened directly, e.g. from a shared link). Tapping the
image opens it fullscreen (`openFullscreenImage` →
`presentation/item_detail/fullscreen_image_view.dart`): a black
`InteractiveViewer` (pinch/scroll to zoom, up to 4x) with a tap-to-toggle
`OverlayIconButton` back control, pushed on the root navigator so it
covers the app shell too. A chip next to the title reflects `completed`
("Completed" vs. "Not completed") and is itself tappable — toggling it
calls `ItemDetailStateService.toggleCompleted()`, which writes through
`ItemWriteService.update` and updates the chip in place, without a full
page reload. Each tag chip in the field list is also tappable, navigating
to `/tags?tag=<tag>` with that tag pre-selected (see "Browsing:
categories, tags, topics, authors, languages, publishers, and search"
above).

Editing an item also offers **Delete**, which confirms via a dialog
before calling `EditItemStateService.delete()` — this removes both the
Firestore document and its stored image.

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
  from the header button (light/dark/system, not just a two-way toggle);
  both `ThemeData`s are pre-built in `AppTheme` rather than computed
  per-toggle. The choice persists across reloads via `shared_preferences`
  (`ThemeStateService`'s constructor seeds its initial state by reading
  the `theme_mode` key, `setMode` writes it back), defaulting to dark
  when nothing's stored yet rather than following the OS.
- **Icons** — `pixelarticons` (`Pixel.*`) throughout instead of Material
  icons, matching the pixel-art aesthetic.

## Under the hood

- **State management** — one state service per page/concern, living in
  that feature's `application/` layer, not presentation (`LoginStateService`,
  `SignupStateService`, `HomeStateService`, `ItemListStateService`,
  `AddItemStateService`, `EditItemStateService`, `ItemDetailStateService`,
  `BulkImportStateService`, `CategoriesStateService`, `TagsStateService`,
  `TopicsStateService`, `AuthorsStateService`, `LanguagesStateService`,
  `PublishersStateService`, `SearchStateService`), plus two app-wide ones
  outside any single page, in `shared/`: `SessionStateService` (who's
  signed in) and `ThemeStateService` (light/dark/system). Each is
  implemented as a `Cubit<State>` (the sealed state classes live
  alongside their service in the same file, not split out separately),
  but named/placed to say what it *is* (application's reactive state
  holder) rather than which library implements it — see
  [03-application-layer-cqrs.md](03-application-layer-cqrs.md#readwrite-services-stay-pure-the-state-service-holds-the-reactive-state).
  Pages subscribe to state via `BlocProvider`/`BlocBuilder` and choose
  which view to render; views are pure/props-only — see
  [05-presentation-layer.md](05-presentation-layer.md).
- **Wiring** — `get_it` as the composition root (`composition_root.dart`),
  explicit `registerLazySingleton`/`registerFactory` calls, no codegen —
  see [08-tech-flutter-dart.md](08-tech-flutter-dart.md). Besides the two
  app-wide state services, `getIt` also holds the `SharedPreferences`
  instance (`registerSingleton`, awaited once during
  `configureDependencies` since obtaining it is itself async) that
  `ThemeStateService` reads/writes; a per-page state service is
  constructed directly in its Page's `BlocProvider.create` instead.
- **Firebase** — `firebase_auth` and `cloud_firestore` are called
  directly from infrastructure (`FirebaseIdentityRepository`,
  `FirestoreItemRepository`); nothing above the infrastructure layer
  imports either package, so the application/presentation layers stay
  ignorant of Firebase the same way they were previously ignorant of
  `package:http`.
- **Completed status** — items carry a `completed` flag (Firestore field
  `completed`, defaulting to `false` when absent on older documents —
  see `ItemMapper.toReadModel`). It's set via the checkbox in
  `ItemFormView` (shared by add/edit), threaded through
  `ItemWriteService.create`/`update` and the two state services, and
  rendered as a tappable status chip on the detail page (`_CompletedBadge`
  in `item_detail_view.dart`) that toggles it directly without opening
  the edit form.
- **Firebase configuration** — `firebase_options.dart` builds the
  project's `FirebaseOptions` per platform (web/android/ios/macos) from
  environment variables (`FIREBASE_API_KEY`, `FIREBASE_API_KEY_ANDROID`,
  `FIREBASE_API_KEY_IOS`, ...) rather than hardcoding them, read via
  `flutter_dotenv` from `frontend/.env` (gitignored; `main.dart` calls
  `dotenv.load()` before `Firebase.initializeApp`, which runs before
  anything else). Copy `frontend/.env.example` to `frontend/.env` and fill
  in your project's config to run locally — the committed
  `google-services.json` / `GoogleService-Info.plist` that `flutterfire
  configure` normally generates are gitignored and unused here for the same
  reason. Linux/Windows aren't supported since Firebase's Flutter plugins
  don't target them. Per-user data isolation is enforced server-side by
  `firestore.rules` at the repo root, not by anything in the Flutter app.
