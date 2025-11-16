import express from 'express';
import cors from 'cors';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Load seed data
const itemsData = JSON.parse(
  readFileSync(join(__dirname, 'data', 'items.seed.json'), 'utf-8')
);

// Routes
app.get('/api/items', (req, res) => {
  res.json(itemsData);
});

app.get('/api/items/:id', (req, res) => {
  const item = itemsData.find((item) => item.id === req.params.id);

  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }

  res.json(item);
});

app.post('/api/items', (req, res) => {
  const newItem = {
    id: crypto.randomUUID(),
    ...req.body,
  };
  itemsData.push(newItem);
  res.status(201).json(newItem);
});

app.put('/api/items/:id', (req, res) => {
  const index = itemsData.findIndex((item) => item.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Item not found' });
  }

  itemsData[index] = { ...itemsData[index], ...req.body };
  res.json(itemsData[index]);
});

app.delete('/api/items/:id', (req, res) => {
  const index = itemsData.findIndex((item) => item.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Item not found' });
  }

  itemsData.splice(index, 1);
  res.status(204).send();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', items: itemsData.length });
});

app.listen(PORT, () => {
  console.log(`🚀 Mock API server running at http://localhost:${PORT}`);
  console.log(`📦 Loaded ${itemsData.length} items from seed`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  GET    /api/items       - Get all items`);
  console.log(`  GET    /api/items/:id   - Get item by id`);
  console.log(`  POST   /api/items       - Create new item`);
  console.log(`  PUT    /api/items/:id   - Update item`);
  console.log(`  DELETE /api/items/:id   - Delete item`);
  console.log(`  GET    /health          - Health check\n`);
});
