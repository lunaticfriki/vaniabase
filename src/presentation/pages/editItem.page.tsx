import { useState, useEffect } from 'preact/hooks';
import { route } from 'preact-router';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { NotificationService } from '../../domain/services/notification.service';
import { ItemForm } from '../components/itemForm.component';
import type { ItemFormData } from '../components/itemForm.component';
import { Item } from '../../domain/model/entities/item.entity';
import {
  Title,
  Description,
  Author,
  Cover,
  Topic,
  Format,
  Publisher,
  Language
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { Loading } from '../components/loading.component';

interface Props {
  id?: string;
  path?: string;
}

export function EditItem({ id }: Props) {
  const { t } = useTranslation();
  const itemStateService = container.get(ItemStateService);
  const notificationService = container.get(NotificationService);
  const [loading, setLoading] = useState(true);
  const [item, setItem] = useState<Item | null>(null);

  const [formData, setFormData] = useState<ItemFormData>({
    title: '',
    description: '',
    author: '',
    cover: '',
    tags: '',
    topic: '',
    format: '',
    created: '',
    completed: false,
    year: '',
    publisher: '',
    language: '',
    category: ''
  });

  useEffect(() => {
    if (!id) return;
    const loadItem = async () => {
      setLoading(true);
      const foundItem = await itemStateService.getItem(id);
      if (foundItem) {
        setItem(foundItem);
        setFormData({
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
          category: foundItem.category.name.value.toLowerCase()
        });
      } else {
        notificationService.error(t('item_detail.not_found'));
        route('/');
      }
      setLoading(false);
    };
    loadItem();
  }, [id]);

  const handleSubmit = async (data: ItemFormData) => {
    if (!item) return;
    try {
      const tagsArray = data.tags
        .split(',')
        .map(t => t.trim())
        .filter(Boolean);

      const updatedItem = Item.create({
        id: item.id,
        title: Title.create(data.title),
        description: Description.create(data.description),
        author: Author.create(data.author),
        cover: Cover.create(data.cover),
        owner: item.owner,
        tags: Tags.create(tagsArray),
        topic: Topic.create(data.topic),
        format: Format.create(data.format),
        created: item.created,
        completed: Completed.create(data.completed),
        year: Year.create(parseInt(data.year) || 0),
        publisher: Publisher.create(data.publisher),
        language: Language.create(data.language),
        category: Category.create(Id.create(item.category.id.value), Title.create(data.category))
      });

      await itemStateService.updateItem(updatedItem);
      route(`/item/${id}`);
    } catch (error) {
      notificationService.error(t('create_item.messages.create_error'));
      console.error(error);
    }
  };

  if (loading) return <Loading />;
  if (!item) return null;

  return (
    <div class="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('edit_item.title', { title: item.title.value })}
        </h1>
        <p class="text-white/60">{t('edit_item.subtitle')}</p>
      </div>
      <ItemForm initialValues={formData} onSubmit={handleSubmit} submitLabel={t('edit_item.buttons.save')} />
    </div>
  );
}
