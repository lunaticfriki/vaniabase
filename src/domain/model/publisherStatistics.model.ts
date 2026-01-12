import { Item } from './entities/item.entity';

export interface PublisherData {
  publishers: string[];
  counts: Record<string, number>;
  minCount: number;
  maxCount: number;
}

export class PublisherStatistics {
  public static fromItems(items: Item[]): PublisherData {
    const counts: Record<string, number> = {};

    items.forEach(item => {
      const publisher = item.publisher.value;
      if (publisher) {
        counts[publisher] = (counts[publisher] || 0) + 1;
      }
    });

    const publishers = Object.keys(counts).sort((a, b) => a.localeCompare(b));
    const values = Object.values(counts);
    const maxCount = values.length ? Math.max(...values) : 0;
    const minCount = values.length ? Math.min(...values) : 0;

    return { publishers, counts, maxCount, minCount };
  }
}
