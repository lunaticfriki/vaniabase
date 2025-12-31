import { Item } from './entities/item.entity';

export interface FormatData {
  formats: string[];
  counts: Record<string, number>;
  minCount: number;
  maxCount: number;
}

export class FormatStatistics {
  public static fromItems(items: Item[]): FormatData {
    const counts: Record<string, number> = {};

    items.forEach(item => {
      const format = item.format.value;
      if (format) {
        counts[format] = (counts[format] || 0) + 1;
      }
    });

    const formats = Object.keys(counts).sort();
    const values = Object.values(counts);
    const maxCount = values.length ? Math.max(...values) : 0;
    const minCount = values.length ? Math.min(...values) : 0;

    return { formats, counts, maxCount, minCount };
  }
}
