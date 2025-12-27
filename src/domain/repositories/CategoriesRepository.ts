import { Category } from '../model/entities/Category';
import { Id } from '../model/value-objects/Id';

export abstract class CategoriesRepository {
  abstract save(category: Category): Promise<void>;
  abstract findAll(): Promise<Category[]>;
  abstract findById(id: Id): Promise<Category | undefined>;
}
