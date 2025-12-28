import { injectable, inject } from 'inversify';
import { signal } from '@preact/signals';
import { Category } from '../../domain/model/entities/category.entity';
import { CategoryReadService } from './category.readService';
import { CategoryWriteService } from './category.writeService';

@injectable()
export class CategoryStateService {
  categories = signal<Category[]>([]);

  constructor(
    @inject(CategoryReadService) private readService: CategoryReadService,
    @inject(CategoryWriteService) private writeService: CategoryWriteService
  ) {}

  async loadCategories(): Promise<void> {
    const categories = await this.readService.findAll();
    this.categories.value = categories;
  }

  async createCategory(category: Category): Promise<void> {
    await this.writeService.create(category);
    await this.loadCategories();
  }
}
