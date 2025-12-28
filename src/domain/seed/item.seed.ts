import { Item } from '../model/entities/item.entity';
import { ItemMother } from '../__tests__/item.mother';
import { CategoryMother } from '../__tests__/category.mother';
import { UserSeed } from './user.seed';

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
