import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const BASE_URL = 'http://localhost:3001';

interface Item {
  id: string;
  name: string;
  author: string;
  description: string;
  imageUrl: string;
  topic: string;
  tags: string[];
  owner: string;
  completed: boolean;
  year: string;
  language: string;
  format: string;
  category: string;
}

// Helper function to make HTTP requests
async function request(
  method: string,
  path: string,
  body?: unknown
): Promise<Response> {
  const options: RequestInit = {
    method,
    headers: {
      'Content-Type': 'application/json',
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  return fetch(`${BASE_URL}${path}`, options);
}

// Backup seed data before tests
let originalSeedData: string;

beforeAll(() => {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  originalSeedData = readFileSync(seedPath, 'utf-8');
});

afterAll(() => {
  // Restore original seed data
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  writeFileSync(seedPath, originalSeedData, 'utf-8');
});

describe('Mock API Server', () => {
  describe('Health Check', () => {
    it('should return health status', async () => {
      const response = await request('GET', '/health');
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data).toHaveProperty('status', 'ok');
      expect(data).toHaveProperty('items');
      expect(typeof data.items).toBe('number');
    });
  });

  describe('GET /api/items', () => {
    it('should return all items', async () => {
      const response = await request('GET', '/api/items');
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(Array.isArray(data)).toBe(true);
      expect(data.length).toBeGreaterThan(0);
    });

    it('should return items with correct structure', async () => {
      const response = await request('GET', '/api/items');
      const data = await response.json();

      const item = data[0];
      expect(item).toHaveProperty('id');
      expect(item).toHaveProperty('name');
      expect(item).toHaveProperty('author');
      expect(item).toHaveProperty('description');
      expect(item).toHaveProperty('imageUrl');
      expect(item).toHaveProperty('topic');
      expect(item).toHaveProperty('tags');
      expect(item).toHaveProperty('owner');
      expect(item).toHaveProperty('completed');
      expect(item).toHaveProperty('year');
      expect(item).toHaveProperty('language');
      expect(item).toHaveProperty('format');
      expect(item).toHaveProperty('category');
    });

    it('should return items with valid types', async () => {
      const response = await request('GET', '/api/items');
      const data = await response.json();

      const item = data[0];
      expect(typeof item.id).toBe('string');
      expect(typeof item.name).toBe('string');
      expect(typeof item.author).toBe('string');
      expect(typeof item.description).toBe('string');
      expect(typeof item.imageUrl).toBe('string');
      expect(typeof item.topic).toBe('string');
      expect(Array.isArray(item.tags)).toBe(true);
      expect(typeof item.owner).toBe('string');
      expect(typeof item.completed).toBe('boolean');
      expect(typeof item.year).toBe('string');
      expect(typeof item.language).toBe('string');
      expect(typeof item.format).toBe('string');
      expect(typeof item.category).toBe('string');
    });
  });

  describe('GET /api/items/:id', () => {
    let testItemId: string;

    beforeEach(async () => {
      // Get a valid item ID
      const response = await request('GET', '/api/items');
      const data = await response.json();
      testItemId = data[0].id;
    });

    it('should return a specific item by id', async () => {
      const response = await request('GET', `/api/items/${testItemId}`);
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.id).toBe(testItemId);
      expect(data).toHaveProperty('name');
      expect(data).toHaveProperty('author');
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request('GET', '/api/items/non-existent-id-12345');
      const data = await response.json();

      expect(response.status).toBe(404);
      expect(data).toHaveProperty('error', 'Item not found');
    });
  });

  describe('POST /api/items', () => {
    it('should create a new item', async () => {
      const newItem = {
        name: 'Test Book',
        author: 'Test Author',
        description: 'A test book for unit testing',
        imageUrl: 'https://example.com/test-cover.jpg',
        topic: 'Testing',
        tags: ['test', 'unit-test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);
      const data = await response.json();

      expect(response.status).toBe(201);
      expect(data).toHaveProperty('id');
      expect(data.name).toBe(newItem.name);
      expect(data.author).toBe(newItem.author);
      expect(data.description).toBe(newItem.description);
      expect(data.completed).toBe(newItem.completed);
    });

    it('should generate a unique id for new item', async () => {
      const newItem = {
        name: 'Another Test Book',
        author: 'Another Author',
        description: 'Another test',
        imageUrl: 'https://example.com/test2.jpg',
        topic: 'Testing',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);
      const data = await response.json();

      expect(data.id).toBeDefined();
      expect(data.id.length).toBeGreaterThan(0);
      expect(typeof data.id).toBe('string');
    });

    it('should persist the new item', async () => {
      const newItem = {
        name: 'Persistence Test Book',
        author: 'Persistence Author',
        description: 'Testing persistence',
        imageUrl: 'https://example.com/persist.jpg',
        topic: 'Persistence',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const createResponse = await request('POST', '/api/items', newItem);
      const createdItem = await createResponse.json();

      const getResponse = await request('GET', `/api/items/${createdItem.id}`);
      const retrievedItem = await getResponse.json();

      expect(retrievedItem.id).toBe(createdItem.id);
      expect(retrievedItem.name).toBe(newItem.name);
    });
  });

  describe('PUT /api/items/:id', () => {
    let testItemId: string;

    beforeEach(async () => {
      // Create a test item
      const newItem = {
        name: 'Original Name',
        author: 'Original Author',
        description: 'Original description',
        imageUrl: 'https://example.com/original.jpg',
        topic: 'Testing',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);
      const data = await response.json();
      testItemId = data.id;
    });

    it('should update an existing item', async () => {
      const updates = {
        name: 'Updated Name',
        author: 'Updated Author',
      };

      const response = await request(
        'PUT',
        `/api/items/${testItemId}`,
        updates
      );
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.id).toBe(testItemId);
      expect(data.name).toBe(updates.name);
      expect(data.author).toBe(updates.author);
    });

    it('should partially update an item', async () => {
      const updates = {
        completed: true,
      };

      const response = await request(
        'PUT',
        `/api/items/${testItemId}`,
        updates
      );
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.id).toBe(testItemId);
      expect(data.completed).toBe(true);
      expect(data.name).toBe('Original Name'); // Other fields unchanged
    });

    it('should return 404 when updating non-existent item', async () => {
      const updates = {
        name: 'Updated Name',
      };

      const response = await request(
        'PUT',
        '/api/items/non-existent-id-12345',
        updates
      );
      const data = await response.json();

      expect(response.status).toBe(404);
      expect(data).toHaveProperty('error', 'Item not found');
    });

    it('should persist updates', async () => {
      const updates = {
        name: 'Persisted Update',
      };

      await request('PUT', `/api/items/${testItemId}`, updates);
      const getResponse = await request('GET', `/api/items/${testItemId}`);
      const updatedItem = await getResponse.json();

      expect(updatedItem.name).toBe(updates.name);
    });
  });

  describe('DELETE /api/items/:id', () => {
    let testItemId: string;

    beforeEach(async () => {
      // Create a test item to delete
      const newItem = {
        name: 'To Be Deleted',
        author: 'Delete Author',
        description: 'This will be deleted',
        imageUrl: 'https://example.com/delete.jpg',
        topic: 'Testing',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);
      const data = await response.json();
      testItemId = data.id;
    });

    it('should delete an existing item', async () => {
      const response = await request('DELETE', `/api/items/${testItemId}`);

      expect(response.status).toBe(204);
    });

    it('should return 404 when deleting non-existent item', async () => {
      const response = await request(
        'DELETE',
        '/api/items/non-existent-id-12345'
      );
      const data = await response.json();

      expect(response.status).toBe(404);
      expect(data).toHaveProperty('error', 'Item not found');
    });

    it('should actually remove the item from the collection', async () => {
      await request('DELETE', `/api/items/${testItemId}`);

      const getResponse = await request('GET', `/api/items/${testItemId}`);
      expect(getResponse.status).toBe(404);
    });

    it('should reduce the total item count', async () => {
      const initialResponse = await request('GET', '/health');
      const initialData = await initialResponse.json();
      const initialCount = initialData.items;

      await request('DELETE', `/api/items/${testItemId}`);

      const finalResponse = await request('GET', '/health');
      const finalData = await finalResponse.json();
      const finalCount = finalData.items;

      expect(finalCount).toBe(initialCount - 1);
    });
  });

  describe('CORS', () => {
    it('should include CORS headers', async () => {
      const response = await request('GET', '/api/items');

      expect(response.headers.has('access-control-allow-origin')).toBe(true);
    });
  });

  describe('Content-Type', () => {
    it('should return JSON content type for GET /api/items', async () => {
      const response = await request('GET', '/api/items');

      expect(response.headers.get('content-type')).toContain(
        'application/json'
      );
    });

    it('should return JSON content type for POST /api/items', async () => {
      const newItem = {
        name: 'Content Type Test',
        author: 'Test Author',
        description: 'Testing content type',
        imageUrl: 'https://example.com/test.jpg',
        topic: 'Testing',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);

      expect(response.headers.get('content-type')).toContain(
        'application/json'
      );
    });
  });

  describe('Item Categories', () => {
    it('should handle book category items', async () => {
      const response = await request('GET', '/api/items');
      const data = (await response.json()) as Item[];

      const books = data.filter((item: Item) => item.category === 'book');
      expect(books.length).toBeGreaterThan(0);
    });

    it('should handle multiple categories', async () => {
      const response = await request('GET', '/api/items');
      const data = (await response.json()) as Item[];

      const categories = new Set(data.map((item: Item) => item.category));
      expect(categories.size).toBeGreaterThan(0);
    });
  });

  describe('Item Completion Status', () => {
    let testItemId: string;

    beforeEach(async () => {
      const newItem = {
        name: 'Completion Test',
        author: 'Test Author',
        description: 'Testing completion',
        imageUrl: 'https://example.com/test.jpg',
        topic: 'Testing',
        tags: ['test'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const response = await request('POST', '/api/items', newItem);
      const data = await response.json();
      testItemId = data.id;
    });

    it('should toggle completion status from false to true', async () => {
      const updates = { completed: true };
      const response = await request(
        'PUT',
        `/api/items/${testItemId}`,
        updates
      );
      const data = await response.json();

      expect(data.completed).toBe(true);
    });

    it('should toggle completion status from true to false', async () => {
      // First set to true
      await request('PUT', `/api/items/${testItemId}`, { completed: true });

      // Then toggle back to false
      const response = await request('PUT', `/api/items/${testItemId}`, {
        completed: false,
      });
      const data = await response.json();

      expect(data.completed).toBe(false);
    });
  });

  describe('Item Tags', () => {
    it('should handle items with tags', async () => {
      const response = await request('GET', '/api/items');
      const data = (await response.json()) as Item[];

      data.forEach((item: Item) => {
        expect(Array.isArray(item.tags)).toBe(true);
      });
    });

    it('should allow updating tags', async () => {
      const newItem = {
        name: 'Tag Test',
        author: 'Test Author',
        description: 'Testing tags',
        imageUrl: 'https://example.com/test.jpg',
        topic: 'Testing',
        tags: ['original', 'tag'],
        owner: 'test-owner',
        completed: false,
        year: '2024',
        language: 'English',
        format: 'PDF',
        category: 'book',
      };

      const createResponse = await request('POST', '/api/items', newItem);
      const createdItem = await createResponse.json();

      const newTags = ['updated', 'tag', 'list'];
      const updateResponse = await request(
        'PUT',
        `/api/items/${createdItem.id}`,
        { tags: newTags }
      );
      const updatedItem = await updateResponse.json();

      expect(updatedItem.tags).toEqual(newTags);
    });
  });
});
