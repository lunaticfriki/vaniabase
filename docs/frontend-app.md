# `frontend` — the app

A Flutter web app: the visual front door to the catalog described in
[core-domain.md](core-domain.md), talking to the API described in
[backend-api.md](backend-api.md). Like `backend`, it owns its own
application/infrastructure/presentation layers on top of the shared
`core` domain.

## Pages and navigation

Routing is `go_router` (`app_router.dart`), gated by one rule: signed
out and not already on `/login` or `/signup` → redirected to `/login`;
signed in and on one of those two → redirected to `/`. That check runs
on every navigation (it's wired to `SessionCubit`'s stream via
`GoRouterRefreshStream`), so logging out mid-session immediately kicks
the user back to `/login` rather than leaving a stale authenticated
screen on-screen.

| Route | Page | Requires auth |
|---|---|---|
| `/login` | Sign in with email + password | no |
| `/signup` | Register (email, username, password) | no |
| `/` | Home — a preview of recently added items | yes |
| `/items` | The full catalog, paginated | yes |

`/` and `/items` share a persistent shell (`AppShellView`): a header
with **Home** / **All items** links, a light/dark theme toggle, and a
logout button when signed in; a footer with a GitHub link and the
current year. `/login` and `/signup` render standalone, outside the
shell.

### Signing in and up

Both `LoginCubit` and `SignupCubit` follow the same shape: idle →
in-progress → either back to idle (success) or a failure state carrying
a message pulled straight from the backend's `{"error": ...}` body (see
[backend-api.md](backend-api.md#turning-a-domain-error-into-an-http-response)),
so "email already registered" or "password must be 8-128 characters..."
reaches the user close to verbatim rather than a generic "something
went wrong." On success, the returned session is handed to
`SessionCubit.authenticate`, which is what flips the router's redirect
logic and reveals the authenticated shell.

### Home vs. "All items"

Home shows the 10 most-recently-added items as a taste of the catalog,
with a "See all items" link — it is deliberately not paginated, so it
reads as a preview, not a second copy of the list page. `/items` is the
real browse experience: every item, `PaginationControlView` stepping
one page at a time via `ItemListCubit.nextPage`/`previousPage`, each
page fetched fresh from the backend (no client-side caching of pages
you've already seen).

Both pages lay out items with the same `ResponsiveItemGrid`
(`shared/layout/responsive_item_grid.dart`): centered, targeting 5
columns so a 10-item page reads as two clean rows on a wide screen,
narrowing to fewer, wider columns (and more rows) on small screens.
Home additionally centers that grid vertically in the available space
when there are only a few items, rather than pinning it to the top of
an otherwise empty page.

### What isn't here yet

The frontend is currently **read-only** — browsing only. The backend
supports creating, editing, and deleting items
(see [backend-api.md](backend-api.md)), but there's no page for any of
that yet; adding items today means calling the API directly (`curl`,
the `/docs` Swagger UI, or another client).

### Known gap: no automatic token refresh

`SessionCubit` holds both the access and refresh token in memory after
login, but nothing currently calls `POST /auth/refresh` — not on a
timer, not on a `401`. In practice that means a session silently stops
working 15 minutes after login (the access token's TTL) until the user
logs in again, and a page reload always lands back on `/login` (session
state isn't persisted to storage, only held in memory). Wiring
`ApiClient` to retry a `401` through `/auth/refresh` — and persisting
the session so a reload doesn't sign the user out — is the natural next
step here, not a design decision to leave as-is.

## Look and feel

- **Typography** — Inconsolata everywhere (`AppTheme`, via
  `google_fonts`), a deliberate monospace choice rather than the
  Material default.
- **Color** — primary is a light purple, seeded through Material 3's
  `ColorScheme.fromSeed` so every derived shade (containers, borders,
  disabled states, ...) stays in family automatically rather than being
  hand-picked. Links use the *secondary* color, which differs by theme
  on purpose: a brilliant yellow reads well on the app's dark
  background (`AppTheme._darkBackground`, a dark near-black rather than
  pure `#000000`) but the same yellow is hard to read on white, so
  light theme uses a deeper purple instead.
- **Theme switching** — `ThemeCubit` toggles `ThemeMode` app-wide from
  the header button; both `ThemeData`s are pre-built in `AppTheme`
  rather than computed per-toggle.
- **Icons** — `pixelarticons` (`Pixel.*`) throughout instead of Material
  icons, matching the pixel-art aesthetic.

## Under the hood

- **State management** — one `Cubit` per page/concern
  (`LoginCubit`, `SignupCubit`, `HomeCubit`, `ItemListCubit`), plus two
  app-wide ones outside any single page: `SessionCubit` (who's signed
  in) and `ThemeCubit` (light/dark). Pages read Cubit state and choose
  which view to render; views are pure/props-only — see
  [05-presentation-layer.md](05-presentation-layer.md).
- **Wiring** — `get_it` as the composition root (`composition_root.dart`),
  explicit `registerLazySingleton`/`registerFactory` calls, no codegen —
  see [08-tech-flutter-dart.md](08-tech-flutter-dart.md).
- **HTTP** — a thin `ApiClient` wrapping `package:http`, attaching the
  bearer token from `SessionCubit` to every request and turning a
  non-2xx response into an `ApiException` carrying the backend's error
  message.
- **Where the backend lives** — `API_BASE_URL`, read via
  `String.fromEnvironment` at *build* time (`--dart-define`), defaulting
  to `http://localhost:8080`. Because Flutter web ships as static JS
  that runs in the browser, this has to point wherever the browser can
  reach the backend from — not wherever the frontend container itself
  runs.
