import { Item } from '../model/entities/Item';
import { ItemMother } from '../test/ItemMother';
import { CategoryMother } from '../test/CategoryMother';

export class ItemSeed {
  public static generate(count: number = 30): Item[] {
    const categories = CategoryMother.all();
    const items: Item[] = [];

    for (let i = 0; i < count; i++) {
        const randomCategory = categories[Math.floor(Math.random() * categories.length)];
        items.push(ItemMother.create({ category: randomCategory }));
    }
    return items;
  }
}
