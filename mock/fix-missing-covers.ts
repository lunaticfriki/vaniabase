import { writeFileSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

interface Book {
  id: string;
  name: string;
  author: string;
  imageUrl: string;
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

async function fixMissingCovers() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const books: Book[] = JSON.parse(readFileSync(seedPath, 'utf-8'));

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

  for (const fix of fixes) {
    console.log(`\nSearching for: ${fix.name}`);
    const coverUrl = await searchWithAlternative(
      fix.searchTitle,
      fix.searchAuthor
    );

    if (coverUrl) {
      console.log(`✓ Found: ${coverUrl}`);
      const bookIndex = books.findIndex((b) => b.name === fix.name);
      if (bookIndex !== -1) {
        books[bookIndex].imageUrl = coverUrl;
      }
    } else {
      console.log(`✗ Still not found`);
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  writeFileSync(seedPath, JSON.stringify(books, null, 2));
  console.log('\n✓ Updated seed file');
}

fixMissingCovers().catch(console.error);
