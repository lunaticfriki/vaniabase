import { Item } from '../model/entities/Item';
import { ItemMother } from '../test/ItemMother';
import { CategoryMother } from '../test/CategoryMother';
import { UserSeed } from './UserSeed';

export class ItemSeed {
  public static generate(count: number = 100): Item[] {
    const categories = CategoryMother.all();
    const users = UserSeed.generate();
    const items: Item[] = [];

    console.log(`[ItemSeed] Generating ${count} items with ${categories.length} categories...`);

    for (let i = 0; i < count; i++) {
      const randomCategory = categories[Math.floor(Math.random() * categories.length)];
      const randomUser = users[Math.floor(Math.random() * users.length)];
      const item = ItemMother.create({ 
        category: randomCategory,
        ownerId: randomUser.id
      });
      items.push(item);
    }

    console.log(`[ItemSeed] Generated ${items.length} items.`);
    return items;
  }
}
