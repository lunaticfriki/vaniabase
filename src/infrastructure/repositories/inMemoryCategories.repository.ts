import { injectable } from 'inversify';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { CategoriesRepository } from '../../domain/repositories/categories.repository';
import { CategoryMother } from '../../domain/__tests__/category.mother';

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
