import { useEffect, useMemo } from 'preact/hooks';
import { computed } from '@preact/signals';
import { useTranslation } from 'react-i18next';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { PaginationViewModel } from '../viewModels/pagination.viewModel';
import { Pagination } from '../components/pagination.component';
import { SkeletonItem } from '../components/skeletonItem.component';

interface Props {
  path?: string;
}

export function Collection({ path: _ }: Props) {
  const { t } = useTranslation();
  const itemStateService = container.get(ItemStateService);
  const items = itemStateService.items;
  const isLoading = itemStateService.isLoading;

  const pagination = useMemo(() => new PaginationViewModel(12), []);

  useEffect(() => {
    itemStateService.loadItems();
  }, []);

  useEffect(() => {
    pagination.setTotalItems(items.value.length);
  }, [items.value.length]);

  const currentItems = computed(() => {
    const start = (pagination.currentPage.value - 1) * pagination.itemsPerPage;
    const end = start + pagination.itemsPerPage;
    return items.value.slice(start, end);
  });

  if (isLoading.value && items.value.length === 0) {
    return (
      <div class="space-y-8">
        <div class="space-y-2">
          <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
            {t('collection.title')}{' '}
            <span class="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow ml-2 align-top">
              [...]
            </span>
          </h1>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {Array.from({ length: 12 }).map((_, i) => (
            <SkeletonItem key={i} />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div class="space-y-8">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('collection.title')}{' '}
          <span class="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow ml-2 align-super">
            [{items.value.length}]
          </span>
        </h1>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {currentItems.value.map(item => (
          <PreviewCard key={item.id.value} item={item} />
        ))}
      </div>

      {items.value.length === 0 && (
        <div class="text-center py-20 text-white/40">
          <p>{t('collection.no_items')}</p>
        </div>
      )}

      {items.value.length > 0 && <Pagination pagination={pagination} />}
    </div>
  );
}
