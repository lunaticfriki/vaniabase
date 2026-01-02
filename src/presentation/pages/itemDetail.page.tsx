import { useEffect, useMemo } from 'preact/hooks';
import { Link as RouterLink } from 'preact-router/match';
import { route } from 'preact-router';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { Loading } from '../components/loading.component';
import { ItemDetailViewModel } from '../viewModels/itemDetail.viewModel';
import type { JSX } from 'preact';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  id?: string;
  path?: string;
}

export function ItemDetail({ id }: Props) {
  const { t } = useTranslation();

  const viewModel = useMemo(() => {
    return new ItemDetailViewModel(container.get(ItemStateService));
  }, []);

  const { item, loading } = viewModel;

  useEffect(() => {
    if (id) {
      void viewModel.loadItem(id);
    }
  }, [id]);

  const handleToggleComplete = async () => {
    await viewModel.toggleComplete();
  };

  const handleDelete = async () => {
    if (window.confirm(t('item_detail.confirm_delete'))) {
      await viewModel.deleteItem();
      route('/');
    }
  };

  const handleBack = () => {
    history.go(-1);
  };

  if (loading.value) {
    return <Loading />;
  }

  if (!item.value) {
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

  const currentItem = item.value;

  return (
    <div class="space-y-8 animate-in fade-in duration-500">
      <div class="flex justify-between items-center">
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
        {currentItem && (
          <div class="flex items-center gap-4">
            <Link
              href={`/edit/${currentItem.id.value}`}
              class="flex items-center gap-2 text-brand-magenta hover:text-white transition-colors"
            >
              <span class="uppercase tracking-widest text-xs font-bold">{t('item_detail.edit')}</span>
            </Link>
            <button
              onClick={() => void handleDelete()}
              class="flex items-center gap-2 text-red-500 hover:text-white transition-colors"
            >
              <span class="uppercase tracking-widest text-xs font-bold">{t('item_detail.delete')}</span>
            </button>
          </div>
        )}
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
        <div class="space-y-6">
          <div style="filter: drop-shadow(4px 4px 0px rgba(255, 0, 255, 0.5));">
            <div
              class="aspect-2/3 overflow-hidden bg-zinc-900"
              style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
            >
              <img
                src={currentItem.cover.value}
                alt={`Cover for ${currentItem.title.value}`}
                class="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>

        <div class="space-y-8">
          <div class="space-y-4">
            <div
              class="inline-block px-4 py-1 text-xs font-bold tracking-widest uppercase bg-brand-violet/20 text-brand-magenta border-l-2 border-brand-violet"
              style="clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);"
            >
              <Link href={`/categories/${currentItem.category.name.value.toLowerCase()}`} class="capitalize">
                {t(`categories.list.${currentItem.category.name.value.toLowerCase()}`, currentItem.category.name.value)}
              </Link>
            </div>

            <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-white leading-tight capitalize">
              {currentItem.title.value}
            </h1>

            <div class="text-xl text-white/60">
              {t('item.by')} <span class="text-white capitalize">{currentItem.author.value}</span>
            </div>
          </div>

          <div class="prose prose-invert prose-lg text-white/80">
            <p>{currentItem.description.value}</p>
          </div>

          <div class="pt-4">
            <button
              onClick={() => void handleToggleComplete()}
              style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
              class={`
                w-full md:w-auto px-8 py-4 font-black uppercase tracking-widest transition-all
                ${
                  currentItem.completed.value
                    ? 'bg-white/10 text-white/60 hover:bg-white/20 hover:text-white'
                    : 'bg-green-500 text-black hover:bg-green-400 hover:scale-[1.02] shadow-[0_0_20px_rgba(34,197,94,0.3)]'
                }
              `}
            >
              {currentItem.completed.value
                ? t('create_item.buttons.mark_uncompleted')
                : t('create_item.buttons.mark_completed')}
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-8 border-t border-white/10">
            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.year')}</div>
              <div class="text-lg font-medium">{currentItem.year.value}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">
                {t('item_detail.labels.publisher')}
              </div>
              <div class="text-lg font-medium capitalize">{currentItem.publisher.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">
                {t('item_detail.labels.reference')}
              </div>
              <div class="text-lg font-medium capitalize">{currentItem.reference.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.language')}</div>
              <div class="text-lg font-medium capitalize">{currentItem.language.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.format')}</div>
              <div class="text-lg font-medium capitalize">{currentItem.format.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">{t('item_detail.labels.topic')}</div>
              <div class="text-lg font-medium capitalize">{currentItem.topic.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">
                {t('item_detail.labels.completed')}
              </div>
              <div class="text-lg font-medium capitalize">
                {currentItem.completed.value ? t('item_detail.values.yes') : t('item_detail.values.no')}
              </div>
            </div>
          </div>

          {currentItem.tags.value.length > 0 ? (
            <div class="pt-6">
              <div class="text-xs text-white/40 uppercase tracking-widest mb-3">{t('item_detail.labels.tags')}</div>
              <div class="flex flex-wrap gap-2">
                {currentItem.tags.value.map(tag => (
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
