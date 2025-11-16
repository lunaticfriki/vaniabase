import { CategoryCollectionMother } from './objectMothers/categoryCollection.mother';
import { ItemMother } from './objectMothers/item.mother';
import { CategoryCollection } from '../categoryCollection';
import { Item } from '../item';

describe('categoryCollection domain tests', () => {
  it('should create a category collection', () => {
    const categoryCollection = CategoryCollectionMother.createRandom();

    expect(categoryCollection).toBeDefined();
    expect(categoryCollection.id).toBeDefined();
    expect(categoryCollection.name).toBeDefined();
    expect(categoryCollection.items).toBeDefined();
    expect(categoryCollection.itemCount).toBeDefined();
    expect(categoryCollection.items.length).toBe(categoryCollection.itemCount);
  });

  it('should create an empty category collection', () => {
    const categoryCollection = CategoryCollectionMother.createEmpty();

    expect(categoryCollection).toBeDefined();
    expect(categoryCollection.id).toBe('');
    expect(categoryCollection.name).toBe('');
    expect(categoryCollection.items).toEqual([]);
    expect(categoryCollection.itemCount).toBe(0);
  });

  it('should create a category collection with specific data', () => {
    const data = {
      id: '123',
      name: 'Books',
      items: [ItemMother.createRandom(), ItemMother.createRandom()],
      itemCount: 2,
    };

    const categoryCollection = CategoryCollectionMother.createWithData(data);

    expect(categoryCollection.id).toBe('123');
    expect(categoryCollection.name).toBe('Books');
    expect(categoryCollection.items.length).toBe(2);
    expect(categoryCollection.itemCount).toBe(2);
  });

  it('should create a category collection with specific category name', () => {
    const categoryCollection = CategoryCollectionMother.createWithCategory(
      'Movies',
      3
    );

    expect(categoryCollection.name).toBe('Movies');
    expect(categoryCollection.items.length).toBe(3);
    expect(categoryCollection.itemCount).toBe(3);
    categoryCollection.items.forEach((item) => {
      expect(item.category).toBe('Movies');
    });
  });

  it('should add an item to the collection', () => {
    const categoryCollection = CategoryCollectionMother.createWithCategory(
      'Books',
      2
    );
    const newItem = ItemMother.createRandom();

    const updatedCollection = categoryCollection.addItem(newItem);

    expect(updatedCollection.itemCount).toBe(3);
    expect(updatedCollection.items.length).toBe(3);
    expect(updatedCollection.items).toContain(newItem);
  });

  it('should remove an item from the collection', () => {
    const categoryCollection = CategoryCollectionMother.createWithCategory(
      'Books',
      3
    );
    const itemToRemove = categoryCollection.items[1];

    const updatedCollection = categoryCollection.removeItem(itemToRemove.id);

    expect(updatedCollection.itemCount).toBe(2);
    expect(updatedCollection.items.length).toBe(2);
    expect(updatedCollection.items).not.toContain(itemToRemove);
  });

  it('should check if collection has items', () => {
    const emptyCollection = CategoryCollectionMother.createEmpty();
    const nonEmptyCollection = CategoryCollectionMother.createRandom();

    expect(emptyCollection.hasItems()).toBe(false);
    expect(nonEmptyCollection.hasItems()).toBe(true);
  });

  it('should create category collections from items array', () => {
    const items: Item[] = [];

    for (let i = 0; i < 3; i++) {
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
          'Books'
        )
      );
    }

    for (let i = 0; i < 2; i++) {
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
          'Movies'
        )
      );
    }

    const collections = CategoryCollection.fromItems(items);

    expect(collections).toHaveLength(2);
    expect(collections.find((c) => c.name === 'Books')?.itemCount).toBe(3);
    expect(collections.find((c) => c.name === 'Movies')?.itemCount).toBe(2);
  });
});
