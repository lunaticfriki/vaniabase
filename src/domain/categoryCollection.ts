import { Item } from './item';

export interface ICategoryCollection {
  id: string;
  name: string;
  items: Item[];
  itemCount: number;
}

export class CategoryCollection {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly items: Item[],
    public readonly itemCount: number
  ) {}

  static create(name: string, items: Item[]): CategoryCollection {
    return new CategoryCollection(
      crypto.randomUUID(),
      name,
      items,
      items.length
    );
  }

  static empty(): CategoryCollection {
    return new CategoryCollection('', '', [], 0);
  }

  static fromJson(json: ICategoryCollection): CategoryCollection {
    return new CategoryCollection(
      json.id,
      json.name,
      json.items,
      json.itemCount
    );
  }

  static toJson(categoryCollection: CategoryCollection): ICategoryCollection {
    return {
      id: categoryCollection.id,
      name: categoryCollection.name,
      items: categoryCollection.items,
      itemCount: categoryCollection.itemCount,
    };
  }

  static fromItems(items: Item[]): CategoryCollection[] {
    const categoriesMap = new Map<string, Item[]>();

    items.forEach((item) => {
      const category = item.category;
      if (!categoriesMap.has(category)) {
        categoriesMap.set(category, []);
      }
      categoriesMap.get(category)!.push(item);
    });

    return Array.from(categoriesMap.entries()).map(([name, categoryItems]) =>
      CategoryCollection.create(name, categoryItems)
    );
  }

  addItem(item: Item): CategoryCollection {
    return new CategoryCollection(
      this.id,
      this.name,
      [...this.items, item],
      this.itemCount + 1
    );
  }

  removeItem(itemId: string): CategoryCollection {
    const filteredItems = this.items.filter((item) => item.id !== itemId);
    return new CategoryCollection(
      this.id,
      this.name,
      filteredItems,
      filteredItems.length
    );
  }

  hasItems(): boolean {
    return this.itemCount > 0;
  }
}
