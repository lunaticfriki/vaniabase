# Mock API Server

This folder contains a mock API server, seed data, and utilities for managing book covers for development and testing purposes.

## Structure

```
mock/
├── server.ts              # Express server providing REST API
├── update-covers.ts       # Script to fetch book covers from Open Library API
├── fix-missing-covers.ts  # Script to fix remaining missing covers
└── data/
    └── items.seed.json    # 20 mock items following the Item domain model
```

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

1. **🔄 Reload book covers from API**

   - Runs the `update-covers.ts` script to fetch covers from Open Library
   - If some covers are still missing, prompts to run the `fix-missing-covers.ts` script
   - Automatically reloads the seed data after updating

2. **🚀 Start the server**

   - Starts the API server immediately at `http://localhost:3001`
   - Skips any cover updates

3. **📋 List seed elements**

   - Displays all 20 books in the seed with their details:
     - Title, author, year, topic
     - Format, language, completion status
     - Cover URL and status (✓ for Open Library, 📘 for TypeScript logo, ✗ for missing)
     - Tags
   - Shows total count and number of books with Open Library covers
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
    "compeleted": false,
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

## Book Cover Management

### Automatic Cover Updates

The mock server includes utilities to fetch real book covers from the Open Library API:

**update-covers.ts**: Automatically searches for book covers by title and author

- Fetches covers from Open Library Covers API
- Updates the seed file with actual book cover URLs
- Processes all 20 books in the seed data

**fix-missing-covers.ts**: Handles edge cases for books not found in the initial search

- Uses alternative search strategies
- Manually configured for specific difficult-to-find books

### Manual Cover Update

You can also run the cover update scripts manually:

```bash
cd mock
npx tsx update-covers.ts
npx tsx fix-missing-covers.ts
```

## Notes

- This server is for **development/testing only**
- Data is stored in memory and resets on server restart
- The seed data follows the `Item` domain model from `src/domain/item.ts`
- CORS is enabled for all origins
- Book covers are fetched from Open Library (https://covers.openlibrary.org)
