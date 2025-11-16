# Mock API Server (Rust Version)

This is a complete Rust implementation of the mock API server, providing the same REST API endpoints and cover management tools as the TypeScript version.

## Features

- ✅ Full REST API compatible with the TypeScript version
- ✅ CORS enabled for cross-origin requests
- ✅ Interactive menu system
- ✅ **Own copy of `items.seed.json` data file**
- ✅ **Cover update scripts in Rust** (OpenLibrary, RAWG, MusicBrainz APIs)
- ✅ **Fix missing covers script in Rust**
- ✅ UUID generation for new items
- ✅ Health check endpoint

## Prerequisites

- Rust and Cargo (install from https://rustup.rs/)

## Installation & Running

### Build and run

```bash
cd mock-rust
cargo run
```

### Build for release (optimized)

```bash
cargo build --release
./target/release/mock-rust
```

## Interactive Menu

When you start the server, you'll see:

```
╔════════════════════════════════════════╗
║     Mock API Server - Main Menu       ║
╚════════════════════════════════════════╝

Status: ✓ All covers OK

1. 🔄 Update covers from API
2. 🔧 Fix missing covers
3. 🚀 Start the server
4. 📋 List seed elements
5. 🚪 Exit

Select an option (1-5):
```

### Options:

- **Option 1**: Update covers from external APIs (OpenLibrary, RAWG, MusicBrainz)
- **Option 2**: Find and fix broken/missing cover URLs
- **Option 3**: Starts the REST API server on port 3001
- **Option 4**: Lists all items in the seed data with their details
- **Option 5**: Exits the program

## API Endpoints

Once the server is running on `http://localhost:3001`:

| Method | Endpoint         | Description                                  |
| ------ | ---------------- | -------------------------------------------- |
| GET    | `/api/items`     | Get all items                                |
| GET    | `/api/items/:id` | Get a specific item by ID                    |
| POST   | `/api/items`     | Create a new item                            |
| PUT    | `/api/items/:id` | Update an existing item                      |
| DELETE | `/api/items/:id` | Delete an item                               |
| GET    | `/health`        | Health check (returns status and item count) |

## Data Model

```rust
struct Item {
    id: String,
    name: String,
    author: String,
    description: String,
    image_url: String,
    topic: String,
    tags: Vec<String>,
    owner: String,
    completed: bool,
    year: String,
    language: String,
    format: String,
    category: String,
}
```

## Performance

The Rust version offers:

- Faster startup time
- Lower memory footprint
- Better performance under load
- Native async/await with Tokio

## Cover Update Scripts

The Rust version includes native cover update tools that work with multiple APIs:

### Supported APIs

- **Books**: OpenLibrary API (openlibrary.org)
- **Video Games**: RAWG Video Games Database (rawg.io)
- **Music/CDs**: MusicBrainz + Cover Art Archive
- **Comics/Magazines**: Manual URLs (no automatic API)

### Running Scripts Manually

```bash
# Update all covers from APIs
cargo run --bin update-covers

# Or using make
make update-covers

# Fix missing/broken covers
cargo run --bin fix-missing-covers

# Or using make
make fix-covers
```

## Data Management

This version has its **own copy** of the data in `mock-rust/data/items.seed.json`. Changes made here won't affect the TypeScript version and vice versa.

## Differences from TypeScript Version

1. **Cover Update Scripts**: ✅ Now fully implemented in Rust!
2. **Port**: Same port 3001 for compatibility
3. **Data**: Uses its own `data/items.seed.json` file (independent copy)
4. **API**: 100% compatible REST API

## Testing

The project includes **44 comprehensive unit tests** across all modules:

- **10 tests** for the main server API
- **13 tests** for the update-covers script
- **21 tests** for the fix-missing-covers script

```bash
# Run all tests
cargo test

# Run with verbose output
cargo test -- --nocapture

# Run specific test
cargo test test_get_all_items

# Run tests for specific binary
cargo test --bin mock-rust
cargo test --bin update-covers
cargo test --bin fix-missing-covers

# Run tests in watch mode
cargo watch -x test
```

**Test Results:**

```
Running unittests src/fix_missing_covers.rs
running 21 tests
test result: ok. 21 passed; 0 failed

Running unittests src/main.rs
running 10 tests
test result: ok. 10 passed; 0 failed

Running unittests src/update_covers.rs
running 13 tests
test result: ok. 13 passed; 0 failed

Total: ✅ 44 tests passed
```

See [TESTING.md](TESTING.md) for detailed testing documentation.

## Development

### Watch mode (auto-rebuild on changes)

Install cargo-watch:

```bash
cargo install cargo-watch
```

Then run:

```bash
cargo watch -x run

# Or run tests on file changes
cargo watch -x test
```

## Troubleshooting

### "Failed to read items.seed.json"

Make sure you're running from the `mock-rust` directory and that the `mock/data/items.seed.json` file exists in the parent directory.

### Port already in use

If port 3001 is already in use, you'll need to stop the other server first or modify the port in `src/main.rs`.

## Tech Stack

- **Actix-web**: Fast, pragmatic web framework
- **Serde**: Serialization/deserialization
- **Tokio**: Async runtime
- **UUID**: Unique identifier generation
