import {
  CategoryCollection,
  type ICategoryCollection,
} from '../../categoryCollection';
import { Item } from '../../item';
import { ItemMother } from './item.mother';
import { faker } from '@faker-js/faker';

export class CategoryCollectionMother {
  static createWithData(data: ICategoryCollection): CategoryCollection {
    return new CategoryCollection(
      data.id,
      data.name,
      data.items,
      data.itemCount
    );
  }

  static createEmpty(): CategoryCollection {
    return new CategoryCollection('', '', [], 0);
  }

  static createRandom(): CategoryCollection {
    const itemCount = faker.number.int({ min: 1, max: 10 });
    const categoryName = faker.lorem.word();
    const items: Item[] = [];

    for (let i = 0; i < itemCount; i++) {
      const item = ItemMother.createRandom();
      items.push(
        new Item(
          item.id,
          item.name,
          item.author,
          item.description,
          item.imageUrl,
          item.topic,
          item.tags,
          item.owner,
          item.completed,
          item.year,
          item.language,
          item.format,
          categoryName
        )
      );
    }

    return CategoryCollection.create(categoryName, items);
  }

  static createWithCategory(
    categoryName: string,
    itemCount: number = 5
  ): CategoryCollection {
    const items: Item[] = [];

    for (let i = 0; i < itemCount; i++) {
      const item = ItemMother.createRandom();
      items.push(
        new Item(
          item.id,
          item.name,
          item.author,
          item.description,
          item.imageUrl,
          item.topic,
          item.tags,
          item.owner,
          item.completed,
          item.year,
          item.language,
          item.format,
          categoryName
        )
      );
    }

    return CategoryCollection.create(categoryName, items);
  }
}
