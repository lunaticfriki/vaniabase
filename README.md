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
| [`frontend/`](frontend/) | Flutter app (web, macOS, iOS, Android) — the UI, backed directly by Firebase Auth and Cloud Firestore. |
| [`docs/`](docs/) | Architecture standard (portable, numbered `01-...` files) plus vaniabase-specific docs (business + technical, one per package above). |

## Quickstart

There's no backend to stand up — the frontend talks to Firebase
directly.

1. Create a Firebase project (console.firebase.google.com), enable
   **Authentication** (Email/Password provider) and **Cloud Firestore**.
   Register an app per platform you want to run (Web, Android, iOS — macOS
   reuses the iOS app since they share a bundle ID) via `flutterfire
   configure`, or add them by hand in the console.
2. `cp frontend/.env.example frontend/.env`, then fill it in with each
   registered app's config (Firebase console → Project settings → General
   → Your apps → pick the app → SDK setup and configuration): the
   unsuffixed `FIREBASE_*` keys are the web app, `_ANDROID`/`_IOS` keys
   are the respective native apps. `frontend/.env` is gitignored — real
   credentials never get committed; `frontend/lib/firebase_options.dart`
   just reads them at runtime via `flutter_dotenv`.
3. Deploy the security rules/indexes at the repo root (`firestore.rules`,
   `firestore.indexes.json`) with `firebase deploy --only
   firestore:rules,firestore:indexes`, or paste `firestore.rules` into
   the console's Rules editor.
4. `make install && make frontend` — pub get, then the Flutter app on
   macOS desktop with hot reload (`make frontend-web` runs it in Chrome
   instead).

Run `make help` for the full target list.

### Supported platforms

| Platform | Status | Notes |
|---|---|---|
| Web | Supported | `make frontend-web`, or `docker compose up` (serves the release build via nginx). |
| macOS desktop | Supported | `make frontend` (default). Deployment target 10.15+. Needs Xcode + CocoaPods locally. |
| iOS | Supported | `flutter run -d <device>` from `frontend/`. Deployment target 15.0+ (required by the Firebase SDKs). Needs Xcode + CocoaPods. |
| Android | Supported | `flutter run -d <device>` from `frontend/`. minSdk 24, targetSdk/compileSdk 36. Needs Android Studio + the Android SDK installed locally. |
| Windows / Linux desktop | Not supported | Firebase's Flutter plugins (`firebase_core`/`auth`/`firestore`/`storage`) and `image_picker` don't target these platforms. |

Flutter 3.44.7 / Dart SDK `^3.12.2` (`frontend/pubspec.yaml`), pinned to
match what the Docker build image installs.

## Where to go next

- **What the app does, and why it's built the way it is** —
  [`docs/core-domain.md`](docs/core-domain.md) (the domain model),
  [`docs/frontend-app.md`](docs/frontend-app.md) (the UI, Firebase
  wiring, and user journey).
- **The architecture standard itself** — [`docs/README.md`](docs/README.md),
  written to be copied into other projects as-is.
