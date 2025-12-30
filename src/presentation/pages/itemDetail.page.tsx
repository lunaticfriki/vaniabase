import { useEffect, useState } from 'preact/hooks';
import { Link as RouterLink } from 'preact-router/match';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';
import { Completed } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { Loading } from '../components/loading.component';
import type { JSX } from 'preact';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  id?: string;
  path?: string;
}

export function ItemDetail({ id }: Props) {
  const { t } = useTranslation();
  const [item, setItem] = useState<Item | null>(null);
  const [loading, setLoading] = useState(true);
  const itemStateService = container.get(ItemStateService);

  useEffect(() => {
    if (!id) return;

    const loadItem = async () => {
      setLoading(true);
      const foundItem = await itemStateService.getItem(id);
      if (foundItem) {
        setItem(foundItem);
      } else {
        console.error('Item not found');
      }
      setLoading(false);
    };

    loadItem();
  }, [id]);

  const handleToggleComplete = async () => {
    if (!item) return;

    const newStatus = Completed.create(!item.completed.value);

    const updatedItem = Item.create({
      id: item.id,
      title: item.title,
      description: item.description,
      author: item.author,
      cover: item.cover,
      owner: item.owner,
      tags: item.tags,
      topic: item.topic,
      format: item.format,
      created: item.created,
      completed: newStatus,
      year: item.year,
      publisher: item.publisher,
      language: item.language,
      category: item.category,
      ownerId: item.ownerId
    });

    await itemStateService.updateItem(updatedItem);
    setItem(updatedItem);
  };

  const handleBack = () => {
    history.go(-1);
  };

  if (loading) {
    return <Loading />;
  }

  if (!item) {
    return (
      <div class="flex flex-col items-center justify-center min-h-[50vh] space-y-4">
        <h2 class="text-2xl text-white/50">{t('item_detail.not_found')}</h2>
        <button
          onClick={handleBack}
          class="px-6 py-2 bg-brand-violet text-white rounded hover:bg-brand-violet/80 transition-colors"
        >
          {t('item_detail.back')}
        </button>
      </div>
    );
  }

  return (
    <div class="space-y-8 animate-in fade-in duration-500">
      <div>
        <button
          onClick={handleBack}
          class="flex items-center gap-2 text-white/60 transition-colors group cursor-pointer"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="group-hover:-translate-x-1 group-hover:text-brand-yellow transition-all"
          >
            <path d="M19 12H5" />
            <path d="M12 19l-7-7 7-7" />
          </svg>
          <span class="group-hover:bg-clip-text group-hover:text-transparent group-hover:bg-linear-to-r group-hover:from-brand-magenta group-hover:to-brand-yellow">
            {t('item_detail.back')}
          </span>
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
        <div class="space-y-6">
          <div style="filter: drop-shadow(4px 4px 0px rgba(255, 0, 255, 0.5));">
            <div
              class="aspect-2/3 overflow-hidden bg-zinc-900"
              style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
            >
              <img src={item.cover.value} alt={`Cover for ${item.title.value}`} class="w-full h-full object-cover" />
            </div>
          </div>
        </div>

        <div class="space-y-8">
          <div class="space-y-4">
            <div
              class="inline-block px-4 py-1 text-xs font-bold tracking-widest uppercase bg-brand-violet/20 text-brand-magenta border-l-2 border-brand-violet"
              style="clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);"
            >
              <Link href={`/categories/${item.category.name.value.toLowerCase()}`}>{item.category.name.value}</Link>
            </div>

            <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-white leading-tight">
              {item.title.value}
            </h1>

            <div class="text-xl text-white/60">
              {t('item.by')} <span class="text-white">{item.author.value}</span>
            </div>
          </div>

          <div class="prose prose-invert prose-lg text-white/80">
            <p>{item.description.value}</p>
          </div>

          <div class="pt-4">
            <button
              onClick={handleToggleComplete}
              style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
              class={`
                w-full md:w-auto px-8 py-4 font-black uppercase tracking-widest transition-all
                ${
                  item.completed.value
                    ? 'bg-white/10 text-white/60 hover:bg-white/20 hover:text-white'
                    : 'bg-green-500 text-black hover:bg-green-400 hover:scale-[1.02] shadow-[0_0_20px_rgba(34,197,94,0.3)]'
                }
              `}
            >
              {item.completed.value
                ? t('create_item.buttons.mark_uncompleted')
                : t('create_item.buttons.mark_completed')}
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-8 border-t border-white/10">
            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.year')}</div>
              <div class="text-lg font-medium">{item.year.value}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">
                {t('item_detail.labels.publisher')}
              </div>
              <div class="text-lg font-medium">{item.publisher.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.language')}</div>
              <div class="text-lg font-medium">{item.language.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.format')}</div>
              <div class="text-lg font-medium">{item.format.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.owner')}</div>
              <div class="text-lg font-medium">{item.owner.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.topic')}</div>
              <div class="text-lg font-medium">{item.topic.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">
                {t('item_detail.labels.completed')}
              </div>
              <div class="text-lg font-medium">
                {item.completed.value ? t('item_detail.values.yes') : t('item_detail.values.no')}
              </div>
            </div>
          </div>

          {item.tags.value.length > 0 ? (
            <div class="pt-6">
              <div class="text-xs text-white/40 uppercase tracking-widest mb-3">{t('item_detail.labels.tags')}</div>
              <div class="flex flex-wrap gap-2">
                {item.tags.value.map(tag => (
                  <Link
                    key={tag}
                    href={`/tags/${tag.toLowerCase()}`}
                    class="px-3 py-1 bg-white/5 rounded text-sm text-white/70 hover:bg-white/10 hover:text-white transition-colors"
                  >
                    #{tag}
                  </Link>
                ))}
              </div>
            </div>
          ) : (
            <div class="pt-6">
              <div class="text-xs text-white/40 uppercase tracking-widest mb-3">{t('item_detail.labels.tags')}</div>
              <div class="flex flex-wrap gap-2">
                <span class="px-3 py-1 bg-white/5 rounded text-sm text-white/70">
                  {t('item_detail.values.no_tags')}
                </span>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
