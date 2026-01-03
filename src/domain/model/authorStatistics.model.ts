import { Item } from './entities/item.entity';

export interface AuthorData {
  authors: string[];
  counts: Record<string, number>;
  minCount: number;
  maxCount: number;
}

export class AuthorStatistics {
  public static fromItems(items: Item[]): AuthorData {
    const counts: Record<string, number> = {};

    items.forEach(item => {
      const author = item.author.value;
      if (author) {
        counts[author] = (counts[author] || 0) + 1;
      }
    });

    const authors = Object.keys(counts).sort((a, b) => a.localeCompare(b));
    const values = Object.values(counts);
    const maxCount = values.length ? Math.max(...values) : 0;
    const minCount = values.length ? Math.min(...values) : 0;

    return { authors, counts, maxCount, minCount };
  }
}
