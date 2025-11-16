import { writeFileSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

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

async function checkImageUrl(url: string): Promise<boolean> {
  try {
    const response = await fetch(url, { method: 'HEAD' });
    return response.ok;
  } catch (error) {
    console.log(error);
    return false;
  }
}

async function searchWithAlternative(title: string, author: string) {
  const url = `https://openlibrary.org/search.json?title=${encodeURIComponent(
    title
  )}&author=${encodeURIComponent(author)}&limit=1`;
  console.log(`Trying: ${url}`);

  const response = await fetch(url);
  const data = await response.json();

  if (data.numFound > 0 && data.docs[0]?.cover_i) {
    return `https://covers.openlibrary.org/b/id/${data.docs[0].cover_i}-L.jpg`;
  }
  return null;
}

async function findMissingCovers() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const items: Item[] = JSON.parse(readFileSync(seedPath, 'utf-8'));

  console.log('Checking all image URLs...\n');

  const missingCovers: Array<{ item: Item; index: number }> = [];

  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    const isValid = await checkImageUrl(item.imageUrl);

    if (!isValid) {
      console.log(`✗ [${i + 1}/${items.length}] BROKEN: ${item.name}`);
      console.log(`  Category: ${item.category}`);
      console.log(`  Current URL: ${item.imageUrl}`);
      console.log(`  Author: ${item.author}\n`);
      missingCovers.push({ item, index: i });
    } else {
      console.log(`✓ [${i + 1}/${items.length}] OK: ${item.name}`);
    }

    // Add small delay to avoid overwhelming the servers
    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  console.log(`\n\n=== SUMMARY ===`);
  console.log(`Total items: ${items.length}`);
  console.log(`Broken covers: ${missingCovers.length}`);
  console.log(`Valid covers: ${items.length - missingCovers.length}\n`);

  if (missingCovers.length > 0) {
    console.log('Items with missing/broken covers:');
    missingCovers.forEach(({ item }) => {
      console.log(`  - ${item.name} (${item.category})`);
    });
  }

  return missingCovers;
}

async function fixMissingCovers() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const items: Item[] = JSON.parse(readFileSync(seedPath, 'utf-8'));

  // First, find all items with broken covers
  const missingCovers = await findMissingCovers();

  if (missingCovers.length === 0) {
    console.log('\n✓ All covers are valid!');
    return;
  }

  // Manual fixes for specific items (you can add more here)
  const fixes = [
    {
      name: 'Design Patterns: Elements of Reusable Object-Oriented Software',
      searchTitle: 'Design Patterns',
      searchAuthor: 'Gamma',
    },
    {
      name: 'Test-Driven Development by Example',
      searchTitle: 'Test Driven Development',
      searchAuthor: 'Kent Beck',
    },
    {
      name: 'TypeScript Handbook',
      searchTitle: 'Programming TypeScript',
      searchAuthor: 'Boris Cherny',
    },
  ];

  console.log('\n\n=== ATTEMPTING FIXES ===\n');

  for (const fix of fixes) {
    console.log(`Searching for: ${fix.name}`);
    const coverUrl = await searchWithAlternative(
      fix.searchTitle,
      fix.searchAuthor
    );

    if (coverUrl) {
      console.log(`✓ Found: ${coverUrl}`);
      const itemIndex = items.findIndex((item) => item.name === fix.name);
      if (itemIndex !== -1) {
        items[itemIndex].imageUrl = coverUrl;
      }
    } else {
      console.log(`✗ Still not found`);
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  writeFileSync(seedPath, JSON.stringify(items, null, 2));
  console.log('\n✓ Updated seed file');
}

fixMissingCovers().catch(console.error);
