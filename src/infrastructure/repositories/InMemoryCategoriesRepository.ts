import { injectable } from 'inversify';
import { Category } from '../../domain/model/entities/Category';
import { Id } from '../../domain/model/value-objects/Id';
import { CategoriesRepository } from '../../domain/repositories/CategoriesRepository';
import { CategoryMother } from '../../domain/test/CategoryMother';

@injectable()
export class InMemoryCategoriesRepository implements CategoriesRepository {
  private categories: Map<string, Category> = new Map();

  constructor() {
    const seedCategories = CategoryMother.all();
    seedCategories.forEach(category => {
      this.categories.set(category.id.value, category);
    });
  }

  async save(category: Category): Promise<void> {
    this.categories.set(category.id.value, category);
  }

  async findAll(): Promise<Category[]> {
    return Array.from(this.categories.values());
  }

  async findById(id: Id): Promise<Category | undefined> {
    return this.categories.get(id.value);
  }
}
