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
| [`core/`](core/) | Plain Dart domain layer — entities, value objects, business rules. No Flutter, no HTTP, no database. Shared by `frontend`. |
| [`frontend/`](frontend/) | Flutter web app — the UI, backed directly by Firebase Auth and Cloud Firestore. |
| [`docs/`](docs/) | Architecture standard (portable, numbered `01-...` files) plus vaniabase-specific docs (business + technical, one per package above). |

## Quickstart

There's no backend to stand up — the frontend talks to Firebase
directly.

1. Create a Firebase project (console.firebase.google.com), enable
   **Authentication** (Email/Password provider) and **Cloud Firestore**.
2. `cp frontend/.env.example frontend/.env`, then fill it in with your
   project's web config (Firebase console → Project settings → General →
   Your apps → Web app → SDK setup and configuration).
   `frontend/.env` is gitignored — real credentials never get committed;
   `frontend/lib/firebase_options.dart` just reads them at runtime via
   `flutter_dotenv`.
3. Deploy the security rules/indexes at the repo root (`firestore.rules`,
   `firestore.indexes.json`) with `firebase deploy --only
   firestore:rules,firestore:indexes`, or paste `firestore.rules` into
   the console's Rules editor.
4. `make install && make frontend` — pub get, then the Flutter web app
   with hot reload.

Run `make help` for the full target list.

## Where to go next

- **What the app does, and why it's built the way it is** —
  [`docs/core-domain.md`](docs/core-domain.md) (the domain model),
  [`docs/frontend-app.md`](docs/frontend-app.md) (the UI, Firebase
  wiring, and user journey).
- **The architecture standard itself** — [`docs/README.md`](docs/README.md),
  written to be copied into other projects as-is.
