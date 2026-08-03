# `backend` — the API

A Dart HTTP server (Shelf) exposing the two things a client needs:
prove who you are, and manage your private catalog. It owns its own
application layer (CQRS command/query handlers), infrastructure
(Postgres, bcrypt, JWT), and HTTP routing — only the domain
(`core/modules/{catalog,identity}`, see [core-domain.md](core-domain.md))
is shared with `frontend`. For why application isn't shared too, see
[06-vertical-slicing.md](06-vertical-slicing.md#the-corebackendfrontend-split).

Full endpoint reference with request/response bodies and `curl`
examples lives in [`backend/README.md`](../backend/README.md) — this
document is about the *flow*: what happens, in what order, and why.
There's also a live Swagger UI at `/docs` (backed by `/openapi.yaml`)
once the server is running.

## The user journey

1. **Register** (`POST /auth/register`) — email, username, password.
   The handler (`RegisterUserCommandHandler`) checks both are free,
   hashes the password (bcrypt, never stored or logged in the clear),
   and creates the `User`. It does *not* log the user in — registering
   and authenticating are separate steps, so a client can, say, ask for
   email confirmation between them later without restructuring
   anything.
2. **Log in** (`POST /auth/login`) — email + password. On success, the
   response is a session: an access token, a refresh token, and the
   access token's expiry. From here on, every catalog request carries
   the access token as `Authorization: Bearer <token>`.
3. **Use the catalog** — create, list, fetch, edit, delete items, all
   scoped to whoever the access token identifies.
4. **Refresh** (`POST /auth/refresh`) when the access token is close to
   or past expiry, instead of asking for the password again.
5. **Log out** (`POST /auth/logout`) — revokes the refresh token, so a
   copy of it (leaked, or just left in an old browser tab) can no
   longer be used to mint new access tokens.

### Sessions: access vs. refresh tokens

Two tokens, two different jobs, so a stolen one is less damaging than a
single long-lived credential:

- **Access token** — a signed JWT, 15 minutes by default
  (`ACCESS_TOKEN_TTL_MINUTES`), carrying the user id. Verified
  in-process (`AccessTokenIssuer.verify`, `auth_middleware.dart`) —
  no database round-trip on every request. Short-lived on purpose: if
  one leaks, the exposure window is small.
- **Refresh token** — an opaque, database-backed credential, 30 days by
  default (`REFRESH_TOKEN_TTL_DAYS`). Calling `/auth/refresh`
  *rotates* it: the old one is revoked and a new one issued in the same
  request (`RefreshSessionCommandHandler`), so a refresh token is only
  ever used once. If someone reuses an old (already-rotated) refresh
  token, that's a signal it was stolen — a natural point to add
  "revoke the whole session family" hardening later.

This is a **backend-only** flow so far — see
[frontend-app.md](frontend-app.md#known-gap-no-automatic-token-refresh)
for the client-side gap: the frontend receives and holds a refresh
token but doesn't yet call `/auth/refresh` automatically.

### Browsing the catalog

`GET /items?page=&pageSize=` never returns another user's items — the
query handler (`ListItemsQueryHandler`) is always scoped to the caller
from the access token, not a client-supplied filter, so there's no way
to request someone else's page by tampering with query parameters.
Pagination uses the shared `PageRequest`/`PageResult` contract from
`core` (defaults `page=1`, `pageSize=10`); the response tells the
caller `totalItems`/`totalPages` so a UI can build "page 3 of 12"
controls without a second request.

Fetching, editing, or deleting a *specific* item
(`GET|PATCH|DELETE /items/<id>`) checks `item.isOwnedBy(userId)`
before doing anything else. An id that belongs to someone else comes
back as `404`, identical to an id that doesn't exist at all — the API
never confirms or denies that an item id exists for another account,
which would otherwise leak information about other users' catalogs.

### Why format validation happens twice

`ItemFormatPolicy` (see [core-domain.md](core-domain.md#the-categoryformat-rule))
is checked inside `Item.create`/`Item.update` in the domain — so the
`CreateItemCommandHandler` and `UpdateItemCommandHandler` don't
re-implement the rule, they just let the domain object enforce it and
let the resulting `InvalidFormatForCategoryError` propagate. That's the
hexagonal-architecture point made concrete: the application layer
orchestrates (parse the request, call the domain, map the result), it
doesn't decide.

## Turning a domain error into an HTTP response

Every route runs through `errorMappingMiddleware`
(`shared/http/error_mapping_middleware.dart`), which is the single
place a `DomainError` subtype becomes a status code — handlers never
set status codes themselves:

| Domain error | Status |
|---|---|
| `ItemNotFoundError` | 404 |
| `InvalidCredentialsError`, `InvalidRefreshTokenError` | 401 |
| `EmailAlreadyRegisteredError`, `UsernameAlreadyTakenError` | 409 |
| any other `DomainError` (weak password, invalid category, ...) | 400 |
| anything not a `DomainError` | 500, with the real error kept out of the response |

That last row matters as much as the mapped ones: an unexpected
exception (a bug, a dropped database connection) never leaks internal
detail to a client — the caller only ever sees `{"error": "internal
server error"}`.

## Storage

Postgres, migrated automatically on server startup
(`shared/db/migration_runner.dart` runs everything in
`backend/migrations/` — no separate `migrate` command to remember).
Each aggregate has one repository implementation
(`PostgresItemRepository`, `PostgresUserRepository`,
`PostgresRefreshTokenRepository`) plus an `infrastructure/acl/` mapper
translating rows to/from domain objects, so SQL/column-naming concerns
never leak into `core`.
