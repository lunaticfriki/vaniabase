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

async function searchBookCover(title: string, author: string) {
  const url = `https://openlibrary.org/search.json?title=${encodeURIComponent(
    title
  )}&author=${encodeURIComponent(author)}&limit=1`;
  console.log(`Trying Open Library: ${title}`);

  const response = await fetch(url);
  const data = await response.json();

  if (data.numFound > 0 && data.docs[0]?.cover_i) {
    return `https://covers.openlibrary.org/b/id/${data.docs[0].cover_i}-L.jpg`;
  }
  return null;
}

async function searchGameCover(title: string) {
  try {
    const url = `https://api.rawg.io/api/games?search=${encodeURIComponent(
      title
    )}&page_size=1`;
    console.log(`Trying RAWG: ${title}`);

    const response = await fetch(url);
    const data = await response.json();

    if (
      data.results &&
      data.results.length > 0 &&
      data.results[0].background_image
    ) {
      return data.results[0].background_image;
    }
  } catch (error) {
    console.log(`Error searching RAWG: ${error}`);
  }
  return null;
}

async function searchMusicCover(title: string, author: string) {
  try {
    // Search MusicBrainz for the release
    const url = `https://musicbrainz.org/ws/2/release?query=release:${encodeURIComponent(
      title
    )}%20AND%20artist:${encodeURIComponent(author)}&fmt=json&limit=1`;
    console.log(`Trying MusicBrainz: ${title} by ${author}`);

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Vaniabase/1.0.0 ( dev@vaniabase.com )',
      },
    });
    const data = await response.json();

    if (data.releases && data.releases.length > 0 && data.releases[0].id) {
      const releaseId = data.releases[0].id;
      // Get cover from Cover Art Archive
      const coverUrl = `https://coverartarchive.org/release/${releaseId}/front`;

      // Check if cover exists
      const coverResponse = await fetch(coverUrl, { method: 'HEAD' });
      if (coverResponse.ok) {
        return coverUrl;
      }
    }
  } catch (error) {
    console.log(`Error searching music cover: ${error}`);
  }
  return null;
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
      console.log(`No automatic API for ${category} yet, needs manual URL`);
      return null;
    default:
      console.log(`Unknown category: ${category}`);
      return null;
  }
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

  console.log('\n\n=== ATTEMPTING AUTOMATIC FIXES ===\n');

  // Try to automatically fix missing covers based on category
  for (const { item, index } of missingCovers) {
    console.log(`\nSearching for: ${item.name} (${item.category})`);
    const coverUrl = await searchCoverByCategory(item);

    if (coverUrl) {
      // Verify the found URL is valid
      const isValid = await checkImageUrl(coverUrl);
      if (isValid) {
        console.log(`✓ Found valid cover: ${coverUrl}`);
        items[index].imageUrl = coverUrl;
      } else {
        console.log(`✗ Found cover but URL is invalid`);
      }
    } else {
      console.log(`✗ No cover found - needs manual URL`);
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  // Manual fixes for specific items that couldn't be found automatically
  const manualFixes = [
    {
      name: 'Design Patterns: Elements of Reusable Object-Oriented Software',
      searchTitle: 'Design Patterns',
      searchAuthor: 'Gamma',
      category: 'books',
    },
    {
      name: 'Test-Driven Development by Example',
      searchTitle: 'Test Driven Development',
      searchAuthor: 'Kent Beck',
      category: 'books',
    },
    {
      name: 'TypeScript Handbook',
      searchTitle: 'Programming TypeScript',
      searchAuthor: 'Boris Cherny',
      category: 'books',
    },
  ];

  console.log('\n\n=== ATTEMPTING MANUAL FIXES ===\n');

  for (const fix of manualFixes) {
    const itemIndex = items.findIndex((item) => item.name === fix.name);
    if (itemIndex !== -1 && !(await checkImageUrl(items[itemIndex].imageUrl))) {
      console.log(`Searching for: ${fix.name}`);
      const coverUrl = await searchBookCover(fix.searchTitle, fix.searchAuthor);

      if (coverUrl) {
        console.log(`✓ Found: ${coverUrl}`);
        items[itemIndex].imageUrl = coverUrl;
      } else {
        console.log(`✗ Still not found`);
      }

      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }

  writeFileSync(seedPath, JSON.stringify(items, null, 2));
  console.log('\n✓ Updated seed file');
}

fixMissingCovers().catch(console.error);
