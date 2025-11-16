# Mock API Server

This folder contains a mock API server and seed data for development and testing purposes.

## Structure

```
mock/
├── server.js           # Express server providing REST API
└── data/
    └── items.seed.json # 20 mock items following the Item domain model
```

## Usage

### Start the mock server

```bash
pnpm mock:server
```

The server will start at `http://localhost:3001`

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

## Notes

- This server is for **development/testing only**
- Data is stored in memory and resets on server restart
- The seed data follows the `Item` domain model from `src/domain/item.ts`
- CORS is enabled for all origins
