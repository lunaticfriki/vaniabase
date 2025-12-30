import { useState } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { read, utils } from 'xlsx';
import { route } from 'preact-router';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { AuthService } from '../../application/auth/auth.service';
import { NotificationService } from '../../domain/services/notification.service';
import { Item } from '../../domain/model/entities/item.entity';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import {
  Title,
  Description,
  Author,
  Cover,
  Owner,
  Topic,
  Format,
  Publisher,
  Language
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { v4 as uuidv4 } from 'uuid';
import { ItemForm } from '../components/itemForm.component';
import type { ItemFormData } from '../components/itemForm.component';

const getRandomCover = () => {
  const width = 600;
  const height = 900;
  const id = Math.floor(Math.random() * 1000);
  return `https://picsum.photos/id/${id}/${width}/${height}`;
};

export function CreateItem() {
  const { t } = useTranslation();
  const itemStateService = container.get(ItemStateService);
  const notificationService = container.get(NotificationService);
  const authService = container.get(AuthService);
  const [formData] = useState({
    title: '',
    description: '',
    author: '',
    cover: getRandomCover(),
    tags: '',
    topic: '',
    format: '',
    created: new Date().toISOString().split('T')[0],
    completed: false,
    year: new Date().getFullYear().toString(),
    publisher: '',
    language: 'English',
    category: 'books'
  });
  const handleFileUpload = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;
    try {
      const data = await file.arrayBuffer();
      const workbook = read(data);
      const worksheet = workbook.Sheets[workbook.SheetNames[0]];
      const jsonData = utils.sheet_to_json(worksheet);
      const currentUser = authService.currentUser.value;
      const itemsToCreate = jsonData
        .map((row: any) => {
          const normalizedRow: any = {};
          Object.keys(row).forEach(key => {
            normalizedRow[key.trim().toLowerCase()] = row[key];
          });
          if (!normalizedRow.title || typeof normalizedRow.title !== 'string' || normalizedRow.title.trim() === '') {
            return null;
          }
          const tagsArray = (normalizedRow.tags || '')
            .split(',')
            .map((t: string) => t.trim())
            .filter(Boolean);
          return Item.create({
            id: Id.create(uuidv4()),
            title: Title.create(normalizedRow.title),
            description: Description.create(normalizedRow.description || ''),
            author: Author.create(normalizedRow.author || 'Unknown'),
            cover: Cover.create(getRandomCover()),
            owner: Owner.create(currentUser ? currentUser.id.value : ''),
            tags: Tags.create(tagsArray),
            topic: Topic.create(normalizedRow.topic || ''),
            format: Format.create(normalizedRow.format || ''),
            created: Created.create(normalizedRow.created ? new Date(normalizedRow.created) : new Date()),
            completed: Completed.create(!!normalizedRow.completed),
            year: Year.create(parseInt(normalizedRow.year) || new Date().getFullYear()),
            publisher: Publisher.create(normalizedRow.publisher || ''),
            language: Language.create(normalizedRow.language || 'English'),
            category: Category.create(Id.create(uuidv4()), Title.create(normalizedRow.category || 'books'))
          });
        })
        .filter((item): item is Item => item !== null);
      if (itemsToCreate.length === 0) {
        notificationService.error(t('create_item.messages.no_valid_items'));
        return;
      }
      await itemStateService.createItems(itemsToCreate);
      route('/');
    } catch (error) {
      notificationService.error(t('create_item.messages.parse_error'));
      console.error(error);
    }
  };
  const handleSubmit = async (data: ItemFormData) => {
    try {
      const tagsArray = data.tags
        .split(',')
        .map(t => t.trim())
        .filter(Boolean);
      const currentUser = authService.currentUser.value;
      await itemStateService.createItem(
        Item.create({
          id: Id.create(uuidv4()),
          title: Title.create(data.title),
          description: Description.create(data.description),
          author: Author.create(data.author),
          cover: Cover.create(data.cover),
          owner: Owner.create(currentUser ? currentUser.id.value : ''),
          tags: Tags.create(tagsArray),
          topic: Topic.create(data.topic),
          format: Format.create(data.format),
          created: Created.create(new Date(data.created)),
          completed: Completed.create(data.completed),
          year: Year.create(parseInt(data.year) || 0),
          publisher: Publisher.create(data.publisher),
          language: Language.create(data.language),
          category: Category.create(Id.create(uuidv4()), Title.create(data.category))
        })
      );
      route('/');
    } catch (error) {
      notificationService.error(t('create_item.messages.create_error'));
      console.error(error);
    }
  };
  return (
    <div class="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('create_item.title')}
        </h1>
        <p class="text-white/60">{t('create_item.subtitle')}</p>
      </div>
      <ItemForm initialValues={formData} onSubmit={handleSubmit} submitLabel={t('create_item.buttons.create')} />
      <div class="relative py-4">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-white/10"></div>
        </div>
        <div class="relative flex justify-center text-xs uppercase tracking-widest">
          <span class="bg-black px-4 text-white/40">{t('create_item.import.or_import')}</span>
        </div>
      </div>
      <div class="space-y-4">
        <div class="p-6 border-2 border-dashed border-white/10 rounded-lg hover:border-brand-magenta/50 transition-colors text-center group cursor-pointer relative">
          <input
            type="file"
            accept=".xlsx, .xls, .ods"
            onChange={handleFileUpload}
            class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
          />
          <div class="space-y-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-10 h-10 mx-auto text-white/40 group-hover:text-brand-magenta transition-colors"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="17 8 12 3 7 8" />
              <line x1="12" y1="3" x2="12" y2="15" />
            </svg>
            <p class="text-sm font-bold text-white/60 group-hover:text-white transition-colors">
              {t('create_item.import.drag_drop')}
            </p>
            <p class="text-xs text-white/30">{t('create_item.import.supported_files')}</p>
          </div>
        </div>
        <div class="text-xs text-white/30 space-y-1">
          <p class="font-bold">{t('create_item.import.expected_columns')}</p>
          <p>{t('create_item.import.columns_list')}</p>
        </div>
      </div>
    </div>
  );
}
