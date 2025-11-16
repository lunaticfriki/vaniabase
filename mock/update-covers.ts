import { writeFileSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

interface Book {
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
}

interface OpenLibraryDoc {
  cover_i?: number;
  isbn?: string[];
  key?: string;
  title?: string;
}

interface OpenLibraryResponse {
  docs: OpenLibraryDoc[];
  numFound: number;
}

async function searchBookCover(
  title: string,
  author: string
): Promise<string | null> {
  try {
    const cleanTitle = encodeURIComponent(title.replace(/:.+$/, '').trim());
    const cleanAuthor = encodeURIComponent(author.replace(/and.+$/, '').trim());

    const searchUrl = `https://openlibrary.org/search.json?title=${cleanTitle}&author=${cleanAuthor}&limit=1`;

    console.log(`Searching: ${title} by ${author}`);

    const response = await fetch(searchUrl);
    const data: OpenLibraryResponse = await response.json();

    if (data.numFound > 0 && data.docs[0]) {
      const book = data.docs[0];

      if (book.cover_i) {
        const coverUrl = `https://covers.openlibrary.org/b/id/${book.cover_i}-L.jpg`;
        console.log(`✓ Found cover: ${coverUrl}`);
        return coverUrl;
      }

      if (book.isbn && book.isbn.length > 0) {
        const coverUrl = `https://covers.openlibrary.org/b/isbn/${book.isbn[0]}-L.jpg`;
        console.log(`✓ Found cover (ISBN): ${coverUrl}`);
        return coverUrl;
      }
    }

    console.log(`✗ No cover found for: ${title}`);
    return null;
  } catch (error) {
    console.error(`Error searching for ${title}:`, error);
    return null;
  }
}

async function updateBookCovers() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const books: Book[] = JSON.parse(readFileSync(seedPath, 'utf-8'));

  console.log(`Found ${books.length} books to update\n`);

  for (let i = 0; i < books.length; i++) {
    const book = books[i];
    console.log(`[${i + 1}/${books.length}] Processing: ${book.name}`);

    const coverUrl = await searchBookCover(book.name, book.author);

    if (coverUrl) {
      books[i].imageUrl = coverUrl;
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
    console.log('---');
  }

  writeFileSync(seedPath, JSON.stringify(books, null, 2));

  console.log('\n✓ Seed file updated successfully!');
  console.log(
    `Updated covers: ${
      books.filter((b) => b.imageUrl.includes('covers.openlibrary.org')).length
    }/${books.length}`
  );
}

updateBookCovers().catch(console.error);
