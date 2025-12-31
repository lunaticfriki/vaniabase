import { Item } from './entities/item.entity';

export interface TopicData {
  topics: string[];
  counts: Record<string, number>;
  minCount: number;
  maxCount: number;
}

export class TopicStatistics {
  public static fromItems(items: Item[]): TopicData {
    const counts: Record<string, number> = {};

    items.forEach(item => {
      const topic = item.topic.value;
      if (topic) {
        counts[topic] = (counts[topic] || 0) + 1;
      }
    });

    const topics = Object.keys(counts).sort();
    const values = Object.values(counts);
    const maxCount = values.length ? Math.max(...values) : 0;
    const minCount = values.length ? Math.min(...values) : 0;

    return { topics, counts, maxCount, minCount };
  }
}
