import { CategoryMother } from './CategoryMother';
import { Category } from '../model/entities/Category';

describe('Category Entity', () => {
  it('should be created with valid values', () => {
    const category = CategoryMother.create();
    expect(category).toBeInstanceOf(Category);
    expect(category.id).toBeDefined();
    expect(category.name).toBeDefined();
  });

  it('should maintain immutability', () => {
    const category = CategoryMother.create();

    const initialName = category.name.value;
    expect(category.name.value).toBe(initialName);
  });

  it('should create an empty category', () => {
    const category = CategoryMother.empty();
    expect(category).toBeInstanceOf(Category);
    expect(category.id.value).toBe('');
    expect(category.name.value).toBe('');
  });

  it('should create a category with random values', () => {
    const category = CategoryMother.createRandom();
    expect(category).toBeInstanceOf(Category);
    expect(category.id).toBeDefined();
    expect(category.name).toBeDefined();
  });
});
