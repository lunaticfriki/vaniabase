# vaniabase backend

Dart HTTP API for vaniabase: user registration/authentication and a
per-user item catalog CRUD. Only the domain layer (entities, value
objects, repository ports) lives in the sibling `core` package (a path
dependency, shared with `frontend`); this package owns its own
application layer (CQRS command/query handlers), infrastructure
(Postgres, bcrypt, JWT), and the HTTP layer — see
[`docs/06-vertical-slicing.md`](../docs/06-vertical-slicing.md#the-corebackendfrontend-split)
for why application isn't shared with `frontend` too.

## Run with Docker (recommended)

Everything (Postgres + the backend) is orchestrated by the
`docker-compose.yml` at the **repo root** — run these commands from
there, not from `backend/`.

```bash
# from the repo root
cp .env.example .env   # then edit JWT_SECRET before deploying anywhere real
docker compose up --build
```

The API is now listening on `http://localhost:8080`. Database schema
migrations run automatically on backend startup — no separate migrate
step.

Useful commands (also from the repo root):

```bash
docker compose logs -f backend   # tail backend logs
docker compose ps                # check container status
docker compose down              # stop everything
docker compose down -v           # stop and also wipe the Postgres volume
```

### Environment variables

Set in `.env` (repo root) or directly in `docker-compose.yml`:

| Variable | Default | Purpose |
|---|---|---|
| `DB_PASSWORD` | `vaniabase` | Postgres password (also used by the `postgres` service itself) |
| `JWT_SECRET` | `dev-secret-change-me` | Signs access tokens — set a real secret outside local dev |
| `ACCESS_TOKEN_TTL_MINUTES` | `15` | Access token lifetime |
| `REFRESH_TOKEN_TTL_DAYS` | `30` | Refresh token lifetime |

`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `PORT` are fixed by
`docker-compose.yml` for the containerized setup and don't need to be set
manually there.

## Run locally without Docker

Needs the Dart SDK and a running Postgres.

```bash
# start a local Postgres (or point at one you already have)
docker run -d --name vaniabase-postgres -p 5432:5432 \
  -e POSTGRES_USER=vaniabase -e POSTGRES_PASSWORD=vaniabase -e POSTGRES_DB=vaniabase \
  postgres:16-alpine

cd backend
dart pub get

DB_HOST=localhost DB_PORT=5432 DB_NAME=vaniabase DB_USER=vaniabase DB_PASSWORD=vaniabase \
JWT_SECRET=dev-secret \
dart run bin/server.dart
```

Migrations run automatically on startup here too. The server reads
`migrations/` relative to its working directory, so run `dart run
bin/server.dart` from inside `backend/`.

## Smoke-testing the API

```bash
BASE=http://localhost:8080

curl -X POST $BASE/auth/register -H 'content-type: application/json' \
  -d '{"email":"jane@example.com","username":"jane_doe","password":"password123"}'

curl -X POST $BASE/auth/login -H 'content-type: application/json' \
  -d '{"email":"jane@example.com","password":"password123"}'
# -> {"accessToken": "...", "refreshToken": "...", "accessTokenExpiresAt": "..."}
```

Use the `accessToken` as a Bearer token for every `/items` request:

```bash
curl -X POST $BASE/items -H "authorization: Bearer <accessToken>" \
  -H 'content-type: application/json' \
  -d '{"title":"Dune","creator":["Frank Herbert"],"publisher":"Chilton Books","category":"book","format":"hardcover","year":1965}'

curl "$BASE/items?page=1&pageSize=10" -H "authorization: Bearer <accessToken>"
curl $BASE/items/<id> -H "authorization: Bearer <accessToken>"
curl -X PATCH $BASE/items/<id> -H "authorization: Bearer <accessToken>" \
  -H 'content-type: application/json' -d '{"title":"New Title"}'
curl -X DELETE $BASE/items/<id> -H "authorization: Bearer <accessToken>"
```

Refresh the session (rotates the refresh token — the old one stops
working) and log out:

```bash
curl -X POST $BASE/auth/refresh -H 'content-type: application/json' \
  -d '{"refreshToken":"<refreshToken>"}'

curl -X POST $BASE/auth/logout -H 'content-type: application/json' \
  -d '{"refreshToken":"<refreshToken>"}'
```

## API reference

| Method | Path | Auth | Body |
|---|---|---|---|
| POST | `/auth/register` | — | `email`, `username`, `password` |
| POST | `/auth/login` | — | `email`, `password` |
| POST | `/auth/refresh` | — | `refreshToken` |
| POST | `/auth/logout` | — | `refreshToken` |
| POST | `/items` | Bearer | `title`, `creator[]`, `publisher`, `category`, `format`, plus optional `tags[]`, `topic`, `year`, `description`, `language`, `imageUrl` |
| GET | `/items?page=&pageSize=` | Bearer | — (defaults: `page=1`, `pageSize=10`); response is `{items, page, pageSize, totalItems, totalPages}` |
| GET | `/items/<id>` | Bearer | — |
| PATCH | `/items/<id>` | Bearer | any subset of the create fields |
| DELETE | `/items/<id>` | Bearer | — |

`category` is one of `book`, `comic`, `magazine`, `movie`, `videogame`,
`musicAlbum`. `format` must be valid for the chosen `category` (e.g.
`vinyl` only for `musicAlbum`) or the request fails with `400`.

The catalog is private per user: `/items` endpoints only ever see the
authenticated caller's own items — an item id that exists but belongs to
someone else returns `404`, the same as one that doesn't exist at all.

Error responses are `{"error": "<message>"}` with the status code
reflecting the failure: `400` invalid input, `401` missing/invalid/expired
token or bad login credentials, `404` not found (or not yours), `409`
duplicate email/username.

## Tests

`core`'s domain suite needs nothing:

```bash
cd ../core && dart test
```

This package's suite mixes two kinds of tests in `test/`: application-layer
tests (command/query handlers, mocktail-mocked ports — no external
dependency) and infrastructure tests (the Postgres repositories, run
against a real database). Since they share one `test/` tree, a plain
`dart test` here needs Postgres reachable via the `DB_*` env vars for
*all* of it to pass:

```bash
docker run -d --name vaniabase-test-postgres -p 5433:5432 \
  -e POSTGRES_USER=vaniabase -e POSTGRES_PASSWORD=vaniabase -e POSTGRES_DB=vaniabase \
  postgres:16-alpine

DB_HOST=localhost DB_PORT=5433 DB_NAME=vaniabase DB_USER=vaniabase DB_PASSWORD=vaniabase \
dart run tool/run_migrations.dart

DB_HOST=localhost DB_PORT=5433 DB_NAME=vaniabase DB_USER=vaniabase DB_PASSWORD=vaniabase \
dart test
```

To run just the fast, dependency-free parts (application-layer handlers,
`BcryptPasswordHasher`, `JwtAccessTokenIssuer`) without a database, point
`dart test` at those specific folders instead of the whole `test/` tree —
anything under `test/modules/*/infrastructure/postgres_*_test.dart` needs
Postgres.

`dart analyze` runs cleanly in both packages with no external dependencies
needed.
