import { injectable, inject } from 'inversify';
import { signal } from '@preact/signals';
import { Item } from '../../domain/model/entities/Item';
import { ItemReadService } from './item.readService';
import { ItemWriteService } from './item.writeService';

@injectable()
export class ItemStateService {
    items = signal<Item[]>([]);

    constructor(
        @inject(ItemReadService) private readService: ItemReadService,
        @inject(ItemWriteService) private writeService: ItemWriteService
    ) {}

    async loadItems(): Promise<void> {
        const items = await this.readService.findAll();
        this.items.value = items;
    }

    async createItem(item: Item): Promise<void> {
        await this.writeService.create(item);
        await this.loadItems();
    }
    
    async updateItem(item: Item): Promise<void> {
        await this.writeService.update(item);
        await this.loadItems();
    }
}
