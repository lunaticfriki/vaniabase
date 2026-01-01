
import { signal } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import {
  Title,
  Description,
  Author,
  Cover,
  Topic,
  Format,
  Publisher,
  Language,
  Reference
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import type { ItemFormData } from '../components/itemForm.component';

export class EditItemViewModel {
  public formData = signal<ItemFormData | null>(null);
  public loading = signal<boolean>(true);
  public item = signal<Item | null>(null);

  constructor(
    private itemStateService: ItemStateService,
  ) {}

  async loadItem(id: string) {
    this.loading.value = true;
    const foundItem = await this.itemStateService.getItem(id);
    
    if (foundItem) {
      this.item.value = foundItem;
      this.formData.value = {
        title: foundItem.title.value,
        description: foundItem.description.value,
        author: foundItem.author.value,
        cover: foundItem.cover.value,
        tags: foundItem.tags.value.join(', '),
        topic: foundItem.topic.value,
        format: foundItem.format.value,
        created: foundItem.created.value.toISOString().split('T')[0],
        completed: foundItem.completed.value,
        year: foundItem.year.value.toString(),
        publisher: foundItem.publisher.value,
        language: foundItem.language.value,
        category: foundItem.category.name.value,
        reference: foundItem.reference.value
      };
    } else {
      console.error('Item not found');
      this.item.value = null;
      this.formData.value = null;
    }
    
    this.loading.value = false;
  }

  async updateItem(data: ItemFormData): Promise<void> {
    const currentItem = this.item.value;
    if (!currentItem) return;

    const tagsArray = data.tags.split(',').map(t => t.trim()).filter(Boolean);
    const updatedCategory = data.category !== currentItem.category.name.value
      ? Category.create(Id.create(crypto.randomUUID()), Title.create(data.category))
      : currentItem.category;

    const updatedItem = Item.create({
      id: currentItem.id,
      title: Title.create(data.title),
      description: Description.create(data.description),
      author: Author.create(data.author),
      cover: Cover.create(data.cover), 
      owner: currentItem.owner,
      tags: Tags.create(tagsArray),
      topic: Topic.create(data.topic),
      format: Format.create(data.format),
      created: Created.create(new Date(data.created)),
      completed: Completed.create(data.completed),
      year: Year.create(parseInt(data.year) || 0),
      publisher: Publisher.create(data.publisher),
      language: Language.create(data.language),
      category: Category.create(updatedCategory.id, Title.create(data.category)),
      reference: Reference.create(data.reference || '0')
    });

    await this.itemStateService.updateItem(updatedItem);
    this.item.value = updatedItem;
  }

  async uploadCover(file: File): Promise<string> {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
  }
}
