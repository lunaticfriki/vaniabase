import { injectable, inject } from 'inversify';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { CategoriesRepository } from '../../domain/repositories/categories.repository';

@injectable()
export class CategoryReadService {
  constructor(@inject(CategoriesRepository) private repository: CategoriesRepository) {}

  async findAll(): Promise<Category[]> {
    return this.repository.findAll();
  }

  async findById(id: Id): Promise<Category | undefined> {
    return this.repository.findById(id);
  }
}
