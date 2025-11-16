import express, { Request, Response } from 'express';
import cors from 'cors';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';
import { spawn } from 'child_process';
import * as readline from 'readline';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = 3001;

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

app.use(cors());
app.use(express.json());

const itemsData: Item[] = JSON.parse(
  readFileSync(join(__dirname, 'data', 'items.seed.json'), 'utf-8')
);

app.get('/api/items', (_req: Request, res: Response) => {
  res.json(itemsData);
});

app.get('/api/items/:id', (req: Request, res: Response) => {
  const item = itemsData.find((item) => item.id === req.params.id);

  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }

  res.json(item);
});

app.post('/api/items', (req: Request, res: Response) => {
  const newItem: Item = {
    id: randomUUID(),
    ...req.body,
  };
  itemsData.push(newItem);
  res.status(201).json(newItem);
});

app.put('/api/items/:id', (req: Request, res: Response) => {
  const index = itemsData.findIndex((item) => item.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Item not found' });
  }

  itemsData[index] = { ...itemsData[index], ...req.body };
  res.json(itemsData[index]);
});

app.delete('/api/items/:id', (req: Request, res: Response) => {
  const index = itemsData.findIndex((item) => item.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Item not found' });
  }

  itemsData.splice(index, 1);
  res.status(204).send();
});

app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', items: itemsData.length });
});

function checkMissingCovers(): boolean {
  return itemsData.some(
    (item) =>
      !item.imageUrl.includes('covers.openlibrary.org') &&
      !item.imageUrl.includes('logo.ts')
  );
}

function runUpdateCoversScript(): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log('\n📚 Running update-covers script...\n');
    const updateProcess = spawn('npx', ['tsx', 'update-covers.ts'], {
      cwd: __dirname,
      stdio: 'inherit',
    });

    updateProcess.on('close', (code) => {
      if (code === 0) {
        console.log('\n✓ Cover update completed\n');
        resolve();
      } else {
        console.error(`\n✗ Cover update failed with code ${code}\n`);
        reject(new Error(`Process exited with code ${code}`));
      }
    });
  });
}

function runFixMissingCoversScript(): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log('\n🔧 Running fix-missing-covers script...\n');
    const fixProcess = spawn('npx', ['tsx', 'fix-missing-covers.ts'], {
      cwd: __dirname,
      stdio: 'inherit',
    });

    fixProcess.on('close', (code) => {
      if (code === 0) {
        console.log('\n✓ Missing covers fix completed\n');
        resolve();
      } else {
        console.error(`\n✗ Missing covers fix failed with code ${code}\n`);
        reject(new Error(`Process exited with code ${code}`));
      }
    });
  });
}

function reloadSeedData() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const newData = JSON.parse(readFileSync(seedPath, 'utf-8'));
  itemsData.length = 0;
  itemsData.push(...newData);
  console.log(`\n✓ Reloaded ${itemsData.length} items from seed\n`);
}

function listSeedElements() {
  console.log('\n📚 Current Seed Data:\n');
  console.log('═'.repeat(80));

  itemsData.forEach((item, index) => {
    const coverStatus = item.imageUrl.includes('covers.openlibrary.org')
      ? '✓'
      : item.imageUrl.includes('logo.ts')
      ? '📘'
      : '✗';
    console.log(`\n${index + 1}. ${item.name}`);
    console.log(`   Author: ${item.author}`);
    console.log(`   Category: ${item.category}`);
    console.log(`   Year: ${item.year} | Topic: ${item.topic}`);
    console.log(`   Format: ${item.format} | Language: ${item.language}`);
    console.log(`   Cover: ${coverStatus} ${item.imageUrl}`);
    console.log(`   Completed: ${item.completed ? '✓' : '✗'}`);
    console.log(`   Tags: ${item.tags.join(', ')}`);
  });

  console.log('\n' + '═'.repeat(80));
  console.log(
    `\nTotal: ${itemsData.length} items | ${
      itemsData.filter((i) => i.imageUrl.includes('covers.openlibrary.org'))
        .length
    } with Open Library covers\n`
  );
}

async function showMenu(): Promise<boolean> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string): Promise<string> => {
    return new Promise((resolve) => {
      rl.question(prompt, resolve);
    });
  };

  try {
    const hasMissingCovers = checkMissingCovers();
    const coverStatus = hasMissingCovers
      ? '⚠️  Some covers missing'
      : '✓ All covers OK';

    console.log('\n╔════════════════════════════════════════╗');
    console.log('║     Mock API Server - Main Menu       ║');
    console.log('╚════════════════════════════════════════╝\n');
    console.log(`Status: ${coverStatus}\n`);
    console.log('1. 🔄 Reload book covers from API');
    console.log('2. 🚀 Start the server');
    console.log('3. 📋 List seed elements');
    console.log('4. 🚪 Exit\n');

    const answer = await question('Select an option (1-4): ');

    rl.close();

    switch (answer.trim()) {
      case '1': {
        await runUpdateCoversScript();
        const stillMissing = checkMissingCovers();
        if (stillMissing) {
          const rl2 = readline.createInterface({
            input: process.stdin,
            output: process.stdout,
          });
          const fixAnswer = await new Promise<string>((resolve) => {
            rl2.question(
              'Some covers are still missing. Run fix script? (y/n): ',
              resolve
            );
          });
          rl2.close();
          if (
            fixAnswer.toLowerCase() === 'y' ||
            fixAnswer.toLowerCase() === 'yes'
          ) {
            await runFixMissingCoversScript();
          }
        }
        reloadSeedData();
        return true;
      }
      case '2':
        return false;
      case '3':
        listSeedElements();
        return true;
      case '4':
        console.log('\n👋 Goodbye!\n');
        process.exit(0);
        break;
      default:
        console.log('\n❌ Invalid option. Please select 1-4.\n');
        return true;
    }
  } catch (error) {
    rl.close();
    throw error;
  }
}

function startServer() {
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
}

async function main() {
  console.log('🎬 Starting Mock API Server...\n');

  let continueMenu = true;

  while (continueMenu) {
    continueMenu = await showMenu();
  }

  startServer();
}

main().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
