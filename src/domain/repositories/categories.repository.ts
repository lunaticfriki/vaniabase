import { Category } from '../model/entities/category.entity';
import { Id } from '../model/value-objects/id.valueObject';

export abstract class CategoriesRepository {
  abstract save(category: Category): Promise<void>;
  abstract findAll(): Promise<Category[]>;
  abstract findById(id: Id): Promise<Category | undefined>;
}
