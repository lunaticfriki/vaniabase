
import { signal } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';
import { ImageLookupService } from '../../infrastructure/services/imageLookupService';
import {
  Author,
  Cover,
  Description,
  Format,
  Publisher,
  Language,
  Reference,
  Title,
  Topic
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { v4 as uuidv4 } from 'uuid';
import type { ItemFormData } from '../components/itemForm.component';
import * as XLSX from 'xlsx';

interface ExcelRow {
  Title?: string;
  Description?: string;
  Author?: string;
  Tags?: string;
  Topic?: string;
  Format?: string;
  Created?: string;
  Completed?: boolean | string;
  Year?: string | number;
  Publisher?: string;
  Language?: string;
  Category?: string;
  Reference?: string | number;
  title?: string;
  description?: string;
  author?: string;
  tags?: string;
  topic?: string;
  format?: string;
  created?: string;
  completed?: boolean | string;
  year?: string | number;
  publisher?: string;
  language?: string;
  category?: string;
  reference?: string | number;
}

export class CreateItemViewModel {
  public formData = signal<ItemFormData>({
    title: '',
    description: '',
    author: '',
    cover: '',
    tags: '',
    topic: '',
    format: '',
    created: new Date().toISOString().split('T')[0],
    completed: false,
    year: new Date().getFullYear().toString(),
    publisher: '',
    language: '',
    category: 'books',
    reference: '0'
  });

  public isImporting = signal(false);
  public importError = signal<string | null>(null);

  constructor(
    private itemStateService: ItemStateService,
    private imageLookupService: ImageLookupService
  ) {}

  async createItem(data: ItemFormData, userId: string): Promise<void> {
    const newItem = Item.create({
      id: Id.create(uuidv4()),
      title: Title.create(data.title),
      description: Description.create(data.description),
      author: Author.create(data.author),
      cover: Cover.create(data.cover || (await this.imageLookupService.findImage(data.title))),
      owner: Id.create(userId),
      tags: Tags.create(data.tags.split(',').map(t => t.trim()).filter(Boolean)),
      topic: Topic.create(data.topic),
      format: Format.create(data.format),
      created: Created.create(new Date(data.created)),
      completed: Completed.create(data.completed),
      year: Year.create(parseInt(data.year) || 0),
      publisher: Publisher.create(data.publisher),
      language: Language.create(data.language),
      category: Category.create(Id.create(uuidv4()), Title.create(data.category)),
      reference: Reference.create(data.reference || '0')
    });

    await this.itemStateService.createItem(newItem);
  }

  async uploadCover(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result as string);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  async processExcelFile(file: File, userId: string): Promise<boolean> {
    this.isImporting.value = true;
    this.importError.value = null;

    try {
      const data = await file.arrayBuffer();
      const workbook = XLSX.read(data);
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      const jsonData = XLSX.utils.sheet_to_json<ExcelRow>(sheet);

      const itemsToCreate = await Promise.all(
        jsonData
          .map(async row => {
            const normalizedRow = {
              title: row.Title || row.title,
              description: row.Description || row.description,
              author: row.Author || row.author,
              tags: row.Tags || row.tags,
              topic: row.Topic || row.topic,
              format: row.Format || row.format,
              created: row.Created || row.created,
              completed: row.Completed ?? row.completed,
              year: row.Year || row.year,
              publisher: row.Publisher || row.publisher,
              language: row.Language || row.language,
              category: row.Category || row.category,
              reference: row.Reference || row.reference
            };

            if (!normalizedRow.title) return null;

            const coverUrl = await this.imageLookupService.findImage(normalizedRow.title);

            return Item.create({
              id: Id.create(uuidv4()),
              title: Title.create(normalizedRow.title),
              description: Description.create(normalizedRow.description as string || ''),
              author: Author.create(normalizedRow.author as string || 'Unknown'),
              cover: Cover.create(coverUrl),
              owner: Id.create(userId),
              tags: Tags.create((normalizedRow.tags as string || '').split(',').map(t => t.trim()).filter(Boolean)),
              topic: Topic.create(normalizedRow.topic as string || ''),
              format: Format.create(normalizedRow.format as string || ''),
              created: Created.create(new Date(normalizedRow.created as string || Date.now())),
              completed: Completed.create(!!normalizedRow.completed),
              year: Year.create(parseInt(String(normalizedRow.year)) || 0),
              publisher: Publisher.create(normalizedRow.publisher as string || ''),
              language: Language.create(normalizedRow.language as string || 'English'),
              category: Category.create(Id.create(uuidv4()), Title.create(normalizedRow.category as string || 'books')),
              reference: Reference.create(normalizedRow.reference ? normalizedRow.reference.toString() : '0')
            });
          })
      );

      const validItems = itemsToCreate.filter((item): item is Item => item !== null);

      if (validItems.length === 0) {
        throw new Error('no_valid_items');
      }

      await Promise.all(validItems.map(item => this.itemStateService.createItem(item)));
      return true;

    } catch (err: unknown) {
      console.error('Import error:', err);
      if (err instanceof Error) {
        this.importError.value = err.message;
      } else {
        this.importError.value = 'parse_error';
      }
      return false;
    } finally {
      this.isImporting.value = false;
    }
  }
}
