# `core` — the domain

`core` is a plain Dart package with no Flutter, no HTTP, no database
driver — just the two bounded contexts that define what vaniabase *is*,
independent of how it's shown (`frontend`). `frontend` depends on it; it
depends on nothing project-specific.

For the architectural rules this package follows (entities, value
objects, private constructors, ports), see
[01-domain-layer.md](01-domain-layer.md). This document is about what's
actually modeled and why, not how DDD is applied mechanically.

## Catalog — what vaniabase is for

The pitch: **one private place to track everything you own or want to
track** — books, comics, magazines, movies, video games, and music
albums — instead of splitting that across five different apps (or a
spreadsheet).

An **Item** (`modules/catalog/domain/entities/item.dart`) is one entry in
that catalog. Every item belongs to exactly one owner (`ownerId`) — there
is no shared or public catalog, no browsing other users' collections.
Fields:

| Field | Required | Meaning |
|---|---|---|
| `title` | yes | What it's called |
| `creator` | yes | Author(s)/director(s)/artist(s) — a list, so co-authored works aren't forced into one string |
| `publisher` | yes | Who put it out |
| `category` | yes | `book`, `comic`, `magazine`, `movie`, `videogame`, or `musicAlbum` |
| `format` | yes | The physical/digital shape it's in — see below |
| `tags` | no | Freeform labels, for the user's own filtering/organizing |
| `topic` | no | Subject matter, distinct from tags (e.g. "cooking" vs. a personal tag like "to re-read") |
| `year` | no | Publication year |
| `description` | no | Free text |
| `language` | no | — |
| `imageUrl` | no | Cover art |

### The category/format rule

Not every format makes sense for every category — a `musicAlbum` can't
be a `paperback`, a `book` can't be `vinyl`. This is enforced by
`ItemFormatPolicy`
(`modules/catalog/domain/services/item_format_policy.dart`), a domain
service (it's a rule about the relationship between two value objects,
not something either owns alone):

| Category | Allowed formats |
|---|---|
| `book` | `hardcover`, `paperback`, `ebook` |
| `comic` | `hardcover`, `paperback`, `ebook` |
| `magazine` | `paperback`, `digitalDownload` |
| `movie` | `dvd`, `bluRay`, `digitalDownload` |
| `videogame` | `cartridge`, `dvd`, `bluRay`, `digitalDownload` |
| `musicAlbum` | `cd`, `vinyl`, `digitalDownload` |

`Item.create` and `Item.update` both check this policy and throw
`InvalidFormatForCategoryError` if it's violated — so an invalid
category/format pairing can never exist in the system, not even
transiently, regardless of which layer is constructing the item.

An item can only ever be read, edited, or deleted by the user who owns
it. In the current Firebase-backed setup this is enforced by
`firestore.rules` at the data layer (`request.auth.uid ==
resource.data.ownerId`) rather than by `Item.isOwnedBy(userId)` — see
[frontend-app.md](frontend-app.md) for how the frontend talks to
Firestore.

## Identity — accounts and sessions

The second bounded context: registering an account and proving who you
are on each request. Authentication itself is now handled by Firebase
Auth directly from `frontend` (see
[frontend-app.md](frontend-app.md)) rather than by a backend built on
this domain model, so the entities below currently describe the
identity rules as modeled in `core` without a consuming
application/infrastructure layer. Two entities:

**User** (`modules/identity/domain/entities/user.dart`) — an email,
a username, and a password hash. Business rules live in the value
objects, not scattered across handlers:

- **Email** — normalized (trimmed, lower-cased) on creation, must look
  like an email. Normalizing here means `Jane@Example.com` and
  `jane@example.com` are the same account — one less way to
  accidentally allow duplicate signups.
- **Username** — 3-30 characters, letters/digits/underscore only.
- **Password** — 8-128 characters, at least one letter and one digit.
  The domain only ever sees the raw password long enough to validate
  its shape; hashing would happen in an infrastructure adapter (e.g. a
  `PasswordHasher` implementation) — `PasswordHash` is what actually
  gets stored and compared. Firebase Auth handles this itself for the
  credentials it manages.

Both email and username are unique account-wide — registering with one
already taken fails with `EmailAlreadyRegisteredError` /
`UsernameAlreadyTakenError` rather than silently overwriting anything.

**RefreshToken** (`modules/identity/domain/entities/refresh_token.dart`)
— models a long-lived credential issued alongside a short-lived access
token at login, so an app wouldn't need to ask for a password again every
15 minutes. It knows its own validity: `isExpired` (past `expiresAt`),
`isRevoked` (explicitly logged out via `revoke()`), and `isValid`
(neither). Firebase Auth manages its own token refresh under the hood, so
`frontend` doesn't currently construct this entity — it's kept here as
domain modeling for a self-issued session, should the project ever need
one again.

## Shared building blocks

`shared/` holds the handful of concepts that don't belong to either
bounded context: `Timestamp` and `DomainNumber` (base value-object
patterns other value objects build on), `PageRequest`/`PageResult` (the
offset-based pagination contract `frontend`'s catalog list query uses —
see [frontend-app.md](frontend-app.md)), and `DomainError`/`DomainWarning`,
the base types every business-rule violation in this document
(`WeakPasswordError`, `InvalidFormatForCategoryError`,
`ItemNotFoundError`, ...) extends — see
[01-domain-layer.md](01-domain-layer.md#domain-errors-and-warnings-live-in-the-domain-not-the-application-layer).
