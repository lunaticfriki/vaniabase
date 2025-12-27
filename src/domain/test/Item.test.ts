import { ItemMother } from './ItemMother';
import { Item } from '../model/entities/Item';

describe('Item Entity', () => {
  it('should be created with valid values', () => {
    const item = ItemMother.create();
    expect(item).toBeInstanceOf(Item);
    expect(item.id).toBeDefined();
    expect(item.title).toBeDefined();
  });

  it('should maintain immutability', () => {
    const item = ItemMother.create();

    const initialTitle = item.title.value;
    expect(item.title.value).toBe(initialTitle);
  });

  it('should create an empty item', () => {
    const item = ItemMother.empty();
    expect(item).toBeInstanceOf(Item);
    expect(item.id.value).toBe('');
    expect(item.title.value).toBe('');
  });

  it('should create an item with random values', () => {
    const item = ItemMother.createRandom();
    expect(item).toBeInstanceOf(Item);
    expect(item.id).toBeDefined();
    expect(item.title).toBeDefined();
  });
});
