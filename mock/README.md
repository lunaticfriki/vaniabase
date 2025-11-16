# Mock API Server

This folder contains a mock API server, seed data, and utilities for managing item covers for development and testing purposes.

## Structure

```
mock/
├── server.ts              # Express server providing REST API
├── server.test.ts         # Comprehensive test suite for the API
├── update-covers.ts       # Script to fetch covers from multiple APIs based on category
├── fix-missing-covers.ts  # Script to fix remaining missing covers
├── TEST_README.md         # Detailed testing documentation
└── data/
    └── items.seed.json    # Mock items following the Item domain model
```

## Cover APIs Support

The scripts now support multiple media types with appropriate APIs:

- **Books**: Open Library API (`openlibrary.org`)
- **Video Games**: RAWG Video Games Database API (`rawg.io`)
- **Music/CDs**: MusicBrainz + Cover Art Archive APIs
- **Comics/Magazines**: Manual URLs (no automatic API yet)

## Usage

### Start the mock server

```bash
pnpm mock:server
```

When starting the server, you'll see an interactive menu with the following options:

#### Interactive Menu

```
╔════════════════════════════════════════╗
║     Mock API Server - Main Menu       ║
╚════════════════════════════════════════╝

Status: ✓ All covers OK

1. 🔄 Reload book covers from API
2. 🚀 Start the server
3. 📋 List seed elements
4. 🚪 Exit

Select an option (1-4):
```

**Menu Options:**

1. **🔄 Reload covers from APIs**

   - Runs the `update-covers.ts` script to fetch covers from appropriate APIs based on item category
   - Supports books (Open Library), games (RAWG), and music (MusicBrainz/Cover Art Archive)
   - If some covers are still missing, prompts to run the `fix-missing-covers.ts` script
   - Automatically reloads the seed data after updating

2. **🚀 Start the server**

   - Starts the API server immediately at `http://localhost:3001`
   - Skips any cover updates

3. **📋 List seed elements**

   - Displays all items in the seed with their details:
     - Title, author, year, topic, category
     - Format, language, completion status
     - Cover URL and status (✓ for valid API cover, ✗ for missing)
     - Tags
   - Shows total count and number of items with valid covers
   - Returns to the menu after displaying

4. **🚪 Exit**
   - Closes the application without starting the server

### Available Endpoints

- `GET /api/items` - Get all items
- `GET /api/items/:id` - Get a specific item by ID
- `POST /api/items` - Create a new item
- `PUT /api/items/:id` - Update an item
- `DELETE /api/items/:id` - Delete an item
- `GET /health` - Health check endpoint

### Example Usage

```bash
# Get all items
curl http://localhost:3001/api/items

# Get a specific item
curl http://localhost:3001/api/items/1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p

# Create a new item
curl -X POST http://localhost:3001/api/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Book",
    "author": "John Doe",
    "description": "A great book",
    "imageUrl": "https://example.com/image.jpg",
    "topic": "Technology",
    "tags": ["tech"],
    "owner": "user123",
    "completed": false,
    "year": "2024",
    "language": "English",
    "format": "Book"
  }'
```

## Integration with Frontend

In your infrastructure layer, you can create an HTTP client that points to this mock server:

```typescript
const BASE_URL = 'http://localhost:3001/api';

export async function fetchItems(): Promise<Item[]> {
  const response = await fetch(`${BASE_URL}/items`);
  return response.json();
}
```

## Cover Management

### Automatic Cover Updates

The mock server includes utilities to fetch real covers from multiple APIs based on item category:

**update-covers.ts**: Automatically searches for covers by category

- **Books**: Fetches from Open Library API (by title and author)
- **Video Games**: Fetches from RAWG API (by game title)
- **Music/CDs**: Fetches from MusicBrainz + Cover Art Archive (by album and artist)
- **Comics/Magazines**: Keeps existing URLs (no automatic API)
- Updates the seed file with actual cover URLs
- Processes all items in the seed data

**fix-missing-covers.ts**: Handles edge cases for items not found in the initial search

- Checks all image URLs for validity
- Automatically attempts to fix broken covers using category-specific APIs
- Includes manual fixes for specific difficult-to-find items
- Reports summary of broken vs. valid covers

### Manual Cover Update

You can also run the cover update scripts manually:

```bash
cd mock
npx tsx update-covers.ts      # Update all covers from APIs
npx tsx fix-missing-covers.ts # Fix remaining broken/missing covers
```

## Testing

The mock server includes a comprehensive test suite covering all API endpoints and functionality.

### Running Tests

1. **Start the mock server** in a terminal:

   ```bash
   pnpm mock:server
   # Select option 2 to start the server
   ```

2. **Run tests** in another terminal:

   ```bash
   # Run tests once
   pnpm test:mock

   # Run tests in watch mode
   pnpm test:mock:watch

   # Run with coverage
   pnpm test:mock:coverage
   ```

### Test Coverage

The test suite includes:

- ✅ Health check endpoint
- ✅ GET all items
- ✅ GET item by ID (with 404 handling)
- ✅ POST create new items
- ✅ PUT update items (full and partial updates)
- ✅ DELETE items with proper cleanup
- ✅ CORS headers validation
- ✅ Content-Type validation
- ✅ Item categories handling
- ✅ Completion status toggling
- ✅ Tags management

For detailed testing documentation, see [TEST_README.md](./TEST_README.md).

## Notes

- This server is for **development/testing only**
- Data is stored in memory and resets on server restart
- The seed data follows the `Item` domain model from `src/domain/item.ts`
- CORS is enabled for all origins
- Book covers are fetched from Open Library (https://covers.openlibrary.org)
- Test suite automatically backs up and restores seed data
