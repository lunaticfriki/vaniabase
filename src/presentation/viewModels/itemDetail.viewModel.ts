
import { signal } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';
import { Completed } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';

export class ItemDetailViewModel {
  public item = signal<Item | null>(null);
  public loading = signal<boolean>(true);

  constructor(private itemStateService: ItemStateService) {}

  async loadItem(id: string) {
    this.loading.value = true;
    const foundItem = await this.itemStateService.getItem(id);
    if (foundItem) {
      this.item.value = foundItem;
    } else {
      console.error('Item not found');
      this.item.value = null;
    }
    this.loading.value = false;
  }

  async toggleComplete() {
    const currentItem = this.item.value;
    if (!currentItem) return;

    const newStatus = Completed.create(!currentItem.completed.value);

    const updatedItem = Item.create({
      id: currentItem.id,
      title: currentItem.title,
      description: currentItem.description,
      author: currentItem.author,
      cover: currentItem.cover,
      owner: currentItem.owner,
      tags: currentItem.tags,
      topic: currentItem.topic,
      format: currentItem.format,
      created: currentItem.created,
      completed: newStatus,
      year: currentItem.year,
      publisher: currentItem.publisher,
      language: currentItem.language,
      category: currentItem.category,
      reference: currentItem.reference
    });

    await this.itemStateService.updateItem(updatedItem);
    this.item.value = updatedItem;
  }

  async deleteItem(): Promise<void> {
    const currentItem = this.item.value;
    if (!currentItem) return;
    await this.itemStateService.deleteItem(currentItem.id.value);
  }
}
