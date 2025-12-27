import { describe, it, expect } from 'vitest';
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
});
