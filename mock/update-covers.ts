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

async function searchGameCover(title: string): Promise<string | null> {
  try {
    const url = `https://api.rawg.io/api/games?search=${encodeURIComponent(
      title
    )}&page_size=1`;
    console.log(`Searching RAWG for: ${title}`);

    const response = await fetch(url);
    const data = await response.json();

    if (
      data.results &&
      data.results.length > 0 &&
      data.results[0].background_image
    ) {
      const coverUrl = data.results[0].background_image;
      console.log(`✓ Found cover: ${coverUrl}`);
      return coverUrl;
    }

    console.log(`✗ No cover found for: ${title}`);
    return null;
  } catch (error) {
    console.error(`Error searching for ${title}:`, error);
    return null;
  }
}

async function searchMusicCover(
  title: string,
  author: string
): Promise<string | null> {
  try {
    const url = `https://musicbrainz.org/ws/2/release?query=release:${encodeURIComponent(
      title
    )}%20AND%20artist:${encodeURIComponent(author)}&fmt=json&limit=1`;
    console.log(`Searching MusicBrainz for: ${title} by ${author}`);

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Vaniabase/1.0.0 ( dev@vaniabase.com )',
      },
    });
    const data = await response.json();

    if (data.releases && data.releases.length > 0 && data.releases[0].id) {
      const releaseId = data.releases[0].id;
      const coverUrl = `https://coverartarchive.org/release/${releaseId}/front`;

      // Check if cover exists
      const coverResponse = await fetch(coverUrl, { method: 'HEAD' });
      if (coverResponse.ok) {
        console.log(`✓ Found cover: ${coverUrl}`);
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

async function searchCoverByCategory(item: Item): Promise<string | null> {
  const category = item.category.toLowerCase();

  switch (category) {
    case 'books':
      return await searchBookCover(item.name, item.author);
    case 'videogames':
    case 'video games':
      return await searchGameCover(item.name);
    case 'cd':
    case 'music':
    case 'album':
      return await searchMusicCover(item.name, item.author);
    case 'comics':
    case 'magazines':
      console.log(`No automatic API for ${category} - keeping current URL`);
      return null;
    default:
      console.log(`Unknown category: ${category} - keeping current URL`);
      return null;
  }
}

async function updateCovers() {
  const seedPath = join(__dirname, 'data', 'items.seed.json');
  const items: Item[] = JSON.parse(readFileSync(seedPath, 'utf-8'));

  console.log(`Found ${items.length} items to update\n`);

  let updated = 0;

  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    console.log(
      `[${i + 1}/${items.length}] Processing: ${item.name} (${item.category})`
    );

    const coverUrl = await searchCoverByCategory(item);

    if (coverUrl) {
      items[i].imageUrl = coverUrl;
      updated++;
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
    console.log('---');
  }

  writeFileSync(seedPath, JSON.stringify(items, null, 2));

  console.log('\n✓ Seed file updated successfully!');
  console.log(`Updated covers: ${updated}/${items.length}`);
}

updateCovers().catch(console.error);
