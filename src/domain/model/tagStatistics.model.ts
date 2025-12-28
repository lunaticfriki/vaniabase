import { Item } from './entities/item.entity';

export interface TagData {
  tags: string[];
  counts: Record<string, number>;
  minCount: number;
  maxCount: number;
}

export class TagStatistics {
  public static fromItems(items: Item[]): TagData {
    const counts: Record<string, number> = {};
    
    items.forEach(item => {
      item.tags.value.forEach(t => {
        const key = t;
        counts[key] = (counts[key] || 0) + 1;
      });
    });

    const tags = Object.keys(counts).sort();
    const values = Object.values(counts);
    const maxCount = values.length ? Math.max(...values) : 0;
    const minCount = values.length ? Math.min(...values) : 0;

    return { tags, counts, maxCount, minCount };
  }
}
