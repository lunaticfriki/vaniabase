import { injectable, inject } from 'inversify';
import { Category } from '../../domain/model/entities/Category';
import { Id } from '../../domain/model/value-objects/Id';
import { CategoriesRepository } from '../../domain/repositories/CategoriesRepository';

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
