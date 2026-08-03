# vaniabase

A personal catalog: one private place to track the books, comics,
magazines, movies, video games, and music you own or want to keep tabs
on, instead of splitting that across five different apps or a
spreadsheet. Each account's catalog is its own — there's no shared or
public browsing.

A Dart/Flutter monorepo, built as a reference implementation of a
specific architecture (Domain-Driven Design + Hexagonal Architecture +
CQRS + Vertical Slicing) as much as it is an app — see
[`docs/`](docs/) for both.

## Layout

| Package | What it is |
|---|---|
| [`core/`](core/) | Plain Dart domain layer — entities, value objects, business rules. No Flutter, no HTTP, no database. Shared by `backend` and `frontend`. |
| [`backend/`](backend/) | Dart HTTP API — auth (register/login/refresh/logout) and catalog CRUD, backed by Postgres. |
| [`frontend/`](frontend/) | Flutter web app — the UI. |
| [`docs/`](docs/) | Architecture standard (portable, numbered `01-...` files) plus vaniabase-specific docs (business + technical, one per package above). |

## Quickstart

Everything (Postgres + backend + frontend) is orchestrated by the root
`docker-compose.yml`:

```bash
cp .env.example .env   # then edit JWT_SECRET before deploying anywhere real
docker compose up --build
```

- Frontend: `http://localhost:8081`
- Backend API: `http://localhost:8080` (Swagger UI at `/docs`)

For local development without Docker (hot reload, debugging), or a
full API reference with `curl` examples, see
[`backend/README.md`](backend/README.md). The short version, using the
`Makefile`:

```bash
make install   # pub get for all three packages
make db        # Postgres only, via Docker
make dev       # backend + frontend, both with hot reload
make test      # all three packages
```

Run `make help` for the full target list.

## Where to go next

- **What the app does, and why it's built the way it is** —
  [`docs/core-domain.md`](docs/core-domain.md) (the domain model),
  [`docs/backend-api.md`](docs/backend-api.md) (the API and its
  flows), [`docs/frontend-app.md`](docs/frontend-app.md) (the UI and
  user journey).
- **The architecture standard itself** — [`docs/README.md`](docs/README.md),
  written to be copied into other projects as-is.
- **API details and `curl` examples** — [`backend/README.md`](backend/README.md).
